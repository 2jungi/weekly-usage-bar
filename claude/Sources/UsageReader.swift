import Foundation
import CryptoKit

private struct OAuthCredential {
    let token: String
    let expiresAt: Date?
    var expired: Bool { expiresAt.map { $0 <= Date().addingTimeInterval(30) } ?? false }
}

private final class NoRedirect: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) { completionHandler(nil) }
}

/// Only the access token is held in memory. No credentials are written by this app.
enum UsageReader {
    private static func run(_ path: String, _ args: [String], capture: Bool, timeout: Double) throws -> (Int32, Data) {
        let process = Process(), output = Pipe()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args
        process.currentDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = capture ? output : FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        let killTask = DispatchWorkItem {
            if process.isRunning { process.terminate() }
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                if process.isRunning { kill(process.processIdentifier, SIGKILL) }
            }
        }
        try process.run()
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: killTask)
        defer { killTask.cancel() }
        let data = capture ? output.fileHandleForReading.readDataToEndOfFile() : Data()
        process.waitUntilExit()
        return (process.terminationStatus, data)
    }

    private static func credential() throws -> OAuthCredential {
        let env = ProcessInfo.processInfo.environment
        let home = FileManager.default.homeDirectoryForCurrentUser
        let configDir = env["CLAUDE_CONFIG_DIR"].map { URL(fileURLWithPath: $0).standardizedFileURL }
            ?? home.appendingPathComponent(".claude")
        var service = "Claude Code-credentials"
        if env["CLAUDE_CONFIG_DIR"] != nil {
            let digest = SHA256.hash(data: Data(configDir.path.utf8)).map { String(format: "%02x", $0) }.joined()
            service += "-" + digest.prefix(8)
        }
        let (status, keychainData) = try run("/usr/bin/security",
            ["find-generic-password", "-a", NSUserName(), "-s", service, "-w"], capture: true, timeout: 15)
        let data: Data
        if status == 0 {
            data = keychainData
        } else if let saved = try? Data(contentsOf: configDir.appendingPathComponent(".credentials.json")) {
            data = saved
        } else {
            throw UsageError.credentialsUnavailable
        }
        guard data.count < 1_000_000,
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let oauth = object["claudeAiOauth"] as? [String: Any],
              let token = oauth["accessToken"] as? String, !token.isEmpty else {
            throw UsageError.credentialsUnavailable
        }
        let expiry = (oauth["expiresAt"] as? Double).map { Date(timeIntervalSince1970: $0 / 1000) }
        return OAuthCredential(token: token, expiresAt: expiry)
    }

    /// A local /usage command causes the official CLI to refresh its own login.
    /// On Claude Code 2.1.116, print mode returns "not available" with zero API tokens;
    /// the startup authentication refresh still succeeds. No token rotation is implemented here.
    private static func refreshViaCLI() throws {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let candidates = [home + "/.local/bin/claude", "/opt/homebrew/bin/claude", "/usr/local/bin/claude"]
        guard let cli = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else {
            throw UsageError.expired
        }
        _ = try run(cli, ["-p", "/usage", "--output-format", "json", "--no-session-persistence",
            "--tools", "", "--strict-mcp-config", "--mcp-config", "{\"mcpServers\":{}}",
            "--setting-sources", "", "--settings", "{\"disableAllHooks\":true}"],
            capture: false, timeout: 25)
    }

    static func read() throws -> UsageSnapshot {
        var auth = try credential()
        var refreshed = false
        if auth.expired {
            try refreshViaCLI()
            refreshed = true
            auth = try credential()
            guard !auth.expired else { throw UsageError.expired }
        }
        do { return try fetch(auth) }
        catch UsageError.unauthorized where !refreshed {
            try refreshViaCLI()
            return try fetch(credential())
        }
    }

    private static func fetch(_ credential: OAuthCredential) throws -> UsageSnapshot {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 12
        config.timeoutIntervalForResource = 20
        config.httpCookieStorage = nil
        let session = URLSession(configuration: config, delegate: NoRedirect(), delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/api/oauth/usage")!)
        request.setValue("Bearer " + credential.token, forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Claude-Weekly-Usage/1.0.0", forHTTPHeaderField: "User-Agent")
        let completion = DispatchSemaphore(value: 0)
        let lock = NSLock()
        var outcome: Result<(Data, HTTPURLResponse), Error>?
        let task = session.dataTask(with: request) { data, response, error in
            lock.lock()
            defer { lock.unlock(); completion.signal() }
            if error != nil { outcome = .failure(UsageError.connection) }
            else if let data = data, let http = response as? HTTPURLResponse { outcome = .success((data, http)) }
            else { outcome = .failure(UsageError.connection) }
        }
        task.resume()
        guard completion.wait(timeout: .now() + 22) == .success else { task.cancel(); throw UsageError.connection }
        lock.lock()
        let completed = outcome
        lock.unlock()
        guard let completed = completed else { throw UsageError.connection }
        let (data, response) = try completed.get()
        switch response.statusCode {
        case 200: break
        case 401, 403: throw UsageError.unauthorized
        case 429:
            throw UsageError.rateLimited(retryDate(response.value(forHTTPHeaderField: "Retry-After")))
        default: throw UsageError.server(response.statusCode)
        }
        guard data.count < 1_000_000,
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw UsageError.unavailable
        }
        return try UsageSnapshot.parse(object)
    }

    static func retryDate(_ value: String?, now: Date = Date()) -> Date {
        let minimum = now.addingTimeInterval(300)
        guard let value = value else { return minimum }
        if let seconds = Double(value), seconds.isFinite, seconds >= 0 {
            return max(minimum, now.addingTimeInterval(seconds))
        }
        let format = DateFormatter()
        format.locale = Locale(identifier: "en_US_POSIX")
        format.timeZone = TimeZone(secondsFromGMT: 0)
        format.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return max(minimum, format.date(from: value) ?? minimum)
    }
}

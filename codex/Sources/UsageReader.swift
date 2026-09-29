import Foundation

final class UsageReader {
    static func read() throws -> UsageSnapshot {
        let userHome = FileManager.default.homeDirectoryForCurrentUser.path
        let appFolders = ["/Applications", userHome + "/Applications"]
        let candidates = appFolders.flatMap { folder in [
            folder + "/ChatGPT.app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex",
            folder + "/Codex.app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex",
            folder + "/Codex.app/Contents/Resources/codex"
        ] } + ["/opt/homebrew/bin/codex", "/usr/local/bin/codex", userHome + "/.local/bin/codex"]
        guard let cli = candidates.first(where: { FileManager.default.isExecutableFile(atPath: $0) }) else {
            throw UsageError.missingCLI
        }
        let process = Process()
        let input = Pipe(), output = Pipe()
        process.executableURL = URL(fileURLWithPath: cli)
        process.arguments = ["app-server"]
        process.currentDirectoryURL = FileManager.default.homeDirectoryForCurrentUser
        process.standardInput = input
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        process.environment = environment
        try process.run()
        let timeout = DispatchWorkItem {
            if process.isRunning { process.terminate() }
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                if process.isRunning { kill(process.processIdentifier, SIGKILL) }
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 20, execute: timeout)
        defer {
            timeout.cancel()
            try? input.fileHandleForWriting.close()
            if process.isRunning { process.terminate() }
            process.waitUntilExit()
            try? output.fileHandleForReading.close()
        }
        func send(_ object: [String: Any]) throws {
            var data = try JSONSerialization.data(withJSONObject: object)
            data.append(0x0A)
            try input.fileHandleForWriting.write(contentsOf: data)
        }
        try send(["id": 1, "method": "initialize", "params": ["clientInfo": [
            "name": "weekly_usage_bar", "title": "Weekly Usage Bar", "version": "1.2.0"
        ]]])
        var buffer = Data()
        while true {
            let chunk = output.fileHandleForReading.availableData
            if chunk.isEmpty { throw UsageError.connection }
            buffer.append(chunk)
            guard buffer.count < 4_000_000 else { throw UsageError.connection }
            while let newline = buffer.firstIndex(of: 0x0A) {
                let line = Data(buffer[..<newline])
                buffer.removeSubrange(...newline)
                guard let message = try JSONSerialization.jsonObject(with: line) as? [String: Any] else { continue }
                if (message["id"] as? Int) == 1 {
                    guard message["error"] == nil else { throw UsageError.connection }
                    try send(["method": "initialized"])
                    try send(["id": 2, "method": "account/rateLimits/read"])
                }
                if (message["id"] as? Int) == 2 {
                    guard let result = message["result"] as? [String: Any] else { throw UsageError.unavailable }
                    return try UsageSnapshot.parse(result)
                }
            }
        }
    }
}

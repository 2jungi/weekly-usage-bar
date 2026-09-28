import AppKit
import Foundation

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var item: NSStatusItem!
    private var timer: Timer?
    private var snapshot: UsageSnapshot?
    private var refreshing = false
    private var refreshFailed = false
    private var errorMessage = ""
    private var nextAllowedRead = Date.distantPast
    private let menu = NSMenu()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let id = Bundle.main.bundleIdentifier ?? "io.github.2jungi.claude-weekly-usage-bar"
        if NSRunningApplication.runningApplications(withBundleIdentifier: id).count > 1 {
            NSApp.terminate(nil)
            return
        }
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.autosaveName = "ClaudeWeeklyUsageStatusItem"
        if let button = item.button {
            let logo = LocalAssets.menuBarIcon()
            logo?.size = NSSize(width: 18, height: 18)
            logo?.isTemplate = true
            button.image = logo
            button.imagePosition = .imageTrailing
            button.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
            button.title = "… "
            button.setAccessibilityLabel(tr("Claude Code 주간 한도 잔액", "Claude Code weekly quota remaining"))
        }
        menu.delegate = self
        item.menu = menu
        refresh()
        timer = Timer(timeInterval: 300, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        timer?.tolerance = 15
        RunLoop.main.add(timer!, forMode: .common)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(refresh),
            name: NSWorkspace.didWakeNotification, object: nil)
        updateDisplay()
    }

    @objc func refresh() {
        guard !refreshing, Date() >= nextAllowedRead else { rebuildMenu(); return }
        refreshing = true
        nextAllowedRead = Date().addingTimeInterval(60)
        rebuildMenu()
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let result = Result { try UsageReader.read() }
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.refreshing = false
                switch result {
                case .success(let value):
                    self.snapshot = value; self.refreshFailed = false; self.errorMessage = ""
                case .failure(let error):
                    self.refreshFailed = true
                    switch error {
                    case UsageError.rateLimited(let next):
                        self.nextAllowedRead = next
                        self.errorMessage = tr("서버 조회 제한 · 잠시 후 자동 재시도", "Rate limited · Retrying after the cooldown")
                    case UsageError.credentialsUnavailable, UsageError.keychainDenied:
                        self.errorMessage = tr("Claude Code 로그인 또는 키체인 접근을 확인하세요", "Claude Code login unavailable · Sign in or allow Keychain access")
                    case UsageError.unavailable, UsageError.expired, UsageError.unauthorized:
                        self.errorMessage = tr("주간 한도를 확인할 수 없습니다 · Claude Code 로그인 확인", "Weekly quota unavailable · Check Claude Code sign-in")
                    default:
                        self.errorMessage = tr("연결 실패 · 네트워크 확인 후 자동 재시도", "Connection failed · Retrying automatically")
                    }
                }
                self.updateDisplay()
            }
        }
    }

    func updateDisplay() {
        let expired = snapshot?.resetsAt.map { $0 <= Date() } ?? false
        let stale = snapshot.map { Date().timeIntervalSince($0.fetchedAt) > 900 } ?? false
        if let value = snapshot, !expired, !stale, !refreshFailed {
            item.button?.title = "\(value.remaining)% "
            item.button?.toolTip = tr("주간 한도 \(value.remaining)% 남음 · 클릭하여 자세히 보기", "\(value.remaining)% of weekly quota left · Click for details")
        } else {
            item.button?.title = refreshing && snapshot == nil ? "… " : "--% "
            item.button?.toolTip = tr("주간 한도 확인 중 · 클릭하여 상태 보기", "Checking weekly quota · Click for status")
        }
        item.button?.setAccessibilityValue(item.button?.title ?? "")
        rebuildMenu()
        if let flag = CommandLine.arguments.firstIndex(of: "--diagnostic-file"),
           CommandLine.arguments.indices.contains(flag + 1) {
            let diagnostics: [String: Any] = [
                "title": item.button?.title ?? "", "logoLoaded": item.button?.image != nil,
                "logoAfterPercent": item.button?.imagePosition == .imageTrailing,
                "statusItemVisible": item.isVisible,
                "windowVisible": item.button?.window?.isVisible ?? false,
                "menu": menu.items.map { $0.title }, "refreshFailed": refreshFailed,
                "lastSuccessfulFetch": snapshot?.fetchedAt.timeIntervalSince1970 ?? 0
            ]
            if let data = try? JSONSerialization.data(withJSONObject: diagnostics, options: .prettyPrinted) {
                try? data.write(to: URL(fileURLWithPath: CommandLine.arguments[flag + 1]), options: .atomic)
            }
        }
    }

    func menuWillOpen(_ menu: NSMenu) {
        updateDisplay()
        if snapshot == nil || Date().timeIntervalSince(snapshot!.fetchedAt) > 300 { refresh() }
    }

    func rebuildMenu() {
        menu.removeAllItems()
        func info(_ title: String) {
            let row = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            row.isEnabled = false
            menu.addItem(row)
        }
        func action(_ title: String, _ selector: Selector) {
            let row = NSMenuItem(title: title, action: selector, keyEquivalent: "")
            row.target = self
            menu.addItem(row)
        }
        info(tr("Claude Code 주간 사용 한도", "Claude Code weekly quota"))
        if let value = snapshot {
            let outdated = refreshFailed || Date().timeIntervalSince(value.fetchedAt) > 900 || (value.resetsAt.map { $0 <= Date() } ?? false)
            info(tr("\(outdated ? "마지막 확인 잔액" : "잔액") \(value.remaining)%  ·  사용 \(Int(value.used))%",
                    "\(outdated ? "Last known" : "Remaining") \(value.remaining)%  ·  Used \(Int(value.used))%"))
            if let reset = value.resetsAt {
                let format = DateFormatter()
                format.locale = Locale.current
                format.dateFormat = tr("M월 d일 (E) HH:mm", "MMM d (EEE) HH:mm")
                info(tr("다음 초기화: ", "Resets: ") + format.string(from: reset))
            }
            if let sessionRemaining = value.sessionRemaining {
                info(tr("5시간 한도 잔액: \(sessionRemaining)%", "5-hour quota remaining: \(sessionRemaining)%"))
                if let reset = value.sessionResetsAt {
                    let format = DateFormatter()
                    format.dateFormat = tr("M월 d일 HH:mm", "MMM d HH:mm")
                    info(tr("5시간 한도 초기화: ", "5-hour reset: ") + format.string(from: reset))
                }
            }
            let format = DateFormatter()
            format.dateFormat = "HH:mm:ss"
            info(tr("마지막 확인: \(format.string(from: value.fetchedAt)) · 5분마다 갱신", "Checked: \(format.string(from: value.fetchedAt)) · Every 5 minutes"))
        }
        if refreshFailed { info(errorMessage) }
        if refreshFailed && nextAllowedRead > Date() {
            let format = DateFormatter()
            format.dateFormat = "HH:mm"
            info(tr("다음 조회 가능: ", "Next check available: ") + format.string(from: nextAllowedRead))
        }
        if refreshing { info(tr("현재 사용량 확인 중…", "Checking usage…")) }
        menu.addItem(.separator())
        action(tr("지금 새로고침", "Refresh now"), #selector(refresh))
        menu.items.last?.isEnabled = !refreshing && Date() >= nextAllowedRead
        action(tr("Claude 열기", "Open Claude"), #selector(openClaude))
        menu.addItem(.separator())
        action(tr("메뉴바 앱 종료", "Quit Claude Weekly Usage"), #selector(quit))
    }

    @objc func openClaude() {
        let folders = ["/Applications", FileManager.default.homeDirectoryForCurrentUser.path + "/Applications"]
        let paths = folders.map { $0 + "/Claude.app" }
        if let path = paths.first(where: { FileManager.default.fileExists(atPath: $0) }) {
            NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: path), configuration: .init())
        }
    }
    @objc func quit() { NSApp.terminate(nil) }
}

if CommandLine.arguments.contains("--quit-running") {
    for id in ["io.github.2jungi.claude-weekly-usage-bar"] {
        for running in NSRunningApplication.runningApplications(withBundleIdentifier: id)
            where running.processIdentifier != ProcessInfo.processInfo.processIdentifier {
            running.terminate()
            let deadline = Date().addingTimeInterval(5)
            // NSRunningApplication refreshes termination state through the run loop.
            while !running.isTerminated && Date() < deadline {
                RunLoop.current.run(until: Date().addingTimeInterval(0.1))
            }
            if !running.isTerminated {
                fputs("Please quit Claude Weekly Usage from its menu bar before continuing.\n", stderr)
                exit(1)
            }
        }
    }
    exit(0)
}

if CommandLine.arguments.contains("--check") {
    do {
        let value = try UsageReader.read()
        print("weekly_remaining=\(value.remaining)% session_remaining=\(value.sessionRemaining.map(String.init) ?? "unknown")%")
        exit(0)
    } catch {
        print("Unable to read weekly limits: \(error)")
        exit(1)
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()

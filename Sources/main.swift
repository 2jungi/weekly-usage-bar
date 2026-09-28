import AppKit
import Foundation

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var item: NSStatusItem!
    private var timer: Timer?
    private var snapshot: UsageSnapshot?
    private var refreshing = false
    private var refreshFailed = false
    private var errorMessage = ""
    private let menu = NSMenu()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let id = Bundle.main.bundleIdentifier ?? "io.github.2jungi.weekly-usage-bar"
        if NSRunningApplication.runningApplications(withBundleIdentifier: id).count > 1 {
            NSApp.terminate(nil)
            return
        }
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.autosaveName = "WeeklyUsageStatusItem"
        if let button = item.button {
            let logo = LocalAssets.menuBarIcon()
            logo?.size = NSSize(width: 18, height: 18)
            logo?.isTemplate = true
            button.image = logo
            button.imagePosition = .imageTrailing
            button.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
            button.title = "… "
            button.setAccessibilityLabel(tr("주간 사용 한도 잔액", "Weekly quota remaining"))
        }
        menu.delegate = self
        item.menu = menu
        refresh()
        timer = Timer(timeInterval: 60, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        timer?.tolerance = 5
        RunLoop.main.add(timer!, forMode: .common)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(refresh),
            name: NSWorkspace.didWakeNotification, object: nil)
        updateDisplay()
    }

    @objc func refresh() {
        guard !refreshing else { return }
        refreshing = true
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
                    case UsageError.missingCLI:
                        self.errorMessage = tr("Codex를 찾을 수 없습니다 · 설치 후 로그인하세요", "Codex not found · Install it and sign in")
                    case UsageError.unavailable:
                        self.errorMessage = tr("주간 한도를 확인할 수 없습니다 · Codex 로그인 확인", "Weekly quota unavailable · Check Codex sign-in")
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
        let stale = snapshot.map { Date().timeIntervalSince($0.fetchedAt) > 180 } ?? false
        if let value = snapshot, !expired, !stale, !refreshFailed {
            item.button?.title = "\(value.remaining)% "
            item.button?.toolTip = tr("주간 한도 \(value.remaining)% 남음 · 클릭하여 자세히 보기", "\(value.remaining)% of weekly quota left · Click for details")
        } else {
            item.button?.title = refreshing && snapshot == nil ? "… " : "--% "
            item.button?.toolTip = tr("주간 한도 확인 중 · 클릭하여 상태 보기", "Checking weekly quota · Click for status")
        }
        item.button?.setAccessibilityValue(item.button?.title ?? "")
        rebuildMenu()
    }

    func menuWillOpen(_ menu: NSMenu) {
        updateDisplay()
        if snapshot == nil || Date().timeIntervalSince(snapshot!.fetchedAt) > 30 { refresh() }
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
        info(tr("Codex 주간 사용 한도", "Codex weekly quota"))
        if let value = snapshot {
            let outdated = refreshFailed || Date().timeIntervalSince(value.fetchedAt) > 180 || (value.resetsAt.map { $0 <= Date() } ?? false)
            info(tr("\(outdated ? "마지막 확인 잔액" : "잔액") \(value.remaining)%  ·  사용 \(Int(value.used))%",
                    "\(outdated ? "Last known" : "Remaining") \(value.remaining)%  ·  Used \(Int(value.used))%"))
            if let reset = value.resetsAt {
                let format = DateFormatter()
                format.locale = Locale.current
                format.dateFormat = tr("M월 d일 (E) HH:mm", "MMM d (EEE) HH:mm")
                info(tr("다음 초기화: ", "Resets: ") + format.string(from: reset))
            }
            let format = DateFormatter()
            format.dateFormat = "HH:mm:ss"
            info(tr("마지막 확인: \(format.string(from: value.fetchedAt)) · 1분마다 갱신", "Checked: \(format.string(from: value.fetchedAt)) · Every minute"))
        }
        if refreshFailed { info(errorMessage) }
        if refreshing { info(tr("현재 사용량 확인 중…", "Checking usage…")) }
        menu.addItem(.separator())
        action(tr("지금 새로고침", "Refresh now"), #selector(refresh))
        menu.items.last?.isEnabled = !refreshing
        action(tr("ChatGPT / Codex 열기", "Open ChatGPT / Codex"), #selector(openChatGPT))
        menu.addItem(.separator())
        action(tr("메뉴바 앱 종료", "Quit Weekly Usage"), #selector(quit))
    }

    @objc func openChatGPT() {
        let folders = ["/Applications", FileManager.default.homeDirectoryForCurrentUser.path + "/Applications"]
        let paths = folders.flatMap { [$0 + "/ChatGPT.app", $0 + "/Codex.app"] }
        if let path = paths.first(where: { FileManager.default.fileExists(atPath: $0) }) {
            NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: path), configuration: .init())
        }
    }
    @objc func quit() { NSApp.terminate(nil) }
}

if CommandLine.arguments.contains("--quit-running") {
    for id in ["io.github.2jungi.weekly-usage-bar", "local.jungi.weekly-usage"] {
        for running in NSRunningApplication.runningApplications(withBundleIdentifier: id)
            where running.processIdentifier != ProcessInfo.processInfo.processIdentifier {
            running.terminate()
            let deadline = Date().addingTimeInterval(5)
            while !running.isTerminated && Date() < deadline { Thread.sleep(forTimeInterval: 0.1) }
            if !running.isTerminated {
                fputs("Please quit Weekly Usage from its menu bar before continuing.\n", stderr)
                exit(1)
            }
        }
    }
    exit(0)
}

if CommandLine.arguments.contains("--check") {
    do {
        let value = try UsageReader.read()
        print("weekly_remaining=\(value.remaining)% window=10080 minutes")
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

import AppKit

enum LocalAssets {
    /// Load, but never copy or redistribute, artwork from the user's official app.
    static func menuBarIcon() -> NSImage? {
        let folders = ["/Applications", FileManager.default.homeDirectoryForCurrentUser.path + "/Applications"]
        for folder in folders {
            for app in ["ChatGPT.app", "Codex.app"] {
                let base = folder + "/" + app + "/Contents/Resources/chatgptTemplate"
                if let image = NSImage(contentsOfFile: base + ".png") {
                    if let data = try? Data(contentsOf: URL(fileURLWithPath: base + "@2x.png")),
                       let retina = NSBitmapImageRep(data: data) {
                        retina.size = NSSize(width: 18, height: 18)
                        image.addRepresentation(retina)
                    }
                    return image
                }
            }
        }
        return NSImage(systemSymbolName: "chart.pie", accessibilityDescription: "Weekly usage")
    }
}

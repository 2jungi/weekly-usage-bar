import AppKit

enum LocalAssets {
    static func menuBarIcon() -> NSImage? {
        let folders = ["/Applications", FileManager.default.homeDirectoryForCurrentUser.path + "/Applications"]
        for folder in folders {
            let base = folder + "/Claude.app/Contents/Resources/TrayIconTemplate"
            if let image = NSImage(contentsOfFile: base + ".png") {
                if let data = try? Data(contentsOf: URL(fileURLWithPath: base + "@2x.png")),
                   let retina = NSBitmapImageRep(data: data) {
                    retina.size = NSSize(width: 18, height: 18)
                    image.addRepresentation(retina)
                }
                return image
            }
        }
        return NSImage(systemSymbolName: "chart.pie", accessibilityDescription: "Claude weekly usage")
    }
}

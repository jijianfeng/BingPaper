import Foundation
import AppKit

public final class WallpaperManager {
    public static let shared = WallpaperManager()
    
    public let wallpaperDirectory: URL
    
    private init() {
        let picturesDir = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
        self.wallpaperDirectory = picturesDir.appendingPathComponent("BingWallpapers", isDirectory: true)
        try? FileManager.default.createDirectory(at: wallpaperDirectory, withIntermediateDirectories: true)
    }
    
    public func saveImageFile(data: Data, filename: String) throws -> URL {
        let fileURL = wallpaperDirectory.appendingPathComponent(filename)
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }
    
    public func setAsDesktopWallpaper(fileURL: URL) throws {
        let workspace = NSWorkspace.shared
        for screen in NSScreen.screens {
            try workspace.setDesktopImageURL(fileURL, for: screen, options: [:])
        }
    }
    
    public func openWallpaperFolder() {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: wallpaperDirectory.path)
    }
}

import Foundation

public final class FavoriteManager {
    public static let shared = FavoriteManager()
    
    private let storageURL: URL
    private var cachedFavorites: [BingImage] = []
    private let queue = DispatchQueue(label: "com.bingpaper.favoritemanager", attributes: .concurrent)
    
    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("BingPaper", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        self.storageURL = appDir.appendingPathComponent("favorites.json")
        self.cachedFavorites = loadFromDisk()
    }
    
    public func getAllFavorites() -> [BingImage] {
        queue.sync { cachedFavorites }
    }
    
    public func isFavorite(image: BingImage) -> Bool {
        queue.sync {
            cachedFavorites.contains { $0.id == image.id }
        }
    }
    
    @discardableResult
    public func toggleFavorite(image: BingImage, localFilePath: String? = nil) -> Bool {
        queue.sync(flags: .barrier) {
            if let index = cachedFavorites.firstIndex(where: { $0.id == image.id }) {
                cachedFavorites.remove(at: index)
                saveToDisk(cachedFavorites)
                return false
            } else {
                var favImage = image
                favImage.isFavorite = true
                favImage.favoritedAt = Date()
                if let path = localFilePath {
                    favImage.localFilePath = path
                }
                cachedFavorites.insert(favImage, at: 0)
                saveToDisk(cachedFavorites)
                return true
            }
        }
    }
    
    public func removeFavorite(id: String) {
        queue.sync(flags: .barrier) {
            cachedFavorites.removeAll { $0.id == id }
            saveToDisk(cachedFavorites)
        }
    }
    
    private func loadFromDisk() -> [BingImage] {
        guard FileManager.default.fileExists(atPath: storageURL.path),
              let data = try? Data(contentsOf: storageURL),
              let decoded = try? JSONDecoder().decode([BingImage].self, from: data) else {
            return []
        }
        return decoded
    }
    
    private func saveToDisk(_ list: [BingImage]) {
        guard let data = try? JSONEncoder().encode(list) else { return }
        try? data.write(to: storageURL, options: .atomic)
    }
}

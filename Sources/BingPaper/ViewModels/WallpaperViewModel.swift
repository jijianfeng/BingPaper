import Foundation
import SwiftUI
import Combine
import AppKit

public enum MainTab: String, CaseIterable, Identifiable {
    case daily = "每日发现"
    case favorites = "我的收藏"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .daily: return "photo.on.rectangle.angled"
        case .favorites: return "heart.fill"
        }
    }
}

@MainActor
public final class WallpaperViewModel: ObservableObject {
    @Published public var dailyImages: [BingImage] = []
    @Published public var favorites: [BingImage] = []
    @Published public var currentIndex: Int = 0
    @Published public var selectedTab: MainTab = .daily
    @Published public var isLoading: Bool = false
    @Published public var statusMessage: String?
    @Published public var isSettingWallpaper: Bool = false
    
    private let apiService = BingAPIService.shared
    private let wallpaperManager = WallpaperManager.shared
    private let favoriteManager = FavoriteManager.shared
    
    public var currentImage: BingImage? {
        guard !dailyImages.isEmpty, currentIndex >= 0, currentIndex < dailyImages.count else {
            return nil
        }
        return dailyImages[currentIndex]
    }
    
    public init() {
        loadFavorites()
        Task {
            await loadDailyWallpapers()
        }
    }
    
    public func loadFavorites() {
        self.favorites = favoriteManager.getAllFavorites()
    }
    
    public func loadDailyWallpapers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let images = try await apiService.fetchWallpapers(count: 8)
            self.dailyImages = images
            if currentIndex >= images.count {
                self.currentIndex = 0
            }
            loadFavorites()
        } catch {
            self.showToast("获取壁纸失败: \(error.localizedDescription)")
        }
    }
    
    public func nextImage() {
        guard !dailyImages.isEmpty else { return }
        currentIndex = (normalizedCurrentIndex + 1) % dailyImages.count
    }
    
    public func previousImage() {
        guard !dailyImages.isEmpty else { return }
        currentIndex = (normalizedCurrentIndex - 1 + dailyImages.count) % dailyImages.count
    }

    private var normalizedCurrentIndex: Int {
        guard !dailyImages.isEmpty else { return 0 }
        return min(max(currentIndex, 0), dailyImages.count - 1)
    }
    
    public func isCurrentFavorite() -> Bool {
        guard let current = currentImage else { return false }
        return favoriteManager.isFavorite(image: current)
    }
    
    public func isImageFavorite(_ image: BingImage) -> Bool {
        return favoriteManager.isFavorite(image: image)
    }
    
    public func toggleFavorite(for image: BingImage? = nil) {
        guard let target = image ?? currentImage else { return }
        let isFav = favoriteManager.toggleFavorite(image: target)
        loadFavorites()
        showToast(isFav ? "已添加到「我的收藏」 ❤️" : "已从收藏夹移除")
    }
    
    public func removeFavorite(image: BingImage) {
        favoriteManager.removeFavorite(id: image.id)
        loadFavorites()
        showToast("已从收藏夹移除")
    }
    
    public func applyWallpaper(image: BingImage? = nil) async {
        guard !isSettingWallpaper,
              let target = image ?? currentImage else { return }
        isSettingWallpaper = true
        defer { isSettingWallpaper = false }
        
        do {
            showToast("正在下载 4K 超清壁纸...")
            let safeTitle = target.startdate + "_" + target.title.replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ":", with: "-")
            let filename = "\(safeTitle)_UHD.jpg"
            
            var data: Data
            do {
                data = try await apiService.downloadImageData(from: target.uhdUrlString)
            } catch {
                data = try await apiService.downloadImageData(from: target.hdUrlString)
            }
            
            let localURL = try wallpaperManager.saveImageFile(data: data, filename: filename)
            try wallpaperManager.setAsDesktopWallpaper(fileURL: localURL)
            showToast("🎉 已成功设置为 Mac 桌面壁纸！")
        } catch {
            showToast("设置壁纸失败: \(error.localizedDescription)")
        }
    }
    
    public func saveCurrentToDisk(image: BingImage? = nil) async {
        guard let target = image ?? currentImage else { return }
        do {
            let safeTitle = target.startdate + "_" + target.title.replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ":", with: "-")
            let filename = "\(safeTitle)_UHD.jpg"
            let data = try await apiService.downloadImageData(from: target.uhdUrlString)
            _ = try wallpaperManager.saveImageFile(data: data, filename: filename)
            showToast("已保存到图片目录: BingWallpapers")
        } catch {
            showToast("保存失败: \(error.localizedDescription)")
        }
    }
    
    public func openFolder() {
        wallpaperManager.openWallpaperFolder()
    }
    
    public func showToast(_ msg: String) {
        self.statusMessage = msg
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if self.statusMessage == msg {
                self.statusMessage = nil
            }
        }
    }
}

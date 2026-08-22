import SwiftUI

public struct FavoritesGridView: View {
    @EnvironmentObject var viewModel: WallpaperViewModel
    
    public init() {}
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    public var body: some View {
        if viewModel.favorites.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "heart.slash")
                    .font(.system(size: 36))
                    .foregroundColor(.secondary)
                Text("暂无收藏壁纸")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("在「每日发现」中点击 ❤️ 爱心图标即可收藏你喜爱的壁纸")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, minHeight: 280)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("共收藏 \(viewModel.favorites.count) 张壁纸")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("打开存储文件夹") {
                        viewModel.openFolder()
                    }
                    .font(.caption)
                    .buttonStyle(.link)
                }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.favorites) { fav in
                            FavoriteItemCard(image: fav)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 320)
            }
        }
    }
}

struct FavoriteItemCard: View {
    let image: BingImage
    @EnvironmentObject var viewModel: WallpaperViewModel
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: image.hdUrlString)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .overlay(ProgressView().controlSize(.small))
                    case .success(let img):
                        img
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.red.opacity(0.1))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.secondary)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 85)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 悬浮删除/取消收藏按钮
                Button(action: {
                    viewModel.removeFavorite(image: image)
                }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.black.opacity(0.65))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(4)
                .opacity(isHovered ? 1.0 : 0.0)
            }
            
            Text(image.title.isEmpty ? image.copyright : image.title)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
            
            HStack {
                Text(image.formattedDate)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    Task { await viewModel.applyWallpaper(image: image) }
                }) {
                    Text("设为桌面")
                        .font(.system(size: 9, weight: .medium))
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
        .padding(6)
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

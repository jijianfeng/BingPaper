import SwiftUI

public struct FavoritesGridView: View {
    @EnvironmentObject var viewModel: WallpaperViewModel
    @Environment(\.colorScheme) var colorScheme
    
    public init() {}
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    public var body: some View {
        let isDark = colorScheme == .dark
        
        if viewModel.favorites.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "heart.slash")
                    .font(.system(size: 38))
                    .foregroundColor(isDark ? Color.white.opacity(0.45) : Color.primary.opacity(0.35))
                Text("暂无收藏壁纸")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isDark ? .white : .primary)
                Text("在「每日发现」中点击 ❤️ 爱心图标\n即可永久收藏你喜爱的必应壁纸")
                    .font(.system(size: 11))
                    .foregroundColor(isDark ? Color.white.opacity(0.65) : .secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, minHeight: 280)
            .glassCard(cornerRadius: 12, opacity: isDark ? 0.4 : 0.6)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("共收藏 \(viewModel.favorites.count) 张壁纸")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isDark ? Color.white.opacity(0.75) : .secondary)
                    Spacer()
                    Button("打开存储文件夹") {
                        viewModel.openFolder()
                    }
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.0, green: 0.55, blue: 0.95))
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 2)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.favorites) { fav in
                            FavoriteGlassItemCard(image: fav)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(maxHeight: 330)
            }
        }
    }
}

struct FavoriteGlassItemCard: View {
    let image: BingImage
    @EnvironmentObject var viewModel: WallpaperViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: image.hdUrlString)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.05))
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
                                    .foregroundColor(isDark ? .white.opacity(0.5) : .secondary)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 悬浮删除/取消收藏玻璃按钮
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.removeFavorite(image: image)
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.black.opacity(0.65))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.6))
                }
                .buttonStyle(.plain)
                .padding(5)
                .opacity(isHovered ? 1.0 : 0.0)
            }
            
            Text(image.title.isEmpty ? image.copyright : image.title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(isDark ? .white : Color(red: 0.1, green: 0.14, blue: 0.22))
                .lineLimit(1)
            
            HStack {
                Text(image.formattedDate)
                    .font(.system(size: 9))
                    .foregroundColor(isDark ? Color.white.opacity(0.6) : .secondary)
                
                Spacer()
                
                Button(action: {
                    Task { await viewModel.applyWallpaper(image: image) }
                }) {
                    Text("设为桌面")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.0, green: 0.50, blue: 0.95).opacity(0.85), Color(red: 0.0, green: 0.75, blue: 0.95).opacity(0.75)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .glassCard(cornerRadius: 10, opacity: isDark ? (isHovered ? 0.65 : 0.4) : (isHovered ? 0.85 : 0.65))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

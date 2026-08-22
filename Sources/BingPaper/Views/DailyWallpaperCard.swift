import SwiftUI
import AppKit

public struct DailyWallpaperCard: View {
    @EnvironmentObject var viewModel: WallpaperViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isHoveringImage = false
    
    public init() {}
    
    public var body: some View {
        let isDark = colorScheme == .dark
        
        if let image = viewModel.currentImage {
            VStack(alignment: .leading, spacing: 12) {
                // 1. 壁纸预览画框 (16:9) + 液态玻璃外框与悬浮控制
                ZStack {
                    RemoteImageView(url: URL(string: image.hdUrlString)) { phase in
                        switch phase {
                        case .loading:
                            Rectangle()
                                .fill(isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                                .overlay(
                                    ProgressView()
                                        .controlSize(.regular)
                                )
                        case .success(let loadedImage):
                            Image(nsImage: loadedImage)
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.red.opacity(0.1))
                                .overlay(
                                    VStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.triangle")
                                            .font(.title2)
                                        Text("图片加载失败")
                                            .font(.caption)
                                    }
                                    .foregroundColor(isDark ? .white.opacity(0.7) : .secondary)
                                )
                        }
                    }
                    .frame(height: 205)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // 左右切换悬浮玻璃按钮
                    HStack {
                        Button(action: {
                            viewModel.previousImage()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    ZStack {
                                        VisualEffectBlur(material: .popover, blendingMode: .withinWindow)
                                        Color.black.opacity(0.35)
                                    }
                                )
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 0.8))
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 10)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.nextImage()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    ZStack {
                                        VisualEffectBlur(material: .popover, blendingMode: .withinWindow)
                                        Color.black.opacity(0.35)
                                    }
                                )
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 0.8))
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 10)
                    }
                    
                    // 右上角心形收藏按钮 (毛玻璃浮岛)
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    viewModel.toggleFavorite()
                                }
                            }) {
                                Image(systemName: viewModel.isCurrentFavorite() ? "heart.fill" : "heart")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(viewModel.isCurrentFavorite() ? Color(red: 1.0, green: 0.25, blue: 0.45) : .white)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        ZStack {
                                            VisualEffectBlur(material: .popover, blendingMode: .withinWindow)
                                            Color.black.opacity(0.35)
                                        }
                                    )
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                viewModel.isCurrentFavorite() ?
                                                Color(red: 1.0, green: 0.35, blue: 0.55).opacity(0.7) :
                                                Color.white.opacity(0.4),
                                                lineWidth: 0.8
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                            .padding([.top, .trailing], 10)
                        }
                        Spacer()
                    }
                    
                    // 底部序号毛玻璃胶囊指示器
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(0..<viewModel.dailyImages.count, id: \.self) { idx in
                                Circle()
                                    .fill(idx == viewModel.currentIndex ? Color(red: 0.0, green: 0.85, blue: 1.0) : Color.white.opacity(0.35))
                                    .frame(width: idx == viewModel.currentIndex ? 7 : 5,
                                           height: idx == viewModel.currentIndex ? 7 : 5)
                                    .shadow(color: idx == viewModel.currentIndex ? Color(red: 0.0, green: 0.85, blue: 1.0).opacity(0.8) : .clear, radius: 3)
                            }
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(
                            ZStack {
                                VisualEffectBlur(material: .popover, blendingMode: .withinWindow)
                                Color.black.opacity(0.4)
                            }
                        )
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 0.8))
                        .padding(.bottom, 8)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: isDark ? [
                                    Color.white.opacity(0.55),
                                    Color.white.opacity(0.1),
                                    Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.3)
                                ] : [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.4),
                                    Color(red: 0.0, green: 0.6, blue: 1.0).opacity(0.25)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(isDark ? 0.35 : 0.12), radius: 10, x: 0, y: 5)
                
                // 2. 标题与版权故事（透明毛玻璃卡片）
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(image.title.isEmpty ? "必应壁纸" : image.title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(isDark ? .white : Color(red: 0.1, green: 0.14, blue: 0.22))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(image.formattedDate)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(isDark ? .white.opacity(0.8) : Color.primary.opacity(0.7))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(isDark ? Color.white.opacity(0.12) : Color.black.opacity(0.06))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.08), lineWidth: 0.6))
                    }
                    
                    Text(image.copyright)
                        .font(.system(size: 11))
                        .foregroundColor(isDark ? .white.opacity(0.72) : Color(red: 0.25, green: 0.30, blue: 0.38))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let link = image.fullCopyrightLink {
                        Link(destination: link) {
                            HStack(spacing: 3) {
                                Text("探索背后故事")
                                Image(systemName: "arrow.up.right.square")
                            }
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(red: 0.0, green: 0.55, blue: 0.95))
                        }
                    }
                }
                .padding(10)
                .glassCard(cornerRadius: 10, opacity: isDark ? 0.45 : 0.70)
                
                // 3. 底部液态玻璃操作栏
                HStack(spacing: 8) {
                    // 主按钮：液态流光玻璃按钮
                    Button(action: {
                        Task { await viewModel.applyWallpaper() }
                    }) {
                        HStack(spacing: 6) {
                            if viewModel.isSettingWallpaper {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "desktopcomputer")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            Text("设为桌面壁纸")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.50, blue: 0.95).opacity(0.90),
                                    Color(red: 0.0, green: 0.75, blue: 0.95).opacity(0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.8), Color.white.opacity(0.2)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color(red: 0.0, green: 0.5, blue: 0.95).opacity(0.35), radius: 8, x: 0, y: 3)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isSettingWallpaper)
                    
                    // 保存原图玻璃按钮
                    Button(action: {
                        Task { await viewModel.saveCurrentToDisk() }
                    }) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isDark ? .white : Color.primary.opacity(0.8))
                            .frame(width: 34, height: 34)
                            .background(isDark ? Color.white.opacity(0.12) : Color.black.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.12), lineWidth: 0.8)
                            )
                    }
                    .buttonStyle(.plain)
                    .help("保存原图至本地 Pictures 目录")
                    
                    // 打开文件夹玻璃按钮
                    Button(action: {
                        viewModel.openFolder()
                    }) {
                        Image(systemName: "folder")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isDark ? .white : Color.primary.opacity(0.8))
                            .frame(width: 34, height: 34)
                            .background(isDark ? Color.white.opacity(0.12) : Color.black.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isDark ? Color.white.opacity(0.3) : Color.black.opacity(0.12), lineWidth: 0.8)
                            )
                    }
                    .buttonStyle(.plain)
                    .help("打开壁纸保存文件夹")
                }
            }
        } else if viewModel.isLoading {
            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.regular)
                Text("正在从必应加载最新壁纸...")
                    .font(.system(size: 12))
                    .foregroundColor(isDark ? .white.opacity(0.8) : .secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 280)
            .glassCard(cornerRadius: 12, opacity: isDark ? 0.4 : 0.6)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 32))
                    .foregroundColor(isDark ? .white.opacity(0.6) : .secondary)
                Text("未能获取壁纸数据")
                    .font(.headline)
                    .foregroundColor(isDark ? .white : .primary)
                Button("重新尝试") {
                    Task { await viewModel.loadDailyWallpapers() }
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, minHeight: 280)
            .glassCard(cornerRadius: 12, opacity: isDark ? 0.4 : 0.6)
        }
    }
}

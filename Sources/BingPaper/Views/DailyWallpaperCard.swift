import SwiftUI
import AppKit

public struct DailyWallpaperCard: View {
    @EnvironmentObject var viewModel: WallpaperViewModel
    @State private var isHoveringImage = false
    
    public init() {}
    
    public var body: some View {
        if let image = viewModel.currentImage {
            VStack(alignment: .leading, spacing: 12) {
                // 1. 壁纸预览区 (16:9)
                ZStack {
                    AsyncImage(url: URL(string: image.hdUrlString)) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                                .overlay(
                                    ProgressView()
                                        .controlSize(.regular)
                                )
                        case .success(let img):
                            img
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
                                    .foregroundColor(.secondary)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    // 浮层交互：左右切换按钮 & 收藏按钮
                    HStack {
                        Button(action: { viewModel.previousImage() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.black.opacity(0.55))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(.leading, 8)
                        
                        Spacer()
                        
                        Button(action: { viewModel.nextImage() }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.black.opacity(0.55))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 8)
                    }
                    
                    // 右上角收藏按钮
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: { viewModel.toggleFavorite() }) {
                                Image(systemName: viewModel.isCurrentFavorite() ? "heart.fill" : "heart")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(viewModel.isCurrentFavorite() ? .red : .white)
                                    .frame(width: 32, height: 32)
                                    .background(Color.black.opacity(0.55))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .padding([.top, .trailing], 8)
                        }
                        Spacer()
                    }
                    
                    // 底部序号指示器
                    VStack {
                        Spacer()
                        HStack(spacing: 5) {
                            ForEach(0..<viewModel.dailyImages.count, id: \.self) { idx in
                                Circle()
                                    .fill(idx == viewModel.currentIndex ? Color.white : Color.white.opacity(0.4))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Capsule())
                        .padding(.bottom, 8)
                    }
                }
                
                // 2. 标题与版权描述
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(image.title.isEmpty ? "必应壁纸" : image.title)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(image.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.12))
                            .cornerRadius(4)
                    }
                    
                    Text(image.copyright)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    if let link = image.fullCopyrightLink {
                        Link(destination: link) {
                            HStack(spacing: 3) {
                                Text("了解背后的故事")
                                Image(systemName: "arrow.up.right.square")
                            }
                            .font(.caption2)
                            .foregroundColor(.accentColor)
                        }
                    }
                }
                
                // 3. 底部操作按钮栏
                HStack(spacing: 10) {
                    Button(action: {
                        Task { await viewModel.applyWallpaper() }
                    }) {
                        HStack(spacing: 6) {
                            if viewModel.isSettingWallpaper {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "desktopcomputer")
                            }
                            Text("设为桌面壁纸")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isSettingWallpaper)
                    
                    Button(action: {
                        Task { await viewModel.saveCurrentToDisk() }
                    }) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 15))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.bordered)
                    .help("保存原图至本地")
                    
                    Button(action: {
                        viewModel.openFolder()
                    }) {
                        Image(systemName: "folder")
                            .font(.system(size: 15))
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.bordered)
                    .help("打开壁纸保存文件夹")
                }
            }
        } else if viewModel.isLoading {
            VStack(spacing: 12) {
                ProgressView()
                Text("正在加载必应壁纸...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 280)
        } else {
            VStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("未能获取壁纸数据")
                    .font(.headline)
                Button("重新加载") {
                    Task { await viewModel.loadDailyWallpapers() }
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, minHeight: 280)
        }
    }
}

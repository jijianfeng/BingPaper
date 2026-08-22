import SwiftUI
import AppKit

public struct MenuBarContentView: View {
    @EnvironmentObject var viewModel: WallpaperViewModel
    @Environment(\.colorScheme) var colorScheme
    
    public init() {}
    
    public var body: some View {
        let isDark = colorScheme == .dark
        
        ZStack {
            // 1. 全局底色：深浅色自适应极光液态毛玻璃背景
            AuroraAmbientBackground()
            
            // 2. 主体内容布局
            VStack(spacing: 14) {
                // 顶部工具栏
                HStack(spacing: 6) {
                    // Logo 与标题
                    HStack(spacing: 5) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.0, green: 0.85, blue: 1.0), Color(red: 0.2, green: 0.55, blue: 1.0)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("BingPaper")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(isDark ? .white : Color(red: 0.12, green: 0.16, blue: 0.24))
                            .lineLimit(1)
                            .fixedSize()
                    }
                    
                    Spacer(minLength: 6)
                    
                    // 自定义玻璃胶囊 Tab 切换器 (强制单行不折叠)
                    HStack(spacing: 2) {
                        ForEach(MainTab.allCases) { tab in
                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    viewModel.selectedTab = tab
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 10, weight: .semibold))
                                    Text(tab.rawValue)
                                        .font(.system(size: 11, weight: .medium))
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                                .foregroundColor(
                                    viewModel.selectedTab == tab ?
                                    (isDark ? .white : Color(red: 0.08, green: 0.12, blue: 0.22)) :
                                    (isDark ? .white.opacity(0.6) : .secondary)
                                )
                                .padding(.horizontal, 9)
                                .padding(.vertical, 5)
                                .background(
                                    ZStack {
                                        if viewModel.selectedTab == tab {
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(
                                                    isDark ?
                                                    LinearGradient(colors: [Color.white.opacity(0.28), Color.white.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                                    LinearGradient(colors: [Color.white, Color.white.opacity(0.92)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(isDark ? Color.white.opacity(0.45) : Color.black.opacity(0.08), lineWidth: 0.8)
                                                )
                                                .shadow(color: isDark ? .clear : Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
                                        }
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(3)
                    .background(isDark ? Color.black.opacity(0.25) : Color.black.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(isDark ? Color.white.opacity(0.15) : Color.black.opacity(0.08), lineWidth: 0.8)
                    )
                    .fixedSize()
                    
                    Spacer(minLength: 6)
                    
                    // 右侧操作按钮组
                    HStack(spacing: 5) {
                        // 刷新按钮 (玻璃小圆钮)
                        Button(action: {
                            Task { await viewModel.loadDailyWallpapers() }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(isDark ? .white.opacity(0.85) : Color.primary.opacity(0.75))
                                .frame(width: 26, height: 26)
                                .background(isDark ? Color.white.opacity(0.10) : Color.black.opacity(0.05))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(isDark ? Color.white.opacity(0.25) : Color.black.opacity(0.10), lineWidth: 0.8))
                        }
                        .buttonStyle(.plain)
                        .help("刷新壁纸数据")
                        
                        // 菜单按钮
                        Menu {
                            Button("打开壁纸保存目录") {
                                viewModel.openFolder()
                            }
                            Divider()
                            Button("退出 BingPaper") {
                                NSApplication.shared.terminate(nil)
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(isDark ? .white.opacity(0.85) : Color.primary.opacity(0.75))
                                .frame(width: 26, height: 26)
                                .background(isDark ? Color.white.opacity(0.10) : Color.black.opacity(0.05))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(isDark ? Color.white.opacity(0.25) : Color.black.opacity(0.10), lineWidth: 0.8))
                        }
                        .menuStyle(.borderlessButton)
                        .frame(width: 26)
                    }
                }
                .padding(.horizontal, 2)
                
                // 视图内容切换
                Group {
                    switch viewModel.selectedTab {
                    case .daily:
                        DailyWallpaperCard()
                    case .favorites:
                        FavoritesGridView()
                    }
                }
                
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        // 状态浮条：悬浮于底部，不参与布局高度计算，避免高度抖动触发 Popover 窗口 resize
        .overlay(alignment: .bottom) {
            if let msg = viewModel.statusMessage {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.0, green: 0.85, blue: 1.0))
                    Text(msg)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isDark ? .white : Color(red: 0.08, green: 0.16, blue: 0.28))
                        .lineLimit(1)
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 14)
                .background(
                    ZStack {
                        VisualEffectBlur(material: isDark ? .popover : .hudWindow, blendingMode: .behindWindow)
                        isDark ? Color(red: 0.05, green: 0.2, blue: 0.45).opacity(0.65) : Color.white.opacity(0.92)
                    }
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.85, blue: 1.0).opacity(0.6),
                                    isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.08)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(isDark ? 0.3 : 0.1), radius: 6, x: 0, y: 3)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 10)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.statusMessage)
        // 固定宽高：Popover 内容尺寸恒定，杜绝 updateAnimatedWindowSize 触发链
        .frame(width: 410, height: 440)
    }
}

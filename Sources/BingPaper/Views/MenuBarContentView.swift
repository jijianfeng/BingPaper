import SwiftUI
import AppKit

public struct MenuBarContentView: View {
    @EnvironmentObject var viewModel: WallpaperViewModel
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // 1. 顶部栏 (应用标题、分段选择器、刷新、退出)
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundColor(.accentColor)
                    Text("BingPaper")
                        .font(.headline)
                }
                
                Spacer()
                
                Picker("", selection: $viewModel.selectedTab) {
                    ForEach(MainTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
                
                Spacer()
                
                // 刷新按钮
                Button(action: {
                    Task { await viewModel.loadDailyWallpapers() }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .help("刷新壁纸数据")
                
                // 退出菜单
                Menu {
                    Button("打开壁纸目录") {
                        viewModel.openFolder()
                    }
                    Divider()
                    Button("退出 BingPaper") {
                        NSApplication.shared.terminate(nil)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 13))
                }
                .menuStyle(.borderlessButton)
                .frame(width: 20)
            }
            .padding(.horizontal, 4)
            
            Divider()
            
            // 2. 主体视图切换
            Group {
                switch viewModel.selectedTab {
                case .daily:
                    DailyWallpaperCard()
                case .favorites:
                    FavoritesGridView()
                }
            }
            
            // 3. 状态提示 Toast 浮条
            if let msg = viewModel.statusMessage {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                    Text(msg)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.accentColor.opacity(0.92))
                .clipShape(Capsule())
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.2), value: viewModel.statusMessage)
            }
        }
        .padding(14)
        .frame(width: 380)
    }
}

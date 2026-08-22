import Foundation
import AppKit
import SwiftUI

@MainActor
public final class StatusBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var contextMenu: NSMenu!
    private let viewModel: WallpaperViewModel
    
    public init(viewModel: WallpaperViewModel) {
        self.viewModel = viewModel
        super.init()
        setupStatusItem()
        setupPopover()
        setupContextMenu()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "photo.on.rectangle.angled", accessibilityDescription: "BingPaper")
            button.target = self
            button.action = #selector(statusBarButtonClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.appearance = nil // 自动跟随 macOS 系统深浅色外观
        
        let contentView = MenuBarContentView()
            .environmentObject(viewModel)
        popover.contentViewController = NSHostingController(rootView: contentView)
    }
    
    private func setupContextMenu() {
        contextMenu = NSMenu()
        
        let refreshItem = NSMenuItem(title: "刷新壁纸数据", action: #selector(refreshClicked), keyEquivalent: "r")
        refreshItem.target = self
        contextMenu.addItem(refreshItem)
        
        let openFolderItem = NSMenuItem(title: "打开壁纸保存目录", action: #selector(openFolderClicked), keyEquivalent: "o")
        openFolderItem.target = self
        contextMenu.addItem(openFolderItem)
        
        contextMenu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "退出 BingPaper", action: #selector(quitClicked), keyEquivalent: "q")
        quitItem.target = self
        contextMenu.addItem(quitItem)
    }
    
    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        if event?.type == .rightMouseUp {
            // 右键：弹出原生上下文菜单（包含退出等）
            if popover.isShown {
                popover.performClose(sender)
            }
            statusItem.menu = contextMenu
            statusItem.button?.performClick(nil)
            // 弹出后将 menu 置空，保证下次左键恢复触发 popover
            DispatchQueue.main.async { [weak self] in
                self?.statusItem.menu = nil
            }
        } else {
            // 左键：弹出/收起主界面 Popover
            togglePopover(sender)
        }
    }
    
    public func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // 不要修改 popover 窗口的 isOpaque/backgroundColor：
            // macOS 26 上该 hack 与 NSVisualEffectView 材质叠加会导致布局递归崩溃
            if let window = popover.contentViewController?.view.window {
                window.makeKey()
            }
        }
    }
    
    @objc private func refreshClicked() {
        Task { @MainActor in
            await viewModel.loadDailyWallpapers()
        }
    }
    
    @objc private func openFolderClicked() {
        Task { @MainActor in
            viewModel.openFolder()
        }
    }
    
    @objc private func quitClicked() {
        NSApplication.shared.terminate(nil)
    }
}

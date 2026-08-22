import SwiftUI
import AppKit

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    let viewModel = WallpaperViewModel()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置为后台常驻模式（隐藏 Dock 图标，纯菜单栏应用）
        NSApp.setActivationPolicy(.accessory)
        statusBarController = StatusBarController(viewModel: viewModel)
    }
}

@main
struct BingPaperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

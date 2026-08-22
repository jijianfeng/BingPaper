import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏 Dock 图标，纯菜单栏驻留
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct BingPaperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = WallpaperViewModel()
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environmentObject(viewModel)
        } label: {
            Image(systemName: "photo.on.rectangle.angled")
        }
        .menuBarExtraStyle(.window)
    }
}

# BingPaper (必应壁纸 for Mac)

一款轻量、原生的 macOS 菜单栏壁纸应用。常驻顶部菜单栏，提供每日必应高清壁纸浏览、背景故事查看、壁纸收藏以及一键设置为 Mac 桌面壁纸等功能。

---

## ✨ 核心特性

- 🌄 **每日发现**：自动拉取微软 Bing 官方每日壁纸，展示高清画质、精美标题与摄影背后的故事。
- ⏪ **历史翻页**：支持前后切换查看最近 8 天的历史壁纸。
- ❤️ **壁纸收藏**：一键收藏喜爱壁纸，支持持久化离线存储，随时在「我的收藏」面板中翻看与重新设为桌面。
- 🖥️ **一键设为壁纸**：后台自动下载 4K 超清（UHD）原图并调用 macOS 原生 API 即时设置为当前桌面壁纸（支持多显示器）。
- 💾 **本地保存**：支持一键将 4K 原图保存到本地 `~/Pictures/BingWallpapers` 目录。
- 🍃 **极简轻量**：基于原生 SwiftUI 6 + AppKit 开发，不占用 Dock 栏，内存占用极低。

---

## 🛠️ 项目结构

```text
BingPaper/
├── Package.swift               # Swift Package 配置
├── build_app.sh                # 一键编译与生成 BingPaper.app 脚本
└── Sources/
    └── BingPaper/
        ├── App/
        │   └── BingPaperApp.swift          # 应用入口 (MenuBarExtra, 纯菜单栏驻留)
        ├── Models/
        │   └── BingImage.swift            # 壁纸数据模型与 JSON 解析
        ├── Services/
        │   ├── BingAPIService.swift       # Bing 官方 API 交互与图片下载
        │   ├── WallpaperManager.swift     # 本地壁纸存储与 macOS 桌面设置
        │   └── FavoriteManager.swift      # 收藏夹持久化管理
        ├── ViewModels/
        │   └── WallpaperViewModel.swift   # 视图驱动与业务逻辑
        └── Views/
            ├── MenuBarContentView.swift   # 菜单栏主弹窗（Tab切换：发现 / 收藏）
            ├── DailyWallpaperCard.swift   # 每日发现大卡片视图
            └── FavoritesGridView.swift    # 我的收藏图库网格视图
```

---

## 🚀 编译与运行

### 1. 一键编译与打包为 macOS App
在项目根目录下执行：
```bash
./build_app.sh
```
执行后会在 `build/` 目录下生成 `BingPaper.app`。

### 2. 启动应用
- 直接在终端中运行：
  ```bash
  open build/BingPaper.app
  ```
- 或将 `build/BingPaper.app` 拖入系统的 `/Applications`（应用程序）目录中开机使用。

### 3. 开发与调试
直接使用 Swift 命令行运行：
```bash
swift run
```
或直接用 Xcode 打开 `Package.swift` 进行可视化调试与界面开发。

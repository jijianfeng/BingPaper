import Foundation
import AppKit
import CoreGraphics

func createBingPaperIcon(size: CGFloat = 1024) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    
    // 1. macOS Squircle 圆角矩形背景
    let inset: CGFloat = size * 0.08
    let squircleRect = rect.insetBy(dx: inset, dy: inset)
    let cornerRadius: CGFloat = size * 0.22
    let path = CGPath(roundedRect: squircleRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    
    // 阴影
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -size * 0.03), blur: size * 0.06, color: NSColor.black.withAlphaComponent(0.35).cgColor)
    context.addPath(path)
    context.setFillColor(NSColor.black.cgColor)
    context.fillPath()
    context.restoreGState()
    
    // 裁剪到 Squircle
    context.saveGState()
    context.addPath(path)
    context.clip()
    
    // 2. 背景天空渐变 (Deep Sky to Twilight Horizon)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let skyColors = [
        NSColor(red: 0.06, green: 0.15, blue: 0.35, alpha: 1.0).cgColor, // 深邃藏蓝
        NSColor(red: 0.08, green: 0.38, blue: 0.72, alpha: 1.0).cgColor, // 必应蓝
        NSColor(red: 0.22, green: 0.65, blue: 0.88, alpha: 1.0).cgColor, // 天空青蓝
        NSColor(red: 0.95, green: 0.65, blue: 0.45, alpha: 1.0).cgColor  // 晨曦暖橙
    ] as CFArray
    let skyLocations: [CGFloat] = [0.0, 0.45, 0.75, 1.0]
    if let skyGradient = CGGradient(colorsSpace: colorSpace, colors: skyColors, locations: skyLocations) {
        context.drawLinearGradient(skyGradient,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.maxY),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
    }
    
    // 3. 晨曦旭日 (Glowing Sunrise)
    let sunCenter = CGPoint(x: squircleRect.midX + size * 0.12, y: squircleRect.minY + size * 0.46)
    let sunRadius: CGFloat = size * 0.14
    
    context.saveGState()
    let sunGlowColors = [
        NSColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 0.9).cgColor,
        NSColor(red: 1.0, green: 0.75, blue: 0.3, alpha: 0.5).cgColor,
        NSColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 0.0).cgColor
    ] as CFArray
    let sunGlowLocations: [CGFloat] = [0.0, 0.5, 1.0]
    if let sunGradient = CGGradient(colorsSpace: colorSpace, colors: sunGlowColors, locations: sunGlowLocations) {
        context.drawRadialGradient(sunGradient,
                                   startCenter: sunCenter,
                                   startRadius: 0,
                                   endCenter: sunCenter,
                                   endRadius: sunRadius * 1.8,
                                   options: [])
    }
    context.restoreGState()
    
    // 4. 远景群山 (Far Mountains)
    context.saveGState()
    let farMountain = CGMutablePath()
    farMountain.move(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY))
    farMountain.addLine(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY + size * 0.28))
    farMountain.addLine(to: CGPoint(x: squircleRect.minX + size * 0.28, y: squircleRect.minY + size * 0.44))
    farMountain.addLine(to: CGPoint(x: squircleRect.minX + size * 0.55, y: squircleRect.minY + size * 0.32))
    farMountain.addLine(to: CGPoint(x: squircleRect.minX + size * 0.78, y: squircleRect.minY + size * 0.48))
    farMountain.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY + size * 0.35))
    farMountain.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY))
    farMountain.closeSubpath()
    
    context.addPath(farMountain)
    let farMountainColors = [
        NSColor(red: 0.45, green: 0.35, blue: 0.60, alpha: 0.85).cgColor,
        NSColor(red: 0.20, green: 0.18, blue: 0.40, alpha: 0.95).cgColor
    ] as CFArray
    if let grad = CGGradient(colorsSpace: colorSpace, colors: farMountainColors, locations: [0.0, 1.0]) {
        context.clip()
        context.drawLinearGradient(grad,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.minY + size * 0.48),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
    }
    context.restoreGState()
    
    // 5. 中景主峰 (Majestic Main Peak)
    context.saveGState()
    let mainMountain = CGMutablePath()
    mainMountain.move(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY))
    mainMountain.addLine(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY + size * 0.15))
    mainMountain.addLine(to: CGPoint(x: squircleRect.minX + size * 0.36, y: squircleRect.minY + size * 0.40))
    mainMountain.addLine(to: CGPoint(x: squircleRect.minX + size * 0.68, y: squircleRect.minY + size * 0.18))
    mainMountain.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY + size * 0.25))
    mainMountain.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY))
    mainMountain.closeSubpath()
    
    context.addPath(mainMountain)
    let mainMountainColors = [
        NSColor(red: 0.12, green: 0.25, blue: 0.50, alpha: 0.95).cgColor,
        NSColor(red: 0.05, green: 0.12, blue: 0.28, alpha: 1.0).cgColor
    ] as CFArray
    if let grad = CGGradient(colorsSpace: colorSpace, colors: mainMountainColors, locations: [0.0, 1.0]) {
        context.clip()
        context.drawLinearGradient(grad,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.minY + size * 0.40),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
    }
    context.restoreGState()
    
    // 6. 前景微风波澜/山峦 (Foreground Silhouette)
    context.saveGState()
    let fgMountain = CGMutablePath()
    fgMountain.move(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY))
    fgMountain.addLine(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY + size * 0.22))
    fgMountain.addCurve(to: CGPoint(x: squircleRect.minX + size * 0.52, y: squircleRect.minY + size * 0.14),
                        control1: CGPoint(x: squircleRect.minX + size * 0.2, y: squircleRect.minY + size * 0.25),
                        control2: CGPoint(x: squircleRect.minX + size * 0.35, y: squircleRect.minY + size * 0.12))
    fgMountain.addCurve(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY + size * 0.18),
                        control1: CGPoint(x: squircleRect.minX + size * 0.7, y: squircleRect.minY + size * 0.16),
                        control2: CGPoint(x: squircleRect.minX + size * 0.85, y: squircleRect.minY + size * 0.22))
    fgMountain.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY))
    fgMountain.closeSubpath()
    
    context.addPath(fgMountain)
    let fgColors = [
        NSColor(red: 0.04, green: 0.08, blue: 0.18, alpha: 1.0).cgColor,
        NSColor(red: 0.01, green: 0.04, blue: 0.10, alpha: 1.0).cgColor
    ] as CFArray
    if let grad = CGGradient(colorsSpace: colorSpace, colors: fgColors, locations: [0.0, 1.0]) {
        context.clip()
        context.drawLinearGradient(grad,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.minY + size * 0.22),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
    }
    context.restoreGState()
    
    // 7. 壁纸取景框与 Bing 光芒标记 (Wallpaper Viewfinder Frame / Aperture Ring)
    context.saveGState()
    let frameRect = squircleRect.insetBy(dx: size * 0.06, dy: size * 0.06)
    let framePath = CGPath(roundedRect: frameRect, cornerWidth: cornerRadius * 0.8, cornerHeight: cornerRadius * 0.8, transform: nil)
    context.addPath(framePath)
    context.setLineWidth(size * 0.008)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.25).cgColor)
    context.strokePath()
    context.restoreGState()
    
    // 8. 边缘高光与内阴影 (Glass / macOS Border Highlight)
    context.saveGState()
    context.addPath(path)
    context.setLineWidth(size * 0.012)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.35).cgColor)
    context.strokePath()
    context.restoreGState()
    
    context.restoreGState() // 还原 Squircle 裁剪
    
    image.unlockFocus()
    return image
}

let icon = createBingPaperIcon(size: 1024)
guard let tiffData = icon.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Failed to render PNG")
}

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.png"
let outputURL = URL(fileURLWithPath: outputPath)
try pngData.write(to: outputURL)
print("✅ Logo 成功生成至: \(outputURL.path)")

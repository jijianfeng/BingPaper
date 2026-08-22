import Foundation
import AppKit
import CoreGraphics

func createGlassmorphismBingPaperIcon(size: CGFloat = 1024) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    // 1. macOS Squircle 基础轮廓
    let inset: CGFloat = size * 0.08
    let squircleRect = rect.insetBy(dx: inset, dy: inset)
    let cornerRadius: CGFloat = size * 0.22
    let squirclePath = CGPath(roundedRect: squircleRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    
    // 2. 超清柔和环境投影 (Ambient Soft Shadow)
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -size * 0.035),
                      blur: size * 0.07,
                      color: NSColor(red: 0.0, green: 0.15, blue: 0.4, alpha: 0.38).cgColor)
    context.addPath(squirclePath)
    context.setFillColor(NSColor(red: 0.02, green: 0.08, blue: 0.22, alpha: 0.95).cgColor)
    context.fillPath()
    context.restoreGState()
    
    // 裁剪为 Squircle 主体
    context.saveGState()
    context.addPath(squirclePath)
    context.clip()
    
    // 3. 背景深空极光发光层 (Luminous Aurora Base)
    let baseSkyColors = [
        NSColor(red: 0.03, green: 0.08, blue: 0.20, alpha: 1.0).cgColor,
        NSColor(red: 0.05, green: 0.16, blue: 0.38, alpha: 1.0).cgColor,
        NSColor(red: 0.08, green: 0.28, blue: 0.58, alpha: 1.0).cgColor
    ] as CFArray
    if let skyGrad = CGGradient(colorsSpace: colorSpace, colors: baseSkyColors, locations: [0.0, 0.5, 1.0]) {
        context.drawLinearGradient(skyGrad,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.maxY),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
    }
    
    // 4. 背景高透光斑与极光透射 (Vibrant Backlight Aurora)
    context.saveGState()
    let auroraCenter1 = CGPoint(x: squircleRect.minX + size * 0.25, y: squircleRect.minY + size * 0.65)
    let auroraColors1 = [
        NSColor(red: 0.0, green: 0.82, blue: 0.98, alpha: 0.65).cgColor,  // 电光青蓝
        NSColor(red: 0.0, green: 0.45, blue: 0.95, alpha: 0.25).cgColor,
        NSColor(red: 0.0, green: 0.2, blue: 0.6, alpha: 0.0).cgColor
    ] as CFArray
    if let grad1 = CGGradient(colorsSpace: colorSpace, colors: auroraColors1, locations: [0.0, 0.5, 1.0]) {
        context.drawRadialGradient(grad1, startCenter: auroraCenter1, startRadius: 0, endCenter: auroraCenter1, endRadius: size * 0.45, options: [])
    }
    
    let auroraCenter2 = CGPoint(x: squircleRect.maxX - size * 0.2, y: squircleRect.minY + size * 0.55)
    let auroraColors2 = [
        NSColor(red: 1.0, green: 0.42, blue: 0.65, alpha: 0.55).cgColor,  // 暮光霓虹粉
        NSColor(red: 1.0, green: 0.65, blue: 0.25, alpha: 0.35).cgColor,  // 晨光金
        NSColor(red: 0.8, green: 0.2, blue: 0.5, alpha: 0.0).cgColor
    ] as CFArray
    if let grad2 = CGGradient(colorsSpace: colorSpace, colors: auroraColors2, locations: [0.0, 0.5, 1.0]) {
        context.drawRadialGradient(grad2, startCenter: auroraCenter2, startRadius: 0, endCenter: auroraCenter2, endRadius: size * 0.42, options: [])
    }
    context.restoreGState()
    
    // 5. 悬浮发光旭日 (Luminous Floating Orb Sun)
    let sunCenter = CGPoint(x: squircleRect.midX + size * 0.12, y: squircleRect.minY + size * 0.50)
    let sunRadius = size * 0.13
    
    context.saveGState()
    let sunHalo = [
        NSColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 0.95).cgColor,
        NSColor(red: 1.0, green: 0.72, blue: 0.30, alpha: 0.65).cgColor,
        NSColor(red: 1.0, green: 0.45, blue: 0.20, alpha: 0.20).cgColor,
        NSColor(red: 1.0, green: 0.30, blue: 0.10, alpha: 0.0).cgColor
    ] as CFArray
    if let sunGrad = CGGradient(colorsSpace: colorSpace, colors: sunHalo, locations: [0.0, 0.3, 0.65, 1.0]) {
        context.drawRadialGradient(sunGrad, startCenter: sunCenter, startRadius: 0, endCenter: sunCenter, endRadius: sunRadius * 2.2, options: [])
    }
    context.restoreGState()
    
    // 6. 第一层透明磨砂玻璃山（远景毛玻璃）
    context.saveGState()
    let glassMountainFar = CGMutablePath()
    glassMountainFar.move(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY))
    glassMountainFar.addLine(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY + size * 0.26))
    glassMountainFar.addLine(to: CGPoint(x: squircleRect.minX + size * 0.26, y: squircleRect.minY + size * 0.46))
    glassMountainFar.addLine(to: CGPoint(x: squircleRect.minX + size * 0.52, y: squircleRect.minY + size * 0.34))
    glassMountainFar.addLine(to: CGPoint(x: squircleRect.minX + size * 0.76, y: squircleRect.minY + size * 0.50))
    glassMountainFar.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY + size * 0.36))
    glassMountainFar.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY))
    glassMountainFar.closeSubpath()
    
    // 玻璃填充（高透明度磨砂发光质感）
    context.addPath(glassMountainFar)
    let glassColors1 = [
        NSColor.white.withAlphaComponent(0.32).cgColor,
        NSColor(red: 0.25, green: 0.45, blue: 0.85, alpha: 0.22).cgColor,
        NSColor(red: 0.10, green: 0.18, blue: 0.42, alpha: 0.35).cgColor
    ] as CFArray
    if let gGrad1 = CGGradient(colorsSpace: colorSpace, colors: glassColors1, locations: [0.0, 0.4, 1.0]) {
        context.saveGState()
        context.clip()
        context.drawLinearGradient(gGrad1,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.minY + size * 0.50),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
        context.restoreGState()
    }
    
    // 玻璃折射边缘高光 (Specular Glass Ridge 1)
    context.addPath(glassMountainFar)
    context.setLineWidth(size * 0.006)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.65).cgColor)
    context.strokePath()
    context.restoreGState()
    
    // 7. 第二层透明液态玻璃山（中景主峰）
    context.saveGState()
    let glassMountainMid = CGMutablePath()
    glassMountainMid.move(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY))
    glassMountainMid.addLine(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY + size * 0.16))
    glassMountainMid.addLine(to: CGPoint(x: squircleRect.minX + size * 0.38, y: squircleRect.minY + size * 0.42))
    glassMountainMid.addLine(to: CGPoint(x: squircleRect.minX + size * 0.65, y: squircleRect.minY + size * 0.22))
    glassMountainMid.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY + size * 0.28))
    glassMountainMid.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY))
    glassMountainMid.closeSubpath()
    
    context.addPath(glassMountainMid)
    let glassColors2 = [
        NSColor.white.withAlphaComponent(0.40).cgColor,
        NSColor(red: 0.05, green: 0.60, blue: 0.95, alpha: 0.28).cgColor,
        NSColor(red: 0.02, green: 0.12, blue: 0.32, alpha: 0.48).cgColor
    ] as CFArray
    if let gGrad2 = CGGradient(colorsSpace: colorSpace, colors: glassColors2, locations: [0.0, 0.35, 1.0]) {
        context.saveGState()
        context.clip()
        context.drawLinearGradient(gGrad2,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.minY + size * 0.42),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
        context.restoreGState()
    }
    
    // 脊线晶莹高光
    context.addPath(glassMountainMid)
    context.setLineWidth(size * 0.007)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.85).cgColor)
    context.strokePath()
    context.restoreGState()
    
    // 8. 前景流光高透玻璃层 (Foreground Liquid Glass Wave)
    context.saveGState()
    let glassForeground = CGMutablePath()
    glassForeground.move(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY))
    glassForeground.addLine(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY + size * 0.24))
    glassForeground.addCurve(to: CGPoint(x: squircleRect.minX + size * 0.52, y: squircleRect.minY + size * 0.15),
                             control1: CGPoint(x: squircleRect.minX + size * 0.2, y: squircleRect.minY + size * 0.28),
                             control2: CGPoint(x: squircleRect.minX + size * 0.35, y: squircleRect.minY + size * 0.12))
    glassForeground.addCurve(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY + size * 0.20),
                             control1: CGPoint(x: squircleRect.minX + size * 0.70, y: squircleRect.minY + size * 0.18),
                             control2: CGPoint(x: squircleRect.minX + size * 0.86, y: squircleRect.minY + size * 0.24))
    glassForeground.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY))
    glassForeground.closeSubpath()
    
    context.addPath(glassForeground)
    let fgGlassColors = [
        NSColor.white.withAlphaComponent(0.48).cgColor,
        NSColor(red: 0.0, green: 0.80, blue: 0.95, alpha: 0.30).cgColor,
        NSColor(red: 0.01, green: 0.06, blue: 0.18, alpha: 0.55).cgColor
    ] as CFArray
    if let fgGrad = CGGradient(colorsSpace: colorSpace, colors: fgGlassColors, locations: [0.0, 0.3, 1.0]) {
        context.saveGState()
        context.clip()
        context.drawLinearGradient(fgGrad,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.minY + size * 0.25),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
        context.restoreGState()
    }
    
    // 前景高光刃边
    context.addPath(glassForeground)
    context.setLineWidth(size * 0.008)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.92).cgColor)
    context.strokePath()
    context.restoreGState()
    
    // 9. 悬浮磨砂玻璃画框 (Floating Frosted Glass Viewport Frame)
    context.saveGState()
    let frameRect = squircleRect.insetBy(dx: size * 0.065, dy: size * 0.065)
    let framePath = CGPath(roundedRect: frameRect, cornerWidth: cornerRadius * 0.78, cornerHeight: cornerRadius * 0.78, transform: nil)
    
    // 内框微光描边
    context.addPath(framePath)
    context.setLineWidth(size * 0.005)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.35).cgColor)
    context.strokePath()
    
    // 四角极简取景微标记 (Corner Viewfinder Crosshairs)
    let markLen: CGFloat = size * 0.035
    let markPad: CGFloat = size * 0.03
    let marks = CGMutablePath()
    // 左上
    marks.move(to: CGPoint(x: frameRect.minX + markPad, y: frameRect.maxY - markPad - markLen))
    marks.addLine(to: CGPoint(x: frameRect.minX + markPad, y: frameRect.maxY - markPad))
    marks.addLine(to: CGPoint(x: frameRect.minX + markPad + markLen, y: frameRect.maxY - markPad))
    // 右上
    marks.move(to: CGPoint(x: frameRect.maxX - markPad - markLen, y: frameRect.maxY - markPad))
    marks.addLine(to: CGPoint(x: frameRect.maxX - markPad, y: frameRect.maxY - markPad))
    marks.addLine(to: CGPoint(x: frameRect.maxX - markPad, y: frameRect.maxY - markPad - markLen))
    // 左下
    marks.move(to: CGPoint(x: frameRect.minX + markPad, y: frameRect.minY + markPad + markLen))
    marks.addLine(to: CGPoint(x: frameRect.minX + markPad, y: frameRect.minY + markPad))
    marks.addLine(to: CGPoint(x: frameRect.minX + markPad + markLen, y: frameRect.minY + markPad))
    // 右下
    marks.move(to: CGPoint(x: frameRect.maxX - markPad - markLen, y: frameRect.minY + markPad))
    marks.addLine(to: CGPoint(x: frameRect.maxX - markPad, y: frameRect.minY + markPad))
    marks.addLine(to: CGPoint(x: frameRect.maxX - markPad, y: frameRect.minY + markPad + markLen))
    
    context.addPath(marks)
    context.setLineWidth(size * 0.004)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.55).cgColor)
    context.strokePath()
    context.restoreGState()
    
    // 10. macOS 26 液态玻璃斜切倒角与透光折射 (Liquid Glass Bevel & Prism Reflection)
    context.saveGState()
    // 左上至右下的对角透光高光 (Diagonal Specular Sheen)
    let sheenPath = CGMutablePath()
    sheenPath.move(to: CGPoint(x: squircleRect.minX, y: squircleRect.maxY))
    sheenPath.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.maxY))
    sheenPath.addLine(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY + size * 0.3))
    sheenPath.closeSubpath()
    
    context.addPath(sheenPath)
    let sheenColors = [
        NSColor.white.withAlphaComponent(0.28).cgColor,
        NSColor.white.withAlphaComponent(0.08).cgColor,
        NSColor.white.withAlphaComponent(0.0).cgColor
    ] as CFArray
    if let sheenGrad = CGGradient(colorsSpace: colorSpace, colors: sheenColors, locations: [0.0, 0.4, 1.0]) {
        context.clip()
        context.drawLinearGradient(sheenGrad,
                                   start: CGPoint(x: squircleRect.minX, y: squircleRect.maxY),
                                   end: CGPoint(x: squircleRect.maxX, y: squircleRect.minY + size * 0.2),
                                   options: [])
    }
    context.restoreGState()
    
    // 11. 外圈双层超薄晶莹玻璃边缘 (Crisp Glass Outer Rim)
    context.saveGState()
    context.addPath(squirclePath)
    context.setLineWidth(size * 0.015)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.55).cgColor)
    context.strokePath()
    
    let innerRect = squircleRect.insetBy(dx: size * 0.006, dy: size * 0.006)
    let innerSquircle = CGPath(roundedRect: innerRect, cornerWidth: cornerRadius * 0.96, cornerHeight: cornerRadius * 0.96, transform: nil)
    context.addPath(innerSquircle)
    context.setLineWidth(size * 0.005)
    context.setStrokeColor(NSColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 0.35).cgColor)
    context.strokePath()
    context.restoreGState()
    
    context.restoreGState() // 结束 Squircle 裁剪
    
    image.unlockFocus()
    return image
}

let icon = createGlassmorphismBingPaperIcon(size: 1024)
guard let tiffData = icon.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Failed to render PNG")
}

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.png"
let outputURL = URL(fileURLWithPath: outputPath)
try pngData.write(to: outputURL)
print("✅ macOS 26 液态高透玻璃 Logo 渲染完成: \(outputURL.path)")

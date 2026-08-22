import Foundation
import AppKit
import CoreGraphics

func createEnhancedGlassmorphismIcon(size: CGFloat = 1024) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    
    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    // 1. macOS Squircle 基础几何体
    let inset: CGFloat = size * 0.08
    let squircleRect = rect.insetBy(dx: inset, dy: inset)
    let cornerRadius: CGFloat = size * 0.225
    let squirclePath = CGPath(roundedRect: squircleRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    
    // 2. 超柔和通透环境投影 (Deep Ambient & Glow Shadow)
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -size * 0.04),
                      blur: size * 0.08,
                      color: NSColor(red: 0.0, green: 0.12, blue: 0.35, alpha: 0.45).cgColor)
    context.addPath(squirclePath)
    context.setFillColor(NSColor(red: 0.01, green: 0.04, blue: 0.12, alpha: 0.98).cgColor)
    context.fillPath()
    context.restoreGState()
    
    // 裁剪进入 Squircle 内部
    context.saveGState()
    context.addPath(squirclePath)
    context.clip()
    
    // 3. 背景：深邃宇宙与多色极光底色 (Deep Space & Vibrant Aurora Under-Glass)
    let deepSpaceColors = [
        NSColor(red: 0.02, green: 0.05, blue: 0.14, alpha: 1.0).cgColor,
        NSColor(red: 0.04, green: 0.10, blue: 0.26, alpha: 1.0).cgColor,
        NSColor(red: 0.06, green: 0.16, blue: 0.38, alpha: 1.0).cgColor
    ] as CFArray
    if let spaceGrad = CGGradient(colorsSpace: colorSpace, colors: deepSpaceColors, locations: [0.0, 0.5, 1.0]) {
        context.drawLinearGradient(spaceGrad,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.maxY),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
    }
    
    // 极光透光光斑 1 (电光青蓝 - 左上方)
    context.saveGState()
    let aurora1 = CGPoint(x: squircleRect.minX + size * 0.22, y: squircleRect.minY + size * 0.68)
    let aColors1 = [
        NSColor(red: 0.0, green: 0.92, blue: 1.0, alpha: 0.75).cgColor,
        NSColor(red: 0.0, green: 0.55, blue: 0.98, alpha: 0.35).cgColor,
        NSColor(red: 0.0, green: 0.2, blue: 0.6, alpha: 0.0).cgColor
    ] as CFArray
    if let aGrad1 = CGGradient(colorsSpace: colorSpace, colors: aColors1, locations: [0.0, 0.45, 1.0]) {
        context.drawRadialGradient(aGrad1, startCenter: aurora1, startRadius: 0, endCenter: aurora1, endRadius: size * 0.48, options: [])
    }
    
    // 极光透光光斑 2 (霓虹紫红与晨曦金 - 右侧)
    let aurora2 = CGPoint(x: squircleRect.maxX - size * 0.18, y: squircleRect.minY + size * 0.58)
    let aColors2 = [
        NSColor(red: 1.0, green: 0.35, blue: 0.75, alpha: 0.65).cgColor,
        NSColor(red: 1.0, green: 0.68, blue: 0.22, alpha: 0.45).cgColor,
        NSColor(red: 0.7, green: 0.1, blue: 0.5, alpha: 0.0).cgColor
    ] as CFArray
    if let aGrad2 = CGGradient(colorsSpace: colorSpace, colors: aColors2, locations: [0.0, 0.42, 1.0]) {
        context.drawRadialGradient(aGrad2, startCenter: aurora2, startRadius: 0, endCenter: aurora2, endRadius: size * 0.45, options: [])
    }
    context.restoreGState()
    
    // 4. 玻璃后的发光恒星/旭日 (Glowing Sun Sphere behind the glass)
    let sunCenter = CGPoint(x: squircleRect.midX + size * 0.14, y: squircleRect.minY + size * 0.52)
    let sunRadius = size * 0.12
    
    context.saveGState()
    let sunGlow = [
        NSColor(red: 1.0, green: 0.98, blue: 0.90, alpha: 1.0).cgColor,
        NSColor(red: 1.0, green: 0.82, blue: 0.35, alpha: 0.85).cgColor,
        NSColor(red: 1.0, green: 0.50, blue: 0.15, alpha: 0.35).cgColor,
        NSColor(red: 1.0, green: 0.30, blue: 0.10, alpha: 0.0).cgColor
    ] as CFArray
    if let sunGrad = CGGradient(colorsSpace: colorSpace, colors: sunGlow, locations: [0.0, 0.25, 0.6, 1.0]) {
        context.drawRadialGradient(sunGrad, startCenter: sunCenter, startRadius: 0, endCenter: sunCenter, endRadius: sunRadius * 2.5, options: [])
    }
    context.restoreGState()
    
    // 5. 第一层【高透磨砂玻璃山】 (Far Glass Mountain Plate)
    context.saveGState()
    let mountainFar = CGMutablePath()
    mountainFar.move(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY))
    mountainFar.addLine(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY + size * 0.28))
    mountainFar.addLine(to: CGPoint(x: squircleRect.minX + size * 0.26, y: squircleRect.minY + size * 0.48))
    mountainFar.addLine(to: CGPoint(x: squircleRect.minX + size * 0.52, y: squircleRect.minY + size * 0.36))
    mountainFar.addLine(to: CGPoint(x: squircleRect.minX + size * 0.76, y: squircleRect.minY + size * 0.52))
    mountainFar.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY + size * 0.38))
    mountainFar.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY))
    mountainFar.closeSubpath()
    
    // 玻璃板后投影 (Drop Shadow of Glass Slab)
    context.setShadow(offset: CGSize(width: 0, height: -size * 0.02),
                      blur: size * 0.04,
                      color: NSColor.black.withAlphaComponent(0.4).cgColor)
    
    // 玻璃半透明渐变填充
    context.addPath(mountainFar)
    let glassColors1 = [
        NSColor.white.withAlphaComponent(0.38).cgColor,
        NSColor(red: 0.4, green: 0.65, blue: 1.0, alpha: 0.22).cgColor,
        NSColor(red: 0.12, green: 0.20, blue: 0.45, alpha: 0.28).cgColor
    ] as CFArray
    if let gGrad1 = CGGradient(colorsSpace: colorSpace, colors: glassColors1, locations: [0.0, 0.4, 1.0]) {
        context.saveGState()
        context.clip()
        context.drawLinearGradient(gGrad1,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.minY + size * 0.52),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
        context.restoreGState()
    }
    
    // 玻璃顶部晶莹高光倒角 (Crisp Frosted Top Edge)
    context.addPath(mountainFar)
    context.setLineWidth(size * 0.008)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.75).cgColor)
    context.strokePath()
    context.restoreGState()
    
    // 6. 第二层【液态晶体玻璃主峰】 (Mid Liquid Crystal Peak)
    context.saveGState()
    let mountainMid = CGMutablePath()
    mountainMid.move(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY))
    mountainMid.addLine(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY + size * 0.18))
    mountainMid.addLine(to: CGPoint(x: squircleRect.minX + size * 0.38, y: squircleRect.minY + size * 0.44))
    mountainMid.addLine(to: CGPoint(x: squircleRect.minX + size * 0.65, y: squircleRect.minY + size * 0.24))
    mountainMid.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY + size * 0.30))
    mountainMid.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY))
    mountainMid.closeSubpath()
    
    // 玻璃板投影
    context.setShadow(offset: CGSize(width: 0, height: -size * 0.025),
                      blur: size * 0.045,
                      color: NSColor.black.withAlphaComponent(0.45).cgColor)
    
    // 玻璃填充（具有强烈透光青蓝折射）
    context.addPath(mountainMid)
    let glassColors2 = [
        NSColor.white.withAlphaComponent(0.48).cgColor,
        NSColor(red: 0.0, green: 0.75, blue: 1.0, alpha: 0.30).cgColor,
        NSColor(red: 0.04, green: 0.15, blue: 0.38, alpha: 0.38).cgColor
    ] as CFArray
    if let gGrad2 = CGGradient(colorsSpace: colorSpace, colors: glassColors2, locations: [0.0, 0.35, 1.0]) {
        context.saveGState()
        context.clip()
        context.drawLinearGradient(gGrad2,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.minY + size * 0.44),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
        context.restoreGState()
    }
    
    // 晶体棱线超亮高光
    context.addPath(mountainMid)
    context.setLineWidth(size * 0.010)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.92).cgColor)
    context.strokePath()
    context.restoreGState()
    
    // 7. 第三层【前景流光高透曲面玻璃】 (Foreground Curved Liquid Glass Wave)
    context.saveGState()
    let mountainFg = CGMutablePath()
    mountainFg.move(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY))
    mountainFg.addLine(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY + size * 0.25))
    mountainFg.addCurve(to: CGPoint(x: squircleRect.minX + size * 0.52, y: squircleRect.minY + size * 0.16),
                        control1: CGPoint(x: squircleRect.minX + size * 0.2, y: squircleRect.minY + size * 0.30),
                        control2: CGPoint(x: squircleRect.minX + size * 0.35, y: squircleRect.minY + size * 0.13))
    mountainFg.addCurve(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY + size * 0.22),
                        control1: CGPoint(x: squircleRect.minX + size * 0.70, y: squircleRect.minY + size * 0.19),
                        control2: CGPoint(x: squircleRect.minX + size * 0.86, y: squircleRect.minY + size * 0.26))
    mountainFg.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.minY))
    mountainFg.closeSubpath()
    
    context.setShadow(offset: CGSize(width: 0, height: -size * 0.03),
                      blur: size * 0.05,
                      color: NSColor.black.withAlphaComponent(0.5).cgColor)
    
    context.addPath(mountainFg)
    let fgGlassColors = [
        NSColor.white.withAlphaComponent(0.55).cgColor,
        NSColor(red: 0.0, green: 0.85, blue: 1.0, alpha: 0.35).cgColor,
        NSColor(red: 0.02, green: 0.08, blue: 0.22, alpha: 0.45).cgColor
    ] as CFArray
    if let fgGrad = CGGradient(colorsSpace: colorSpace, colors: fgGlassColors, locations: [0.0, 0.3, 1.0]) {
        context.saveGState()
        context.clip()
        context.drawLinearGradient(fgGrad,
                                   start: CGPoint(x: squircleRect.midX, y: squircleRect.minY + size * 0.26),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY),
                                   options: [])
        context.restoreGState()
    }
    
    // 纯白高光刀锋边缘
    context.addPath(mountainFg)
    context.setLineWidth(size * 0.012)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.98).cgColor)
    context.strokePath()
    context.restoreGState()
    
    // 8. 悬浮磨砂玻璃取景框 (Floating Frosted Reticle with Viewfinder Crosshairs)
    context.saveGState()
    let frameRect = squircleRect.insetBy(dx: size * 0.065, dy: size * 0.065)
    let frameCorner = cornerRadius * 0.78
    let framePath = CGPath(roundedRect: frameRect, cornerWidth: frameCorner, cornerHeight: frameCorner, transform: nil)
    
    // 边框微光
    context.addPath(framePath)
    context.setLineWidth(size * 0.006)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.40).cgColor)
    context.strokePath()
    
    // 四角极简取景准星标记 (Corner Crosshairs)
    let markLen: CGFloat = size * 0.040
    let markPad: CGFloat = size * 0.028
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
    context.setLineWidth(size * 0.005)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.70).cgColor)
    context.strokePath()
    context.restoreGState()
    
    // 9. 玻璃表面大幅面流动光泽 (Big Specular Curved Glass Glare)
    context.saveGState()
    let glarePath = CGMutablePath()
    glarePath.move(to: CGPoint(x: squircleRect.minX, y: squircleRect.maxY))
    glarePath.addLine(to: CGPoint(x: squircleRect.maxX, y: squircleRect.maxY))
    glarePath.addCurve(to: CGPoint(x: squircleRect.minX, y: squircleRect.minY + size * 0.42),
                       control1: CGPoint(x: squircleRect.maxX - size * 0.15, y: squircleRect.maxY - size * 0.25),
                       control2: CGPoint(x: squircleRect.minX + size * 0.35, y: squircleRect.minY + size * 0.55))
    glarePath.closeSubpath()
    
    context.addPath(glarePath)
    let glareColors = [
        NSColor.white.withAlphaComponent(0.42).cgColor,
        NSColor.white.withAlphaComponent(0.12).cgColor,
        NSColor.white.withAlphaComponent(0.0).cgColor
    ] as CFArray
    if let glareGrad = CGGradient(colorsSpace: colorSpace, colors: glareColors, locations: [0.0, 0.45, 1.0]) {
        context.clip()
        context.drawLinearGradient(glareGrad,
                                   start: CGPoint(x: squircleRect.minX + size * 0.1, y: squircleRect.maxY),
                                   end: CGPoint(x: squircleRect.midX, y: squircleRect.minY + size * 0.3),
                                   options: [])
    }
    context.restoreGState()
    
    // 10. 外轮廓三层高透微晶玻璃倒角与折射亮边 (Triple-Pass Specular Rim)
    context.saveGState()
    // 外层主高光边框 (Top-Left Specular Reflection)
    context.addPath(squirclePath)
    context.setLineWidth(size * 0.016)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.68).cgColor)
    context.strokePath()
    
    // 内层青蓝棱镜折射光 (Inner Prismatic Cyan Bevel)
    let innerRect1 = squircleRect.insetBy(dx: size * 0.007, dy: size * 0.007)
    let innerSquircle1 = CGPath(roundedRect: innerRect1, cornerWidth: cornerRadius * 0.95, cornerHeight: cornerRadius * 0.95, transform: nil)
    context.addPath(innerSquircle1)
    context.setLineWidth(size * 0.006)
    context.setStrokeColor(NSColor(red: 0.3, green: 0.85, blue: 1.0, alpha: 0.55).cgColor)
    context.strokePath()
    
    // 极细内部内阴影 (Subtle Inner Depth Stroke)
    let innerRect2 = squircleRect.insetBy(dx: size * 0.014, dy: size * 0.014)
    let innerSquircle2 = CGPath(roundedRect: innerRect2, cornerWidth: cornerRadius * 0.90, cornerHeight: cornerRadius * 0.90, transform: nil)
    context.addPath(innerSquircle2)
    context.setLineWidth(size * 0.003)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.25).cgColor)
    context.strokePath()
    context.restoreGState()
    
    context.restoreGState() // 结束 Squircle 裁剪
    
    image.unlockFocus()
    return image
}

let icon = createEnhancedGlassmorphismIcon(size: 1024)
guard let tiffData = icon.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Failed to render PNG")
}

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.png"
let outputURL = URL(fileURLWithPath: outputPath)
try pngData.write(to: outputURL)
print("✅ 超高透液态玻璃 (Liquid Glass) Logo 渲染完成: \(outputURL.path)")

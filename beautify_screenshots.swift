import Foundation
import AppKit
import CoreGraphics

func getCroppedCard(inputURL: URL) -> (CGImage, CGSize)? {
    guard let sourceImage = NSImage(contentsOf: inputURL),
          let tiffData = sourceImage.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let cgImage = bitmap.cgImage else { return nil }
    
    let srcWidth = CGFloat(cgImage.width)
    let srcHeight = CGFloat(cgImage.height)
    
    // 微调去除最外层 2px 以及顶层小边缘
    let topTrim: CGFloat = 16
    let sideTrim: CGFloat = 4
    let bottomTrim: CGFloat = 6
    
    let cropRect = CGRect(x: sideTrim,
                          y: bottomTrim,
                          width: srcWidth - sideTrim * 2,
                          height: srcHeight - topTrim - bottomTrim)
    
    guard let cropped = cgImage.cropping(to: cropRect) else { return nil }
    return (cropped, cropRect.size)
}

func createStudioCard(inputURL: URL, isDark: Bool) -> NSImage? {
    guard let (croppedCG, cardSize) = getCroppedCard(inputURL: inputURL) else { return nil }
    
    let paddingX: CGFloat = 80
    let paddingY: CGFloat = 60
    
    let canvasWidth = cardSize.width + paddingX * 2
    let canvasHeight = cardSize.height + paddingY * 2
    
    let resultImage = NSImage(size: NSSize(width: canvasWidth, height: canvasHeight))
    resultImage.lockFocus()
    guard let context = NSGraphicsContext.current?.cgContext else {
        resultImage.unlockFocus()
        return nil
    }
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    // 展台背景渐变
    if isDark {
        let bgColors = [
            NSColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 1.0).cgColor,
            NSColor(red: 0.03, green: 0.04, blue: 0.08, alpha: 1.0).cgColor
        ] as CFArray
        if let bgGrad = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0]) {
            context.drawLinearGradient(bgGrad, start: CGPoint(x: 0, y: canvasHeight), end: CGPoint(x: canvasWidth, y: 0), options: [])
        }
        
        let glowCenter = CGPoint(x: canvasWidth / 2, y: canvasHeight / 2)
        let glowColors = [
            NSColor(red: 0.0, green: 0.55, blue: 1.0, alpha: 0.22).cgColor,
            NSColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 0.08).cgColor,
            NSColor.clear.cgColor
        ] as CFArray
        if let glowGrad = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0.0, 0.5, 1.0]) {
            context.drawRadialGradient(glowGrad, startCenter: glowCenter, startRadius: 0, endCenter: glowCenter, endRadius: canvasWidth * 0.6, options: [])
        }
    } else {
        let bgColors = [
            NSColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0).cgColor,
            NSColor(red: 0.90, green: 0.92, blue: 0.96, alpha: 1.0).cgColor
        ] as CFArray
        if let bgGrad = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0]) {
            context.drawLinearGradient(bgGrad, start: CGPoint(x: 0, y: canvasHeight), end: CGPoint(x: canvasWidth, y: 0), options: [])
        }
        
        let glowCenter = CGPoint(x: canvasWidth / 2, y: canvasHeight / 2)
        let glowColors = [
            NSColor(red: 0.0, green: 0.65, blue: 1.0, alpha: 0.12).cgColor,
            NSColor(red: 1.0, green: 0.55, blue: 0.65, alpha: 0.08).cgColor,
            NSColor.clear.cgColor
        ] as CFArray
        if let glowGrad = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: [0.0, 0.5, 1.0]) {
            context.drawRadialGradient(glowGrad, startCenter: glowCenter, startRadius: 0, endCenter: glowCenter, endRadius: canvasWidth * 0.6, options: [])
        }
    }
    
    let windowRect = CGRect(x: paddingX, y: paddingY, width: cardSize.width, height: cardSize.height)
    let cornerRadius: CGFloat = 20
    let windowPath = CGPath(roundedRect: windowRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    
    // Apple 柔和环境深投影
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -18),
                      blur: 35,
                      color: isDark ? NSColor.black.withAlphaComponent(0.65).cgColor : NSColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 0.22).cgColor)
    context.addPath(windowPath)
    context.setFillColor(isDark ? NSColor.black.cgColor : NSColor.white.cgColor)
    context.fillPath()
    context.restoreGState()
    
    // 画面绘制
    context.saveGState()
    context.addPath(windowPath)
    context.clip()
    context.draw(croppedCG, in: windowRect)
    context.restoreGState()
    
    // 微晶描边
    context.saveGState()
    context.addPath(windowPath)
    context.setLineWidth(1.5)
    context.setStrokeColor(isDark ? NSColor.white.withAlphaComponent(0.25).cgColor : NSColor.black.withAlphaComponent(0.08).cgColor)
    context.strokePath()
    context.restoreGState()
    
    resultImage.unlockFocus()
    return resultImage
}

func createCombinedBanner(leftURL: URL, leftIsDark: Bool, rightURL: URL, rightIsDark: Bool) -> NSImage? {
    guard let (leftCG, leftSize) = getCroppedCard(inputURL: leftURL),
          let (rightCG, rightSize) = getCroppedCard(inputURL: rightURL) else { return nil }
    
    let scale: CGFloat = 0.88
    let lW = leftSize.width * scale
    let lH = leftSize.height * scale
    let rW = rightSize.width * scale
    let rH = rightSize.height * scale
    
    let gap: CGFloat = 60
    let padX: CGFloat = 80
    let padY: CGFloat = 80
    
    let bannerW = lW + rW + gap + padX * 2
    let bannerH = max(lH, rH) + padY * 2
    
    let banner = NSImage(size: NSSize(width: bannerW, height: bannerH))
    banner.lockFocus()
    guard let context = NSGraphicsContext.current?.cgContext else {
        banner.unlockFocus()
        return nil
    }
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    // 全局高级深空舞台底色
    let bgColors = [
        NSColor(red: 0.05, green: 0.07, blue: 0.12, alpha: 1.0).cgColor,
        NSColor(red: 0.02, green: 0.03, blue: 0.07, alpha: 1.0).cgColor
    ] as CFArray
    if let bgGrad = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0]) {
        context.drawLinearGradient(bgGrad, start: CGPoint(x: 0, y: bannerH), end: CGPoint(x: bannerW, y: 0), options: [])
    }
    
    // 左侧与右侧光晕
    let glow1 = CGPoint(x: padX + lW * 0.5, y: bannerH * 0.5)
    let gColors1 = [
        NSColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 0.22).cgColor,
        NSColor.clear.cgColor
    ] as CFArray
    if let gGrad1 = CGGradient(colorsSpace: colorSpace, colors: gColors1, locations: [0.0, 1.0]) {
        context.drawRadialGradient(gGrad1, startCenter: glow1, startRadius: 0, endCenter: glow1, endRadius: lW * 0.9, options: [])
    }
    
    let glow2 = CGPoint(x: padX + lW + gap + rW * 0.5, y: bannerH * 0.5)
    let gColors2 = [
        NSColor(red: 1.0, green: 0.4, blue: 0.65, alpha: 0.18).cgColor,
        NSColor.clear.cgColor
    ] as CFArray
    if let gGrad2 = CGGradient(colorsSpace: colorSpace, colors: gColors2, locations: [0.0, 1.0]) {
        context.drawRadialGradient(gGrad2, startCenter: glow2, startRadius: 0, endCenter: glow2, endRadius: rW * 0.9, options: [])
    }
    
    // 绘制左侧卡片 (Light Mode: 每日发现)
    let leftRect = CGRect(x: padX, y: padY + (bannerH - padY * 2 - lH) / 2, width: lW, height: lH)
    let leftPath = CGPath(roundedRect: leftRect, cornerWidth: 18, cornerHeight: 18, transform: nil)
    
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -20), blur: 40, color: NSColor.black.withAlphaComponent(0.6).cgColor)
    context.addPath(leftPath)
    context.setFillColor(leftIsDark ? NSColor.black.cgColor : NSColor.white.cgColor)
    context.fillPath()
    context.restoreGState()
    
    context.saveGState()
    context.addPath(leftPath)
    context.clip()
    context.draw(leftCG, in: leftRect)
    context.restoreGState()
    
    context.saveGState()
    context.addPath(leftPath)
    context.setLineWidth(1.2)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.35).cgColor)
    context.strokePath()
    context.restoreGState()
    
    // 绘制右侧卡片 (Dark Mode: 我的收藏)
    let rightRect = CGRect(x: padX + lW + gap, y: padY + (bannerH - padY * 2 - rH) / 2, width: rW, height: rH)
    let rightPath = CGPath(roundedRect: rightRect, cornerWidth: 18, cornerHeight: 18, transform: nil)
    
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: -20), blur: 40, color: NSColor.black.withAlphaComponent(0.7).cgColor)
    context.addPath(rightPath)
    context.setFillColor(rightIsDark ? NSColor.black.cgColor : NSColor.white.cgColor)
    context.fillPath()
    context.restoreGState()
    
    context.saveGState()
    context.addPath(rightPath)
    context.clip()
    context.draw(rightCG, in: rightRect)
    context.restoreGState()
    
    context.saveGState()
    context.addPath(rightPath)
    context.setLineWidth(1.2)
    context.setStrokeColor(NSColor.white.withAlphaComponent(0.25).cgColor)
    context.strokePath()
    context.restoreGState()
    
    banner.unlockFocus()
    return banner
}

func saveAsPNG(image: NSImage, targetURL: URL) {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else { return }
    try? png.write(to: targetURL)
    print("✅ 已生成美化展示图: \(targetURL.path)")
}

let darkFavInput = URL(fileURLWithPath: "assets/screenshots/6be15faa-4cb8-4402-9713-89934a322be6.png")
let lightDailyInput = URL(fileURLWithPath: "assets/screenshots/ee02a370-f196-4132-86f1-22ae6b0bbb68.png")

if let beautifiedDark = createStudioCard(inputURL: darkFavInput, isDark: true) {
    saveAsPNG(image: beautifiedDark, targetURL: URL(fileURLWithPath: "assets/screenshots/showcase_dark.png"))
}

if let beautifiedLight = createStudioCard(inputURL: lightDailyInput, isDark: false) {
    saveAsPNG(image: beautifiedLight, targetURL: URL(fileURLWithPath: "assets/screenshots/showcase_light.png"))
}

if let banner = createCombinedBanner(leftURL: lightDailyInput, leftIsDark: false, rightURL: darkFavInput, rightIsDark: true) {
    saveAsPNG(image: banner, targetURL: URL(fileURLWithPath: "assets/screenshots/showcase_banner.png"))
}

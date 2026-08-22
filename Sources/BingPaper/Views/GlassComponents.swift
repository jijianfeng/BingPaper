import SwiftUI
import AppKit

// MARK: - 原生 NSVisualEffectView 毛玻璃包装
public struct VisualEffectBlur: NSViewRepresentable {
    public var material: NSVisualEffectView.Material = .hudWindow
    public var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    public var state: NSVisualEffectView.State = .active
    
    public init(material: NSVisualEffectView.Material = .hudWindow,
                blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
                state: NSVisualEffectView.State = .active) {
        self.material = material
        self.blendingMode = blendingMode
        self.state = state
    }
    
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        return view
    }
    
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

// MARK: - 液态玻璃卡片修饰器（自适应深浅色模式）
public struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    public var cornerRadius: CGFloat = 12
    public var opacity: Double = 0.65
    
    public func body(content: Content) -> some View {
        let isDark = colorScheme == .dark
        content
            .background(
                ZStack {
                    VisualEffectBlur(material: isDark ? .popover : .hudWindow, blendingMode: .withinWindow)
                        .opacity(opacity)
                    
                    (isDark ? Color.white.opacity(0.06) : Color.white.opacity(0.70))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            stops: isDark ? [
                                .init(color: .white.opacity(0.55), location: 0.0),
                                .init(color: .white.opacity(0.15), location: 0.4),
                                .init(color: Color(red: 0.0, green: 0.8, blue: 1.0).opacity(0.25), location: 0.8),
                                .init(color: .white.opacity(0.08), location: 1.0)
                            ] : [
                                .init(color: .white.opacity(0.95), location: 0.0),
                                .init(color: .white.opacity(0.50), location: 0.4),
                                .init(color: Color(red: 0.0, green: 0.6, blue: 1.0).opacity(0.18), location: 0.8),
                                .init(color: .black.opacity(0.06), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: isDark ? Color.black.opacity(0.25) : Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - 极光透光动态背景（深浅色自适应）
public struct AuroraAmbientBackground: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var animate = false
    
    public init() {}
    
    public var body: some View {
        let isDark = colorScheme == .dark
        ZStack {
            // 底层渐变
            LinearGradient(
                colors: isDark ? [
                    Color(red: 0.04, green: 0.07, blue: 0.16),
                    Color(red: 0.02, green: 0.04, blue: 0.10)
                ] : [
                    Color(red: 0.93, green: 0.95, blue: 0.98),
                    Color(red: 0.96, green: 0.97, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 极光透光斑 1 (电光青蓝 / 晨空浅蓝)
            Circle()
                .fill(
                    RadialGradient(
                        colors: isDark ? [
                            Color(red: 0.0, green: 0.85, blue: 1.0).opacity(0.35),
                            Color(red: 0.0, green: 0.4, blue: 0.9).opacity(0.15),
                            Color.clear
                        ] : [
                            Color(red: 0.0, green: 0.65, blue: 1.0).opacity(0.20),
                            Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.10),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 160
                    )
                )
                .frame(width: 260, height: 260)
                .offset(x: animate ? -60 : -40, y: animate ? -80 : -100)
                .blur(radius: 25)
            
            // 极光透光斑 2 (暮光霓虹粉 / 晨曦暖桃)
            Circle()
                .fill(
                    RadialGradient(
                        colors: isDark ? [
                            Color(red: 1.0, green: 0.3, blue: 0.65).opacity(0.28),
                            Color(red: 1.0, green: 0.65, blue: 0.2).opacity(0.18),
                            Color.clear
                        ] : [
                            Color(red: 1.0, green: 0.45, blue: 0.65).opacity(0.16),
                            Color(red: 1.0, green: 0.75, blue: 0.35).opacity(0.10),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 180
                    )
                )
                .frame(width: 280, height: 280)
                .offset(x: animate ? 80 : 60, y: animate ? 90 : 70)
                .blur(radius: 30)
            
            // 顶层全局超轻磨砂玻璃层
            VisualEffectBlur(material: isDark ? .fullScreenUI : .hudWindow, blendingMode: .withinWindow)
                .opacity(isDark ? 0.4 : 0.6)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

public extension View {
    func glassCard(cornerRadius: CGFloat = 12, opacity: Double = 0.65) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}

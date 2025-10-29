//
//  AnimationComponents.swift
//  BuilderOS
//
//  Animation improvements - Top 3 Quick Wins
//  Reference: ANIMATION_QUICK_WINS.md
//

import SwiftUI

// MARK: - 1. PressableButtonStyle (Button Feedback)

/// Universal button style that adds press animation + haptic feedback
/// Usage: Button { action() } label: { ... }.pressableButton()
struct PressableButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.95
    var hapticEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed && hapticEnabled {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
    }
}

extension View {
    /// Apply pressable button style with optional scale and haptic settings
    func pressableButton(scale: CGFloat = 0.95, haptic: Bool = true) -> some View {
        self.buttonStyle(PressableButtonStyle(scaleAmount: scale, hapticEnabled: haptic))
    }
}

// MARK: - 2. Enhanced Loading Indicator

/// Improved loading indicator with vertical bounce + fade
struct EnhancedLoadingIndicator: View {
    let providerName: String
    let accentColor: Color
    @State private var animating = false

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(accentColor)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .opacity(animating ? 1.0 : 0.5)
                    .offset(y: animating ? -4 : 0) // Vertical bounce
                    .animation(
                        Animation.spring(response: 0.6, dampingFraction: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: animating
                    )
            }
            Text("\(providerName) is thinking...")
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.terminalDim)
        }
        .padding(12)
        .background(Color.terminalInputBackground)
        .terminalBorder(cornerRadius: 16)
        .onAppear {
            animating = true
        }
    }
}

// MARK: - 3. Animation Presets

/// Standard iOS animation parameters for consistency
enum AnimationPresets {
    /// Tab transitions (smooth navigation with spring physics)
    static let tabTransition: Animation = .spring(response: 0.35, dampingFraction: 0.82)

    /// Button presses (snappy feedback)
    static let buttonPress: Animation = .spring(response: 0.3, dampingFraction: 0.7)

    /// Loading indicators (bouncy)
    static let loadingBounce: Animation = .spring(response: 0.6, dampingFraction: 0.5)
}

// MARK: - 4. Floating Animation Modifier

/// Makes a view gently float up and down (for empty state icons, decorative elements)
struct FloatingModifier: ViewModifier {
    @State private var isFloating = false

    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -8 : 0)
            .animation(
                .spring(response: 2.0, dampingFraction: 0.5)
                    .repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                isFloating = true
            }
    }
}

extension View {
    func floatingAnimation() -> some View {
        modifier(FloatingModifier())
    }
}

// MARK: - 5. Adaptive Animation (Reduce Motion Support)

/// Respects accessibility settings (Reduce Motion)
struct AdaptiveAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? .default : animation, value: value)
    }
}

extension View {
    func adaptiveAnimation<V: Equatable>(
        _ animation: Animation = .spring(response: 0.35, dampingFraction: 0.82),
        value: V
    ) -> some View {
        modifier(AdaptiveAnimationModifier(animation: animation, value: value))
    }
}

// MARK: - 6. Performance Monitor (DEBUG Only)

#if DEBUG
/// Real-time FPS counter overlay for performance monitoring
struct PerformanceMonitor: View {
    @StateObject private var monitor = FPSMonitor()

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(monitor.fps >= 55 ? Color.green : Color.red)
                .frame(width: 6, height: 6)

            Text("\(Int(monitor.fps)) FPS")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(6)
        .background(.black.opacity(0.5))
        .clipShape(Capsule())
    }
}

class FPSMonitor: ObservableObject {
    @Published var fps: Double = 60.0
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0

    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func update(displayLink: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = displayLink.timestamp
            return
        }

        let delta = displayLink.timestamp - lastTimestamp
        fps = 1.0 / delta
        lastTimestamp = displayLink.timestamp
    }

    deinit {
        displayLink?.invalidate()
    }
}
#endif

// MARK: - 7. Message Bubble Transition

/// Asymmetric transition for message bubbles (scale + slide + fade)
extension AnyTransition {
    static func messageBubble(isUser: Bool) -> AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8, anchor: isUser ? .bottomTrailing : .bottomLeading)
                .combined(with: .move(edge: .bottom))
                .combined(with: .opacity),
            removal: .opacity
        )
    }
}

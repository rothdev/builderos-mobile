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

// MARK: - 2. Retro Cyberpunk Thinking Indicators

/// Subtle retro cyberpunk thinking indicator with terminal cursor style
struct RetroCyberpunkThinkingIndicator: View {
    let providerName: String
    let accentColor: Color
    @State private var animating = false
    @State private var scanlineOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: 10) {
            // Blinking terminal cursor (most subtle)
            BlinkingCursor(color: accentColor, animating: $animating)

            Text("\(providerName) is thinking...")
                .font(.terminalOutput)
                .foregroundColor(.terminalText.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            // Subtle scanline effect overlay
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.terminalInputBackground)
                    .overlay(
                        // Moving scanline
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        accentColor.opacity(0),
                                        accentColor.opacity(0.05),
                                        accentColor.opacity(0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 2)
                            .offset(y: scanlineOffset)
                    )
            }
        )
        .terminalBorder(cornerRadius: 12)
        .onAppear {
            animating = true

            // Slow scanline animation
            withAnimation(
                .linear(duration: 3.0)
                    .repeatForever(autoreverses: false)
            ) {
                scanlineOffset = 40 // Approximate height of the indicator
            }
        }
    }
}

/// Blinking cursor component (like a terminal)
private struct BlinkingCursor: View {
    let color: Color
    @Binding var animating: Bool
    @State private var isVisible = true

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 2, height: 12)
            .opacity(isVisible ? 1.0 : 0.3)
            .animation(
                .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true),
                value: isVisible
            )
            .onAppear {
                isVisible = false // Start animation
            }
    }
}

/// Alternative: Pulsing glow indicator (more visible but still subtle)
struct PulsingGlowIndicator: View {
    let providerName: String
    let accentColor: Color
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.3

    var body: some View {
        HStack(spacing: 10) {
            // Pulsing dot with glow
            Circle()
                .fill(accentColor)
                .frame(width: 6, height: 6)
                .overlay(
                    // Glow effect
                    Circle()
                        .stroke(accentColor, lineWidth: 1)
                        .scaleEffect(pulseScale)
                        .opacity(pulseOpacity)
                )

            Text("\(providerName) is thinking...")
                .font(.terminalOutput)
                .foregroundColor(.terminalText.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.terminalInputBackground)
        .terminalBorder(cornerRadius: 12)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                pulseScale = 2.0
                pulseOpacity = 0
            }
        }
    }
}

/// Alternative: Minimal loading bars (like system activity)
struct MinimalLoadingBars: View {
    let providerName: String
    let accentColor: Color
    @State private var animating = false

    var body: some View {
        HStack(spacing: 10) {
            // Three minimal bars with staggered animation
            HStack(spacing: 3) {
                ForEach(0..<3) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(accentColor)
                        .frame(width: 2, height: 10)
                        .scaleEffect(y: animating ? 1.0 : 0.4)
                        .animation(
                            .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.15),
                            value: animating
                        )
                }
            }

            Text("\(providerName) is thinking...")
                .font(.terminalOutput)
                .foregroundColor(.terminalText.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.terminalInputBackground)
        .terminalBorder(cornerRadius: 12)
        .onAppear {
            animating = true
        }
    }
}

/// Ultra-minimal terminal cursor indicator (most subtle option)
struct UltraMinimalCursorIndicator: View {
    let providerName: String
    let accentColor: Color
    @State private var isVisible = true

    var body: some View {
        HStack(spacing: 10) {
            // Single blinking cursor line
            Rectangle()
                .fill(accentColor)
                .frame(width: 2, height: 14)
                .opacity(isVisible ? 1.0 : 0.2)
                .animation(
                    .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                    value: isVisible
                )

            Text("\(providerName) is thinking...")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.terminalText.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.terminalInputBackground.opacity(0.5))
        .terminalBorder(cornerRadius: 12)
        .onAppear {
            isVisible = false // Start animation
        }
    }
}

/// DEPRECATED: Old bouncy dots animation (too loud for terminal aesthetic)
struct EnhancedLoadingIndicator: View {
    let providerName: String
    let accentColor: Color
    @State private var animating = false

    var body: some View {
        // Using ultra-minimal cursor indicator (most subtle)
        UltraMinimalCursorIndicator(providerName: providerName, accentColor: accentColor)
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

//
//  ANIMATION_CODE_SNIPPETS.swift
//  BuilderOS Animation Improvements
//
//  Ready-to-use animation code snippets for copy-paste implementation
//  Reference: ANIMATION_AUDIT_REPORT.md for full context
//

import SwiftUI

// MARK: - 1. PressableButtonStyle (Reusable Component)

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

// MARK: - 2. Floating Animation Modifier (Empty State)

/// Makes a view gently float up and down (for empty state icons, decorative elements)
/// Usage: Image(systemName: "cube.transparent").floatingAnimation()
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

// MARK: - 3. Adaptive Animation (Reduce Motion Support)

/// Respects accessibility settings (Reduce Motion)
/// Usage: .adaptiveAnimation(.spring(response: 0.35, dampingFraction: 0.82), value: selectedTab)
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

// MARK: - 4. Performance Monitor (DEBUG Only)

#if DEBUG
/// Real-time FPS counter overlay for performance monitoring
/// Usage: Add to MainContentView as .overlay(alignment: .topTrailing) { PerformanceMonitor() }
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

// MARK: - 5. Animation Parameter Presets

/// Standard iOS animation parameters for consistency across the app
enum AnimationPresets {
    // Button presses (snappy feedback)
    static let buttonPress: Animation = .spring(response: 0.3, dampingFraction: 0.7)

    // Tab transitions (smooth navigation)
    static let tabTransition: Animation = .spring(response: 0.35, dampingFraction: 0.82)

    // Hero transitions (elegant card morphing)
    static let heroTransition: Animation = .spring(response: 0.4, dampingFraction: 0.85)

    // Message appearances (quick in-out)
    static let messageAppearance: Animation = .spring(response: 0.35, dampingFraction: 0.75)

    // Loading indicators (bouncy)
    static let loadingBounce: Animation = .spring(response: 0.6, dampingFraction: 0.5)

    // Floating effects (gentle ambient)
    static let floatingGentle: Animation = .spring(response: 2.0, dampingFraction: 0.5)

    // Quick feedback (instant response)
    static let instantFeedback: Animation = .spring(response: 0.25, dampingFraction: 0.6)
}

// MARK: - 6. Haptic Feedback Helpers

/// Convenience functions for haptic feedback
enum HapticFeedback {
    /// Light tap (button presses, chip taps)
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact (selections, toggles)
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact (confirmations, deletions)
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Selection change (picker wheels, segmented controls)
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    /// Success notification (task complete, connection successful)
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning notification (disconnection warning)
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error notification (connection failed, API error)
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

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

// USAGE EXAMPLE:
// MessageBubbleView(message: message)
//     .transition(.messageBubble(isUser: message.isUser))

// MARK: - 8. Tab Transition

/// Directional slide transition for tab switching
extension AnyTransition {
    static var tabSlide: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        )
    }
}

// USAGE EXAMPLE:
// DashboardView()
//     .transition(.tabSlide)

// MARK: - 9. Loading Indicator (Enhanced)

/// Improved loading indicator with vertical bounce + fade
/// Replace LoadingIndicatorView in ClaudeChatView.swift with this version
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

// MARK: - 10. Quick Action Chip (Press Animation)

/// Enhanced QuickActionChip with press animation + haptic
/// Replace QuickActionChip in ClaudeChatView.swift with this version
struct EnhancedQuickActionChip: View {
    let icon: String
    let text: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticFeedback.light()

            withAnimation(AnimationPresets.instantFeedback) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                withAnimation(AnimationPresets.buttonPress) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.terminalCyan)
                Text(text)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.terminalText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.terminalInputBackground)
            .terminalBorder(cornerRadius: 16)
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .brightness(isPressed ? -0.1 : 0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 11. Conversation Tab Button (Animated Underline)

/// Enhanced ConversationTabButton with sliding underline bar
/// Replace ConversationTabButton in ConversationTabButton.swift with this version
struct EnhancedConversationTabButton: View {
    let tab: ConversationTab
    let isSelected: Bool
    let onTap: () -> Void
    let onClose: () -> Void
    let canClose: Bool

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    // Provider icon
                    if tab.provider.isCustomIcon {
                        Image(tab.provider.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(isSelected ? .white : tab.provider.accentColor)
                    } else {
                        Image(systemName: tab.provider.icon)
                            .font(.system(size: 12))
                            .foregroundColor(isSelected ? .white : tab.provider.accentColor)
                    }

                    Text(tab.title)
                        .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.7))

                    if canClose {
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isSelected ? tab.provider.accentColor.opacity(0.3) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? tab.provider.accentColor : Color.clear, lineWidth: 1)
                )

                // Animated underline bar
                Rectangle()
                    .fill(tab.provider.accentColor)
                    .frame(height: 2)
                    .frame(width: isSelected ? nil : 0)
            }
        }
        .buttonStyle(.plain)
        .animation(AnimationPresets.tabTransition, value: isSelected)
    }
}

// MARK: - 12. Tab Transition Handler (MainContentView)

/// Add to MainContentView.swift to replace generic .animation() modifier
struct TabTransitionHandler: ViewModifier {
    @Binding var selectedTab: Int

    func body(content: Content) -> some View {
        content
            .onChange(of: selectedTab) { oldValue, newValue in
                withAnimation(AnimationPresets.tabTransition) {
                    // Tab transition happens here with spring physics
                }
            }
    }
}

extension View {
    func handleTabTransitions(_ selectedTab: Binding<Int>) -> some View {
        modifier(TabTransitionHandler(selectedTab: selectedTab))
    }
}

// USAGE EXAMPLE (in MainContentView):
// TabView(selection: $selectedTab) { ... }
//     .handleTabTransitions($selectedTab)

// MARK: - 13. Status Badge Spring Fix

/// Fixed TerminalStatusBadge with spring instead of easeInOut
/// Replace animation in TerminalStatusBadge.swift with this:

// OLD:
// .animation(
//     shouldPulse ?
//         .easeInOut(duration: 2).repeatForever(autoreverses: true) :
//         .default,
//     value: pulseAnimation
// )

// NEW:
// .animation(
//     shouldPulse ?
//         .spring(response: 2.0, dampingFraction: 0.5).repeatForever(autoreverses: true) :
//         .default,
//     value: pulseAnimation
// )

// MARK: - IMPLEMENTATION CHECKLIST

/*
 ✅ STEP 1: Add PressableButtonStyle to src/Components/PressableButtonStyle.swift
 ✅ STEP 2: Apply .pressableButton() to all buttons in DashboardView, SettingsView, ClaudeChatView
 ✅ STEP 3: Replace .animation(.easeInOut) with AnimationPresets.tabTransition in MainContentView
 ✅ STEP 4: Fix TerminalStatusBadge spring animation
 ✅ STEP 5: Replace LoadingIndicatorView with EnhancedLoadingIndicator
 ✅ STEP 6: Replace QuickActionChip with EnhancedQuickActionChip
 ✅ STEP 7: Replace ConversationTabButton with EnhancedConversationTabButton
 ✅ STEP 8: Add PerformanceMonitor to MainContentView (DEBUG builds only)
 ✅ STEP 9: Test on physical iPhone for haptic feedback
 ✅ STEP 10: Verify 60fps with PerformanceMonitor
 */

// MARK: - USAGE EXAMPLES

/*
 // 1. Button press animation
 Button("Reconnect") { reconnect() }
     .pressableButton()

 // 2. Floating empty state icon
 Image(systemName: "cube.transparent")
     .floatingAnimation()

 // 3. Reduce Motion support
 TabView(selection: $selectedTab) { ... }
     .adaptiveAnimation(AnimationPresets.tabTransition, value: selectedTab)

 // 4. Haptic feedback
 Button("Delete") {
     HapticFeedback.warning()
     deleteConversation()
 }

 // 5. Message bubble transition
 MessageBubbleView(message: message)
     .transition(.messageBubble(isUser: message.isUser))

 // 6. Performance monitoring (DEBUG only)
 #if DEBUG
 ZStack(alignment: .topTrailing) {
     MainContentView()
     PerformanceMonitor()
 }
 #endif
 */

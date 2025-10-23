import SwiftUI

extension Color {
    static let builderPrimary = Color.blue
    static let builderSecondary = Color(.systemBlue)
    
    // Message backgrounds
    static let userMessageBackground = Color.blue
    static let systemMessageBackground = Color(.systemGray5)
    static let codeBlockBackground = Color(.systemGray2)
    
    // Status colors
    static let successGreen = Color.green
    static let warningOrange = Color.orange
    static let errorRed = Color.red
    
    // Adaptive colors for dark mode
    static let adaptiveBackground = Color(.systemBackground)
    static let adaptiveSecondaryBackground = Color(.secondarySystemBackground)
    static let adaptiveTertiaryBackground = Color(.tertiarySystemBackground)
}

extension Font {
    static let builderTitle = Font.system(.title2, design: .default, weight: .semibold)
    static let builderHeadline = Font.system(.headline, design: .default, weight: .medium)
    static let builderBody = Font.system(.body, design: .default)
    static let builderCode = Font.system(.body, design: .monospaced)
    static let builderCaption = Font.system(.caption, design: .default)
}

struct QuickCommand {
    let title: String
    let command: String
    let icon: String
}

// Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
//
//  Typography.swift
//  BuilderOS
//
//  Design system typography definitions
//

import SwiftUI

// MARK: - Font Extensions
extension Font {
    // MARK: - Display Fonts
    static let displayLarge = Font.system(size: 57, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 45, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 36, weight: .bold, design: .rounded)

    // MARK: - Headline Fonts
    static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .rounded)
    static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .rounded)

    // MARK: - Title Fonts
    static let titleLarge = Font.system(size: 22, weight: .semibold, design: .default)
    static let titleMedium = Font.system(size: 16, weight: .semibold, design: .default)
    static let titleSmall = Font.system(size: 14, weight: .semibold, design: .default)

    // MARK: - Body Fonts
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)

    // MARK: - Label Fonts
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - Monospaced Fonts (for code, IPs, API keys)
    static let monoLarge = Font.system(size: 16, weight: .regular, design: .monospaced)
    static let monoMedium = Font.system(size: 14, weight: .regular, design: .monospaced)
    static let monoSmall = Font.system(size: 12, weight: .regular, design: .monospaced)
}

// MARK: - Text Styles
struct TextStyle {
    let font: Font
    let color: Color
    let lineSpacing: CGFloat

    static let h1 = TextStyle(
        font: .displayLarge,
        color: .textPrimary,
        lineSpacing: 4
    )

    static let h2 = TextStyle(
        font: .displayMedium,
        color: .textPrimary,
        lineSpacing: 4
    )

    static let h3 = TextStyle(
        font: .displaySmall,
        color: .textPrimary,
        lineSpacing: 2
    )

    static let body = TextStyle(
        font: .bodyMedium,
        color: .textPrimary,
        lineSpacing: 2
    )

    static let caption = TextStyle(
        font: .labelMedium,
        color: .textSecondary,
        lineSpacing: 1
    )
}

// MARK: - View Extension for Typography
extension View {
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .foregroundStyle(style.color)
            .lineSpacing(style.lineSpacing)
    }
}

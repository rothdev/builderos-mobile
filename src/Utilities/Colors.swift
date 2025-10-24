//
//  Colors.swift
//  BuilderOS
//
//  Design system color definitions
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors
    static let brandPrimary = Color("BrandPrimary", bundle: nil)
    static let brandSecondary = Color("BrandSecondary", bundle: nil)
    static let brandAccent = Color("BrandAccent", bundle: nil)

    // MARK: - Status Colors
    static let statusSuccess = Color.green
    static let statusWarning = Color.orange
    static let statusError = Color.red
    static let statusInfo = Color.blue

    // MARK: - Semantic Colors (iOS system colors that adapt to Light/Dark mode)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)

    // MARK: - Tailscale Brand Colors
    static let tailscalePrimary = Color(red: 0.18, green: 0.20, blue: 0.24) // #2E3338
    static let tailscaleAccent = Color(red: 0.35, green: 0.56, blue: 1.00) // #598FFF

    // MARK: - Custom Gradient
    static let primaryGradient = LinearGradient(
        colors: [.blue, .blue.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [.blue, .purple],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Terminal Colors
    // Moved to TerminalColors.swift for better organization and design system alignment
}

// MARK: - Color Extensions
extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "#FF5733" or "FF5733")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

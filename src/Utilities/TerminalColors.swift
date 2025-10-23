//
//  TerminalColors.swift
//  BuilderOS
//
//  Terminal color definitions matching design specs
//  Reference: /docs/design/TERMINAL_CHAT_SPECS.md
//

import SwiftUI

/// Terminal color extensions matching the design system
/// Based on TERMINAL_CHAT_SPECS.md color specifications
extension Color {
    // MARK: - Primary Terminal Colors

    /// Cyan (#60efff) - Used for commands, headers, user input
    static let terminalCyan = Color(red: 96/255, green: 239/255, blue: 255/255)

    /// Green (#00ff88) - Used for prompts, success messages, connection status
    static let terminalGreen = Color(red: 0/255, green: 255/255, blue: 136/255)

    /// Pink (#ff6b9d) - Used for gradients, warnings, accent highlights
    static let terminalPink = Color(red: 255/255, green: 107/255, blue: 157/255)

    /// Red (#ff3366) - Used for errors, gradient stops
    static let terminalRed = Color(red: 255/255, green: 51/255, blue: 102/255)

    // MARK: - Background Colors

    /// Dark Background (#0a0e1a) - Main screen background
    static let terminalDark = Color(red: 10/255, green: 14/255, blue: 26/255)

    /// Header/Input Background (rgba(10, 14, 26, 0.9)) - Semi-transparent for blur effect
    static let terminalDarkTransparent = Color(red: 10/255, green: 14/255, blue: 26/255).opacity(0.9)

    /// Input Field Background (rgba(26, 35, 50, 0.6)) - Darker with transparency
    static let terminalInputBackground = Color(red: 26/255, green: 35/255, blue: 50/255).opacity(0.6)

    // MARK: - Text Colors

    /// Primary Text (#b8c5d6) - Default output text
    static let terminalText = Color(red: 184/255, green: 197/255, blue: 214/255)

    /// Dim Text (#4a6080) - Comments, timestamps, secondary info
    static let terminalDim = Color(red: 74/255, green: 96/255, blue: 128/255)

    /// Code Text (#7a9bc0) - Status labels, code blocks
    static let terminalCode = Color(red: 122/255, green: 155/255, blue: 192/255)

    // MARK: - Border Colors

    /// Header Border (#1a2332) - 2px solid
    static let terminalHeaderBorder = Color(red: 26/255, green: 35/255, blue: 50/255)

    /// Input Border (#2a3f5f) - 1px solid
    static let terminalInputBorder = Color(red: 42/255, green: 63/255, blue: 95/255)

    // MARK: - Gradients

    /// Primary gradient for buttons and headers
    /// From cyan (#60efff) → pink (#ff6b9d) → red (#ff3366)
    static var terminalGradient: LinearGradient {
        LinearGradient(
            colors: [.terminalCyan, .terminalPink, .terminalRed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Header title gradient (horizontal variant)
    static var terminalHeaderGradient: LinearGradient {
        LinearGradient(
            colors: [.terminalCyan, .terminalPink, .terminalRed],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Font Extensions

/// Terminal font definitions using JetBrains Mono
/// Reference: TERMINAL_CHAT_SPECS.md typography section
extension Font {
    /// Header title font (15px, bold)
    static let terminalHeader = Font.custom("JetBrainsMono-Bold", size: 15)

    /// Command text font (13px, semibold)
    static let terminalCommand = Font.custom("JetBrainsMono-SemiBold", size: 13)

    /// Output text font (13px, regular)
    static let terminalOutput = Font.custom("JetBrainsMono-Regular", size: 13)

    /// Timestamp font (11px, regular)
    static let terminalTime = Font.custom("JetBrainsMono-Regular", size: 11)

    /// Status font (11px, medium)
    static let terminalStatus = Font.custom("JetBrainsMono-Medium", size: 11)

    /// Input field font (13px, regular)
    static let terminalInput = Font.custom("JetBrainsMono-Regular", size: 13)
}

//
//  ANSIParser.swift
//  BuilderOS
//
//  Enhanced ANSI escape sequence parser for terminal output
//  Supports 256-color mode, bold/italic/underline, cursor movement
//

import Foundation
import SwiftUI

struct ANSIParser {
    /// Parse ANSI escape sequences and convert to attributed string
    static func parse(_ input: String, maxLines: Int = 1000) -> AttributedString {
        var result = AttributedString()
        var currentColor: Color = Color(red: 0.0, green: 1.0, blue: 0.533) // Bright green default
        var currentBgColor: Color? = nil
        var isBold = false
        var isItalic = false
        var isUnderline = false
        var buffer = ""
        var escapeSequence = ""
        var inEscape = false
        var lineCount = 0

        for char in input {
            if char == "\u{1B}" {  // ESC character
                // Add any buffered text before escape sequence
                if !buffer.isEmpty {
                    result.append(createSegment(buffer, color: currentColor, bgColor: currentBgColor, bold: isBold, italic: isItalic, underline: isUnderline))
                    buffer = ""
                }
                inEscape = true
                escapeSequence = ""
            } else if inEscape {
                escapeSequence.append(char)

                // Check if escape sequence is complete
                if char.isLetter || (char == "m" && escapeSequence.contains("[")) || char == "~" {
                    // Process escape sequence
                    let state = processEscapeSequence(
                        escapeSequence,
                        currentColor: currentColor,
                        currentBgColor: currentBgColor,
                        isBold: isBold,
                        isItalic: isItalic,
                        isUnderline: isUnderline
                    )
                    currentColor = state.color
                    currentBgColor = state.bgColor
                    isBold = state.bold
                    isItalic = state.italic
                    isUnderline = state.underline

                    // Handle cursor movement and clear commands
                    if escapeSequence.contains("J") || escapeSequence.contains("K") {
                        // Clear screen/line commands - just continue
                    }

                    inEscape = false
                    escapeSequence = ""
                }
            } else {
                buffer.append(char)

                // Track line count for scrollback limit
                if char == "\n" {
                    lineCount += 1
                }
            }
        }

        // Add remaining buffer
        if !buffer.isEmpty {
            result.append(createSegment(buffer, color: currentColor, bgColor: currentBgColor, bold: isBold, italic: isItalic, underline: isUnderline))
        }

        // Trim to max lines if needed (keep most recent)
        let lines = result.characters.split(separator: "\n")
        if lines.count > maxLines {
            let startIndex = lines.count - maxLines
            let trimmedLines = lines[startIndex...]
            result = AttributedString(trimmedLines.joined(separator: "\n"))
        }

        return result
    }

    private static func createSegment(
        _ text: String,
        color: Color,
        bgColor: Color?,
        bold: Bool,
        italic: Bool,
        underline: Bool
    ) -> AttributedString {
        var segment = AttributedString(text)
        segment.foregroundColor = color

        if let bg = bgColor {
            segment.backgroundColor = bg
        }

        var font = Font.system(size: 14).monospaced()
        if bold && italic {
            font = Font.system(size: 14, weight: .bold, design: .monospaced).italic()
        } else if bold {
            font = Font.system(size: 14, weight: .bold).monospaced()
        } else if italic {
            font = Font.system(size: 14).monospaced().italic()
        }
        segment.font = font

        if underline {
            segment.underlineStyle = .single
        }

        return segment
    }

    private static func processEscapeSequence(
        _ sequence: String,
        currentColor: Color,
        currentBgColor: Color?,
        isBold: Bool,
        isItalic: Bool,
        isUnderline: Bool
    ) -> (color: Color, bgColor: Color?, bold: Bool, italic: Bool, underline: Bool) {

        // Remove [ and m
        let codeString = sequence
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "m", with: "")
            .replacingOccurrences(of: "~", with: "")

        let codes = codeString.split(separator: ";").compactMap { Int($0) }

        var newColor = currentColor
        var newBgColor = currentBgColor
        var newBold = isBold
        var newItalic = isItalic
        var newUnderline = isUnderline

        var i = 0
        while i < codes.count {
            let code = codes[i]

            switch code {
            case 0:  // Reset all
                newColor = Color(red: 0.0, green: 1.0, blue: 0.533) // Bright green
                newBgColor = nil
                newBold = false
                newItalic = false
                newUnderline = false

            case 1:  // Bold
                newBold = true
            case 2:  // Dim (treat as normal)
                newBold = false
            case 3:  // Italic
                newItalic = true
            case 4:  // Underline
                newUnderline = true
            case 22: // Normal intensity
                newBold = false
            case 23: // Not italic
                newItalic = false
            case 24: // Not underline
                newUnderline = false

            // Standard colors (30-37)
            case 30: newColor = .black
            case 31: newColor = .red
            case 32: newColor = Color(red: 0.0, green: 1.0, blue: 0.533) // Bright green
            case 33: newColor = .yellow
            case 34: newColor = .blue
            case 35: newColor = .purple
            case 36: newColor = Color(red: 0.376, green: 0.937, blue: 1.0) // Cyan
            case 37: newColor = .white

            // Background colors (40-47)
            case 40: newBgColor = .black
            case 41: newBgColor = .red
            case 42: newBgColor = .green
            case 43: newBgColor = .yellow
            case 44: newBgColor = .blue
            case 45: newBgColor = .purple
            case 46: newBgColor = .cyan
            case 47: newBgColor = .white
            case 49: newBgColor = nil // Default background

            // Bright colors (90-97)
            case 90: newColor = .gray
            case 91: newColor = Color(red: 1.0, green: 0.42, blue: 0.616) // Bright red
            case 92: newColor = Color(red: 0.0, green: 1.0, blue: 0.533) // Bright green
            case 93: newColor = .yellow
            case 94: newColor = Color(red: 0.376, green: 0.65, blue: 1.0) // Bright blue
            case 95: newColor = Color(red: 1.0, green: 0.42, blue: 1.0) // Bright magenta
            case 96: newColor = Color(red: 0.376, green: 0.937, blue: 1.0) // Bright cyan
            case 97: newColor = .white

            // Bright background colors (100-107)
            case 100: newBgColor = .gray
            case 101: newBgColor = Color(red: 1.0, green: 0.42, blue: 0.616)
            case 102: newBgColor = Color(red: 0.0, green: 1.0, blue: 0.533)
            case 103: newBgColor = .yellow
            case 104: newBgColor = .blue
            case 105: newBgColor = .purple
            case 106: newBgColor = .cyan
            case 107: newBgColor = .white

            // 256-color mode (38;5;N for foreground, 48;5;N for background)
            case 38:
                if i + 2 < codes.count && codes[i + 1] == 5 {
                    let colorIndex = codes[i + 2]
                    newColor = color256(colorIndex)
                    i += 2 // Skip next 2 codes
                }
            case 48:
                if i + 2 < codes.count && codes[i + 1] == 5 {
                    let colorIndex = codes[i + 2]
                    newBgColor = color256(colorIndex)
                    i += 2 // Skip next 2 codes
                }

            default:
                break
            }

            i += 1
        }

        return (newColor, newBgColor, newBold, newItalic, newUnderline)
    }

    /// Convert 256-color index to SwiftUI Color
    private static func color256(_ index: Int) -> Color {
        switch index {
        // Standard colors (0-15) - matches basic 16 colors
        case 0: return .black
        case 1: return .red
        case 2: return .green
        case 3: return .yellow
        case 4: return .blue
        case 5: return .purple
        case 6: return .cyan
        case 7: return .white
        case 8: return .gray
        case 9: return Color(red: 1.0, green: 0.42, blue: 0.616)
        case 10: return Color(red: 0.0, green: 1.0, blue: 0.533)
        case 11: return .yellow
        case 12: return .blue
        case 13: return .purple
        case 14: return Color(red: 0.376, green: 0.937, blue: 1.0)
        case 15: return .white

        // 216 colors (16-231) - 6x6x6 RGB cube
        case 16..<232:
            let adjusted = index - 16
            let r = Double((adjusted / 36) % 6) / 5.0
            let g = Double((adjusted / 6) % 6) / 5.0
            let b = Double(adjusted % 6) / 5.0
            return Color(red: r, green: g, blue: b)

        // Grayscale (232-255)
        case 232..<256:
            let gray = Double(index - 232) / 23.0
            return Color(red: gray, green: gray, blue: gray)

        default:
            return .white
        }
    }

    /// Strip ANSI codes (for plain text extraction)
    static func stripANSI(_ input: String) -> String {
        let pattern = "\\u{1B}\\[[0-9;]*[a-zA-Z~]"
        return input.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }
}

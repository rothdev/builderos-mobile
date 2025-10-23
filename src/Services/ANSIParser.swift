//
//  ANSIParser.swift
//  BuilderOS
//
//  ANSI escape sequence parser for terminal output
//  Converts ANSI codes to SwiftUI AttributedString
//

import Foundation
import SwiftUI

struct ANSIParser {
    /// Parse ANSI escape sequences and convert to attributed string
    static func parse(_ input: String) -> AttributedString {
        var result = AttributedString()
        var currentColor: Color = .green // Default terminal color (cyan/green)
        var isBold = false
        var buffer = ""
        var escapeSequence = ""
        var inEscape = false

        for char in input {
            if char == "\u{1B}" {  // ESC character
                // Add any buffered text before escape sequence
                if !buffer.isEmpty {
                    var segment = AttributedString(buffer)
                    segment.foregroundColor = currentColor
                    if isBold {
                        segment.font = .system(size: 14, weight: .bold).monospaced()
                    } else {
                        segment.font = .system(size: 14).monospaced()
                    }
                    result.append(segment)
                    buffer = ""
                }
                inEscape = true
                escapeSequence = ""
            } else if inEscape {
                escapeSequence.append(char)

                // Check if escape sequence is complete
                if char.isLetter || (char == "m" && escapeSequence.contains("[")) {
                    // Process escape sequence
                    (currentColor, isBold) = processEscapeSequence(escapeSequence, currentColor: currentColor, isBold: isBold)
                    inEscape = false
                    escapeSequence = ""
                }
            } else {
                buffer.append(char)
            }
        }

        // Add remaining buffer
        if !buffer.isEmpty {
            var segment = AttributedString(buffer)
            segment.foregroundColor = currentColor
            if isBold {
                segment.font = .system(size: 14, weight: .bold).monospaced()
            } else {
                segment.font = .system(size: 14).monospaced()
            }
            result.append(segment)
        }

        return result
    }

    private static func processEscapeSequence(_ sequence: String, currentColor: Color, isBold: Bool) -> (Color, Bool) {
        // Parse ANSI color codes
        // Format: [XXm where XX is the code

        // Remove [ and m
        let codeString = sequence
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "m", with: "")

        let codes = codeString.split(separator: ";").compactMap { Int($0) }

        var newColor = currentColor
        var newBold = isBold

        for code in codes {
            switch code {
            case 0:  // Reset
                newColor = .green
                newBold = false
            case 1:  // Bold
                newBold = true
            case 22: // Normal intensity
                newBold = false
            case 30: newColor = .black
            case 31: newColor = .red
            case 32: newColor = .green
            case 33: newColor = .yellow
            case 34: newColor = .blue
            case 35: newColor = .purple
            case 36: newColor = Color(red: 0.376, green: 0.937, blue: 1.0) // Cyan - terminal theme
            case 37: newColor = .white
            case 90: newColor = .gray
            case 91: newColor = Color(red: 1.0, green: 0.42, blue: 0.616) // Bright red - terminal theme
            case 92: newColor = Color(red: 0.0, green: 1.0, blue: 0.533) // Bright green - terminal theme
            case 93: newColor = .yellow
            case 94: newColor = .blue
            case 95: newColor = .purple
            case 96: newColor = Color(red: 0.376, green: 0.937, blue: 1.0) // Bright cyan
            case 97: newColor = .white
            default:
                break
            }
        }

        return (newColor, newBold)
    }

    /// Strip ANSI codes (for plain text extraction)
    static func stripANSI(_ input: String) -> String {
        let pattern = "\\u{1B}\\[[0-9;]*[a-zA-Z]"
        return input.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }
}

//
//  TerminalKey.swift
//  BuilderOS
//
//  Terminal special keys (Tab, Esc, Arrows, Ctrl combinations)
//

import Foundation

enum TerminalKey: String, CaseIterable, Identifiable {
    case tab = "Tab"
    case escape = "Esc"
    case up = "↑"
    case down = "↓"
    case left = "←"
    case right = "→"
    case ctrlC = "^C"
    case ctrlD = "^D"
    case ctrlZ = "^Z"

    var id: String { rawValue }

    /// Byte sequence to send to terminal
    var bytes: [UInt8] {
        switch self {
        case .tab:
            return [0x09]  // Tab
        case .escape:
            return [0x1B]  // ESC
        case .up:
            return [0x1B, 0x5B, 0x41]  // ESC[A
        case .down:
            return [0x1B, 0x5B, 0x42]  // ESC[B
        case .left:
            return [0x1B, 0x5B, 0x44]  // ESC[D
        case .right:
            return [0x1B, 0x5B, 0x43]  // ESC[C
        case .ctrlC:
            return [0x03]  // ^C
        case .ctrlD:
            return [0x04]  // ^D
        case .ctrlZ:
            return [0x1A]  // ^Z
        }
    }
}

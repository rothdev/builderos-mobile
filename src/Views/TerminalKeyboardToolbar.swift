//
//  TerminalKeyboardToolbar.swift
//  BuilderOS
//
//  Accessory keyboard toolbar for terminal special keys
//

import SwiftUI
import Inject

struct TerminalKeyboardToolbar: View {
    let onKeyPress: (TerminalKey) -> Void
    @ObserveInjection var inject

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TerminalKey.allCases) { key in
                    Button(action: { onKeyPress(key) }) {
                        Text(key.rawValue)
                            .font(.system(size: 14, weight: .medium).monospaced())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.15))
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 44)
        .background(Color.black.opacity(0.3))
        .enableInjection()
    }
}

#Preview {
    TerminalKeyboardToolbar { key in
        print("Key pressed: \(key.rawValue)")
    }
    .background(Color(red: 0.04, green: 0.055, blue: 0.102))
}

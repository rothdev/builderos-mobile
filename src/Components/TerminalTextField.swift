//
//  TerminalTextField.swift
//  BuilderOS
//
//  Terminal-styled text input with cyan text and dark background
//  Matches TerminalChatView input field design
//

import SwiftUI

struct TerminalTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .font(.system(size: 15, weight: .regular, design: .monospaced))
        .foregroundColor(.terminalCyan)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.terminalInputBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.terminalInputBorder, lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        TerminalTextField(placeholder: "https://tunnel.trycloudflare.com", text: .constant(""))

        TerminalTextField(placeholder: "Enter API Key", text: .constant(""), isSecure: true)

        TerminalTextField(placeholder: "Command", text: .constant("status"))
    }
    .padding()
    .background(Color.terminalDark)
}

//
//  KeyboardDiagnosticView.swift
//  BuilderOS
//
//  Diagnostic view to test if keyboard works at all
//

import SwiftUI

struct KeyboardDiagnosticView: View {
    @State private var testInput = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 40) {
            Text("KEYBOARD DIAGNOSTIC TEST")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text("If you can type here, keyboard works:")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.gray)

            TextField("Tap here and type...", text: $testInput)
                .font(.system(size: 18, design: .monospaced))
                .foregroundColor(.cyan)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
                .focused($isFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 40)

            Text("Input: \(testInput)")
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.green)

            Button("Focus TextField") {
                isFocused = true
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.04, green: 0.055, blue: 0.102))
        .onAppear {
            // Auto-focus after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isFocused = true
            }
        }
    }
}

#Preview {
    KeyboardDiagnosticView()
}

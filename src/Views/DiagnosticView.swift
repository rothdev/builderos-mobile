//
//  DiagnosticView.swift
//  BuilderOS
//
//  Emergency diagnostic view to test basic SwiftUI rendering
//

import SwiftUI
import Inject

struct DiagnosticView: View {
    @ObserveInjection var inject

    var body: some View {
        let _ = print("🟢 DIAG: DiagnosticView body rendering")

        return ZStack {
            // Bright background to ensure visibility
            Color.green
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("DIAGNOSTIC VIEW")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.red)

                Text("If you can see this,")
                    .font(.system(size: 20))
                    .foregroundColor(.black)

                Text("SwiftUI rendering is working")
                    .font(.system(size: 20))
                    .foregroundColor(.black)

                Divider()
                    .background(Color.black)
                    .frame(height: 2)

                Text("Time: \(Date().formatted())")
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundColor(.blue)

                Button("Tap Me") {
                    print("🟢 DIAG: Button tapped!")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .enableInjection()
    }
}

#Preview {
    DiagnosticView()
}

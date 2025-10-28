//
//  AttachmentButton.swift
//  BuilderOS
//
//  Button for attaching files/photos to chat messages
//

import SwiftUI

struct AttachmentButton: View {
    let onPhotoTap: () -> Void
    let onDocumentTap: () -> Void
    @State private var showingActionSheet = false

    var body: some View {
        Button(action: {
            showingActionSheet = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.terminalCyan)
        }
        .confirmationDialog("Add Attachment", isPresented: $showingActionSheet) {
            Button("Photo or Video") {
                onPhotoTap()
            }

            Button("Document") {
                onDocumentTap()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Choose the type of file to attach")
        }
    }
}

// MARK: - Preview

#Preview {
    AttachmentButton(
        onPhotoTap: { print("Photo tapped") },
        onDocumentTap: { print("Document tapped") }
    )
    .padding()
    .background(Color.terminalDark)
}

//
//  MessageAttachmentRow.swift
//  BuilderOS
//
//  Displays an uploaded attachment inside a chat bubble
//

import SwiftUI

struct MessageAttachmentRow: View {
    let attachment: ChatAttachment
    let isUser: Bool

    private var backgroundColor: Color {
        isUser
            ? Color.terminalInputBackground.opacity(0.7)
            : Color.terminalInputBackground
    }

    private var borderColor: Color {
        isUser ? .terminalCyan.opacity(0.6) : .terminalInputBorder
    }

    private var attachmentLine: String {
        "\(attachment.type.displayName) • \(attachment.formattedSize)"
    }

    private var attachmentURL: URL? {
        guard let remote = attachment.remoteURL else { return nil }
        return URL(string: remote)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: attachment.type.icon)
                .font(.system(size: 14))
                .foregroundColor(.terminalCyan)
                .frame(width: 28, height: 28)
                .background(Color.terminalDark.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.filename)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.terminalText)
                    .lineLimit(1)

                Text(attachmentLine)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.terminalDim)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if let url = attachmentURL {
                Link(destination: url) {
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.terminalCyan)
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(backgroundColor)
        .terminalBorder(cornerRadius: 12, color: borderColor)
    }
}

#Preview {
    MessageAttachmentRow(attachment: .mockDocument, isUser: true)
        .padding()
        .background(Color.terminalDark)
}

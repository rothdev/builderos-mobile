//
//  FilePreviewChip.swift
//  BuilderOS
//
//  Preview chip for selected file attachments
//

import SwiftUI

struct FilePreviewChip: View {
    let attachment: ChatAttachment
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // Thumbnail or icon
            if let thumbnailData = attachment.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: attachment.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(.terminalCyan)
                    .frame(width: 40, height: 40)
                    .background(Color.terminalInputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // File info
            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.filename)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.terminalText)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(attachment.type.displayName)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.terminalDim)

                    Text("•")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.terminalDim)

                    Text(attachment.formattedSize)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.terminalDim)
                }
            }

            Spacer()

            // Upload state indicator
            uploadStateView

            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.terminalDim)
            }
        }
        .padding(8)
        .background(Color.terminalInputBackground)
        .terminalBorder(cornerRadius: 12)
    }

    @ViewBuilder
    private var uploadStateView: some View {
        switch attachment.uploadState {
        case .pending:
            Image(systemName: "clock.fill")
                .font(.system(size: 12))
                .foregroundColor(.terminalCyan)

        case .uploading(let progress):
            ZStack {
                Circle()
                    .stroke(Color.terminalDim.opacity(0.3), lineWidth: 2)
                    .frame(width: 20, height: 20)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.terminalCyan, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(progress * 100))")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.terminalText)
            }

        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.green)

        case .failed(let error):
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundColor(.red)
                .help(error)
        }
    }
}

// MARK: - Preview

#Preview("Pending") {
    FilePreviewChip(
        attachment: .mockImage,
        onRemove: { print("Remove") }
    )
    .padding()
    .background(Color.terminalDark)
}

#Preview("Uploading") {
    FilePreviewChip(
        attachment: .mockVideo,
        onRemove: { print("Remove") }
    )
    .padding()
    .background(Color.terminalDark)
}

#Preview("Completed") {
    FilePreviewChip(
        attachment: .mockDocument,
        onRemove: { print("Remove") }
    )
    .padding()
    .background(Color.terminalDark)
}

#Preview("Failed") {
    FilePreviewChip(
        attachment: .mockFailed,
        onRemove: { print("Remove") }
    )
    .padding()
    .background(Color.terminalDark)
}

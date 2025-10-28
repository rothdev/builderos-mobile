import SwiftUI

struct FileAttachmentChip: View {
    let attachment: FileAttachment
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            // File type icon
            Image(systemName: attachment.type.icon)
                .font(.caption)
                .foregroundColor(attachment.type.color)
                .frame(width: 24, height: 24)
                .background(attachment.type.color.opacity(0.15))
                .cornerRadius(6)

            // File info
            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.filename)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.primary)

                Text(attachment.formattedSize)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Upload progress or remove button
            if attachment.uploadProgress > 0 && attachment.uploadProgress < 1 {
                CircularProgressView(progress: attachment.uploadProgress)
                    .frame(width: 20, height: 20)
            } else {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
}

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 2)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, lineWidth: 2)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
    }
}

// Preview
struct FileAttachmentChip_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            FileAttachmentChip(
                attachment: FileAttachment(
                    type: .photo,
                    data: Data(),
                    filename: "screenshot.jpg",
                    mimeType: "image/jpeg"
                ),
                onRemove: {}
            )

            FileAttachmentChip(
                attachment: FileAttachment(
                    type: .document,
                    data: Data(count: 1024 * 500), // 500 KB
                    filename: "document.pdf",
                    mimeType: "application/pdf"
                ),
                onRemove: {}
            )
        }
        .padding()
    }
}

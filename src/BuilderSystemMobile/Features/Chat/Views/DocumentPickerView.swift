import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var selectedDocuments: [FileAttachment]
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
            .pdf,
            .text,
            .plainText,
            .json,
            .image,
            .movie,
            .audio,
            .archive,
            .spreadsheet,
            .presentation
        ], asCopy: true)

        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView

        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.presentationMode.wrappedValue.dismiss()

            for url in urls {
                // Access security-scoped resource
                guard url.startAccessingSecurityScopedResource() else {
                    continue
                }

                defer {
                    url.stopAccessingSecurityScopedResource()
                }

                do {
                    let data = try Data(contentsOf: url)
                    let filename = url.lastPathComponent
                    let mimeType = getMimeType(for: url)

                    let attachment = FileAttachment(
                        type: .document,
                        data: data,
                        filename: filename,
                        mimeType: mimeType
                    )

                    DispatchQueue.main.async {
                        self.parent.selectedDocuments.append(attachment)
                    }
                } catch {
                    print("Error reading document: \(error.localizedDescription)")
                }
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }

        private func getMimeType(for url: URL) -> String {
            if let uti = UTType(filenameExtension: url.pathExtension) {
                return uti.preferredMIMEType ?? "application/octet-stream"
            }
            return "application/octet-stream"
        }
    }
}

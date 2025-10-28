import SwiftUI
import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedPhotos: [FileAttachment]
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 5 // Allow up to 5 photos
        configuration.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()

            guard !results.isEmpty else { return }

            // Process selected photos
            for result in results {
                let itemProvider = result.itemProvider

                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        guard let self = self,
                              let image = image as? UIImage,
                              let imageData = image.jpegData(compressionQuality: 0.8) else {
                            return
                        }

                        let filename = "photo_\(UUID().uuidString).jpg"
                        let attachment = FileAttachment(
                            type: .photo,
                            data: imageData,
                            filename: filename,
                            mimeType: "image/jpeg"
                        )

                        DispatchQueue.main.async {
                            self.parent.selectedPhotos.append(attachment)
                        }
                    }
                }
            }
        }
    }
}

//
//  AttachmentService.swift
//  BuilderOS
//
//  Service for handling file/photo picking and attachment management
//

import Foundation
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

/// Service managing file and photo attachments
@MainActor
class AttachmentService: ObservableObject {
    @Published var selectedAttachments: [ChatAttachment] = []
    @Published var isProcessing: Bool = false
    @Published var lastError: String?

    // Maximum file size (50 MB)
    private let maxFileSize: Int64 = 50_000_000

    // API client for uploads
    private let apiClient = BuilderOSAPIClient()

    // MARK: - Photo/Video Picker

    /// Present PHPickerViewController for photo/video selection
    func presentPhotoPicker(from viewController: UIViewController) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 10  // Allow up to 10 selections
        config.filter = .any(of: [.images, .videos])

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = PhotoPickerCoordinator(service: self)
        viewController.present(picker, animated: true)
    }

    /// Handle photo picker results
    func handlePhotoPickerResults(_ results: [PHPickerResult]) {
        isProcessing = true
        lastError = nil

        Task {
            for result in results {
                await processPhotoPickerResult(result)
            }
            isProcessing = false
        }
    }

    private func processPhotoPickerResult(_ result: PHPickerResult) async {
        let itemProvider = result.itemProvider

        // Determine type
        var utType: UTType?
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            utType = .image
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            utType = .movie
        }

        guard let utType = utType else {
            print("⚠️ Unsupported item type")
            return
        }

        do {
            // Load file representation
            if let url = try await itemProvider.loadFileRepresentation(for: utType) {
                await createAttachment(from: url, utType: utType)
            }
        } catch {
            print("❌ Failed to load item: \(error)")
            lastError = "Failed to load item: \(error.localizedDescription)"
        }
    }

    // MARK: - Document Picker

    /// Present UIDocumentPickerViewController for file selection
    func presentDocumentPicker(from viewController: UIViewController) {
        let types: [UTType] = [
            .pdf,
            .text,
            .plainText,
            .sourceCode,
            .json,
            .yaml,
            .xml,
            .zip,
            .archive
        ]

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = DocumentPickerCoordinator(service: self)
        viewController.present(picker, animated: true)
    }

    /// Handle document picker results
    func handleDocumentPickerResults(_ urls: [URL]) {
        isProcessing = true
        lastError = nil

        Task {
            for url in urls {
                // Start accessing security-scoped resource
                guard url.startAccessingSecurityScopedResource() else {
                    print("⚠️ Could not access file: \(url)")
                    continue
                }

                defer { url.stopAccessingSecurityScopedResource() }

                await createAttachment(from: url, utType: nil)
            }
            isProcessing = false
        }
    }

    // MARK: - Attachment Creation

    private func createAttachment(from sourceURL: URL, utType: UTType?) async {
        do {
            // Get file attributes
            let attributes = try FileManager.default.attributesOfItem(atPath: sourceURL.path)
            guard let fileSize = attributes[.size] as? Int64 else {
                throw AttachmentError.invalidFile
            }

            // Check file size
            if fileSize > maxFileSize {
                lastError = "File too large (\(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)) exceeds 50 MB limit)"
                return
            }

            let filename = sourceURL.lastPathComponent
            let fileExtension = sourceURL.pathExtension

            // Determine attachment type
            let attachmentType: AttachmentType
            if let utType = utType {
                attachmentType = AttachmentType.from(utType: utType)
            } else {
                attachmentType = AttachmentType.from(fileExtension: fileExtension)
            }

            // Determine MIME type
            let mimeType: String
            if let utType = utType {
                mimeType = utType.preferredMIMEType ?? "application/octet-stream"
            } else if let inferredUTType = UTType(filenameExtension: fileExtension) {
                mimeType = inferredUTType.preferredMIMEType ?? "application/octet-stream"
            } else {
                mimeType = "application/octet-stream"
            }

            // Copy to temporary location
            let tempURL = try copyToTemporaryLocation(from: sourceURL, filename: filename)

            // Generate thumbnail for images
            var thumbnailData: Data?
            if attachmentType == .photo {
                thumbnailData = await generateThumbnail(for: tempURL)
            }

            let attachment = ChatAttachment(
                filename: filename,
                size: fileSize,
                mimeType: mimeType,
                type: attachmentType,
                localURL: tempURL,
                uploadState: .pending,
                thumbnailData: thumbnailData
            )

            selectedAttachments.append(attachment)
            print("✅ Added attachment: \(filename) (\(attachment.formattedSize))")

        } catch {
            print("❌ Failed to create attachment: \(error)")
            lastError = "Failed to process file: \(error.localizedDescription)"
        }
    }

    // MARK: - File Management

    private func copyToTemporaryLocation(from sourceURL: URL, filename: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let attachmentsDir = tempDir.appendingPathComponent("attachments", isDirectory: true)

        // Create attachments directory if needed
        if !FileManager.default.fileExists(atPath: attachmentsDir.path) {
            try FileManager.default.createDirectory(at: attachmentsDir, withIntermediateDirectories: true)
        }

        let destURL = attachmentsDir.appendingPathComponent(filename)

        // Remove existing file if present
        if FileManager.default.fileExists(atPath: destURL.path) {
            try FileManager.default.removeItem(at: destURL)
        }

        // Copy file
        try FileManager.default.copyItem(at: sourceURL, to: destURL)

        return destURL
    }

    private func generateThumbnail(for imageURL: URL) async -> Data? {
        guard let image = UIImage(contentsOfFile: imageURL.path) else { return nil }

        // Generate thumbnail (max 150x150)
        let targetSize = CGSize(width: 150, height: 150)
        let renderer = UIGraphicsImageRenderer(size: targetSize)

        let thumbnail = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return thumbnail.pngData()
    }

    // MARK: - Attachment Management

    /// Remove attachment from selection
    func removeAttachment(_ attachment: ChatAttachment) {
        selectedAttachments.removeAll { $0.id == attachment.id }

        // Clean up local file
        if let localURL = attachment.localURL {
            try? FileManager.default.removeItem(at: localURL)
        }
    }

    /// Clear all selected attachments
    func clearAllAttachments() {
        for attachment in selectedAttachments {
            if let localURL = attachment.localURL {
                try? FileManager.default.removeItem(at: localURL)
            }
        }
        selectedAttachments.removeAll()
    }

    /// Clean up temporary files for completed/failed uploads
    func cleanupCompletedAttachments() {
        for attachment in selectedAttachments where attachment.uploadState.isCompleted || attachment.uploadState.isFailed {
            if let localURL = attachment.localURL {
                try? FileManager.default.removeItem(at: localURL)
            }
        }

        selectedAttachments.removeAll { $0.uploadState.isCompleted || $0.uploadState.isFailed }
    }

    // MARK: - Upload

    /// Upload all pending attachments
    func uploadAllAttachments() async throws {
        let pendingAttachments = selectedAttachments.filter { $0.uploadState == .pending }

        guard !pendingAttachments.isEmpty else { return }

        isProcessing = true
        lastError = nil

        defer { isProcessing = false }

        for attachment in pendingAttachments {
            do {
                // Update state to uploading
                updateAttachmentState(attachment.id, state: .uploading(progress: 0.0))

                // Upload file
                let remoteURL = try await apiClient.uploadFile(attachment) { progress in
                    Task { @MainActor in
                        self.updateAttachmentState(attachment.id, state: .uploading(progress: progress))
                    }
                }

                // Update state to completed
                updateAttachmentState(attachment.id, state: .completed(remoteURL: remoteURL))

            } catch {
                print("❌ Upload failed for \(attachment.filename): \(error)")
                lastError = "Upload failed: \(error.localizedDescription)"
                updateAttachmentState(attachment.id, state: .failed(error: error.localizedDescription))
            }
        }
    }

    /// Upload a specific attachment
    func uploadAttachment(_ attachment: ChatAttachment) async throws -> String {
        guard attachment.uploadState == .pending else {
            throw AttachmentError.invalidFile
        }

        updateAttachmentState(attachment.id, state: .uploading(progress: 0.0))

        do {
            let remoteURL = try await apiClient.uploadFile(attachment) { progress in
                Task { @MainActor in
                    self.updateAttachmentState(attachment.id, state: .uploading(progress: progress))
                }
            }

            updateAttachmentState(attachment.id, state: .completed(remoteURL: remoteURL))
            return remoteURL

        } catch {
            updateAttachmentState(attachment.id, state: .failed(error: error.localizedDescription))
            throw error
        }
    }

    /// Update attachment upload state
    private func updateAttachmentState(_ attachmentId: UUID, state: UploadState) {
        guard let index = selectedAttachments.firstIndex(where: { $0.id == attachmentId }) else {
            return
        }

        var updatedAttachment = selectedAttachments[index]
        updatedAttachment.uploadState = state
        selectedAttachments[index] = updatedAttachment
    }
}

// MARK: - PHPicker Coordinator

class PhotoPickerCoordinator: NSObject, PHPickerViewControllerDelegate {
    let service: AttachmentService

    init(service: AttachmentService) {
        self.service = service
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        Task { @MainActor in
            service.handlePhotoPickerResults(results)
        }
    }
}

// MARK: - Document Picker Coordinator

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    let service: AttachmentService

    init(service: AttachmentService) {
        self.service = service
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        Task { @MainActor in
            service.handleDocumentPickerResults(urls)
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // User cancelled
    }
}

// MARK: - Errors

enum AttachmentError: LocalizedError {
    case invalidFile
    case fileTooLarge
    case unsupportedType

    var errorDescription: String? {
        switch self {
        case .invalidFile:
            return "Invalid file"
        case .fileTooLarge:
            return "File too large (50 MB limit)"
        case .unsupportedType:
            return "Unsupported file type"
        }
    }
}

// MARK: - ItemProvider Extension

extension NSItemProvider {
    func loadFileRepresentation(for contentType: UTType) async throws -> URL? {
        try await withCheckedThrowingContinuation { continuation in
            _ = loadFileRepresentation(forTypeIdentifier: contentType.identifier) { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: url)
                }
            }
        }
    }
}

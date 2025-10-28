//
//  ChatAttachment.swift
//  BuilderOS
//
//  Chat message attachment model for file uploads
//

import Foundation
import UIKit
import UniformTypeIdentifiers

/// Type of attachment
enum AttachmentType: String, Codable, CaseIterable {
    case photo
    case video
    case document
    case code
    case pdf
    case archive
    case audio
    case other

    var displayName: String {
        switch self {
        case .photo: return "Photo"
        case .video: return "Video"
        case .document: return "Document"
        case .code: return "Code"
        case .pdf: return "PDF"
        case .archive: return "Archive"
        case .audio: return "Audio"
        case .other: return "File"
        }
    }

    var icon: String {
        switch self {
        case .photo: return "photo.fill"
        case .video: return "video.fill"
        case .document: return "doc.fill"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .pdf: return "doc.richtext.fill"
        case .archive: return "doc.zipper"
        case .audio: return "waveform"
        case .other: return "doc.fill"
        }
    }

    /// Determine attachment type from file extension
    static func from(fileExtension: String) -> AttachmentType {
        let ext = fileExtension.lowercased()

        // Images
        if ["jpg", "jpeg", "png", "gif", "heic", "heif", "webp", "bmp", "tiff"].contains(ext) {
            return .photo
        }

        // Videos
        if ["mp4", "mov", "m4v", "avi", "mkv", "webm"].contains(ext) {
            return .video
        }

        // Documents
        if ["txt", "rtf", "doc", "docx", "pages"].contains(ext) {
            return .document
        }

        // Code files
        if ["swift", "py", "js", "ts", "jsx", "tsx", "java", "kt", "cpp", "c", "h", "m", "mm",
            "go", "rs", "rb", "php", "html", "css", "json", "xml", "yaml", "yml", "sh", "bash"].contains(ext) {
            return .code
        }

        // PDF
        if ext == "pdf" {
            return .pdf
        }

        // Archives
        if ["zip", "tar", "gz", "7z", "rar", "bz2"].contains(ext) {
            return .archive
        }

        // Audio
        if ["mp3", "m4a", "wav", "aac", "flac", "ogg"].contains(ext) {
            return .audio
        }

        return .other
    }

    /// Determine attachment type from UTType
    static func from(utType: UTType) -> AttachmentType {
        if utType.conforms(to: .image) {
            return .photo
        } else if utType.conforms(to: .movie) {
            return .video
        } else if utType.conforms(to: .pdf) {
            return .pdf
        } else if utType.conforms(to: .audio) {
            return .audio
        } else if utType.conforms(to: .sourceCode) {
            return .code
        } else if utType.conforms(to: .archive) {
            return .archive
        } else if utType.conforms(to: .text) {
            return .document
        }
        return .other
    }
}

/// Upload state for an attachment
enum UploadState: Codable, Equatable {
    case pending
    case uploading(progress: Double)
    case completed(remoteURL: String)
    case failed(error: String)

    var isInProgress: Bool {
        if case .uploading = self { return true }
        return false
    }

    var isCompleted: Bool {
        if case .completed = self { return true }
        return false
    }

    var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }

    var progress: Double? {
        if case .uploading(let progress) = self { return progress }
        return nil
    }

    static func == (lhs: UploadState, rhs: UploadState) -> Bool {
        switch (lhs, rhs) {
        case (.pending, .pending):
            return true
        case (.uploading(let lProgress), .uploading(let rProgress)):
            return lProgress == rProgress
        case (.completed(let lURL), .completed(let rURL)):
            return lURL == rURL
        case (.failed(let lError), .failed(let rError)):
            return lError == rError
        default:
            return false
        }
    }
}

/// Chat attachment model
struct ChatAttachment: Identifiable, Codable, Equatable {
    let id: UUID
    let filename: String
    let size: Int64  // bytes
    let mimeType: String
    let type: AttachmentType
    var localURL: URL?  // Local file URL before upload
    var uploadState: UploadState
    var thumbnailData: Data?  // For images/videos
    let createdAt: Date

    init(
        id: UUID = UUID(),
        filename: String,
        size: Int64,
        mimeType: String,
        type: AttachmentType,
        localURL: URL? = nil,
        uploadState: UploadState = .pending,
        thumbnailData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.filename = filename
        self.size = size
        self.mimeType = mimeType
        self.type = type
        self.localURL = localURL
        self.uploadState = uploadState
        self.thumbnailData = thumbnailData
        self.createdAt = createdAt
    }

    /// Human-readable file size
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    /// File extension from filename
    var fileExtension: String {
        (filename as NSString).pathExtension
    }

    static func == (lhs: ChatAttachment, rhs: ChatAttachment) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data
extension ChatAttachment {
    static let mockImage = ChatAttachment(
        filename: "screenshot.png",
        size: 1_234_567,
        mimeType: "image/png",
        type: .photo,
        uploadState: .pending
    )

    static let mockVideo = ChatAttachment(
        filename: "demo.mp4",
        size: 15_234_567,
        mimeType: "video/mp4",
        type: .video,
        uploadState: .uploading(progress: 0.45)
    )

    static let mockDocument = ChatAttachment(
        filename: "report.pdf",
        size: 2_345_678,
        mimeType: "application/pdf",
        type: .pdf,
        uploadState: .completed(remoteURL: "https://example.com/files/report.pdf")
    )

    static let mockCode = ChatAttachment(
        filename: "AppDelegate.swift",
        size: 12_345,
        mimeType: "text/plain",
        type: .code,
        uploadState: .pending
    )

    static let mockFailed = ChatAttachment(
        filename: "large_file.zip",
        size: 100_000_000,
        mimeType: "application/zip",
        type: .archive,
        uploadState: .failed(error: "File too large (100 MB limit)")
    )

    static let mockList: [ChatAttachment] = [
        mockImage,
        mockVideo,
        mockDocument,
        mockCode
    ]
}

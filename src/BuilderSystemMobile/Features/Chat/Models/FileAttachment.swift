import Foundation
import SwiftUI

struct FileAttachment: Identifiable, Equatable {
    let id = UUID()
    let type: AttachmentType
    let data: Data
    let filename: String
    let mimeType: String
    var uploadProgress: Double = 0.0

    enum AttachmentType: String {
        case photo
        case document

        var icon: String {
            switch self {
            case .photo:
                return "photo"
            case .document:
                return "doc.fill"
            }
        }

        var color: Color {
            switch self {
            case .photo:
                return .blue
            case .document:
                return .orange
            }
        }
    }

    static func == (lhs: FileAttachment, rhs: FileAttachment) -> Bool {
        lhs.id == rhs.id
    }

    var formattedSize: String {
        let bytes = Double(data.count)
        let kb = bytes / 1024
        let mb = kb / 1024

        if mb >= 1 {
            return String(format: "%.1f MB", mb)
        } else if kb >= 1 {
            return String(format: "%.1f KB", kb)
        } else {
            return "\(Int(bytes)) bytes"
        }
    }
}

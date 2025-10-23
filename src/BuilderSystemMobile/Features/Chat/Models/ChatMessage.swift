import Foundation
import SwiftUI

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let type: MessageType
    let hasVoiceAttachment: Bool
    
    init(content: String, isUser: Bool, type: MessageType = .text, hasVoiceAttachment: Bool = false) {
        self.content = content
        self.isUser = isUser
        self.type = type
        self.hasVoiceAttachment = hasVoiceAttachment
        self.timestamp = Date()
    }
    
    var isCodeBlock: Bool {
        return type == .code || content.contains("```") || content.contains("#!/")
    }
    
    var typeIcon: String {
        switch type {
        case .text:
            return "text.bubble"
        case .code:
            return "chevron.left.forwardslash.chevron.right"
        case .status:
            return "info.circle"
        case .error:
            return "exclamationmark.triangle"
        case .success:
            return "checkmark.circle"
        case .command:
            return "terminal"
        }
    }
    
    var typeColor: Color {
        switch type {
        case .text:
            return .primary
        case .code:
            return .blue
        case .status:
            return .secondary
        case .error:
            return .red
        case .success:
            return .green
        case .command:
            return .orange
        }
    }
}

enum MessageType: String, Codable, CaseIterable {
    case text = "text"
    case code = "code"
    case status = "status"
    case error = "error"
    case success = "success"
    case command = "command"
    
    var displayName: String {
        switch self {
        case .text:
            return "Message"
        case .code:
            return "Code"
        case .status:
            return "Status"
        case .error:
            return "Error"
        case .success:
            return "Success"
        case .command:
            return "Command"
        }
    }
}
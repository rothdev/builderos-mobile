import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isConnected = false
    @Published var messageText = ""
    @Published var attachments: [FileAttachment] = []

    private let sshService: SSHServiceProtocol
    private let uploadService: FileUploadService
    private var cancellables = Set<AnyCancellable>()
    
    init(sshService: SSHServiceProtocol = SSHService(), uploadService: FileUploadService = FileUploadService()) {
        self.sshService = sshService
        self.uploadService = uploadService

        // Monitor connection state
        sshService.connectionStatePublisher
            .map { $0.isConnected }
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)

        // Add welcome message
        addWelcomeMessage()
    }
    
    func sendMessage(_ text: String, hasVoiceAttachment: Bool = false) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let attachmentCount = attachments.count

        // Add user message
        let userMessage = ChatMessage(
            content: text,
            isUser: true,
            type: .command,
            hasVoiceAttachment: hasVoiceAttachment,
            fileAttachmentCount: attachmentCount
        )
        messages.append(userMessage)

        // Upload attachments if any
        if !attachments.isEmpty {
            Task {
                await uploadAttachments()
            }
        }

        // Clear attachments
        attachments.removeAll()

        // Execute command if connected
        if isConnected {
            executeCommand(text)
        } else {
            addSystemMessage("Not connected to Builder System. Please connect first.", type: .error)
        }
    }
    
    func sendCommand(_ command: String) {
        sendMessage(command)
    }
    
    private func executeCommand(_ command: String) {
        Task {
            do {
                let result = try await sshService.executeCommand(command)
                let responseType = determineMessageType(for: result)
                addSystemMessage(result, type: responseType)
            } catch {
                addSystemMessage("Error executing command: \(error.localizedDescription)", type: .error)
            }
        }
    }
    
    private func addSystemMessage(_ content: String, type: MessageType) {
        let message = ChatMessage(
            content: content,
            isUser: false,
            type: type
        )
        messages.append(message)
    }
    
    private func addWelcomeMessage() {
        let welcomeText = """
        Welcome to Builder System Mobile! 
        
        Connect to your Builder System server to start managing capsules, checking status, and running commands.
        
        Use the voice button to dictate commands or type them directly.
        """
        
        addSystemMessage(welcomeText, type: .status)
    }
    
    private func determineMessageType(for content: String) -> MessageType {
        let lowercased = content.lowercased()
        
        if lowercased.contains("error") || lowercased.contains("failed") || lowercased.contains("exception") {
            return .error
        } else if lowercased.contains("success") || lowercased.contains("completed") || lowercased.contains("done") {
            return .success
        } else if content.contains("```") || content.contains("#!/") || content.contains("def ") || content.contains("function ") {
            return .code
        } else if lowercased.contains("status") || lowercased.contains("info") || lowercased.contains("version") {
            return .status
        } else {
            return .text
        }
    }
    
    func clearMessages() {
        messages.removeAll()
        addWelcomeMessage()
    }
    
    func connectToBuilder(configuration: SSHConfiguration) {
        Task {
            do {
                try await sshService.connect(configuration: configuration)
                addSystemMessage("Connected to Builder System at \(configuration.host)", type: .success)
            } catch {
                addSystemMessage("Failed to connect: \(error.localizedDescription)", type: .error)
            }
        }
    }
    
    func disconnect() {
        sshService.disconnect()
        addSystemMessage("Disconnected from Builder System", type: .status)
    }

    // MARK: - File Attachment Methods

    func addAttachment(_ attachment: FileAttachment) {
        attachments.append(attachment)
    }

    func removeAttachment(id: UUID) {
        attachments.removeAll { $0.id == id }
    }

    func uploadAttachments() async {
        guard !attachments.isEmpty else { return }

        do {
            let results = try await uploadService.uploadFiles(attachments, to: "/api/upload")
            addSystemMessage("Uploaded \(attachments.count) file(s) successfully", type: .success)
        } catch {
            addSystemMessage("Failed to upload files: \(error.localizedDescription)", type: .error)
        }
    }
}
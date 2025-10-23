import XCTest
@testable import BuilderSystemMobile

final class ChatViewModelTests: XCTestCase {
    var chatViewModel: ChatViewModel!
    var mockSSHService: MockSSHService!
    
    override func setUp() {
        super.setUp()
        mockSSHService = MockSSHService()
        chatViewModel = ChatViewModel(sshService: mockSSHService)
    }
    
    override func tearDown() {
        chatViewModel = nil
        mockSSHService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Test that chat starts with welcome message
        XCTAssertEqual(chatViewModel.messages.count, 1)
        XCTAssertFalse(chatViewModel.messages.first?.isUser ?? true)
        XCTAssertEqual(chatViewModel.messages.first?.type, .status)
    }
    
    func testSendMessage() {
        let testMessage = "test command"
        chatViewModel.sendMessage(testMessage)
        
        // Should add user message
        XCTAssertEqual(chatViewModel.messages.count, 2) // Welcome + user message
        XCTAssertEqual(chatViewModel.messages.last?.content, testMessage)
        XCTAssertTrue(chatViewModel.messages.last?.isUser ?? false)
    }
    
    func testMessageTypeDetection() {
        let chatViewModel = ChatViewModel(sshService: mockSSHService)
        
        // Test different message types through private method reflection would be complex
        // For now, just test that messages are being processed
        chatViewModel.sendMessage("status")
        XCTAssertTrue(chatViewModel.messages.count > 1)
    }
}

// Mock SSH Service for testing
class MockSSHService: SSHServiceProtocol {
    var connectionState: SSHConnectionState = .disconnected
    var connectionStatePublisher: Published<SSHConnectionState>.Publisher {
        Published(initialValue: connectionState).projectedValue
    }
    
    func connect(configuration: SSHConfiguration) async throws {
        connectionState = .connected
    }
    
    func executeCommand(_ command: String) async throws -> String {
        return "Mock response for: \(command)"
    }
    
    func startInteractiveSession() async throws {
        // Mock implementation
    }
    
    func disconnect() {
        connectionState = .disconnected
    }
}
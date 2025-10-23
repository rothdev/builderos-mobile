import Foundation

struct SSHConfiguration: Codable {
    let host: String
    let port: Int
    let username: String
    let privateKeyPath: String?
    let password: String?
    let timeout: TimeInterval
    
    init(host: String, port: Int = 22, username: String, privateKeyPath: String? = nil, password: String? = nil, timeout: TimeInterval = 10.0) {
        self.host = host
        self.port = port
        self.username = username
        self.privateKeyPath = privateKeyPath
        self.password = password
        self.timeout = timeout
    }
    
    static let `default` = SSHConfiguration(
        host: "localhost",
        username: "user"
    )
}

enum SSHConnectionState {
    case disconnected
    case connecting
    case connected
    case error(String)
    
    var isConnected: Bool {
        if case .connected = self {
            return true
        }
        return false
    }
    
    var statusText: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .error(let message):
            return "Error: \(message)"
        }
    }
}

enum SSHError: Error, LocalizedError {
    case connectionFailed(String)
    case authenticationFailed
    case commandExecutionFailed(String)
    case sessionNotFound
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let message):
            return "Connection failed: \(message)"
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials."
        case .commandExecutionFailed(let message):
            return "Command execution failed: \(message)"
        case .sessionNotFound:
            return "SSH session not found or has been terminated."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
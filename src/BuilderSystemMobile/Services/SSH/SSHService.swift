//
//  SSHService.swift (Stub for build)
//  BuilderOS
//
//  NOTE: Full SSH implementation requires NMSSH pod dependency
//

import Foundation

protocol SSHServiceProtocol {
    func connect(configuration: SSHConfiguration)
    func disconnect()
    func executeCommand(_ command: String, completion: @escaping (Result<String, Error>) -> Void)
}

enum ConnectionState {
    case disconnected
    case connecting
    case connected
    case error(String)

    var statusText: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .error(let message): return "Error: \(message)"
        }
    }
}

class SSHService: SSHServiceProtocol, ObservableObject {
    @Published var isConnected: Bool = false
    @Published var output: String = ""
    @Published var connectionState: ConnectionState = .disconnected

    init() {}
    
    func connect(configuration: SSHConfiguration) {
        // Stub: Would connect via NMSSH
        print("SSHService stub: connect called")
    }
    
    func disconnect() {
        // Stub: Would disconnect
        isConnected = false
    }
    
    func executeCommand(_ command: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Stub: Would execute command via SSH
        completion(.success("SSH feature requires NMSSH library (not yet installed)"))
    }
}

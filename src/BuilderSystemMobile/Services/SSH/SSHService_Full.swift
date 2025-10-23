import Foundation
import NMSSH
import Combine

protocol SSHServiceProtocol {
    func connect(configuration: SSHConfiguration) async throws
    func executeCommand(_ command: String) async throws -> String
    func startInteractiveSession() async throws
    func disconnect()
    var connectionState: SSHConnectionState { get }
    var connectionStatePublisher: Published<SSHConnectionState>.Publisher { get }
}

@MainActor
class SSHService: ObservableObject, SSHServiceProtocol {
    @Published private(set) var connectionState: SSHConnectionState = .disconnected
    
    var connectionStatePublisher: Published<SSHConnectionState>.Publisher { $connectionState }
    
    private var session: NMSSHSession?
    private var configuration: SSHConfiguration?
    private var channel: NMSSHChannel?
    
    func connect(configuration: SSHConfiguration) async throws {
        self.configuration = configuration
        connectionState = .connecting
        
        do {
            let session = NMSSHSession(host: configuration.host,
                                       port: configuration.port,
                                       andUsername: configuration.username)
            
            session.connect(withTimeout: configuration.timeout)
            
            guard session.isConnected else {
                throw SSHError.connectionFailed("Unable to establish connection")
            }
            
            // Authenticate
            var authSuccess = false
            
            if let privateKeyPath = configuration.privateKeyPath {
                authSuccess = session.authenticateBy(publicKey: nil,
                                                   privateKey: privateKeyPath,
                                                   andPassword: configuration.password)
            } else if let password = configuration.password {
                authSuccess = session.authenticate(byPassword: password)
            }
            
            guard authSuccess else {
                session.disconnect()
                throw SSHError.authenticationFailed
            }
            
            self.session = session
            connectionState = .connected
            
        } catch {
            connectionState = .error(error.localizedDescription)
            throw SSHError.networkError(error)
        }
    }
    
    func executeCommand(_ command: String) async throws -> String {
        guard let session = session, session.isConnected else {
            throw SSHError.sessionNotFound
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let error: NSErrorPointer = nil
                    let result = session.channel.execute(command, error: error)
                    
                    if let error = error?.pointee {
                        continuation.resume(throwing: SSHError.commandExecutionFailed(error.localizedDescription))
                    } else {
                        continuation.resume(returning: result ?? "")
                    }
                } catch {
                    continuation.resume(throwing: SSHError.commandExecutionFailed(error.localizedDescription))
                }
            }
        }
    }
    
    func startInteractiveSession() async throws {
        guard let session = session, session.isConnected else {
            throw SSHError.sessionNotFound
        }
        
        channel = session.channel
        channel?.requestPty = true
        channel?.ptyTerminalType = NMSSHChannelPtyTerminal.xterm
    }
    
    func disconnect() {
        channel = nil
        session?.disconnect()
        session = nil
        connectionState = .disconnected
    }
    
    deinit {
        disconnect()
    }
}
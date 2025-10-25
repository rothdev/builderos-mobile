import Foundation
import Combine

#if canImport(NMSSH)
import NMSSH
#endif

protocol SSHServiceProtocol: AnyObject {
    var connectionState: SSHConnectionState { get }
    var connectionStatePublisher: Published<SSHConnectionState>.Publisher { get }
    
    func connect(configuration: SSHConfiguration) async throws
    func executeCommand(_ command: String) async throws -> String
    func startInteractiveSession() async throws
    func disconnect()
}

@MainActor
class SSHService: ObservableObject, SSHServiceProtocol {
    @Published private(set) var connectionState: SSHConnectionState = .disconnected
    
    var connectionStatePublisher: Published<SSHConnectionState>.Publisher { $connectionState }
    
    #if canImport(NMSSH)
    private var session: NMSSHSession?
    private var channel: NMSSHChannel?
    private var configuration: SSHConfiguration?
    #else
    private var isSessionActive = false
    private var simulatedHistory: [String] = []
    #endif
    
    func connect(configuration: SSHConfiguration) async throws {
        connectionState = .connecting
        
        #if canImport(NMSSH)
        do {
            let session = NMSSHSession(host: configuration.host,
                                       port: configuration.port,
                                       andUsername: configuration.username)
            
            session.connect(withTimeout: configuration.timeout)
            
            guard session.isConnected else {
                throw SSHError.connectionFailed("Unable to establish connection")
            }
            
            var authenticationSucceeded = false
            
            if let privateKeyPath = configuration.privateKeyPath {
                authenticationSucceeded = session.authenticateBy(
                    publicKey: nil,
                    privateKey: privateKeyPath,
                    andPassword: configuration.password
                )
            } else if let password = configuration.password {
                authenticationSucceeded = session.authenticate(byPassword: password)
            }
            
            guard authenticationSucceeded else {
                session.disconnect()
                throw SSHError.authenticationFailed
            }
            
            self.session = session
            self.configuration = configuration
            connectionState = .connected
        } catch {
            connectionState = .error(error.localizedDescription)
            throw SSHError.networkError(error)
        }
        #else
        // Simulated connection for environments without NMSSH available.
        try await Task.sleep(nanoseconds: 250_000_000)
        isSessionActive = true
        simulatedHistory.append("Connected to \(configuration.host)")
        connectionState = .connected
        #endif
    }
    
    func executeCommand(_ command: String) async throws -> String {
        #if canImport(NMSSH)
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
        #else
        guard isSessionActive else {
            throw SSHError.sessionNotFound
        }
        
        try await Task.sleep(nanoseconds: 100_000_000)
        let simulatedResponse = "Simulated response for: \(command)"
        simulatedHistory.append(simulatedResponse)
        return simulatedResponse
        #endif
    }
    
    func startInteractiveSession() async throws {
        #if canImport(NMSSH)
        guard let session = session, session.isConnected else {
            throw SSHError.sessionNotFound
        }
        
        channel = session.channel
        channel?.requestPty = true
        channel?.ptyTerminalType = NMSSHChannelPtyTerminal.xterm
        #else
        guard isSessionActive else {
            throw SSHError.sessionNotFound
        }
        // No-op for simulated environment
        #endif
    }
    
    func disconnect() {
        #if canImport(NMSSH)
        channel = nil
        session?.disconnect()
        session = nil
        configuration = nil
        #else
        isSessionActive = false
        simulatedHistory.append("Disconnected")
        #endif
        
        connectionState = .disconnected
    }
    
    deinit {
        disconnect()
    }
}

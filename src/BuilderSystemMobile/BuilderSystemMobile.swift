// Main module file for BuilderSystemMobile
// This file exposes the public interface of the module

// App
public struct BuilderSystemMobileApp {
    public init() {}
}

// Core Models
public struct ChatMessage {}
public enum MessageType {}
public struct SSHConfiguration {}
public enum SSHConnectionState {}

// Services
public protocol SSHServiceProtocol {}
public class SSHService {}
public class VoiceManager {}
public class TTSManager {}
public class NotificationService {}

// Views
public struct ChatView {}
public struct ContentView {}
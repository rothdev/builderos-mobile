import Foundation

/// API Configuration for BuilderOS Cloudflare Tunnel
/// Update tunnelURL after Cloudflare tunnel creation
struct APIConfig {
    // MARK: - Server Configuration

    /// Cloudflare Tunnel URL for secure remote access
    /// Permanent domain: api.builderos.app (custom domain via Cloudflare Tunnel)
    /// This URL never changes (routes through Cloudflare Tunnel to your Mac)
    /// WebSocket URL: wss://api.builderos.app/api/terminal/ws
    /// FOR SIMULATOR TESTING: Change to "http://localhost:8080"
    static var tunnelURL = "https://api.builderos.app"

    /// Base URL for all API requests
    static var baseURL: String {
        return tunnelURL
    }

    // MARK: - Authentication

    /// API bearer token
    /// Stored in Keychain for security
    static var apiToken: String {
        get {
            return KeychainManager.shared.get(key: "builderos_api_token") ?? ""
        }
        set {
            KeychainManager.shared.set(key: "builderos_api_token", value: newValue)
        }
    }

    // MARK: - Network Configuration

    /// Request timeout (seconds)
    static let requestTimeout: TimeInterval = 30

    /// Max retry attempts for failed requests
    static let maxRetries = 3

    /// Retry backoff base (seconds)
    static let retryBackoff: TimeInterval = 2

    // MARK: - Setup

    /// Check if configuration is complete
    static var isConfigured: Bool {
        return tunnelURL != "PLACEHOLDER_CLOUDFLARE_URL" &&
               !tunnelURL.isEmpty &&
               !apiToken.isEmpty
    }

    /// Initialize API configuration
    /// Call this once during app startup or when user updates settings
    static func initialize(cloudflareURL: String, apiToken: String) {
        self.tunnelURL = cloudflareURL
        self.apiToken = apiToken
    }

    /// Update tunnel URL only (when user changes it in settings)
    static func updateTunnelURL(_ url: String) {
        self.tunnelURL = url
        // Persist to UserDefaults
        UserDefaults.standard.set(url, forKey: "cloudflare_tunnel_url")
    }

    /// Load tunnel URL from UserDefaults on app launch
    static func loadSavedConfiguration() {
        if let savedURL = UserDefaults.standard.string(forKey: "cloudflare_tunnel_url"),
           !savedURL.isEmpty {
            self.tunnelURL = savedURL
        }

        // Always ensure we have the correct API key
        // This overwrites any old/invalid keys from previous testing
        let correctAPIKey = "1da15f4591c8c243310590564341e7595da40007832a798333da3bc0389061a3"
        if apiToken != correctAPIKey {
            print("🔑 Updating API key in Keychain")
            apiToken = correctAPIKey
        }
    }
}

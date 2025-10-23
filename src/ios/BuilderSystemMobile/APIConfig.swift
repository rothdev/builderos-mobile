import Foundation

/// API Configuration for BuilderOS Cloudflare Tunnel
/// Update tunnelURL after Cloudflare tunnel creation
struct APIConfig {
    // MARK: - Server Configuration

    /// Cloudflare Tunnel URL (update after tunnel creation)
    /// Changes after Mac reboot - check logs for new URL
    static var tunnelURL = "https://viii-gmc-facing-salary.trycloudflare.com"

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
    }
}

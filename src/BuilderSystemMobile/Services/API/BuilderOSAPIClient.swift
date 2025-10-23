import Foundation

/// BuilderOS API Client
/// Connects to Mac's API server via Cloudflare Tunnel
class BuilderOSAPIClient: ObservableObject {

    // MARK: - Configuration

    @Published var tunnelURL: String = UserDefaults.standard.string(forKey: "cloudflare_tunnel_url") ?? "" {
        didSet {
            UserDefaults.standard.set(tunnelURL, forKey: "cloudflare_tunnel_url")
            APIConfig.updateTunnelURL(tunnelURL)
            updateBaseURL()
        }
    }

    @Published var apiKey: String = UserDefaults.standard.string(forKey: "builderOS.apiKey") ?? "dev-key-change-me" {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "builderOS.apiKey")
            APIConfig.apiToken = apiKey
        }
    }

    @Published var isConnected: Bool = false
    @Published var lastError: String?

    private var baseURL: URL?

    // MARK: - Initialization

    init() {
        // Load saved configuration
        APIConfig.loadSavedConfiguration()
        if let savedURL = UserDefaults.standard.string(forKey: "cloudflare_tunnel_url") {
            tunnelURL = savedURL
        }
        updateBaseURL()
    }

    private func updateBaseURL() {
        guard !tunnelURL.isEmpty else {
            baseURL = nil
            return
        }
        baseURL = URL(string: tunnelURL)
    }

    // MARK: - Health Check

    func healthCheck() async -> Bool {
        guard let url = baseURL?.appendingPathComponent("/api/health") else {
            lastError = "No Cloudflare Tunnel URL configured"
            isConnected = false
            return false
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10 // Increased for remote HTTPS connection

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                await MainActor.run {
                    isConnected = true
                    lastError = nil
                }
                return true
            }
        } catch {
            await MainActor.run {
                isConnected = false
                lastError = "Connection failed: \(error.localizedDescription)"
            }
        }

        return false
    }

    // MARK: - System Control

    /// Put Mac to sleep remotely
    func sleepMac() async throws -> Bool {
        guard let url = baseURL?.appendingPathComponent("/api/system/sleep") else {
            throw APIError.notConfigured
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        // Decode response
        let decoder = JSONDecoder()
        let result = try decoder.decode(SleepResponse.self, from: data)
        return result.success
    }

    // MARK: - System Status

    func getSystemStatus() async throws -> SystemStatus {
        guard let url = baseURL?.appendingPathComponent("/api/status") else {
            throw APIError.notConfigured
        }

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(SystemStatus.self, from: data)
    }

    // MARK: - Capsules

    func listCapsules() async throws -> [Capsule] {
        guard let url = baseURL?.appendingPathComponent("/api/capsules") else {
            throw APIError.notConfigured
        }

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(CapsulesResponse.self, from: data)
        return result.capsules
    }

    func getCapsule(name: String) async throws -> CapsuleDetail {
        guard let url = baseURL?.appendingPathComponent("/api/capsules/\(name)") else {
            throw APIError.notConfigured
        }

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(CapsuleDetail.self, from: data)
    }

    // MARK: - Agents

    func listAgents() async throws -> [Agent] {
        guard let url = baseURL?.appendingPathComponent("/api/agents") else {
            throw APIError.notConfigured
        }

        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(AgentsResponse.self, from: data)
        return result.agents
    }

    func submitTask(capsule: String, agent: String, prompt: String) async throws -> TaskResponse {
        guard let url = baseURL?.appendingPathComponent("/api/agents/tasks") else {
            throw APIError.notConfigured
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let taskRequest = TaskRequest(capsule: capsule, agent: agent, prompt: prompt)
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(taskRequest)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(TaskResponse.self, from: data)
    }
}

// MARK: - API Models

struct SystemStatus: Codable {
    let builderos: BuilderOSInfo
    let network: NetworkInfo
    let timestamp: String

    struct BuilderOSInfo: Codable {
        let root: String
        let branch: String
        let capsules: Int
    }

    struct NetworkInfo: Codable {
        let tailscale_status: String
        let tailscale_ip: String?
    }
}

struct Capsule: Codable, Identifiable {
    var id: String { name }
    let name: String
    let title: String
    let purpose: String
}

struct CapsulesResponse: Codable {
    let count: Int
    let capsules: [Capsule]
}

struct CapsuleDetail: Codable {
    let name: String
    let title: String
    let purpose: String
    let path: String
    let directories: [String]
}

struct Agent: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
}

struct AgentsResponse: Codable {
    let count: Int
    let agents: [Agent]
}

struct TaskRequest: Codable {
    let capsule: String
    let agent: String
    let prompt: String
    let priority: String = "normal"
}

struct TaskResponse: Codable {
    let task_id: String
    let status: String
    let message: String
    let note: String?
}

// MARK: - System Control Models

struct SleepResponse: Codable {
    let success: Bool
    let message: String?
}

// MARK: - Errors

enum APIError: Error, LocalizedError {
    case notConfigured
    case invalidResponse
    case httpError(Int)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Cloudflare Tunnel URL not configured. Please set it in settings."
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

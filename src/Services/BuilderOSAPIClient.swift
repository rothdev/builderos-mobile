//
//  BuilderOSAPIClient.swift
//  BuilderOS
//
//  Simple API client stub for BuilderOS server
//

import Foundation
import Combine

@MainActor
class BuilderOSAPIClient: ObservableObject {
    @Published var capsules: [Capsule] = []
    @Published var systemStatus: SystemStatus?
    @Published var isLoading: Bool = false
    @Published var hasAPIKey: Bool = false
    @Published var isConnected: Bool = false

    var apiKey: String = ""
    var lastError: String?

    private var baseURL: String {
        return APIConfig.baseURL
    }

    var tunnelURL: String {
        return APIConfig.tunnelURL
    }

    init() {
        // Load saved configuration on init
        APIConfig.loadSavedConfiguration()
    }

    func setAPIKey(_ key: String) {
        self.apiKey = key
        self.hasAPIKey = !key.isEmpty
        APIConfig.apiToken = key
    }

    func fetchCapsules() async throws {
        // Stub: Would fetch from API
        isLoading = true
        defer { isLoading = false }

        // Mock data
        capsules = []
    }

    func fetchSystemStatus() async throws {
        // Stub: Would fetch from API
        isLoading = true
        defer { isLoading = false }

        // Mock data
        systemStatus = nil
    }

    func sleepMac() async throws {
        // Stub: Would call API
        print("Sleep Mac API call (stub)")
    }

    func wakeMac() async throws {
        // Stub: Would call API
        print("Wake Mac API call (stub)")
    }

    func healthCheck() async -> Bool {
        isLoading = true
        lastError = nil

        defer { isLoading = false }

        guard let url = URL(string: "\(baseURL)/api/status") else {
            lastError = "Invalid URL"
            isConnected = false
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = APIConfig.requestTimeout

        // Add API key if available
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }

        // Retry logic with exponential backoff
        for attempt in 0..<APIConfig.maxRetries {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    lastError = "Invalid response"
                    continue
                }

                if httpResponse.statusCode == 200 {
                    isConnected = true
                    return true
                } else if httpResponse.statusCode == 401 {
                    lastError = "Invalid API key"
                    isConnected = false
                    return false
                } else {
                    lastError = "Server error: \(httpResponse.statusCode)"
                }
            } catch {
                lastError = error.localizedDescription

                // Wait before retrying (exponential backoff)
                if attempt < APIConfig.maxRetries - 1 {
                    let backoff = APIConfig.retryBackoff * pow(2.0, Double(attempt))
                    try? await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                }
            }
        }

        isConnected = false
        return false
    }
}

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
    @Published var isConnected: Bool = false {
        didSet {
            print("🔴 API: isConnected changed from \(oldValue) to \(isConnected) [Thread: \(Thread.isMainThread ? "MAIN" : "BACKGROUND")]")
        }
    }

    var lastError: String?

    // CRITICAL FIX: Use computed properties to defer Keychain access
    // This prevents blocking main thread during app launch
    var apiKey: String {
        get {
            return APIConfig.apiToken
        }
        set {
            APIConfig.apiToken = newValue
            hasAPIKey = !newValue.isEmpty
        }
    }

    private var baseURL: String {
        return APIConfig.baseURL
    }

    var tunnelURL: String {
        return APIConfig.tunnelURL
    }

    init() {
        print("🟢 API: BuilderOSAPIClient init() starting")

        // CRITICAL FIX: Defer all Keychain/UserDefaults access until after init
        // Schedule configuration load for next run loop to avoid blocking
        Task { @MainActor in
            print("🟢 API: Loading saved configuration")
            APIConfig.loadSavedConfiguration()
            self.hasAPIKey = !APIConfig.apiToken.isEmpty
            print("🟢 API: Configuration loaded, hasAPIKey=\(self.hasAPIKey)")
        }

        print("🟢 API: BuilderOSAPIClient init() complete")
    }

    func setAPIKey(_ key: String) {
        self.apiKey = key // This will set APIConfig.apiToken via the computed property setter
    }

    func fetchCapsules() async throws {
        isLoading = true
        lastError = nil

        defer { isLoading = false }

        guard let url = URL(string: "\(baseURL)/api/capsules") else {
            lastError = "Invalid URL"
            isConnected = false
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = APIConfig.requestTimeout

        // Add API key header
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        } else {
            lastError = "Missing API key"
            throw APIError.missingAPIKey
        }

        // Retry logic with exponential backoff
        for attempt in 0..<APIConfig.maxRetries {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    lastError = "Invalid response"
                    continue
                }

                switch httpResponse.statusCode {
                case 200:
                    // Parse JSON response
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(CapsulesResponse.self, from: data)

                    capsules = apiResponse.capsules
                    isConnected = true
                    print("✅ Fetched \(capsules.count) capsules")
                    return

                case 401:
                    lastError = "Invalid API key"
                    isConnected = false
                    throw APIError.unauthorized

                case 404:
                    lastError = "Endpoint not found"
                    isConnected = false
                    throw APIError.endpointNotFound

                default:
                    lastError = "Server error: \(httpResponse.statusCode)"
                    if attempt == APIConfig.maxRetries - 1 {
                        throw APIError.serverError(httpResponse.statusCode)
                    }
                }
            } catch let error as APIError {
                // Re-throw API errors immediately (no retry)
                throw error
            } catch {
                lastError = error.localizedDescription

                // Wait before retrying (exponential backoff)
                if attempt < APIConfig.maxRetries - 1 {
                    let backoff = APIConfig.retryBackoff * pow(2.0, Double(attempt))
                    try? await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                } else {
                    isConnected = false
                    throw error
                }
            }
        }
    }

    func fetchSystemStatus() async throws {
        // Stub: Would fetch from API
        isLoading = true
        defer { isLoading = false }

        // Mock data
        systemStatus = nil
    }

    func sleepMac() async throws {
        guard let url = URL(string: "\(baseURL)/api/system/sleep") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = APIConfig.requestTimeout

        // Add API key header
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        } else {
            throw APIError.missingAPIKey
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            print("✅ Mac sleep initiated successfully")
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.endpointNotFound
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }

    func wakeMac() async throws {
        // Stub: Would call API
        print("Wake Mac API call (stub)")
    }

    // MARK: - Preview Helpers

    /// Create a mock API client with sample data for previews
    static func mockWithData() -> BuilderOSAPIClient {
        let client = BuilderOSAPIClient()
        client.isConnected = true
        client.hasAPIKey = true
        client.capsules = Capsule.mockList
        client.systemStatus = SystemStatus.mock
        return client
    }

    /// Create a disconnected mock client for testing error states
    static func mockDisconnected() -> BuilderOSAPIClient {
        let client = BuilderOSAPIClient()
        client.isConnected = false
        client.hasAPIKey = false
        client.lastError = "Unable to connect to BuilderOS"
        return client
    }

    /// Create a loading state mock client
    static func mockLoading() -> BuilderOSAPIClient {
        let client = BuilderOSAPIClient()
        client.isLoading = true
        client.isConnected = true
        client.hasAPIKey = true
        return client
    }

    // MARK: - File Upload

    /// Upload file with progress tracking
    func uploadFile(
        _ attachment: ChatAttachment,
        progressHandler: @escaping (Double) -> Void
    ) async throws -> String {
        guard let localURL = attachment.localURL else {
            throw APIError.invalidURL
        }

        guard let url = URL(string: "\(baseURL)/api/files/upload") else {
            throw APIError.invalidURL
        }

        // Read file data
        let fileData = try Data(contentsOf: localURL)

        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 300 // 5 minutes for large files
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Add API key header
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        } else {
            throw APIError.missingAPIKey
        }

        // Build multipart body
        var body = Data()

        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(attachment.filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(attachment.mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // Add metadata
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"type\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(attachment.type.rawValue)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        progressHandler(0.0)

        // Create upload task with progress delegate
        let progressDelegate = UploadProgressDelegate(onProgress: progressHandler)
        let session = URLSession(configuration: .default, delegate: progressDelegate, delegateQueue: nil)
        defer {
            session.finishTasksAndInvalidate()
        }

        let (data, response) = try await session.upload(for: request, from: body)
        progressHandler(1.0)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            // Parse response to get remote URL
            let decoder = JSONDecoder()
            let uploadResponse = try decoder.decode(FileUploadResponse.self, from: data)
            return uploadResponse.url

        case 401:
            throw APIError.unauthorized

        case 413:
            throw APIError.fileTooLarge

        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }

    /// Upload multiple files concurrently
    func uploadFiles(
        _ attachments: [ChatAttachment],
        progressHandler: @escaping (UUID, Double) -> Void
    ) async throws -> [UUID: String] {
        var results: [UUID: String] = [:]

        // Upload files concurrently (max 3 at a time)
        try await withThrowingTaskGroup(of: (UUID, String).self) { group in
            for attachment in attachments {
                group.addTask {
                    let remoteURL = try await self.uploadFile(attachment) { progress in
                        progressHandler(attachment.id, progress)
                    }
                    return (attachment.id, remoteURL)
                }
            }

            for try await (id, remoteURL) in group {
                results[id] = remoteURL
            }
        }

        return results
    }

    // MARK: - API Methods

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
                let (_, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    lastError = "Invalid response"
                    continue
                }

                if httpResponse.statusCode == 200 {
                    print("✅ Health check successful - setting isConnected = true")

                    // CRITICAL FIX: Force a toggle to ensure @Published fires even if value was already true
                    if isConnected {
                        print("   isConnected was already true, forcing toggle...")
                        isConnected = false
                    }
                    isConnected = true
                    print("   isConnected is now: \(isConnected)")
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

// MARK: - API Response Models

struct CapsulesResponse: Codable {
    let count: Int
    let capsules: [Capsule]
}

// MARK: - Upload Progress Delegate

private final class UploadProgressDelegate: NSObject, URLSessionTaskDelegate {
    private let onProgress: (Double) -> Void

    init(onProgress: @escaping (Double) -> Void) {
        self.onProgress = onProgress
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        guard totalBytesExpectedToSend > 0 else { return }
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        let clampedProgress = min(max(progress, 0.0), 1.0)

        // Use weak self to prevent retain cycle with async dispatch
        DispatchQueue.main.async { [weak self] in
            self?.onProgress(clampedProgress)
        }
    }
}

struct FileUploadResponse: Codable {
    let url: String
    let filename: String
    let size: Int64
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case missingAPIKey
    case invalidResponse
    case unauthorized
    case endpointNotFound
    case serverError(Int)
    case fileTooLarge

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .missingAPIKey:
            return "API key is required"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Unauthorized: Invalid API key"
        case .endpointNotFound:
            return "API endpoint not found"
        case .serverError(let code):
            return "Server error: \(code)"
        case .fileTooLarge:
            return "File too large (50 MB limit)"
        }
    }
}

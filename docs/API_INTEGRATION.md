# BuilderOS API Integration Guide

This document details how the iOS app integrates with the BuilderOS API server via Tailscale.

## Network Architecture

```
┌─────────────────┐
│  iPhone App     │
│  (iOS 17+)      │
└────────┬────────┘
         │
         │ Tailscale VPN (encrypted)
         │
         ▼
┌─────────────────┐
│  Mac            │
│  Tailscale IP:  │
│  100.66.202.6   │
└────────┬────────┘
         │
         │ localhost
         │
         ▼
┌─────────────────┐
│  BuilderOS API  │
│  Port 8080      │
│  (Python)       │
└─────────────────┘
```

## Connection Flow

### 1. Tailscale VPN Establishment

```swift
// TailscaleConnectionManager.swift

func connect() async throws {
    // 1. Verify authentication
    guard authenticationState == .authenticated else {
        throw ConnectionError.notAuthenticated
    }

    // 2. Configure VPN with Tailscale settings
    try await configureVPN()

    // 3. Start VPN tunnel
    try vpnManager?.connection.startVPNTunnel()

    // 4. Discover devices on network
    await discoverDevices()
}
```

### 2. Mac Discovery

```swift
func discoverDevices() async {
    // In production: let devices = try await Tailscale.listDevices()

    // Find Mac by hostname pattern
    macDevice = connectedDevices.first { device in
        device.hostName.contains("macbook") ||
        device.os.lowercased().contains("darwin")
    }
}
```

### 3. API Client Auto-Configuration

```swift
// BuilderOSAPIClient.swift

private var baseURL: URL? {
    // Auto-use Tailscale IP from connection manager
    guard let macIP = TailscaleConnectionManager.shared.macDevice?.ipAddress else {
        return nil
    }
    return URL(string: "http://\(macIP):8080")
}
```

## API Endpoints

All endpoints relative to `http://100.66.202.6:8080/api/`

### System Status

**GET** `/api/status`

**Response:**
```json
{
  "version": "2.1.0",
  "uptime": 245678,
  "capsulesCount": 25,
  "activeCapsulesCount": 7,
  "lastAuditTime": "2025-10-22T10:30:00Z",
  "healthStatus": "healthy",
  "services": [
    {
      "id": "api",
      "name": "BuilderOS API",
      "isRunning": true,
      "port": 8080
    }
  ]
}
```

**Swift Implementation:**
```swift
func fetchSystemStatus() async throws -> SystemStatus {
    let endpoint = "/api/status"
    let data = try await performRequest(endpoint: endpoint)
    return try JSONDecoder().decode(SystemStatus.self, from: data)
}
```

### List Capsules

**GET** `/api/capsules`

**Response:**
```json
[
  {
    "id": "jellyfin-server-ops",
    "name": "Jellyfin Server Ops",
    "description": "Media server management",
    "status": "active",
    "createdAt": "2024-09-15T08:00:00Z",
    "updatedAt": "2025-10-21T16:45:00Z",
    "path": "/Users/Ty/BuilderOS/capsules/jellyfin-server-ops",
    "tags": ["media", "server", "automation"]
  }
]
```

**Swift Implementation:**
```swift
func fetchCapsules() async throws -> [Capsule] {
    let endpoint = "/api/capsules"
    let data = try await performRequest(endpoint: endpoint)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode([Capsule].self, from: data)
}
```

### Capsule Details

**GET** `/api/capsules/{id}`

**Parameters:**
- `id` (path) - Capsule identifier

**Response:**
```json
{
  "id": "jellyfin-server-ops",
  "name": "Jellyfin Server Ops",
  "description": "Media server management",
  "status": "active",
  "createdAt": "2024-09-15T08:00:00Z",
  "updatedAt": "2025-10-21T16:45:00Z",
  "path": "/Users/Ty/BuilderOS/capsules/jellyfin-server-ops",
  "tags": ["media", "server", "automation"]
}
```

### Capsule Metrics

**GET** `/api/capsules/{id}/metrics`

**Response:**
```json
{
  "totalFiles": 42,
  "linesOfCode": 3847,
  "lastModified": "2025-10-21T16:45:00Z",
  "diskUsage": 2457600
}
```

**Swift Implementation:**
```swift
func fetchCapsuleMetrics(_ capsuleId: String) async throws -> CapsuleMetrics {
    let endpoint = "/api/capsules/\(capsuleId)/metrics"
    let data = try await performRequest(endpoint: endpoint)
    return try JSONDecoder().decode(CapsuleMetrics.self, from: data)
}
```

### Execute Capsule Action

**POST** `/api/capsules/{id}/actions`

**Request Body:**
```json
{
  "action": "start" | "stop" | "restart" | "deploy"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Action executed successfully",
  "output": "..."
}
```

**Swift Implementation:**
```swift
func executeCapsuleAction(_ capsuleId: String, action: String) async throws {
    let endpoint = "/api/capsules/\(capsuleId)/actions"
    let body = ["action": action]
    _ = try await performRequest(endpoint: endpoint, method: "POST", body: body)
}
```

## Authentication

### API Key Header

All requests include API key in header:

```swift
request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
```

**Example:**
```
GET /api/status HTTP/1.1
Host: 100.66.202.6:8080
X-API-Key: sk-builderos-abc123xyz789...
Content-Type: application/json
```

### API Key Storage

API keys stored securely in iOS Keychain:

```swift
// Save to Keychain
private func saveAPIKey(_ key: String) throws {
    let data = key.data(using: .utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "com.builderos.api",
        kSecAttrAccount as String: "api-key",
        kSecValueData as String: data
    ]

    SecItemDelete(query as CFDictionary)
    let status = SecItemAdd(query as CFDictionary, nil)

    guard status == errSecSuccess else {
        throw APIError.networkError("Failed to save API key")
    }
}

// Load from Keychain
private func loadAPIKey() -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "com.builderos.api",
        kSecAttrAccount as String: "api-key",
        kSecReturnData as String: true
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    guard status == errSecSuccess,
          let data = result as? Data,
          let key = String(data: data, encoding: .utf8) else {
        return nil
    }

    return key
}
```

## Error Handling

### API Error Types

```swift
enum APIError: LocalizedError {
    case noConnection
    case invalidAPIKey
    case networkError(String)
    case decodingError(String)
    case serverError(Int, String)

    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "Not connected to BuilderOS Mac"
        case .invalidAPIKey:
            return "Invalid API key. Check settings."
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Data error: \(message)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        }
    }
}
```

### HTTP Status Code Handling

```swift
private func performRequest(endpoint: String, method: String = "GET", body: [String: Any]? = nil) async throws -> Data {
    // ... request setup ...

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.networkError("Invalid response")
    }

    switch httpResponse.statusCode {
    case 200...299:
        return data
    case 401:
        throw APIError.invalidAPIKey
    case 400...499:
        let message = String(data: data, encoding: .utf8) ?? "Client error"
        throw APIError.serverError(httpResponse.statusCode, message)
    case 500...599:
        let message = String(data: data, encoding: .utf8) ?? "Server error"
        throw APIError.serverError(httpResponse.statusCode, message)
    default:
        throw APIError.networkError("Unexpected status code: \(httpResponse.statusCode)")
    }
}
```

## Network Security

### HTTP over Tailscale

While the API uses HTTP (not HTTPS), it's secure because:

1. ✅ **Tailscale VPN encrypts all traffic** - End-to-end WireGuard encryption
2. ✅ **Localhost connection** - API only listens on localhost, not exposed to internet
3. ✅ **Tailscale network isolation** - Only devices on your Tailscale network can connect
4. ✅ **API key authentication** - Additional layer of authentication

**Traffic flow:**
```
iPhone App → [Tailscale Encrypted Tunnel] → Mac → [Localhost] → API
           (WireGuard encryption)                   (no network)
```

### Info.plist Configuration

Allow HTTP for Tailscale IP:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>100.66.202.6</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <false/>
        </dict>
    </dict>
</dict>
```

## Testing API Integration

### Manual Testing

**1. Test API server from Mac:**
```bash
# Health check
curl http://localhost:8080/api/health

# Status endpoint
curl -H "X-API-Key: sk-builderos-..." http://localhost:8080/api/status

# List capsules
curl -H "X-API-Key: sk-builderos-..." http://localhost:8080/api/capsules
```

**2. Test via Tailscale IP:**
```bash
# From another device on Tailscale network
curl -H "X-API-Key: sk-builderos-..." http://100.66.202.6:8080/api/status
```

### iOS App Testing

**1. Connection test:**
```swift
Task {
    let isConnected = await apiClient.testConnection()
    print("API Connection: \(isConnected ? "✅" : "❌")")
}
```

**2. Fetch data test:**
```swift
Task {
    do {
        let status = try await apiClient.fetchSystemStatus()
        print("System Status: \(status)")

        let capsules = try await apiClient.fetchCapsules()
        print("Capsules: \(capsules.count)")
    } catch {
        print("Error: \(error)")
    }
}
```

## Offline Handling

### Network Availability

The app handles offline scenarios:

```swift
@Published var isConnected: Bool = false

// Monitor VPN connection
private func observeVPNStatus() {
    NotificationCenter.default.publisher(for: .NEVPNStatusDidChange)
        .sink { [weak self] _ in
            Task { @MainActor in
                self?.updateConnectionStatus()
            }
        }
        .store(in: &cancellables)
}

// Update UI based on connection
private func updateConnectionStatus() {
    guard let status = vpnManager?.connection.status else { return }

    switch status {
    case .connected:
        isConnected = true
        Task { await discoverDevices() }
    case .disconnected, .disconnecting, .invalid:
        isConnected = false
    default:
        break
    }
}
```

### Cached Data

For future enhancement, implement caching:

```swift
// Cache capsule data for offline viewing
UserDefaults.standard.set(encodedCapsules, forKey: "cached_capsules")

// Load from cache when offline
if !tailscaleManager.isConnected {
    if let cachedData = UserDefaults.standard.data(forKey: "cached_capsules") {
        capsules = try? JSONDecoder().decode([Capsule].self, from: cachedData)
    }
}
```

## Rate Limiting

No rate limiting currently implemented in BuilderOS API. If needed:

```swift
// Throttle requests using Combine
private var cancellables = Set<AnyCancellable>()

func throttledRefresh() {
    refreshPublisher
        .throttle(for: .seconds(5), scheduler: DispatchQueue.main, latest: true)
        .sink { [weak self] in
            Task {
                await self?.fetchCapsules()
            }
        }
        .store(in: &cancellables)
}
```

## Debugging

### Enable Network Logging

Add to `BuilderOSAPIClient`:

```swift
private func performRequest(...) async throws -> Data {
    // Log request
    print("🌐 Request: \(method) \(url)")
    if let body = body {
        print("📤 Body: \(body)")
    }

    let (data, response) = try await URLSession.shared.data(for: request)

    // Log response
    if let httpResponse = response as? HTTPURLResponse {
        print("📥 Response: \(httpResponse.statusCode)")
        if let json = try? JSONSerialization.jsonObject(with: data) {
            print("📄 Data: \(json)")
        }
    }

    return data
}
```

### Xcode Console

Monitor network activity:

1. **Run app in Xcode**
2. **Open Debug console** (Cmd+Shift+Y)
3. **Filter by "🌐"** to see API requests

### Network Link Conditioner

Test slow/unreliable connections:

1. **Xcode → Settings → Components**
2. **Download "Additional Tools for Xcode"**
3. **Open Network Link Conditioner**
4. **Select profile:** "3G" or "LTE"
5. **Test app performance** under poor network

---

This integration provides seamless, secure access to BuilderOS from your iPhone via Tailscale's encrypted VPN tunnel.

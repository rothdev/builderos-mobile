import SwiftUI

struct SettingsView: View {
    @StateObject private var apiClient = BuilderOSAPIClient()
    @State private var isTestingConnection = false
    @State private var connectionTestResult: String?
    @State private var showSleepConfirmation = false
    @State private var isSleepingMac = false
    @State private var sleepResult: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mac Connection")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cloudflare Tunnel URL")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("https://builderos-xyz.trycloudflare.com", text: $apiClient.tunnelURL)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                            .font(.system(.body, design: .monospaced))
                            .textInputAutocapitalization(.never)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Key")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        SecureField("API Key", text: $apiClient.apiKey)
                            .textContentType(.password)
                            .autocapitalization(.none)
                            .font(.system(.body, design: .monospaced))
                    }

                    Button(action: testConnection) {
                        HStack {
                            if isTestingConnection {
                                ProgressView()
                                    .padding(.trailing, 8)
                            } else {
                                Image(systemName: apiClient.isConnected ? "checkmark.circle.fill" : "antenna.radiowaves.left.and.right")
                                    .foregroundColor(apiClient.isConnected ? .green : .blue)
                                    .padding(.trailing, 8)
                            }
                            Text("Test Connection")
                        }
                    }
                    .disabled(isTestingConnection || apiClient.tunnelURL.isEmpty)

                    if let result = connectionTestResult {
                        Text(result)
                            .font(.caption)
                            .foregroundColor(apiClient.isConnected ? .green : .red)
                    }

                    if let error = apiClient.lastError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                Section(header: Text("Connection Status")) {
                    HStack {
                        Text("Status")
                        Spacer()
                        HStack(spacing: 6) {
                            Circle()
                                .fill(apiClient.isConnected ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            Text(apiClient.isConnected ? "Connected" : "Disconnected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if !apiClient.tunnelURL.isEmpty {
                        HStack {
                            Text("Endpoint")
                            Spacer()
                            Text(apiClient.tunnelURL)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                }

                Section(header: Text("System Control")) {
                    Button(action: {
                        showSleepConfirmation = true
                    }) {
                        HStack {
                            if isSleepingMac {
                                ProgressView()
                                    .padding(.trailing, 8)
                            } else {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(.orange)
                                    .padding(.trailing, 8)
                            }
                            Text("Sleep Mac")
                                .foregroundColor(isSleepingMac ? .secondary : .primary)
                        }
                    }
                    .disabled(!apiClient.isConnected || isSleepingMac)

                    if let result = sleepResult {
                        Text(result)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                Section(header: Text("Setup Instructions")) {
                    VStack(alignment: .leading, spacing: 12) {
                        InstructionStep(
                            number: 1,
                            title: "Setup Cloudflare Tunnel",
                            description: "Backend Dev will create Cloudflare tunnel on Mac"
                        )

                        InstructionStep(
                            number: 2,
                            title: "Get Tunnel URL",
                            description: "Copy the Cloudflare URL (https://builderos-xyz.trycloudflare.com)"
                        )

                        InstructionStep(
                            number: 3,
                            title: "Enter URL Above",
                            description: "Paste the full HTTPS URL in the Cloudflare Tunnel URL field"
                        )

                        InstructionStep(
                            number: 4,
                            title: "Get API Key",
                            description: "Get API token from Mac's BuilderOS API server output"
                        )
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("0.1.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("BuilderOS API")
                        Spacer()
                        Text("v0.1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Sleep Mac", isPresented: $showSleepConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sleep", role: .destructive) {
                    sleepMac()
                }
            } message: {
                Text("Put your Mac to sleep immediately? You'll lose the current connection.")
            }
        }
    }

    private func testConnection() {
        isTestingConnection = true
        connectionTestResult = nil

        Task {
            let success = await apiClient.healthCheck()

            await MainActor.run {
                isTestingConnection = false
                if success {
                    connectionTestResult = "✓ Connected successfully!"
                } else {
                    connectionTestResult = "✗ Connection failed"
                }
            }
        }
    }

    private func sleepMac() {
        isSleepingMac = true
        sleepResult = nil

        Task {
            do {
                let success = try await apiClient.sleepMac()

                await MainActor.run {
                    isSleepingMac = false
                    if success {
                        sleepResult = "✓ Mac is going to sleep..."
                        // Clear connection state since Mac is sleeping
                        apiClient.isConnected = false
                    } else {
                        sleepResult = "✗ Failed to sleep Mac"
                    }
                }
            } catch {
                await MainActor.run {
                    isSleepingMac = false
                    sleepResult = "✗ Error: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 28, height: 28)
                Text("\(number)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
}

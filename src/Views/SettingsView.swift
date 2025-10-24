//
//  SettingsView.swift
//  BuilderOS
//
//  Settings screen with Tailscale and API configuration
//

import SwiftUI
import Inject

struct SettingsView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @ObserveInjection var inject

    @State private var apiKey: String = ""
    @State private var showAPIKeyInput = false
    @State private var showSignOutAlert = false
    @State private var isSaving = false
    @State private var showPowerAlert = false
    @State private var powerAlertMessage = ""
    @State private var isPowerActionInProgress = false

    var body: some View {
        NavigationStack {
            Form {
                // Tailscale section
                Section {
                    connectionStatus
                    tunnelURLRow

                    if apiClient.hasAPIKey {
                        signOutButton
                    }
                } header: {
                    Text("Cloudflare Tunnel")
                } footer: {
                    Text("Secure HTTPS tunnel to BuilderOS API via Cloudflare. Works with Proton VPN on both devices.")
                }

                // API section
                Section {
                    apiKeyRow
                } header: {
                    Text("BuilderOS API")
                } footer: {
                    Text("API key is stored securely in iOS Keychain and never leaves your device.")
                }

                // Power Control section
                Section {
                    powerControlButtons
                } header: {
                    Text("Mac Power Control")
                } footer: {
                    Text("Sleep puts your Mac to sleep immediately. Wake requires Raspberry Pi intermediary device (see documentation).")
                }

                // About section
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "1")

                    Link(destination: URL(string: "https://github.com/builderos")!) {
                        HStack {
                            Text("Documentation")
                            Spacer()
                            Image(systemName: "arrow.up.forward.square")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Clear API Key", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("This will clear your stored API key from Keychain. You'll need to re-enter it to connect.")
            }
            .sheet(isPresented: $showAPIKeyInput) {
                APIKeyInputSheet(apiKey: $apiKey, onSave: saveAPIKey)
            }
            .alert("Power Control", isPresented: $showPowerAlert) {
                Button("OK") { }
            } message: {
                Text(powerAlertMessage)
            }
        }
        .enableInjection()
    }

    private var connectionStatus: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Status")
                    .font(.labelMedium)
                    .foregroundStyle(Color.textSecondary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(apiClient.isConnected ? .green : .red)
                        .frame(width: 8, height: 8)

                    Text(apiClient.isConnected ? "Connected" : "Disconnected")
                        .font(.titleMedium)
                }
            }

            Spacer()

            if apiClient.isLoading {
                ProgressView()
            }
        }
    }

    private var tunnelURLRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Tunnel URL")
                    .font(.labelMedium)
                    .foregroundStyle(Color.textSecondary)

                Text(apiClient.tunnelURL)
                    .font(.monoSmall)
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(1)
            }

            Spacer()
        }
    }

    private var signOutButton: some View {
        Button(role: .destructive) {
            showSignOutAlert = true
        } label: {
            HStack {
                Spacer()
                Text("Clear API Key")
                Spacer()
            }
        }
    }

    private var apiKeyRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("API Key")
                    .font(.labelMedium)

                if apiClient.hasAPIKey {
                    Text("Configured")
                        .font(.labelSmall)
                        .foregroundStyle(.green)
                } else {
                    Text("Not configured")
                        .font(.labelSmall)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            Button(apiClient.hasAPIKey ? "Update" : "Add") {
                showAPIKeyInput = true
            }
        }
    }

    private func saveAPIKey() {
        guard !apiKey.isEmpty else { return }

        isSaving = true

        apiClient.setAPIKey(apiKey)
        apiKey = ""
        showAPIKeyInput = false

        isSaving = false
    }

    private func signOut() {
        // Clear API key from Keychain
        APIConfig.apiToken = ""
        apiClient.setAPIKey("")
    }

    private var powerControlButtons: some View {
        Group {
            Button {
                sleepMac()
            } label: {
                HStack {
                    Image(systemName: "moon.fill")
                        .foregroundStyle(.blue)
                    Text("Sleep Mac")
                    Spacer()
                    if isPowerActionInProgress {
                        ProgressView()
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .disabled(!apiClient.isConnected || !apiClient.hasAPIKey || isPowerActionInProgress)

            Button {
                wakeMac()
            } label: {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(.orange)
                    Text("Wake Mac")
                    Spacer()
                    if isPowerActionInProgress {
                        ProgressView()
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .disabled(!apiClient.isConnected || !apiClient.hasAPIKey || isPowerActionInProgress)
        }
    }

    private func sleepMac() {
        isPowerActionInProgress = true

        Task {
            do {
                try await apiClient.sleepMac()
                await MainActor.run {
                    powerAlertMessage = "Mac is going to sleep..."
                    showPowerAlert = true
                    isPowerActionInProgress = false
                }
            } catch {
                await MainActor.run {
                    powerAlertMessage = "Failed to sleep Mac: \(error.localizedDescription)"
                    showPowerAlert = true
                    isPowerActionInProgress = false
                }
            }
        }
    }

    private func wakeMac() {
        isPowerActionInProgress = true

        Task {
            do {
                try await apiClient.wakeMac()
                await MainActor.run {
                    powerAlertMessage = "Wake feature requires Raspberry Pi intermediary. See documentation for setup."
                    showPowerAlert = true
                    isPowerActionInProgress = false
                }
            } catch {
                await MainActor.run {
                    powerAlertMessage = "Failed to wake Mac: \(error.localizedDescription)"
                    showPowerAlert = true
                    isPowerActionInProgress = false
                }
            }
        }
    }
}

// MARK: - API Key Input Sheet
struct APIKeyInputSheet: View {
    @Binding var apiKey: String
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("API Key", text: $apiKey)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .fontDesign(.monospaced)
                } header: {
                    Text("BuilderOS API Key")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter your BuilderOS API key. You can generate one from your Mac:")

                        Text("cd /Users/Ty/BuilderOS/api\n./server_mode.sh")
                            .font(.caption)
                            .fontDesign(.monospaced)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            .navigationTitle("API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .disabled(apiKey.isEmpty)
                }
            }
        }
    }
}

#Preview("Connected") {
    SettingsView()
        .environmentObject(BuilderOSAPIClient.mockWithData())
}

#Preview("No API Key") {
    SettingsView()
        .environmentObject(BuilderOSAPIClient.mockDisconnected())
}

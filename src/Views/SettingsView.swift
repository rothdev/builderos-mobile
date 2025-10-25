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
            ZStack {
                // Terminal background
                Color.terminalDark
                    .ignoresSafeArea()

                // Subtle radial gradient overlay
                RadialGradient(
                    colors: [
                        Color.terminalPink.opacity(0.08),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: 500
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Cloudflare Tunnel section
                        tunnelSection

                        // API section
                        apiSection

                        // Power Control section
                        powerControlSection

                        // About section
                        aboutSection
                    }
                    .padding()
                }
            }
            .navigationTitle("SETTINGS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .alert("Clear Settings", isPresented: $showSignOutAlert) {
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

    // MARK: - Tunnel Section
    private var tunnelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            TerminalSectionHeader(title: "CLOUDFLARE TUNNEL")

            TerminalCard {
                VStack(spacing: 16) {
                    connectionStatus

                    Divider()
                        .background(Color.terminalInputBorder)

                    tunnelURLRow

                    // Reconnect button (when disconnected)
                    if !apiClient.isConnected && apiClient.hasAPIKey {
                        Divider()
                            .background(Color.terminalInputBorder)

                        Button {
                            Task {
                                let _ = await apiClient.healthCheck()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundStyle(Color.terminalCyan)
                                Text("Reconnect")
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.terminalCyan)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.terminalInputBackground)
                            .terminalBorder(cornerRadius: 8)
                        }
                    }

                    if apiClient.hasAPIKey {
                        Divider()
                            .background(Color.terminalInputBorder)

                        signOutButton
                    }
                }
            }

            Text("Secure HTTPS tunnel to BuilderOS API via Cloudflare. Works with Proton VPN on both devices.")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.terminalDim)
                .padding(.horizontal, 4)
        }
    }

    // MARK: - API Section
    private var apiSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            TerminalSectionHeader(title: "BUILDEROS API")

            TerminalCard {
                apiKeyRow
            }

            Text("API key is stored securely in iOS Keychain and never leaves your device.")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.terminalDim)
                .padding(.horizontal, 4)
        }
    }

    // MARK: - Power Control Section
    private var powerControlSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            TerminalSectionHeader(title: "MAC POWER CONTROL")

            TerminalCard {
                VStack(spacing: 12) {
                    powerControlButtons
                }
            }

            Text("Sleep puts your Mac to sleep immediately. Wake requires Raspberry Pi intermediary device (see documentation).")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.terminalDim)
                .padding(.horizontal, 4)
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            TerminalSectionHeader(title: "ABOUT")

            TerminalCard {
                VStack(spacing: 12) {
                    HStack {
                        Text("Version")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(Color.terminalCode)
                        Spacer()
                        Text("1.0.0")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(.terminalCyan)
                    }

                    Divider()
                        .background(Color.terminalInputBorder)

                    HStack {
                        Text("Build")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(Color.terminalCode)
                        Spacer()
                        Text("1")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(.terminalCyan)
                    }

                    Divider()
                        .background(Color.terminalInputBorder)

                    Link(destination: URL(string: "https://github.com/builderos")!) {
                        HStack {
                            Text("Documentation")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.terminalCyan)
                            Spacer()
                            Image(systemName: "arrow.up.forward.square")
                                .foregroundStyle(Color.terminalCode)
                        }
                    }
                }
            }
        }
    }

    private var connectionStatus: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Status")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.terminalCode)

                TerminalStatusBadge(
                    text: apiClient.isConnected ? "CONNECTED" : "DISCONNECTED",
                    color: apiClient.isConnected ? .terminalGreen : .terminalRed,
                    shouldPulse: apiClient.isConnected
                )
            }

            Spacer()

            if apiClient.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .terminalCyan))
            }
        }
    }

    private var tunnelURLRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tunnel URL")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.terminalCode)

            TextField("https://your-tunnel-url.trycloudflare.com", text: Binding(
                get: { apiClient.tunnelURL },
                set: { newValue in
                    APIConfig.updateTunnelURL(newValue)
                }
            ))
            .font(.system(size: 12, design: .monospaced))
            .foregroundStyle(Color.terminalCyan)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .keyboardType(.URL)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.terminalInputBackground)
            .terminalBorder(cornerRadius: 6)
            .onSubmit {
                Task {
                    _ = await apiClient.healthCheck()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var signOutButton: some View {
        Button {
            showSignOutAlert = true
        } label: {
            HStack {
                Spacer()
                Text("Clear Settings")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.terminalRed)
                Spacer()
            }
            .padding(.vertical, 12)
            .background(Color.terminalRed.opacity(0.1))
            .terminalBorder(color: .terminalRed)
        }
    }

    private var apiKeyRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("API Key")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.terminalCode)

                if apiClient.hasAPIKey {
                    Text("Configured")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.terminalGreen)
                } else {
                    Text("Not configured")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(Color.terminalPink)
                }
            }

            Spacer()

            Button(apiClient.hasAPIKey ? "Update" : "Add") {
                showAPIKeyInput = true
            }
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
            .foregroundColor(.terminalCyan)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.terminalInputBackground)
            .terminalBorder(cornerRadius: 8)
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
                        .foregroundStyle(Color.terminalCyan)
                        .font(.system(size: 18))
                    Text("Sleep Mac")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(buttonEnabled ? .terminalText : .terminalDim)
                    Spacer()
                    if isPowerActionInProgress {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .terminalCyan))
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.terminalCode)
                    }
                }
                .padding(.vertical, 12)
            }
            .disabled(!buttonEnabled)
            .opacity(buttonEnabled ? 1.0 : 0.5)

            Divider()
                .background(Color.terminalInputBorder)

            Button {
                wakeMac()
            } label: {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .foregroundStyle(Color.terminalPink)
                        .font(.system(size: 18))
                    Text("Wake Mac")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(buttonEnabled ? .terminalText : .terminalDim)
                    Spacer()
                    if isPowerActionInProgress {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .terminalCyan))
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.terminalCode)
                    }
                }
                .padding(.vertical, 12)
            }
            .disabled(!buttonEnabled)
            .opacity(buttonEnabled ? 1.0 : 0.5)
        }
    }

    private var buttonEnabled: Bool {
        apiClient.isConnected && apiClient.hasAPIKey && !isPowerActionInProgress
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

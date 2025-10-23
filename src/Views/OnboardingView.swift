//
//  OnboardingView.swift
//  BuilderOS
//
//  Initial onboarding and Cloudflare Tunnel setup
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentStep = 0
    @State private var tunnelURL = ""
    @State private var apiKey = ""
    @State private var isTestingConnection = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Logo and branding
                Image(systemName: "cube.box.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(.blue.gradient)

                VStack(spacing: 16) {
                    Text("BuilderOS")
                        .font(.system(size: 40, weight: .bold, design: .rounded))

                    Text("Connect to your Mac")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Step content
                stepContent

                Spacer()

                // Action buttons
                VStack(spacing: 16) {
                    actionButton

                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                currentStep -= 1
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
            .alert("Connection Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            welcomeStep
        case 1:
            setupStep
        case 2:
            connectionStep
        default:
            EmptyView()
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Access your BuilderOS system from anywhere")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text("Securely connect to your Mac using Cloudflare Tunnel. Fast, encrypted, and works with VPNs.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 300)
        }
    }

    private var setupStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "link.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Enter Connection Details")
                .font(.headline)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cloudflare Tunnel URL")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("https://builderos-xyz.trycloudflare.com", text: $tunnelURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .font(.system(.body, design: .monospaced))
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    SecureField("Enter API Key", text: $apiKey)
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal)

            Text("Get these from your Mac's BuilderOS server output")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
    }

    private var connectionStep: some View {
        VStack(spacing: 16) {
            if isTestingConnection {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                Text("Testing connection...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if apiClient.isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)

                Text("Connected!")
                    .font(.headline)

                VStack(spacing: 8) {
                    Text("BuilderOS Mobile")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(tunnelURL)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontDesign(.monospaced)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.orange)

                Text("Connection failed")
                    .font(.headline)

                Text("Check your tunnel URL and API key, and make sure your Mac's BuilderOS server is running.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 300)
            }
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        Button(action: handleAction) {
            HStack {
                Text(buttonTitle)
                    .fontWeight(.semibold)

                if isTestingConnection {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(actionButtonEnabled ? LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!actionButtonEnabled)
    }

    private var actionButtonEnabled: Bool {
        switch currentStep {
        case 0: return true
        case 1: return !tunnelURL.isEmpty && !apiKey.isEmpty
        case 2: return apiClient.isConnected || !isTestingConnection
        default: return false
        }
    }

    private var buttonTitle: String {
        switch currentStep {
        case 0: return "Get Started"
        case 1: return "Test Connection"
        case 2:
            if isTestingConnection {
                return "Testing..."
            } else if apiClient.isConnected {
                return "Continue to BuilderOS"
            } else {
                return "Try Again"
            }
        default: return "Next"
        }
    }

    private func handleAction() {
        switch currentStep {
        case 0:
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                currentStep = 1
            }
        case 1:
            testConnection()
        case 2:
            if apiClient.isConnected {
                completeOnboarding()
            } else {
                testConnection()
            }
        default:
            break
        }
    }

    private func testConnection() {
        isTestingConnection = true

        // Save credentials
        APIConfig.updateTunnelURL(tunnelURL)
        apiClient.setAPIKey(apiKey)

        Task {
            let success = await apiClient.healthCheck()

            await MainActor.run {
                isTestingConnection = false

                if success {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        currentStep = 2
                    }
                } else {
                    showError = true
                    errorMessage = apiClient.lastError ?? "Connection failed. Please check your credentials."
                }
            }
        }
    }

    private func completeOnboarding() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(BuilderOSAPIClient())
}

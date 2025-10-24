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
            ZStack {
                // Terminal background with gradient
                Color.terminalDark
                    .ignoresSafeArea()

                // Subtle radial gradient overlay
                RadialGradient(
                    colors: [
                        Color.terminalCyan.opacity(0.15),
                        Color.terminalPink.opacity(0.1),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // Logo with terminal aesthetic
                    ZStack {
                        // Glow effect
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.terminalCyan.opacity(0.3),
                                        Color.terminalPink.opacity(0.2),
                                        Color.terminalRed.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)

                        // Logo container with gradient border
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.terminalDark.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [.terminalCyan, .terminalPink, .terminalRed],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: Color.terminalCyan.opacity(0.3), radius: 20)

                            Text("🏗️")
                                .font(.system(size: 64))
                        }
                        .frame(width: 120, height: 120)
                    }

                    VStack(spacing: 16) {
                        TerminalGradientText(text: "$ BUILDEROS", fontSize: 32)

                        Text("Connect to your Mac")
                            .font(.system(size: 18, design: .monospaced))
                            .foregroundStyle(Color.terminalText)
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
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundStyle(Color.terminalText.opacity(0.7))
                        }
                    }
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 24)
            }
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
                .foregroundStyle(
                    LinearGradient(
                        colors: [.terminalCyan, .terminalPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Access your BuilderOS system from anywhere")
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.terminalText)

            Text("Securely connect to your Mac using Cloudflare Tunnel. Fast, encrypted, and works with VPNs.")
                .font(.system(size: 14, design: .monospaced))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.terminalCode)
                .frame(maxWidth: 300)
                .lineSpacing(4)
        }
    }

    private var setupStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "link.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.terminalCyan, .terminalPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Enter Connection Details")
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                .foregroundColor(.terminalText)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cloudflare Tunnel URL")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.terminalCode)

                    TerminalTextField(placeholder: "https://builderos-xyz.trycloudflare.com", text: $tunnelURL)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.terminalCode)

                    TerminalTextField(placeholder: "Enter API Key", text: $apiKey, isSecure: true)
                        .textContentType(.password)
                }
            }
            .padding(.horizontal)

            Text("Get these from your Mac's BuilderOS server output")
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.terminalDim)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
        }
    }

    private var connectionStep: some View {
        VStack(spacing: 16) {
            if isTestingConnection {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .terminalCyan))
                    .scaleEffect(1.5)
                    .padding()
                Text("Testing connection...")
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundStyle(Color.terminalText)
            } else if apiClient.isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.terminalGreen)
                    .shadow(color: .terminalGreen.opacity(0.6), radius: 20)

                Text("Connected!")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.terminalGreen)

                TerminalCard {
                    VStack(spacing: 8) {
                        Text("BuilderOS Mobile")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.terminalCyan)

                        Text(tunnelURL)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(Color.terminalCode)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.terminalRed)

                Text("Connection failed")
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundColor(.terminalRed)

                Text("Check your tunnel URL and API key, and make sure your Mac's BuilderOS server is running.")
                    .font(.system(size: 13, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.terminalCode)
                    .frame(maxWidth: 300)
                    .lineSpacing(4)
            }
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        TerminalButton(title: buttonTitle, action: handleAction, isDisabled: !actionButtonEnabled)
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
        .environmentObject(BuilderOSAPIClient.mockDisconnected())
}

//
//  MainContentView.swift
//  BuilderSystemMobile
//
//  Main app content after onboarding - Self-contained preview version
//

import SwiftUI

// Mock types for preview
struct Capsule: Identifiable {
    let id = UUID()
    let title: String
    let purpose: String
}

@MainActor
class BuilderOSAPIClient: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var tunnelURL: String = "https://tunnel.example.com"

    func listCapsules() async throws -> [Capsule] {
        return []
    }

    func sleepMac() async throws {
        // Mock implementation
    }
}

struct MainContentView: View {
    @StateObject private var apiClient = BuilderOSAPIClient()

    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(apiClient)
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            CapsulesListView()
                .environmentObject(apiClient)
                .tabItem {
                    Label("Capsules", systemImage: "cube.box.fill")
                }

            TerminalPlaceholder()
                .tabItem {
                    Label("Terminal", systemImage: "terminal.fill")
                }

            SettingsView()
                .environmentObject(apiClient)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// Simple Dashboard View
struct DashboardView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Connection Status Card
                    HStack {
                        Image(systemName: apiClient.isConnected ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(apiClient.isConnected ? .green : .orange)
                            .font(.title2)

                        VStack(alignment: .leading) {
                            Text(apiClient.isConnected ? "Connected" : "Disconnected")
                                .font(.headline)
                            Text(apiClient.tunnelURL)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("BuilderOS")
        }
    }
}

// Simple Capsules List
struct CapsulesListView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @State private var capsules: [Capsule] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    ProgressView()
                } else if capsules.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cube.box")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("No Capsules")
                            .font(.title2)
                        Text("Connect to your Mac to view capsules")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ForEach(capsules) { capsule in
                        VStack(alignment: .leading) {
                            Text(capsule.title)
                                .font(.headline)
                            Text(capsule.purpose)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Capsules")
            .task {
                await loadCapsules()
            }
        }
    }

    private func loadCapsules() async {
        isLoading = true
        do {
            capsules = try await apiClient.listCapsules()
        } catch {
            print("Error loading capsules: \(error)")
        }
        isLoading = false
    }
}

// Terminal Placeholder
struct TerminalPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "terminal.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                Text("Terminal")
                    .font(.title2)

                Text("Multi-tab terminal interface")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Terminal")
        }
    }
}

// Simple Settings View
struct SettingsView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Connection") {
                    LabeledContent("Tunnel URL") {
                        Text(apiClient.tunnelURL)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    LabeledContent("Status") {
                        HStack {
                            Circle()
                                .fill(apiClient.isConnected ? .green : .red)
                                .frame(width: 8, height: 8)
                            Text(apiClient.isConnected ? "Connected" : "Disconnected")
                                .font(.caption)
                        }
                    }
                }

                Section("System") {
                    Button("Sleep Mac") {
                        Task {
                            try? await apiClient.sleepMac()
                        }
                    }
                    .foregroundStyle(.orange)

                    Button("Reset Onboarding") {
                        hasCompletedOnboarding = false
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    MainContentView()
}

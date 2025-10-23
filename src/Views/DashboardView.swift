//
//  DashboardView.swift
//  BuilderOS
//
//  Main dashboard with system status and capsule list
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @State private var systemStatus: SystemStatus?
    @State private var isRefreshing = false
    @State private var isLoading = false
    @State private var capsules: [Capsule] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Connection status
                    connectionStatusCard

                    // System status
                    if let status = systemStatus {
                        systemStatusCard(status)
                    }

                    // Capsules section
                    capsulesSection

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("BuilderOS")
            .refreshable {
                await refreshData()
            }
            .task {
                await loadInitialData()
            }
        }
    }

    private var connectionStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: apiClient.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(apiClient.isConnected ? .green : .red)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(apiClient.isConnected ? "Connected" : "Disconnected")
                        .font(.headline)

                    if apiClient.isConnected {
                        Text("BuilderOS Mobile")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if isRefreshing {
                    ProgressView()
                }
            }

            if !apiClient.tunnelURL.isEmpty {
                Divider()

                HStack {
                    Label(apiClient.tunnelURL, systemImage: "network")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontDesign(.monospaced)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Label("Cloudflare Tunnel", systemImage: "lock.shield.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func systemStatusCard(_ status: SystemStatus) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("System Status")
                    .font(.headline)

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(colorForHealth(status.healthStatus))
                        .frame(width: 8, height: 8)

                    Text(status.healthStatus.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                statItem(title: "Version", value: status.version, icon: "tag.fill")
                statItem(title: "Uptime", value: status.uptimeFormatted, icon: "clock.fill")
                statItem(title: "Capsules", value: "\(status.activeCapsulesCount)/\(status.capsulesCount)", icon: "cube.box.fill")
                statItem(title: "Services", value: "\(status.services.filter { $0.isRunning }.count)/\(status.services.count)", icon: "server.rack")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.background.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var capsulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Capsules")
                .font(.headline)
                .padding(.horizontal, 4)

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else if capsules.isEmpty {
                emptyState
            } else {
                capsulesGrid
            }
        }
    }

    private var capsulesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(capsules) { capsule in
                NavigationLink {
                    CapsuleDetailView(capsule: capsule)
                } label: {
                    CapsuleCard(capsule: capsule)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cube.transparent")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No capsules found")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    private func colorForHealth(_ health: SystemStatus.HealthStatus) -> Color {
        switch health {
        case .healthy: return .green
        case .degraded: return .orange
        case .down: return .red
        }
    }

    private func loadInitialData() async {
        isLoading = true
        isRefreshing = true

        do {
            try? await apiClient.fetchSystemStatus()
            systemStatus = apiClient.systemStatus
            try? await apiClient.fetchCapsules()
            capsules = apiClient.capsules
        }

        isLoading = false
        isRefreshing = false
    }

    private func refreshData() async {
        await loadInitialData()
    }
}

// MARK: - Capsule Card Component
struct CapsuleCard: View {
    let capsule: Capsule

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cube.box.fill")
                    .foregroundStyle(.blue)

                Spacer()
            }

            Text(capsule.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(capsule.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DashboardView()
        .environmentObject(BuilderOSAPIClient())
}

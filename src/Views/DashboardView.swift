//
//  DashboardView.swift
//  BuilderOS
//
//  Main dashboard with system status and capsule list
//

import SwiftUI
import Inject

struct DashboardView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @ObserveInjection var inject
    @State private var systemStatus: SystemStatus?
    @State private var isRefreshing = false
    @State private var isLoading = false
    @State private var capsules: [Capsule] = []
    @State private var connectionState: Bool = false  // Local copy to force UI updates

    var body: some View {
        let _ = print("🟢 DASH: DashboardView body rendering, isLoading=\(isLoading), capsules.count=\(capsules.count), apiClient.isConnected=\(apiClient.isConnected)")

        return NavigationStack {
            ZStack {
                // Terminal background
                Color.terminalDark
                    .ignoresSafeArea()

                // Subtle radial gradient overlay
                RadialGradient(
                    colors: [
                        Color.terminalCyan.opacity(0.1),
                        Color.terminalPink.opacity(0.05),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 0,
                    endRadius: 600
                )
                .ignoresSafeArea()

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
            }
            .navigationTitle("BUILDEROS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .refreshable {
                await refreshData()
            }
            .task {
                await loadInitialData()
            }
        }
        .enableInjection()
    }

    private var connectionStatusCard: some View {
        TerminalCard {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: connectionState ? "bolt.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(connectionState ? Color.terminalCyan : Color.terminalRed)
                        .font(.system(size: 20))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(connectionState ? "Connected" : "Disconnected")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(connectionState ? .terminalCyan : .terminalRed)

                        if connectionState {
                            Text("BuilderOS Mobile")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(Color.terminalCode)
                        }
                    }

                    Spacer()

                    if isRefreshing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .terminalCyan))
                    }
                }

                if !apiClient.tunnelURL.isEmpty {
                    Divider()
                        .background(Color.terminalInputBorder)

                    HStack {
                        Label(apiClient.tunnelURL, systemImage: "network")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(Color.terminalCode)
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer()

                        Label("Cloudflare Tunnel", systemImage: "lock.shield.fill")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(Color.terminalDim)
                    }
                }

                // Reconnect button
                if !connectionState {
                    Divider()
                        .background(Color.terminalInputBorder)

                    Button {
                        Task {
                            isRefreshing = true
                            let success = await apiClient.healthCheck()
                            connectionState = success
                            isRefreshing = false
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
            }
        }
    }

    private func systemStatusCard(_ status: SystemStatus) -> some View {
        TerminalCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TerminalSectionHeader(title: "SYSTEM STATUS")

                    Spacer()

                    TerminalStatusBadge(
                        text: status.healthStatus.displayName.uppercased(),
                        color: colorForHealth(status.healthStatus),
                        shouldPulse: status.healthStatus == .healthy
                    )
                }

                // Stats grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    statItem(title: "Version", value: status.version, icon: "tag.fill")
                    statItem(title: "Uptime", value: status.uptimeFormatted, icon: "clock.fill")
                    statItem(title: "Capsules", value: "\(status.activeCapsulesCount)/\(status.capsulesCount)", icon: "cube.box.fill")
                    statItem(title: "Services", value: "\(status.services.filter { $0.isRunning }.count)/\(status.services.count)", icon: "server.rack")
                }
            }
        }
    }

    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
            }
            .foregroundStyle(Color.terminalCode)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundColor(.terminalCyan)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.terminalInputBackground)
        .terminalBorder(cornerRadius: 8)
    }

    private var capsulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TerminalSectionHeader(title: "CAPSULES")
                .padding(.horizontal, 4)

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .terminalCyan))
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
                .foregroundStyle(Color.terminalCyan.opacity(0.3))

            Text("No capsules found")
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.terminalCode)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    private func colorForHealth(_ health: SystemStatus.HealthStatus) -> Color {
        switch health {
        case .healthy: return .terminalGreen
        case .degraded: return .terminalPink
        case .down: return .terminalRed
        }
    }

    private func loadInitialData() async {
        print("🔵 DASH: loadInitialData() starting")
        isLoading = true
        isRefreshing = true

        // First check connection health
        print("🔵 DASH: Calling healthCheck...")
        let healthResult = await apiClient.healthCheck()
        connectionState = healthResult  // Update local state to force UI refresh
        print("🔵 DASH: healthCheck returned: \(healthResult), apiClient.isConnected = \(apiClient.isConnected), connectionState = \(connectionState)")

        // Then fetch data
        do {
            try? await apiClient.fetchSystemStatus()
            systemStatus = apiClient.systemStatus
            try? await apiClient.fetchCapsules()
            capsules = apiClient.capsules
        }

        isLoading = false
        isRefreshing = false
        print("🔵 DASH: loadInitialData() complete, final isConnected = \(apiClient.isConnected)")
    }

    private func refreshData() async {
        await loadInitialData()
    }
}

// MARK: - Capsule Card Component
struct CapsuleCard: View {
    let capsule: Capsule
    @ObserveInjection var inject

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cube.box.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.terminalCyan, .terminalPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.system(size: 20))

                Spacer()
            }

            Text(capsule.title)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.terminalCyan)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(capsule.purpose)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color.terminalCode)
                .lineLimit(2)
        }
        .padding()
        .background(.ultraThinMaterial)
        .terminalBorder()
        .enableInjection()
    }
}

#Preview("Connected") {
    DashboardView()
        .environmentObject(BuilderOSAPIClient.mockWithData())
}

#Preview("Disconnected") {
    DashboardView()
        .environmentObject(BuilderOSAPIClient.mockDisconnected())
}

#Preview("Loading") {
    DashboardView()
        .environmentObject(BuilderOSAPIClient.mockLoading())
}

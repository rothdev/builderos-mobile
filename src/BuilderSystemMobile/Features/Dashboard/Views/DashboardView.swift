import SwiftUI

struct DashboardView: View {
    @StateObject private var apiClient = BuilderOSAPIClient()
    @State private var capsules: [Capsule] = []
    @State private var systemStatus: SystemStatus?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSettings = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Connection Status Card
                    ConnectionStatusCard(
                        isConnected: apiClient.isConnected,
                        systemStatus: systemStatus,
                        onRefresh: loadData
                    )

                    // Capsules Section
                    if !capsules.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Capsules")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(capsules) { capsule in
                                NavigationLink(destination: CapsuleDetailView(capsuleName: capsule.name)) {
                                    CapsuleCard(capsule: capsule)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }

                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            QuickActionButton(
                                icon: "terminal",
                                title: "Agents",
                                color: .blue,
                                action: { }
                            )

                            QuickActionButton(
                                icon: "doc.text",
                                title: "Logs",
                                color: .green,
                                action: { }
                            )

                            QuickActionButton(
                                icon: "chart.bar",
                                title: "Metrics",
                                color: .orange,
                                action: { }
                            )

                            QuickActionButton(
                                icon: "gearshape",
                                title: "Settings",
                                color: .gray,
                                action: { showSettings = true }
                            )
                        }
                        .padding(.horizontal)
                    }

                    if let error = errorMessage {
                        ErrorCard(message: error)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("BuilderOS")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: loadData) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .task {
            await checkConnection()
        }
    }

    private func checkConnection() async {
        let connected = await apiClient.healthCheck()
        if connected {
            await loadData()
        } else {
            await MainActor.run {
                showSettings = true
            }
        }
    }

    private func loadData() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Load system status
                let status = try await apiClient.getSystemStatus()
                await MainActor.run {
                    systemStatus = status
                }

                // Load capsules
                let fetchedCapsules = try await apiClient.listCapsules()
                await MainActor.run {
                    capsules = fetchedCapsules
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

struct ConnectionStatusCard: View {
    let isConnected: Bool
    let systemStatus: SystemStatus?
    let onRefresh: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(isConnected ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(isConnected ? "Connected" : "Disconnected")
                            .font(.headline)
                    }

                    if let status = systemStatus {
                        Text("Branch: \(status.builderos.branch)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if let status = systemStatus {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(status.builderos.capsules)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Capsules")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            if let status = systemStatus,
               let tailscaleIP = status.network.tailscale_ip {
                HStack {
                    Image(systemName: "network")
                        .foregroundColor(.blue)
                    Text(tailscaleIP)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct CapsuleCard: View {
    let capsule: Capsule

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(capsule.title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(capsule.purpose)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct ErrorCard: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

struct CapsuleDetailView: View {
    let capsuleName: String
    @StateObject private var apiClient = BuilderOSAPIClient()
    @State private var capsuleDetail: CapsuleDetail?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            if let detail = capsuleDetail {
                VStack(alignment: .leading, spacing: 16) {
                    Text(detail.title)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(detail.purpose)
                        .font(.body)
                        .foregroundColor(.secondary)

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Directories")
                            .font(.headline)

                        ForEach(detail.directories, id: \.self) { dir in
                            HStack {
                                Image(systemName: "folder")
                                    .foregroundColor(.blue)
                                Text(dir)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
            } else if isLoading {
                ProgressView()
            } else {
                Text("Failed to load capsule details")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle(capsuleName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadDetail()
        }
    }

    private func loadDetail() async {
        do {
            let detail = try await apiClient.getCapsule(name: capsuleName)
            await MainActor.run {
                capsuleDetail = detail
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    DashboardView()
}

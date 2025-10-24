//
//  LocalhostPreviewView.swift
//  BuilderOS
//
//  Localhost preview with quick links and designed header
//

import SwiftUI
import WebKit

struct QuickLink: Identifiable {
    let id = UUID()
    let name: String
    let port: String
    let description: String
}

struct LocalhostPreviewView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    @State private var currentURL: URL?
    @State private var customPort: String = ""
    @State private var isLoading = false
    @State private var selectedLinkID: UUID?

    let quickLinks = [
        QuickLink(name: "React/Next.js", port: "3000", description: "Development server"),
        QuickLink(name: "n8n Workflows", port: "5678", description: "Workflow automation"),
        QuickLink(name: "BuilderOS API", port: "8080", description: "System API"),
        QuickLink(name: "Vite/Vue", port: "5173", description: "Frontend tooling"),
        QuickLink(name: "Flask/Django", port: "5000", description: "Python web apps")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header section
            connectionHeader

            // Quick links horizontal scroll
            quickLinksSection

            // Custom port input
            customPortSection

            // WebView or empty state
            if let url = currentURL {
                WebView(url: url, isLoading: $isLoading)
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                previewEmptyState
            }
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Connection Header
    private var connectionHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "network")
                .font(.titleSmall)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(apiClient.isConnected ? "Connected" : "Not Connected")
                    .font(.titleMedium)

                if apiClient.isConnected {
                    Text("Cloudflare Tunnel")
                        .font(.monoSmall)
                        .foregroundColor(Color.textSecondary)
                }
            }

            Spacer()

            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }

    // MARK: - Quick Links
    private var quickLinksSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(quickLinks) { link in
                    QuickLinkButton(
                        link: link,
                        isSelected: selectedLinkID == link.id,
                        action: {
                            loadQuickLink(link)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Custom Port Input
    private var customPortSection: some View {
        HStack(spacing: 12) {
            TextField("Custom port (e.g., 3001)", text: $customPort)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()

            Button {
                loadCustomPort()
            } label: {
                Text("Go")
                    .font(.titleMedium)
                    .foregroundColor(.white)
                    .frame(width: 60)
                    .padding(.vertical, 8)
                    .background(customPort.isEmpty ? Color.gray : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(customPort.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
    }

    // MARK: - Empty State
    private var previewEmptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "globe.americas")
                .font(.system(size: 64))
                .foregroundColor(.blue.opacity(0.3))

            Text("Preview Localhost")
                .font(.titleLarge)

            Text("Select a quick link or enter\na custom port to preview\nyour dev servers via Cloudflare Tunnel.")
                .font(.bodyMedium)
                .foregroundColor(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    // MARK: - Actions
    private func loadQuickLink(_ link: QuickLink) {
        guard apiClient.isConnected,
              let baseURL = URL(string: apiClient.tunnelURL) else { return }

        selectedLinkID = link.id

        // Construct URL with port path
        // Note: This assumes Backend Dev configured tunnel with port routing
        // e.g., https://tunnel.com/port-3000 → localhost:3000
        let urlString = "\(baseURL.absoluteString)/port-\(link.port)"

        if let url = URL(string: urlString) {
            currentURL = url
        }
    }

    private func loadCustomPort() {
        guard !customPort.isEmpty,
              apiClient.isConnected,
              let baseURL = URL(string: apiClient.tunnelURL) else { return }

        selectedLinkID = nil
        let urlString = "\(baseURL.absoluteString)/port-\(customPort)"

        if let url = URL(string: urlString) {
            currentURL = url
        }

        customPort = ""
    }
}

// MARK: - Quick Link Button
struct QuickLinkButton: View {
    let link: QuickLink
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(link.name)
                    .font(.titleMedium)

                Text(":\(link.port)")
                    .font(.monoSmall)
                    .opacity(isSelected ? 0.8 : 1.0)

                Text(link.description)
                    .font(.bodySmall)
                    .opacity(isSelected ? 0.7 : 1.0)
            }
            .foregroundColor(isSelected ? .white : Color.textPrimary)
            .frame(width: 140, alignment: .leading)
            .padding(12)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool

        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
    }
}

#Preview {
    LocalhostPreviewView()
}

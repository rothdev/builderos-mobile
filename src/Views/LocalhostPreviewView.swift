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
        ZStack {
            // Terminal background
            Color.terminalDark
                .ignoresSafeArea()

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
        }
    }

    // MARK: - Connection Header
    private var connectionHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: "network")
                .font(.system(size: 18))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.terminalCyan, .terminalPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(apiClient.isConnected ? "Connected" : "Not Connected")
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(apiClient.isConnected ? .terminalCyan : .terminalRed)

                if apiClient.isConnected {
                    Text("Cloudflare Tunnel")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.terminalCode)
                }
            }

            Spacer()

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .terminalCyan))
                    .scaleEffect(0.8)
            }
        }
        .padding()
        .background(Color.terminalInputBackground.opacity(0.8))
        .overlay(
            Rectangle()
                .fill(Color.terminalInputBorder)
                .frame(height: 1),
            alignment: .bottom
        )
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
        .background(Color.terminalDark)
    }

    // MARK: - Custom Port Input
    private var customPortSection: some View {
        HStack(spacing: 12) {
            TerminalTextField(placeholder: "Custom port (e.g., 3001)", text: $customPort)
                .keyboardType(.numberPad)

            Button {
                loadCustomPort()
            } label: {
                Text("Go")
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: 60)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: customPort.isEmpty ?
                                [.gray, .gray] :
                                [.terminalCyan, .terminalPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .terminalCyan.opacity(customPort.isEmpty ? 0 : 0.4), radius: 8)
            }
            .disabled(customPort.isEmpty)
        }
        .padding()
        .background(Color.terminalDark)
    }

    // MARK: - Empty State
    private var previewEmptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "globe.americas")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.terminalCyan.opacity(0.3), .terminalPink.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            TerminalGradientText(text: "Preview Localhost", fontSize: 22, fontWeight: .bold)

            Text("Select a quick link or enter\na custom port to preview\nyour dev servers via Cloudflare Tunnel.")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(Color.terminalCode)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.terminalDark)
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
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))

                Text(":\(link.port)")
                    .font(.system(size: 12, design: .monospaced))
                    .opacity(isSelected ? 0.9 : 1.0)

                Text(link.description)
                    .font(.system(size: 11, design: .monospaced))
                    .opacity(isSelected ? 0.7 : 1.0)
            }
            .foregroundColor(isSelected ? .white : Color.terminalText)
            .frame(width: 140, alignment: .leading)
            .padding(12)
            .background(
                isSelected ?
                    AnyView(LinearGradient(
                        colors: [.terminalCyan, .terminalPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )) :
                    AnyView(Color.terminalInputBackground)
            )
            .terminalBorder(color: isSelected ? .terminalCyan : .terminalInputBorder)
            .shadow(color: isSelected ? .terminalCyan.opacity(0.4) : .clear, radius: 8)
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

//
//  BuilderOSApp.swift
//  BuilderOS
//
//  Main app entry point with Cloudflare Tunnel connectivity
//

import SwiftUI

@main
struct BuilderOSApp: App {
    @StateObject private var apiClient = BuilderOSAPIClient()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        print("🟢 APP: BuilderOSApp init() starting")

        // Load saved configuration (tunnel URL + API key)
        APIConfig.loadSavedConfiguration()
        print("🟢 APP: Loaded API configuration")

        #if DEBUG
        // DEVELOPMENT: Skip onboarding for faster testing
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        print("🟢 APP: Development mode - onboarding skipped")
        #endif

        print("🟢 APP: BuilderOSApp init() complete")
    }

    var body: some Scene {
        let _ = print("🟢 APP: Building WindowGroup, hasCompletedOnboarding=\(hasCompletedOnboarding)")

        return WindowGroup {
            #if DEBUG
            // DEVELOPMENT: Always show main content in debug builds
            MainContentView()
                .environmentObject(apiClient)
                .onAppear {
                    print("🟢 APP: DEBUG mode - showing MainContentView directly")
                }
            #else
            if hasCompletedOnboarding {
                MainContentView()
                    .environmentObject(apiClient)
            } else {
                OnboardingView()
                    .environmentObject(apiClient)
            }
            #endif
        }
    }
}
            


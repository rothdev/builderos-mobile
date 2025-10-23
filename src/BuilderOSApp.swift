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

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainContentView()
                    .environmentObject(apiClient)
            } else {
                OnboardingView()
                    .environmentObject(apiClient)
            }
        }
    }
}
            


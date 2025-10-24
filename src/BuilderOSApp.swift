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
        #if DEBUG
        // Load InjectionIII bundle for hot reload on real devices
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        #endif
    }

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
            


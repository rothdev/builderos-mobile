import SwiftUI

// Note: The actual app implementation is in BuilderSystemMobile/App/
// This file exists for backward compatibility with the old Xcode project structure
// Please use the main project at src/BuilderSystemMobile/ instead

@main
struct BuilderSystemMobileApp: App {
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
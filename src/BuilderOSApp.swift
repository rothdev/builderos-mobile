//
//  BuilderOSApp.swift
//  BuilderOS
//
//  Main app entry point with Cloudflare Tunnel connectivity
//

import SwiftUI
import UserNotifications

@main
struct BuilderOSApp: App {
    @StateObject private var apiClient = BuilderOSAPIClient()
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        print("🟢 APP: BuilderOSApp init() starting")

        // Load saved configuration (tunnel URL + API key)
        APIConfig.loadSavedConfiguration()
        print("🟢 APP: Loaded API configuration")

        // Configure notification center delegate
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        print("🟢 APP: Notification delegate configured")

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
                .environmentObject(notificationManager)
                .onAppear {
                    print("🟢 APP: DEBUG mode - showing MainContentView directly")
                    requestNotificationPermissions()
                }
            #else
            if hasCompletedOnboarding {
                MainContentView()
                    .environmentObject(apiClient)
                    .environmentObject(notificationManager)
                    .onAppear {
                        requestNotificationPermissions()
                    }
            } else {
                OnboardingView()
                    .environmentObject(apiClient)
                    .environmentObject(notificationManager)
            }
            #endif
        }
    }

    // MARK: - Notification Permission Request

    /// Request notification permissions on app launch
    private func requestNotificationPermissions() {
        Task {
            await notificationManager.requestAuthorization()
        }
    }
}

// MARK: - UIApplicationDelegate Methods

extension BuilderOSApp {
    /// Handle successful device token registration
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            notificationManager.didRegisterForRemoteNotifications(deviceToken: deviceToken)
        }
    }

    /// Handle device token registration failure
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task { @MainActor in
            notificationManager.didFailToRegisterForRemoteNotifications(error: error)
        }
    }
}
            


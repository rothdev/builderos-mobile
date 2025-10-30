//
//  BuilderOSApp.swift
//  BuilderOS
//
//  Main app entry point with Cloudflare Tunnel connectivity
//

import SwiftUI
import UserNotifications
import BackgroundTasks

@main
struct BuilderOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var apiClient = BuilderOSAPIClient()
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        print("🟢 APP: BuilderOSApp init() starting")

        // Set window background to prevent blue flash on launch
        // CRITICAL: Must be done in init() before any views render
        configureWindowBackground()

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

    /// Configure window background color to match terminalDark
    /// Prevents blue flash on app launch by setting background before views render
    private func configureWindowBackground() {
        // Terminal dark color: RGB(10, 14, 26)
        let terminalDarkUIColor = UIColor(red: 10/255, green: 14/255, blue: 26/255, alpha: 1.0)

        // Set default window background for all scenes
        UIWindow.appearance().backgroundColor = terminalDarkUIColor
        print("🟢 APP: Window background configured to terminalDark")
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

// MARK: - AppDelegate for Background Tasks and Push Notifications

class AppDelegate: NSObject, UIApplicationDelegate {
    private static let backgroundRefreshIdentifier = "com.builderos.ios.refresh"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("🟢 APP: AppDelegate didFinishLaunching")

        // Register background tasks
        registerBackgroundTasks()

        // Enable background fetch
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        return true
    }

    // MARK: - Background Fetch (Legacy API - still useful for iOS compatibility)

    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("🔄 BACKGROUND: Performing background fetch")

        Task {
            do {
                // Check for new messages across all active sessions
                let hasNewData = try await performBackgroundSync()

                if hasNewData {
                    print("✅ BACKGROUND: New data fetched")
                    completionHandler(.newData)
                } else {
                    print("ℹ️ BACKGROUND: No new data")
                    completionHandler(.noData)
                }
            } catch {
                print("❌ BACKGROUND: Fetch failed: \(error)")
                completionHandler(.failed)
            }
        }
    }

    // MARK: - Background Tasks (Modern API)

    private func registerBackgroundTasks() {
        // Register background refresh task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: Self.backgroundRefreshIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
        }

        print("✅ BACKGROUND: Tasks registered")
    }

    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.backgroundRefreshIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now

        do {
            try BGTaskScheduler.shared.submit(request)
            print("📅 BACKGROUND: Refresh scheduled")
        } catch {
            print("❌ BACKGROUND: Failed to schedule refresh: \(error)")
        }
    }

    private func handleBackgroundRefresh(task: BGAppRefreshTask) {
        print("🔄 BACKGROUND: Handling app refresh task")

        // Schedule next refresh
        scheduleBackgroundRefresh()

        let refreshTask = Task {
            do {
                let hasNewData = try await performBackgroundSync()
                task.setTaskCompleted(success: hasNewData)
            } catch {
                print("❌ BACKGROUND: Refresh failed: \(error)")
                task.setTaskCompleted(success: false)
            }
        }

        // Handle task expiration
        task.expirationHandler = {
            print("⚠️ BACKGROUND: Task expired")
            refreshTask.cancel()
        }
    }

    // MARK: - Background Sync Logic

    @MainActor
    private func performBackgroundSync() async throws -> Bool {
        // This would check for new messages in active chat sessions
        // For now, return false - we'll implement with backend integration
        print("🔄 BACKGROUND: Checking for updates...")

        // TODO: Implement actual background sync
        // - Get list of active sessions from ChatServiceManager
        // - Check each session for new messages
        // - Send local notifications for new messages
        // - Return true if any new messages found

        return false
    }

    // MARK: - Remote Notifications

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            NotificationManager.shared.didRegisterForRemoteNotifications(deviceToken: deviceToken)

            // Schedule first background refresh after registration
            scheduleBackgroundRefresh()
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task { @MainActor in
            NotificationManager.shared.didFailToRegisterForRemoteNotifications(error: error)
        }
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("📱 PUSH: Received remote notification")

        Task { @MainActor in
            // Handle silent push notification for background updates
            if let messageType = userInfo["type"] as? String, messageType == "new_message" {
                print("💬 PUSH: New message notification received")

                // Trigger local notification
                if let senderName = userInfo["sender"] as? String,
                   let messagePreview = userInfo["preview"] as? String {
                    await NotificationManager.shared.sendMessageNotification(
                        from: senderName,
                        preview: messagePreview
                    )
                    completionHandler(.newData)
                    return
                }
            }

            completionHandler(.noData)
        }
    }
}



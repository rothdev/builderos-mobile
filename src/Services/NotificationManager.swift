//
//  NotificationManager.swift
//  BuilderOS
//
//  Push notification management for BuilderOS job completion alerts
//

import Foundation
import UserNotifications
import UIKit

/// Manages push notifications for BuilderOS agent job completion
@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    // MARK: - Published State

    /// Whether user has granted notification permission
    @Published var isAuthorized = false

    /// Current device token (for APNs)
    @Published var deviceToken: String?

    /// Last notification received
    @Published var lastNotification: UNNotification?

    // MARK: - Initialization

    override init() {
        super.init()
        checkAuthorizationStatus()
    }

    // MARK: - Permission Management

    /// Request notification permission from user
    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])

            isAuthorized = granted

            if granted {
                print("📱 NOTIFICATION: Permission granted")
                registerForRemoteNotifications()
            } else {
                print("⚠️ NOTIFICATION: Permission denied")
            }
        } catch {
            print("❌ NOTIFICATION: Authorization failed: \(error)")
            isAuthorized = false
        }
    }

    /// Check current authorization status
    func checkAuthorizationStatus() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            isAuthorized = settings.authorizationStatus == .authorized
            print("📱 NOTIFICATION: Current authorization status: \(settings.authorizationStatus.rawValue)")
        }
    }

    /// Register for remote push notifications (APNs)
    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
            print("📱 NOTIFICATION: Registered for remote notifications")
        }
    }

    // MARK: - Device Token Handling

    /// Handle successful device token registration
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        self.deviceToken = token
        print("📱 NOTIFICATION: Device token received: \(token)")

        // TODO: Send token to BuilderOS API
        // POST /api/notifications/register
        // Body: { "device_token": token, "api_key": savedAPIKey }
    }

    /// Handle device token registration failure
    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("❌ NOTIFICATION: Failed to register for remote notifications: \(error)")
        deviceToken = nil
    }

    // MARK: - Local Notification Testing (MVP)

    /// Send a test notification (for testing without backend)
    func sendTestNotification(
        title: String = "BuilderOS Job Complete",
        body: String = "Your agent task has finished successfully.",
        delay: TimeInterval = 1.0
    ) async {
        guard isAuthorized else {
            print("⚠️ NOTIFICATION: Cannot send test notification - not authorized")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: 1)

        // Add custom data for handling notification tap
        content.userInfo = [
            "type": "job_completion",
            "timestamp": Date().timeIntervalSince1970
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("📱 NOTIFICATION: Test notification scheduled")
        } catch {
            print("❌ NOTIFICATION: Failed to schedule test notification: \(error)")
        }
    }

    /// Quick test notification examples
    func sendBuildCompleteNotification() async {
        await sendTestNotification(
            title: "Build Complete ✅",
            body: "iOS app built successfully in 45 seconds"
        )
    }

    func sendTestsPassedNotification() async {
        await sendTestNotification(
            title: "Tests Passed ✅",
            body: "All 127 tests passed. Code coverage: 89%"
        )
    }

    func sendDeploymentCompleteNotification() async {
        await sendTestNotification(
            title: "Deployment Complete 🚀",
            body: "BuilderOS Mobile deployed to TestFlight"
        )
    }

    func sendAgentJobCompleteNotification(agentName: String, taskDescription: String) async {
        await sendTestNotification(
            title: "\(agentName) Complete",
            body: taskDescription
        )
    }

    // MARK: - Badge Management

    /// Clear notification badge
    func clearBadge() {
        Task {
            do {
                try await UNUserNotificationCenter.current().setBadgeCount(0)
                print("📱 NOTIFICATION: Badge cleared")
            } catch {
                print("❌ NOTIFICATION: Failed to clear badge: \(error)")
            }
        }
    }

    /// Set badge count
    func setBadge(count: Int) {
        Task {
            do {
                try await UNUserNotificationCenter.current().setBadgeCount(count)
                print("📱 NOTIFICATION: Badge set to \(count)")
            } catch {
                print("❌ NOTIFICATION: Failed to set badge: \(error)")
            }
        }
    }

    // MARK: - Notification Handling

    /// Handle notification received while app in foreground
    func handleForegroundNotification(_ notification: UNNotification) {
        lastNotification = notification
        print("📱 NOTIFICATION: Received in foreground: \(notification.request.content.title)")
    }

    /// Handle notification tap
    func handleNotificationTap(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        print("📱 NOTIFICATION: User tapped notification with userInfo: \(userInfo)")

        // TODO: Navigate to relevant screen based on notification type
        // Example: Navigate to specific capsule, job log, or test results
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    /// Show notification even when app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        Task { @MainActor in
            handleForegroundNotification(notification)
        }

        // Show banner, sound, and badge even when app is open
        completionHandler([.banner, .sound, .badge])
    }

    /// Handle notification tap
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Task { @MainActor in
            handleNotificationTap(response)
        }

        completionHandler()
    }
}

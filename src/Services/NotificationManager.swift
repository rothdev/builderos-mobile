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

        // Send token to BuilderOS API
        Task {
            await registerDeviceToken(token)
        }
    }

    /// Register device token with backend
    private func registerDeviceToken(_ token: String) async {
        let tunnelURL = APIConfig.tunnelURL
        let apiKey = APIConfig.apiToken

        guard !tunnelURL.isEmpty, !apiKey.isEmpty else {
            print("⚠️ NOTIFICATION: Cannot register device - missing config")
            return
        }

        let endpoint = "\(tunnelURL)/api/notifications/register"

        guard let url = URL(string: endpoint) else {
            print("❌ NOTIFICATION: Invalid URL: \(endpoint)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")

        let payload: [String: Any] = [
            "device_token": token,
            "platform": "ios",
            "device_id": UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ NOTIFICATION: Device token registered with backend")
            } else {
                print("⚠️ NOTIFICATION: Failed to register device token - unexpected response")
            }
        } catch {
            print("❌ NOTIFICATION: Failed to register device token: \(error)")
        }
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

    /// Send notification for new chat message
    func sendMessageNotification(from sender: String, preview: String) async {
        guard isAuthorized else {
            print("⚠️ NOTIFICATION: Cannot send message notification - not authorized")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "New Message from \(sender)"
        content.body = preview
        content.sound = .default
        content.badge = NSNumber(value: 1)

        // Add custom data for handling notification tap
        content.userInfo = [
            "type": "chat_message",
            "sender": sender,
            "timestamp": Date().timeIntervalSince1970
        ]

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil  // Deliver immediately
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("📱 NOTIFICATION: Message notification sent")
        } catch {
            print("❌ NOTIFICATION: Failed to send message notification: \(error)")
        }
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

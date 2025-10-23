import Foundation
import UserNotifications
import Combine

@MainActor
class NotificationService: ObservableObject {
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestPermission() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            await checkAuthorizationStatus()
        } catch {
            print("Error requesting notification permission: \(error)")
        }
    }
    
    func checkAuthorizationStatus() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            authorizationStatus = settings.authorizationStatus
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    func scheduleBuilderSystemNotification(title: String, body: String, userInfo: [String: Any] = [:]) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo
        
        // Add Builder System specific categories
        content.categoryIdentifier = "BUILDER_SYSTEM"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func setupNotificationCategories() {
        // Action for approval notifications
        let approveAction = UNNotificationAction(
            identifier: "APPROVE_ACTION",
            title: "Approve",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Dismiss",
            options: []
        )
        
        let builderCategory = UNNotificationCategory(
            identifier: "BUILDER_SYSTEM",
            actions: [approveAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        notificationCenter.setNotificationCategories([builderCategory])
    }
    
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "APPROVE_ACTION":
            // Handle approval action - could send SSH command or open specific view
            handleApprovalAction(userInfo: userInfo)
        case "DISMISS_ACTION", UNNotificationDefaultActionIdentifier:
            // Handle dismiss or tap action
            handleDefaultAction(userInfo: userInfo)
        default:
            break
        }
    }
    
    private func handleApprovalAction(userInfo: [AnyHashable: Any]) {
        // Implementation for approval action
        // This could send an SSH command or update app state
        print("Handling approval action with userInfo: \(userInfo)")
    }
    
    private func handleDefaultAction(userInfo: [AnyHashable: Any]) {
        // Implementation for default action
        // This could navigate to a specific view or session
        print("Handling default action with userInfo: \(userInfo)")
    }
}
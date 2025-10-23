//
//  ContentView.swift
//  BuilderSystemMobile
//
//  Created by Builder System
//

import SwiftUI

struct ContentView: View {
    // @StateObject private var appState = AppState.shared
    // @StateObject private var navigationCoordinator = NavigationCoordinator.shared
    @State private var selectedTab = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if !appState.isAuthenticated {
                SignInView()
                    .environmentObject(appState)
            } else if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                mainTabView
            }
        }
        .preferredColorScheme(appState.userPreferences.theme == .dark ? .dark : 
                             appState.userPreferences.theme == .light ? .light : nil)
    }
    
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CapsuleListView()
            }
            .tabItem {
                Label("Capsules", systemImage: "cube.box.fill")
            }
            .tag(0)
            .badge(appState.activeCapsuleCount)
            
            NavigationStack {
                WorkflowMonitorView()
            }
            .tabItem {
                Label("Workflows", systemImage: "arrow.triangle.2.circlepath")
            }
            .tag(1)
            .badge(appState.runningWorkflowCount)
            
            NavigationStack {
                SystemHealthDashboard()
            }
            .tabItem {
                Label("Health", systemImage: "heart.text.square.fill")
            }
            .tag(2)
            .badge(appState.criticalAlertCount)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .environmentObject(appState)
        .environmentObject(navigationCoordinator)
        .accentColor(.builderBlue)
    }
}

// MARK: - App State
@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var capsules: [Capsule] = []
    @Published var workflows: [Workflow] = []
    @Published var systemHealth: SystemHealth?
    @Published var activeCapsuleCount = 0
    @Published var runningWorkflowCount = 0
    @Published var criticalAlertCount = 0
    @Published var userPreferences = UserPreferences()
    @Published var isLoading = false
    @Published var error: AppError?
    
    private init() {
        setupObservers()
    }
    
    private func setupObservers() {
        // Setup real-time update observers
    }
}

// MARK: - Navigation Coordinator
@MainActor
final class NavigationCoordinator: ObservableObject {
    static let shared = NavigationCoordinator()
    
    @Published var capsuleDetailPath: [Capsule] = []
    @Published var workflowDetailPath: [Workflow] = []
    @Published var selectedCapsule: Capsule?
    @Published var selectedWorkflow: Workflow?
    @Published var showCreateCapsule = false
    @Published var showCreateWorkflow = false
    
    private init() {}
    
    func navigateToCapsule(_ capsule: Capsule) {
        selectedCapsule = capsule
        capsuleDetailPath.append(capsule)
    }
    
    func navigateToWorkflow(_ workflow: Workflow) {
        selectedWorkflow = workflow
        workflowDetailPath.append(workflow)
    }
}

// MARK: - Color Extensions
extension Color {
    static let builderBlue = Color(red: 0.0, green: 0.478, blue: 1.0)
    static let builderGreen = Color(red: 0.196, green: 0.843, blue: 0.294)
    static let builderOrange = Color(red: 1.0, green: 0.584, blue: 0.0)
    static let builderRed = Color(red: 1.0, green: 0.231, blue: 0.188)
    static let builderPurple = Color(red: 0.686, green: 0.321, blue: 0.871)
}

// MARK: - App Error
enum AppError: LocalizedError {
    case networkError(String)
    case authenticationError(String)
    case dataError(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .dataError(let message):
            return "Data Error: \(message)"
        case .unknown(let message):
            return "Error: \(message)"
        }
    }
}

#Preview {
    ContentView()
}
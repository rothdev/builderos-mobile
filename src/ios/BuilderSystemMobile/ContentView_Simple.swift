//
//  ContentView_Simple.swift
//  BuilderSystemMobile
//
//  Simplified version for testing
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CapsuleListSimpleView()
            }
            .tabItem {
                Label("Capsules", systemImage: "cube.box.fill")
            }
            .tag(0)
            
            NavigationStack {
                Text("Workflows")
                    .font(.largeTitle)
            }
            .tabItem {
                Label("Workflows", systemImage: "arrow.triangle.2.circlepath")
            }
            .tag(1)
            
            NavigationStack {
                Text("Health")
                    .font(.largeTitle)
            }
            .tabItem {
                Label("Health", systemImage: "heart.text.square.fill")
            }
            .tag(2)
            
            NavigationStack {
                Text("Settings")
                    .font(.largeTitle)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
    }
}

struct CapsuleListSimpleView: View {
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(0..<5) { index in
                    CapsuleRowSimple(
                        name: "Capsule \(index + 1)",
                        description: "Builder System capsule",
                        status: ["Planning", "Building", "Testing", "Deployed", "Maintenance"][index % 5]
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Capsules")
        .searchable(text: $searchText)
    }
}

struct CapsuleRowSimple: View {
    let name: String
    let description: String
    let status: String
    
    var statusColor: Color {
        switch status {
        case "Planning": return .blue
        case "Building": return .orange
        case "Testing": return .purple
        case "Deployed": return .green
        case "Maintenance": return .yellow
        default: return .gray
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .foregroundColor(statusColor)
                .cornerRadius(6)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ContentView()
}
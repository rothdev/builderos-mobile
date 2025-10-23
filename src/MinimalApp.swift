//
//  BuilderOSApp.swift (Minimal Version)
//  BuilderOS iOS - Minimal Build
//

import SwiftUI

@main
struct BuilderOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("BuilderOS Mobile")) {
                    HStack {
                        Image(systemName: "server.rack")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Connection Status")
                                .font(.headline)
                            Text("Ready to connect")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "iphone")
                            .foregroundColor(.green)
                        VStack(alignment: .leading) {
                            Text("App Version")
                                .font(.headline)
                            Text("1.0.0 (Build 1)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Quick Actions")) {
                    Button(action: {}) {
                        Label("View Capsules", systemImage: "folder.fill")
                    }
                    
                    Button(action: {}) {
                        Label("System Status", systemImage: "info.circle")
                    }
                    
                    Button(action: {}) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .navigationTitle("BuilderOS")
        }
    }
}

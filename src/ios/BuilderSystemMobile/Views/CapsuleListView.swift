//
//  CapsuleListView.swift
//  BuilderSystemMobile
//
//  Created by Builder System
//

import SwiftUI
import Inject

struct CapsuleListView: View {
    @ObserveInjection var inject
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = CapsuleListViewModel()
    @State private var searchText = ""
    @State private var selectedStatus: Capsule.CapsuleStatus?
    @State private var showFilters = false
    @State private var showCreateCapsule = false

    var body: some View {
        ZStack {
            if viewModel.capsules.isEmpty && !viewModel.isLoading {
                EmptyStateView(
                    icon: "cube.box",
                    title: "No Capsules",
                    message: "Create your first capsule to get started",
                    actionTitle: "Create Capsule",
                    action: { showCreateCapsule = true }
                )
            } else {
                capsuleList
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(
                        icon: "plus",
                        action: { showCreateCapsule = true }
                    )
                    .padding()
                }
            }
        }
        .navigationTitle("Capsules")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showFilters.toggle() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search capsules...")
        .refreshable {
            await viewModel.refresh()
        }
        .sheet(isPresented: $showFilters) {
            FilterView(
                selectedStatus: $selectedStatus
            )
        }
        .sheet(isPresented: $showCreateCapsule) {
            CreateCapsuleView()
        }
        .task {
            await viewModel.loadCapsules()
        }
        .enableInjection()
    }
    
    private var capsuleList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredCapsules) { capsule in
                    CapsuleRowView(capsule: capsule)
                        .contextMenu {
                            capsuleContextMenu(for: capsule)
                        }
                }
            }
            .padding()
        }
        .overlay(alignment: .center) {
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
    
    private var filteredCapsules: [Capsule] {
        viewModel.capsules.filter { capsule in
            let matchesSearch = searchText.isEmpty || 
                capsule.name.localizedCaseInsensitiveContains(searchText) ||
                capsule.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesStatus = selectedStatus == nil || capsule.status == selectedStatus
            
            return matchesSearch && matchesStatus
        }
    }
    
    @ViewBuilder
    private func capsuleContextMenu(for capsule: Capsule) -> some View {
        Button {
            Task { await viewModel.duplicateCapsule(capsule) }
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
        
        Button {
            Task { await viewModel.archiveCapsule(capsule) }
        } label: {
            Label("Archive", systemImage: "archivebox")
        }
        
        Divider()
        
        Button(role: .destructive) {
            Task { await viewModel.deleteCapsule(capsule) }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

// MARK: - Capsule Row View
struct CapsuleRowView: View {
    let capsule: Capsule
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(capsule.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(capsule.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(status: capsule.status)
                    
                    if let health = capsule.healthMetrics {
                        HealthIndicator(score: health.score)
                    }
                }
            }
            
            if isExpanded {
                Divider()
                
                HStack(spacing: 16) {
                    InfoItem(
                        icon: "calendar",
                        title: "Created",
                        value: capsule.createdDate.formatted(date: .abbreviated, time: .omitted)
                    )
                    
                    InfoItem(
                        icon: "tag",
                        title: "Version",
                        value: capsule.version
                    )
                    
                    if !capsule.tags.isEmpty {
                        InfoItem(
                            icon: "tag.fill",
                            title: "Tags",
                            value: capsule.tags.joined(separator: ", ")
                        )
                    }
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                isExpanded.toggle()
            }
        }
    }
}

// MARK: - Supporting Components
struct StatusBadge: View {
    let status: Capsule.CapsuleStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(6)
            .accessibilityLabel("Status: \(status.displayName)")
    }
    
    private var statusColor: Color {
        switch status {
        case .planning: return .blue
        case .building: return .orange
        case .testing: return .purple
        case .deployed: return .green
        case .maintenance: return .yellow
        case .archived: return .gray
        case .failed: return .red
        }
    }
}

struct HealthIndicator: View {
    let score: Double
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: healthIcon)
                .font(.caption)
                .foregroundColor(healthColor)
            
            Text("\(Int(score))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(healthColor)
        }
        .accessibilityLabel("Health score: \(Int(score)) percent")
    }
    
    private var healthIcon: String {
        switch score {
        case 80...100: return "heart.fill"
        case 50..<80: return "heart.lefthalf.fill"
        default: return "heart.slash"
        }
    }
    
    private var healthColor: Color {
        switch score {
        case 80...100: return .green
        case 50..<80: return .yellow
        default: return .red
        }
    }
}

struct InfoItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(title + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// MARK: - View Model
@MainActor
class CapsuleListViewModel: ObservableObject {
    @Published var capsules: [Capsule] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let capsuleService = CapsuleService.shared
    
    func loadCapsules() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            capsules = try await capsuleService.getCapsules()
        } catch {
            self.error = error
        }
    }
    
    func refresh() async {
        await loadCapsules()
    }
    
    func duplicateCapsule(_ capsule: Capsule) async {
        var newCapsule = capsule
        newCapsule.id = UUID().uuidString
        newCapsule.name = "\(capsule.name) (Copy)"
        newCapsule.createdDate = Date()
        
        do {
            let created = try await capsuleService.createCapsule(newCapsule)
            capsules.append(created)
        } catch {
            self.error = error
        }
    }
    
    func archiveCapsule(_ capsule: Capsule) async {
        do {
            let updated = try await capsuleService.updateCapsuleStatus(
                id: capsule.id,
                status: .archived
            )
            if let index = capsules.firstIndex(where: { $0.id == capsule.id }) {
                capsules[index] = updated
            }
        } catch {
            self.error = error
        }
    }
    
    func deleteCapsule(_ capsule: Capsule) async {
        do {
            try await capsuleService.deleteCapsule(id: capsule.id)
            capsules.removeAll { $0.id == capsule.id }
        } catch {
            self.error = error
        }
    }
}

#Preview {
    NavigationStack {
        CapsuleListView()
            .environmentObject(AppState.shared)
    }
}
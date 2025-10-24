//
//  CapsuleDetailView.swift
//  BuilderOS
//

import SwiftUI

struct CapsuleDetailView: View {
    let capsule: Capsule
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(capsule.name)
                            .font(.titleLarge)
                            .fontWeight(.bold)

                        Text(capsule.path)
                            .font(.bodySmall)
                            .foregroundColor(Color.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Status Badge
                    Text(capsule.status.displayName)
                        .font(.labelSmall)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(8)
                }

                Divider()

                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.titleSmall)
                        .fontWeight(.semibold)

                    Text(capsule.description)
                        .font(.bodyMedium)
                        .foregroundColor(Color.textSecondary)
                }

                // Tags
                if !capsule.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.titleSmall)
                            .fontWeight(.semibold)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(capsule.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.labelMedium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.backgroundSecondary)
                                        .foregroundColor(Color.textPrimary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }

                // Metrics (simplified)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Metrics")
                        .font(.titleSmall)
                        .fontWeight(.semibold)

                    VStack(spacing: 8) {
                        MetricRow(label: "Created", value: formatDate(capsule.createdAt))
                        MetricRow(label: "Updated", value: formatDate(capsule.updatedAt))
                        MetricRow(label: "Tags", value: "\(capsule.tags.count)")
                    }
                }

                Spacer()
            }
            .padding(Layout.screenPadding)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusColor: Color {
        switch capsule.status {
        case .active:
            return .statusSuccess
        case .development:
            return .statusInfo
        case .testing:
            return .statusWarning
        case .archived:
            return Color.textSecondary
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct MetricRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.bodyMedium)
                .foregroundColor(Color.textSecondary)
            Spacer()
            Text(value)
                .font(.bodyMedium)
                .foregroundColor(Color.textPrimary)
        }
    }
}

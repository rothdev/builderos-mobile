//
//  CommonComponents.swift
//  BuilderSystemMobile
//
//  Created by Builder System
//

import SwiftUI

// MARK: - Loading View
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 44, height: 44)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.builderBlue, lineWidth: 4)
                    .frame(width: 44, height: 44)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(.gray)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.medium)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.builderBlue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

// MARK: - Error View
struct ErrorView: View {
    let error: Error
    var retry: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.builderRed)
            
            Text("Something went wrong")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retry = retry {
                Button(action: retry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .fontWeight(.medium)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.builderBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.builderBlue)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel("Create new item")
        .accessibilityHint("Double tap to create")
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var onSearchButtonClicked: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .submitLabel(.search)
                .onSubmit {
                    onSearchButtonClicked?()
                }
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Segmented Picker
struct SegmentedPicker<T: Hashable>: View {
    let title: String
    @Binding var selection: T
    let options: [(T, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker(title, selection: $selection) {
                ForEach(options, id: \.0) { value, label in
                    Text(label).tag(value)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var trend: Double? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                if let trend = trend {
                    TrendIndicator(value: trend)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Trend Indicator
struct TrendIndicator: View {
    let value: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: trendIcon)
                .font(.caption)
                .foregroundColor(trendColor)
            
            Text("\(abs(Int(value)))%")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(trendColor)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(trendColor.opacity(0.1))
        .cornerRadius(4)
    }
    
    private var trendIcon: String {
        if value > 0 {
            return "arrow.up.right"
        } else if value < 0 {
            return "arrow.down.right"
        } else {
            return "minus"
        }
    }
    
    private var trendColor: Color {
        if value > 0 {
            return .green
        } else if value < 0 {
            return .red
        } else {
            return .gray
        }
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat = 8
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(progressColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.bold)
        }
    }
    
    private var progressColor: Color {
        switch progress {
        case 0.8...1.0: return .green
        case 0.5..<0.8: return .yellow
        default: return .red
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .builderBlue
            case .secondary: return Color(.systemGray5)
            case .destructive: return .builderRed
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .destructive: return .white
            case .secondary: return .primary
            }
        }
    }
    
    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(style.backgroundColor)
            .foregroundColor(style.foregroundColor)
            .cornerRadius(8)
        }
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView()
        
        MetricCard(
            title: "Active Capsules",
            value: "24",
            icon: "cube.box.fill",
            color: .builderBlue,
            trend: 12.5
        )
        
        ProgressRing(progress: 0.75)
            .frame(width: 60, height: 60)
        
        ActionButton(
            title: "Create Capsule",
            icon: "plus",
            action: {}
        )
    }
    .padding()
}
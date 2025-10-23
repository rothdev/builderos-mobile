# BuilderOS Mobile - Quick Design Reference

**For:** 📱 Mobile Dev (Swift/SwiftUI implementation)
**Source:** Extracted from current SwiftUI implementation
**Last Updated:** January 2025

---

## 🎨 Color Palette

### Light Mode

```swift
// Backgrounds
.systemBackground           // #FFFFFF
.secondarySystemBackground  // #F2F2F7
.tertiarySystemBackground   // #FFFFFF

// Brand & Status
.blue                       // #007AFF (primary)
.green                      // #34C759 (success)
.orange                     // #FF9500 (warning)
.red                        // #FF3B30 (error)

// Chat
Color(.systemGray5)         // #E5E5EA (system message background)
Color(.systemGray2)         // #AEAEB2 (code block background)
```

### Dark Mode

```swift
// Backgrounds
.systemBackground           // #000000
.secondarySystemBackground  // #1C1C1E
.tertiarySystemBackground   // #2C2C2E

// Brand & Status
.blue                       // #0A84FF (primary)
.green                      // #30D158 (success)
.orange                     // #FF9F0A (warning)
.red                        // #FF453A (error)

// Chat
Color(.systemGray5)         // #3A3A3C (system message background)
Color(.systemGray2)         // #636366 (code block background)
```

---

## 📝 Typography

### Font Styles (SF Pro)

```swift
// Display
.displayLarge       // 57pt, Bold, Rounded
.displayMedium      // 45pt, Bold, Rounded
.displaySmall       // 36pt, Bold, Rounded

// Headlines
.headlineLarge      // 32pt, Semibold, Rounded
.headlineMedium     // 28pt, Semibold, Rounded
.headlineSmall      // 24pt, Semibold, Rounded

// Titles
.titleLarge         // 22pt, Semibold, Default
.titleMedium        // 16pt, Semibold, Default
.titleSmall         // 14pt, Semibold, Default

// Body
.bodyLarge          // 16pt, Regular, Default
.bodyMedium         // 14pt, Regular, Default
.bodySmall          // 12pt, Regular, Default

// Labels
.labelLarge         // 14pt, Medium, Default
.labelMedium        // 12pt, Medium, Default
.labelSmall         // 11pt, Medium, Default

// Monospaced (code, IPs, URLs)
.monoLarge          // 16pt, Regular, Monospaced
.monoMedium         // 14pt, Regular, Monospaced
.monoSmall          // 12pt, Regular, Monospaced
```

### Usage Examples

```swift
// Navigation title
.font(.system(size: 40, weight: .bold, design: .rounded))

// Headline in cards
.font(.headline)

// Body text
.font(.system(size: 14))

// Code/technical text
.font(.system(.body, design: .monospaced))

// Captions
.font(.caption)
.foregroundStyle(.secondary)
```

---

## 📏 Spacing (8pt Grid)

```swift
Spacing.xs      // 4pt  - Icon + text gaps
Spacing.sm      // 8pt  - Tight vertical stacks
Spacing.md      // 12pt - Compact lists, grid gaps
Spacing.base    // 16pt - Default padding, VStack spacing
Spacing.lg      // 24pt - Section spacing
Spacing.xl      // 32pt - Major sections
Spacing.xxl     // 48pt - Hero elements
Spacing.xxxl    // 64pt - Empty states
```

### Corner Radius

```swift
CornerRadius.xs      // 4pt  - Minimal
CornerRadius.sm      // 8pt  - Buttons, small cards
CornerRadius.md      // 12pt - Cards (MOST COMMON)
CornerRadius.lg      // 16pt - Large cards
CornerRadius.xl      // 20pt - Extra large
CornerRadius.circle  // 9999pt - Perfect circles
```

### Common Patterns

```swift
// Card padding
.padding()                  // 16pt all sides

// Screen padding
.padding(.horizontal, 20)   // 20pt edges

// VStack spacing
VStack(spacing: 24) { }     // Sections
VStack(spacing: 16) { }     // Default
VStack(spacing: 12) { }     // Compact
VStack(spacing: 8) { }      // Tight

// Grid spacing
LazyVGrid(..., spacing: 12) { }  // Capsule/stat grids
```

---

## ⚡ Animations

### Spring Presets

```swift
.springFast     // response: 0.3, damping: 0.7  - Quick interactions
.springNormal   // response: 0.4, damping: 0.8  - Default
.springBouncy   // response: 0.5, damping: 0.6  - Playful

// Usage
withAnimation(.springFast) {
    currentStep += 1
}
```

### Button Press

```swift
// PrimaryButtonStyle
.scaleEffect(configuration.isPressed ? 0.95 : 1.0)
.animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
```

### Durations

```swift
AnimationDuration.fast      // 0.15s
AnimationDuration.normal    // 0.25s
AnimationDuration.slow      // 0.35s
AnimationDuration.verySlow  // 0.5s
```

---

## 🧩 Common Components

### Material Card

```swift
VStack(spacing: 12) {
    // Content
}
.padding(16)
.background(.ultraThinMaterial)
.clipShape(RoundedRectangle(cornerRadius: 12))
```

### Two-Column Grid

```swift
LazyVGrid(
    columns: [GridItem(.flexible()), GridItem(.flexible())],
    spacing: 12
) {
    // Items
}
```

### Icon + Text Pair

```swift
HStack(spacing: 4) {
    Image(systemName: "tag.fill")
        .font(.caption)
    Text("Label")
        .font(.caption)
}
.foregroundStyle(.secondary)
```

### Status Indicator

```swift
HStack(spacing: 6) {
    Circle()
        .fill(Color.green)
        .frame(width: 8, height: 8)
    Text("Connected")
        .font(.caption)
        .foregroundStyle(.secondary)
}
```

---

## 📱 Layout Constants

```swift
// Device frame (iPhone 15 Pro)
Width: 393pt
Height: 852pt
Safe Area Top: 59pt
Safe Area Bottom: 34pt

// Tab bar
Height: 49pt (content) + 34pt (safe area) = 83pt total

// Touch targets (Apple HIG)
Layout.minTouchTarget: 44pt minimum
Layout.touchTarget: 48pt comfortable
Layout.largeTouchTarget: 56pt large
```

---

## 🎯 Quick Copy-Paste Snippets

### Standard Card

```swift
VStack(alignment: .leading, spacing: 16) {
    Text("Card Title")
        .font(.headline)

    Text("Card content goes here")
        .font(.subheadline)
        .foregroundStyle(.secondary)
}
.padding()
.background(.ultraThinMaterial)
.clipShape(RoundedRectangle(cornerRadius: 12))
```

### Stat Item

```swift
VStack(alignment: .leading, spacing: 4) {
    HStack(spacing: 4) {
        Image(systemName: "icon.name")
            .font(.caption)
        Text("Label")
            .font(.caption)
    }
    .foregroundStyle(.secondary)

    Text("Value")
        .font(.title3)
        .fontWeight(.semibold)
}
.frame(maxWidth: .infinity, alignment: .leading)
.padding(12)
.background(.background.opacity(0.5))
.clipShape(RoundedRectangle(cornerRadius: 8))
```

### Primary Button

```swift
Button(action: { }) {
    Text("Button Text")
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
}
```

### Form Section Header

```swift
VStack(alignment: .leading, spacing: 8) {
    Text("Field Label")
        .font(.caption)
        .foregroundStyle(.secondary)

    TextField("Placeholder", text: $value)
        .font(.system(.body, design: .monospaced))
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
}
```

---

## 🔍 Common Patterns

### Connection Status Card

```swift
VStack(spacing: 12) {
    HStack {
        Image(systemName: isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
            .foregroundStyle(isConnected ? .green : .red)
            .font(.title2)

        VStack(alignment: .leading, spacing: 4) {
            Text(isConnected ? "Connected" : "Disconnected")
                .font(.headline)

            if isConnected {
                Text("BuilderOS Mobile")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }

        Spacer()

        if isRefreshing {
            ProgressView()
        }
    }

    if !tunnelURL.isEmpty {
        Divider()

        HStack {
            Label(tunnelURL, systemImage: "network")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontDesign(.monospaced)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            Label("Cloudflare Tunnel", systemImage: "lock.shield.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
.padding()
.background(.ultraThinMaterial)
.clipShape(RoundedRectangle(cornerRadius: 12))
```

### Empty State

```swift
VStack(spacing: 12) {
    Image(systemName: "cube.transparent")
        .font(.system(size: 48))
        .foregroundStyle(.secondary)

    Text("No items found")
        .font(.headline)
        .foregroundStyle(.secondary)
}
.frame(maxWidth: .infinity)
.padding(40)
```

---

## ✅ Design Checklist

**Before implementing new screens:**

- [ ] Use semantic colors (`.systemBackground`, not hardcoded hex)
- [ ] Support Dynamic Type (use `.font(.headline)` not fixed sizes)
- [ ] Follow 8pt grid for all spacing
- [ ] Use 12pt corner radius for cards (most common)
- [ ] Test Light + Dark mode
- [ ] Minimum 44pt touch targets
- [ ] Use `.ultraThinMaterial` for cards
- [ ] Add VoiceOver labels for custom icons
- [ ] Support landscape orientation (iPad)
- [ ] Use spring animations (`.springFast` for interactions)

---

**Full Specifications:** `DESIGN_SYSTEM_EXTRACTED.md` (15 pages)
**Penpot Project:** http://localhost:3449/#/dashboard/projects/4c46a10f-a510-8112-8006-ff54c883093f
**Penpot Status:** ⚠️ Empty frames, needs population (8-12 hours of design work)

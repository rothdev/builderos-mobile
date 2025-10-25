# Apple DocC Documentation Setup

**Purpose:** Generate rich, interactive documentation for BuilderOS Mobile components

**Status:** Optional - Nice to have for component reference

---

## What is DocC?

Apple's built-in documentation compiler that:
- Generates beautiful documentation websites
- Shows live code examples
- Renders Markdown with syntax highlighting
- Integrates with Xcode
- Exports to static HTML

---

## Quick Start

### 1. Document Your Code

Add documentation comments to components:

```swift
/// Connection status card showing network information
///
/// Displays real-time connection details including:
/// - Cloudflare Tunnel URL
/// - Connection latency
/// - API health status
/// - Last successful sync time
///
/// ## Example Usage
///
/// ```swift
/// ConnectionStatusCard(
///     tunnelURL: "https://api.builderos.app",
///     latency: 12,
///     isConnected: true
/// )
/// ```
///
/// - Parameters:
///   - tunnelURL: The Cloudflare Tunnel endpoint URL
///   - latency: Round-trip latency in milliseconds
///   - isConnected: Current connection state
///
/// - Note: Updates automatically via `@Published` properties
/// - Important: Requires active Cloudflare Tunnel on Mac
struct ConnectionStatusCard: View {
    let tunnelURL: String
    let latency: Int
    let isConnected: Bool

    var body: some View {
        // Implementation...
    }
}
```

### 2. Build Documentation

**In Xcode:**
1. Product → Build Documentation (Cmd+Shift+Ctrl+D)
2. Documentation window opens automatically
3. Browse your documented components

**Command line:**
```bash
# Build documentation
xcodebuild docbuild \
  -scheme BuilderSystemMobile \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Preview locally
docc preview BuilderSystemMobile.doccarchive
```

### 3. View Documentation

- Opens in Xcode Documentation window
- Navigate like Apple's official docs
- Search by component name
- View example code inline

---

## Documentation Best Practices

### What to Document:

**Essential:**
- ✅ Complex components (TerminalView, WebSocketService)
- ✅ Public APIs (BuilderOSAPIClient, KeychainManager)
- ✅ View models (CapsuleListViewModel, DashboardViewModel)
- ✅ Services (APIConfig, TerminalWebSocketService)

**Optional:**
- Simple views (buttons, labels)
- Internal helpers
- View modifiers

### Documentation Structure:

```swift
/// [Brief one-line description]
///
/// [Detailed explanation of component purpose and behavior]
///
/// ## Example Usage
///
/// ```swift
/// [Code example showing typical usage]
/// ```
///
/// - Parameters:
///   - param1: Description of first parameter
///   - param2: Description of second parameter
///
/// - Returns: Description of return value (if applicable)
///
/// - Note: Additional context or tips
/// - Important: Critical information users must know
/// - Warning: Potential pitfalls or gotchas
```

---

## Documenting SwiftUI Views

### View Documentation:

```swift
/// Terminal tab view with multi-tab interface
///
/// Provides WebSocket-based terminal emulation with:
/// - Multiple terminal tabs
/// - ANSI color support
/// - Command history
/// - Auto-reconnect
///
/// ## Example
///
/// ```swift
/// TerminalTabView()
///     .environmentObject(apiClient)
/// ```
///
/// - Requires: `BuilderOSAPIClient` environment object
/// - Important: Tunnel must be configured in Settings
struct TerminalTabView: View {
    @EnvironmentObject var apiClient: BuilderOSAPIClient
    // ...
}
```

### View Modifier Documentation:

```swift
/// Applies liquid glass design system styling
///
/// Creates a frosted glass effect with:
/// - Semi-transparent background blur
/// - Light border highlight
/// - Depth shadow
///
/// ## Example
///
/// ```swift
/// Text("Hello World")
///     .liquidGlassStyle()
/// ```
extension View {
    func liquidGlassStyle() -> some View {
        // Implementation
    }
}
```

---

## Advanced: Documentation Catalog

For comprehensive docs, create a documentation catalog:

### 1. Create Catalog:

```bash
# Create .docc bundle
mkdir BuilderSystemMobile.docc
cd BuilderSystemMobile.docc

# Create root page
cat > BuilderSystemMobile.md << 'EOF'
# BuilderOS Mobile

Native iOS app for remote BuilderOS access via Cloudflare Tunnel.

## Overview

BuilderOS Mobile provides secure, real-time access to your Builder System from iPhone and iPad.

## Topics

### Views
- ``DashboardView``
- ``TerminalTabView``
- ``SettingsView``

### Services
- ``BuilderOSAPIClient``
- ``TerminalWebSocketService``
- ``KeychainManager``

### Models
- ``Capsule``
- ``SystemStatus``
- ``TerminalTab``
EOF
```

### 2. Add to Xcode:

- Drag `.docc` folder into Xcode project
- Target: BuilderSystemMobile
- Build Documentation (Cmd+Shift+Ctrl+D)

---

## Export Documentation

### Static Website:

```bash
# Generate static site
xcodebuild docbuild \
  -scheme BuilderSystemMobile \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Export to HTML
docc convert BuilderSystemMobile.doccarchive \
  --output-path docs-site \
  --hosting-base-path /builderos-mobile

# Preview
python3 -m http.server 8080 -d docs-site
# Open: http://localhost:8080
```

### Host Documentation:

- GitHub Pages
- Netlify
- CloudFlare Pages
- Local web server

---

## When to Use DocC

**High value:**
- ✅ Complex custom components
- ✅ Reusable services/utilities
- ✅ Components with non-obvious behavior
- ✅ Public APIs for other developers

**Low priority:**
- ❌ Solo developer with simple views
- ❌ Self-documenting code
- ❌ Rarely-used internal helpers

**For BuilderOS Mobile:**
- Optional but useful for:
  - Terminal WebSocket implementation
  - API client architecture
  - Custom view modifiers
  - Design system components

---

## Quick Documentation Tips

### 1. Use Markdown:

```swift
/// # Heading
/// ## Subheading
///
/// **Bold** and *italic* text
///
/// - Bullet lists
/// - Work great
///
/// 1. Numbered lists
/// 2. Also supported
///
/// `Inline code` and links: [Apple Docs](https://developer.apple.com)
```

### 2. Link to Other Symbols:

```swift
/// Uses ``BuilderOSAPIClient`` to fetch data
/// See also: ``Capsule`` and ``SystemStatus``
```

### 3. Code Examples:

````swift
/// ## Example
///
/// ```swift
/// let client = BuilderOSAPIClient()
/// let capsules = try await client.fetchCapsules()
/// ```
````

---

## Resources

- **DocC Guide:** https://developer.apple.com/documentation/docc
- **WWDC Videos:** Search "DocC" on developer.apple.com
- **Swift-DocC:** https://github.com/apple/swift-docc

---

*Apple DocC Setup Guide - BuilderOS Mobile*

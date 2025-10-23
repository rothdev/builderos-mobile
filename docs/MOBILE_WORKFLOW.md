# BuilderOS Mobile - Official Development Workflow

**Purpose:** Complete workflow for native iOS app development with design iteration and hot reloading

**Last Updated:** October 2025

---

## Technology Stack

### ✅ Essential Tools

```
📱 Native iOS Development
├─ Swift 5.9+ (Language)
├─ SwiftUI (UI Framework)
├─ Xcode 15+ (IDE)
└─ iOS 17+ (Target Platform)

🎨 Design & Iteration
├─ Penpot (Visual mockups)
├─ Xcode Previews (Component isolation)
├─ InjectionIII (Hot reloading - 30x faster)
└─ Penpot MCP (Design system extraction)

📋 Documentation (Optional)
└─ Apple DocC (Component documentation)
```

### ❌ Tools We Don't Use

- **Storybook** - Web-only, doesn't support Swift/SwiftUI
- **HTML mockups** - Wrong layout model (CSS ≠ SwiftUI)
- **React Native** - Not needed (iOS-only app)
- **Swift Playgrounds** - Redundant with Xcode Previews + InjectionIII

---

## Complete Development Workflow

### Phase 1: Design (Penpot)

**Who:** 📐 UI Designer

**Tool:** Penpot (self-hosted or penpot.app)

**Process:**
1. **Create Penpot project:** "BuilderOS Mobile"
2. **Use iOS device frames:** iPhone 15 Pro (393×852 pt)
3. **Reference Apple HIG:** iOS 17+ design patterns
4. **Design components:**
   - System components (cards, buttons, lists)
   - Screen layouts (Dashboard, Terminal, Settings)
   - States (loading, empty, error)
   - Light + Dark mode variants
5. **Document design system:**
   - Colors (hex values)
   - Typography (SF Pro font scales)
   - Spacing (8pt grid)
   - Component specs

**Output:**
- Penpot file with complete designs
- Design system documentation
- Component specifications
- Screenshots for reference

---

### Phase 2: Implementation (Swift + InjectionIII)

**Who:** 📱 Mobile Dev

**Tool:** Xcode + InjectionIII hot reloading

**Process:**

#### 2.1 Setup (One-Time)

1. **Add InjectionIII package:**
   ```
   File → Add Package Dependencies
   URL: https://github.com/krzysztofzablocki/Inject
   ```

2. **Update View files:**
   ```swift
   import SwiftUI
   import Inject

   struct MyView: View {
       @ObserveInjection var inject

       var body: some View {
           // ... view code
           .enableInjection()
       }
   }
   ```

3. **See:** `docs/INJECTION_SETUP.md` for complete guide

#### 2.2 Development Loop (Fast Iteration)

```
1. Run app on Simulator (Cmd+R) - ONE TIME
   ↓
2. Navigate to screen you're building
   ↓
3. Edit View code in Xcode
   ↓
4. Save file (Cmd+S)
   ↓
5. See changes in Simulator in ~2s ← NO REBUILD!
   ↓
6. Repeat steps 3-5 until satisfied
```

**Speed:** 30x faster than traditional rebuild cycle (60s → 2s)

#### 2.3 Component Isolation (Xcode Previews)

For complex components, use Xcode Previews:

```swift
struct ConnectionStatusCard: View {
    // ... implementation
}

#Preview("Connected") {
    ConnectionStatusCard(
        tunnelURL: "https://example.trycloudflare.com",
        latency: 12,
        isConnected: true
    )
}

#Preview("Disconnected") {
    ConnectionStatusCard(
        tunnelURL: "",
        latency: 0,
        isConnected: false
    )
}

#Preview("Dark Mode") {
    ConnectionStatusCard(
        tunnelURL: "https://example.trycloudflare.com",
        latency: 45,
        isConnected: true
    )
    .preferredColorScheme(.dark)
}
```

**View in Xcode:**
- Canvas panel shows live previews
- Update instantly as you code
- Test multiple states simultaneously

---

### Phase 3: Validation

#### 3.1 Visual Comparison

**Compare Swift implementation against Penpot designs:**

1. **Run app in Simulator**
2. **Screenshot app screens** (Cmd+S in Simulator)
3. **Open Penpot designs side-by-side**
4. **Verify:**
   - Layout matches design
   - Colors match exactly (hex values)
   - Spacing follows 8pt grid
   - Typography scales correctly
   - Dark mode looks good

#### 3.2 Functional Testing

- Test on real iPhone (via USB or TestFlight)
- Verify all interactions work
- Test edge cases (no data, errors, slow network)
- Check accessibility (VoiceOver, Dynamic Type)

---

### Phase 4: Documentation (Optional)

**Who:** 📱 Mobile Dev (assisted by Jarvis)

**Tool:** Apple DocC

**When to document:**
- ✅ Complex components (TerminalView, WebSocketService)
- ✅ Public APIs (BuilderOSAPIClient, KeychainManager)
- ✅ Custom view modifiers
- ✅ Design system components
- ❌ Simple views (buttons, labels)
- ❌ Self-documenting code

**Process:**
1. **Add documentation comments:**
   ```swift
   /// Connection status card showing network info
   ///
   /// Displays real-time connection details including:
   /// - Cloudflare Tunnel URL
   /// - Connection latency
   /// - API health status
   ///
   /// ## Example
   ///
   /// ```swift
   /// ConnectionStatusCard(
   ///     tunnelURL: "https://...",
   ///     latency: 12,
   ///     isConnected: true
   /// )
   /// ```
   struct ConnectionStatusCard: View { }
   ```

2. **Build documentation:**
   ```
   Product → Build Documentation (Cmd+Shift+Ctrl+D)
   ```

3. **Browse in Xcode Documentation window**

**See:** `docs/DOCC_SETUP.md` for complete guide

---

## Iteration Patterns

### New Feature (Penpot → Swift)

```
📐 UI Designer: Design new screen in Penpot
        ↓
📐 UI Designer: Export component specs via Penpot MCP
        ↓
📱 Mobile Dev: Implement in Swift with InjectionIII
        ↓
📱 Mobile Dev: Validate against Penpot designs
```

### Quick UI Tweaks (Swift Source of Truth)

```
📱 Mobile Dev: Adjust spacing/colors in Swift
        ↓
InjectionIII: See changes instantly (~2s)
        ↓
📱 Mobile Dev: Screenshot updated UI
        ↓
📐 UI Designer: Update Penpot to match (documentation)
```

### Design Exploration (Penpot First)

```
📐 UI Designer: Explore 3 design directions in Penpot
        ↓
Ty + Jarvis: Review and choose direction
        ↓
📱 Mobile Dev: Implement chosen design
```

---

## File Organization

### Xcode Project Structure

```
BuilderSystemMobile/
├── App/
│   └── BuilderSystemMobileApp.swift
├── Views/
│   ├── MainContentView.swift       # Tab navigation
│   ├── DashboardView.swift         # System overview
│   ├── CapsuleListView.swift       # Capsule management
│   ├── TerminalTabView.swift       # Terminal interface
│   ├── SettingsView.swift          # Configuration
│   └── Components/
│       ├── ConnectionStatusCard.swift
│       ├── CapsuleRowView.swift
│       └── EmptyStateView.swift
├── Services/
│   ├── BuilderOSAPIClient.swift    # API integration
│   ├── KeychainManager.swift       # Secure storage
│   └── TerminalWebSocketService.swift
├── Models/
│   ├── Capsule.swift
│   ├── SystemStatus.swift
│   └── TerminalTab.swift
└── Utilities/
    ├── Colors.swift                # Design system colors
    ├── Typography.swift            # Font scales
    └── Spacing.swift               # Layout constants
```

### Design Assets

```
design/
├── index.html                      # Master design index
├── design-system.html              # Color/typography reference
├── dashboard-screen.html           # Screen references
├── DESIGN_DOCUMENTATION.md         # Complete specs
├── PENPOT_PROJECT_GUIDE.md         # Penpot setup
└── COMPONENT_SPECS_QUICK_REF.md    # Quick reference
```

---

## Common Workflows

### "I need to build a new screen"

1. **📐 UI Designer:** Design in Penpot with iOS device frame
2. **📐 UI Designer:** Export component specs
3. **📱 Mobile Dev:** Create SwiftUI View file
4. **📱 Mobile Dev:** Add InjectionIII hooks (`@ObserveInjection`, `.enableInjection()`)
5. **📱 Mobile Dev:** Implement with hot reload (2s iterations)
6. **📱 Mobile Dev:** Add Xcode Previews for component isolation
7. **📱 Mobile Dev:** Compare screenshot to Penpot design

### "I need to tweak existing UI"

1. **📱 Mobile Dev:** Run app (Cmd+R)
2. **📱 Mobile Dev:** Navigate to screen
3. **📱 Mobile Dev:** Edit Swift code in Xcode
4. **📱 Mobile Dev:** Save (Cmd+S) → See changes in 2s
5. **📱 Mobile Dev:** Repeat steps 3-4 until satisfied
6. **📐 UI Designer:** Update Penpot to reflect changes (if significant)

### "I need to document a complex component"

1. **📱 Mobile Dev:** Add DocC comments to Swift file
2. **📱 Mobile Dev:** Build Documentation (Cmd+Shift+Ctrl+D)
3. **📱 Mobile Dev:** Browse in Xcode Documentation window
4. **See:** `docs/DOCC_SETUP.md`

---

## Performance Metrics

### Traditional Workflow (Before InjectionIII)

- **Edit → Build → Run:** 30-60 seconds per change
- **Iterations per hour:** ~60-120 changes
- **Lost to waiting:** 30-60 minutes per day

### With InjectionIII (Current)

- **Edit → Save → See:** 1-2 seconds per change
- **Iterations per hour:** ~1,800 changes
- **Time saved:** 45-55 minutes per day
- **Speed improvement:** 30x faster

---

## Setup Checklist

### One-Time Setup

- [ ] Penpot instance running (local or hosted)
- [ ] Penpot MCP configured in Claude Code
- [ ] InjectionIII package added to Xcode project
- [ ] Key View files updated with InjectionIII hooks
- [ ] Xcode Previews added to complex components

### Per-Session Setup

- [ ] Run app on Simulator (Cmd+R) - ONE TIME
- [ ] Navigate to screen you're working on
- [ ] Keep Xcode and Simulator visible
- [ ] Edit → Save → See (2s iteration loop)

---

## Resources

### Documentation

- **INJECTION_SETUP.md** - InjectionIII installation and usage
- **DOCC_SETUP.md** - Apple DocC documentation setup
- **DESIGN_DOCUMENTATION.md** - Complete design specifications
- **PENPOT_PROJECT_GUIDE.md** - Penpot project structure

### External Links

- **InjectionIII:** https://github.com/krzysztofzablocki/Inject
- **Apple DocC:** https://developer.apple.com/documentation/docc
- **Penpot:** https://penpot.app
- **Apple HIG:** https://developer.apple.com/design/human-interface-guidelines

---

## FAQs

**Q: Why not use Storybook?**
A: Storybook is for web/React Native. Doesn't support native Swift/SwiftUI. Xcode Previews provide the same isolation benefits.

**Q: Why not use HTML mockups?**
A: HTML layout model (CSS) is fundamentally different from SwiftUI. Creates translation friction. Penpot provides visual mockups without code mismatch.

**Q: Why not React Native?**
A: iOS-only app, don't need Android. Native Swift gives better performance and full platform access. InjectionIII provides fast iteration without JavaScript overhead.

**Q: When to update Penpot designs?**
A: When Swift code diverges significantly, screenshot Swift app and update Penpot to reflect reality (documentation).

**Q: How often to build documentation?**
A: Optional. Build when documenting complex APIs or before major handoffs. Not needed for daily work.

---

*Mobile Development Workflow - BuilderOS Mobile*

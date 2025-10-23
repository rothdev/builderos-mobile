# BuilderOS Mobile - Design Preview Documentation

## Overview
This directory contains the complete design system, screen specifications, and interactive HTML preview for the BuilderOS Mobile iOS application.

---

## 📱 Quick Preview

**VIEW THE INTERACTIVE PREVIEW:**

Open this file in your browser:
```
/Users/Ty/BuilderOS/capsules/builder-system-mobile/docs/design/mobile-app-preview.html
```

**Features:**
- ✅ Interactive button clicks
- ✅ Light/Dark mode toggle
- ✅ 4 screen previews (Chat, Empty State, Quick Actions, Connection)
- ✅ iPhone 14 Pro size (393×852px)
- ✅ Realistic iOS styling

---

## 📄 Documentation Files

### 1. **mobile-app-preview.html**
Interactive HTML mockup of all key screens.

**What's included:**
- Main Chat Screen (with sample messages)
- Empty State Screen (welcome message)
- Quick Actions Modal (6 default actions)
- Connection Setup Screen (status, settings)

**How to use:**
1. Open in Safari, Chrome, or any browser
2. Toggle light/dark mode to see both themes
3. Click screen buttons to switch between views
4. Interact with buttons to see active states
5. Review design decisions visually

---

### 1a. **terminal-chat-hybrid.html** ⭐ PRODUCTION-READY
**Hybrid design merging working implementation with refined specs.**

**What's included:**
- 5 iPhone screens (393×852px) showing all states:
  - Empty state with branding
  - Status command (structured output grid)
  - Capsule list (color-coded)
  - Full conversation (mixed output types)
  - Quick actions modal
- JetBrains Mono monospace typography
- Verified color system (cyan #60efff, green #00ff88)
- Gradient backgrounds with scanline effects
- Pulsing animations and visual polish

**How to use:**
1. Open in browser to see all 5 states side-by-side
2. Review structured status output format
3. Study color-coded list formatting
4. Use as exact visual reference for SwiftUI
5. Read companion implementation guide

**Companion files:**
- `HYBRID_IMPLEMENTATION_GUIDE.md` - Complete implementation guide (CODE READY)
- `TERMINAL_CHAT_SPECS.md` - Original specifications
- Screenshots: `terminal-chat-hybrid-full.png`

### 1b. **terminal-chat-preview.html** (Original - Reference Only)
Original terminal aesthetic exploration.

**Status:** Superseded by hybrid design (terminal-chat-hybrid.html)

**Companion files:**
- `TERMINAL_CHAT_SPECS.md` - Complete specifications
- Screenshots: `terminal-chat-final.png`, `terminal-empty-state-full.png`

---

### 2. **DESIGN_SYSTEM.md**
Comprehensive design system documentation.

**Sections:**
- **Color System:** Light/dark mode palettes, hex values, semantic meanings
- **Typography:** Font scales, weights, Dynamic Type support
- **Spacing:** 8pt grid system, component-specific spacing
- **Component Specs:** Detailed specifications for every UI element
- **Animations:** Timing, easing, interaction states
- **iOS Patterns:** Status bar, safe areas, sheet presentations
- **Accessibility:** WCAG compliance, VoiceOver, Reduced Motion
- **Design Tokens:** SwiftUI code snippets for colors, fonts, spacing

**Use this for:**
- Understanding design rationale
- Implementing components in SwiftUI
- Ensuring consistency across screens
- Accessibility compliance checklist

---

### 3. **SCREEN_SPECIFICATIONS.md**
Detailed specifications for each screen.

**Screens documented:**
1. **Chat Screen:** Main interface, message types, input bar
2. **Empty State:** Welcome screen for new users
3. **Quick Actions Modal:** Fast command access
4. **Connection Screen:** Backend connection management

**Each screen includes:**
- Purpose and context
- Layout structure (ASCII diagrams)
- Component breakdown (measurements, styles)
- State management (data models)
- Interactions and edge cases
- Accessibility considerations

**Use this for:**
- Implementing screens in Xcode
- Understanding user flows
- Handling edge cases
- Planning state management

---

## 🎨 Design Decisions

### Why iOS Native?
- **Performance:** Native Swift/SwiftUI for smooth 60fps
- **Platform integration:** VoiceOver, Dynamic Type, Keyboard, Safe Areas
- **Apple ecosystem:** Future Siri shortcuts, widgets, Watch app
- **Offline capable:** Local data caching, works without backend

### Why These Screens First (MVP)?
1. **Chat Screen:** Core functionality - talk to Jarvis
2. **Empty State:** User onboarding and guidance
3. **Quick Actions:** Fast access to common tasks
4. **Connection:** Manage backend connectivity

**Future screens (Phase 2):**
- Capsule Dashboard
- System Monitoring
- Settings and Preferences
- Notifications Center

### Design Language
- **iOS 17+ patterns:** Native look and feel
- **BuilderOS branding:** Blue/purple gradient, 🏗️ icon
- **Minimalist approach:** Focus on content, not chrome
- **Dark mode first:** Optimized for both themes equally

---

## 🔍 Design Review Checklist

Before implementing in Swift, verify:

### Visual Design
- [ ] Colors match specifications exactly
- [ ] Typography scales correctly
- [ ] Spacing follows 8pt grid
- [ ] Border-radius values consistent
- [ ] Gradients render smoothly

### iOS Compliance
- [ ] Status bar height correct (54px notch devices)
- [ ] Safe area insets respected (bottom 34px)
- [ ] Navigation bar standard height (44px)
- [ ] Touch targets minimum 44×44pt
- [ ] Sheet presentations follow iOS patterns

### Accessibility
- [ ] Color contrast meets WCAG AA (4.5:1 text)
- [ ] Dynamic Type support planned
- [ ] VoiceOver labels defined
- [ ] Reduced Motion fallbacks
- [ ] Keyboard navigation works

### Interactions
- [ ] Button press animations feel native
- [ ] Modal transitions smooth (0.3s)
- [ ] Message animations subtle
- [ ] Connection status updates in real-time
- [ ] Input bar responds to keyboard

### States
- [ ] Connected/Disconnected/Connecting states
- [ ] Empty state vs. populated chat
- [ ] Loading states for async operations
- [ ] Error states with helpful messages
- [ ] Success feedback (checkmarks, confirmation)

---

## 🚀 Next Steps for Implementation

### 1. Create Xcode Project
```bash
# Project already exists at:
/Users/Ty/BuilderOS/capsules/builder-system-mobile/BuilderSystemMobile.xcodeproj
```

**Setup:**
- Target: iOS 17.0+
- SwiftUI lifecycle
- Portrait orientation only (for now)
- Support iPhone and iPad (universal)

---

### 2. Define Data Models

**Message.swift:**
```swift
struct Message: Identifiable, Codable {
    let id: UUID
    let content: String
    let sender: MessageSender
    let type: MessageType
    let timestamp: Date
}

enum MessageSender: String, Codable {
    case user
    case system
}

enum MessageType: String, Codable {
    case text
    case code
}
```

**ConnectionStatus.swift:**
```swift
struct ConnectionStatus: Codable {
    var isConnected: Bool
    var server: String
    var version: String
    var latency: Int
    var lastConnected: Date?
}
```

**QuickAction.swift:**
```swift
struct QuickAction: Identifiable {
    let id = UUID()
    let icon: String // SF Symbol name or emoji
    let label: String
    let command: String
}
```

---

### 3. Create ViewModels

**ChatViewModel.swift:**
```swift
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isSending: Bool = false
    @Published var showQuickActions: Bool = false

    func sendMessage() { }
    func loadChatHistory() { }
    func scrollToBottom() { }
}
```

**ConnectionViewModel.swift:**
```swift
@MainActor
class ConnectionViewModel: ObservableObject {
    @Published var status: ConnectionStatus
    @Published var isConnecting: Bool = false
    @Published var lastSync: Date?

    func connect() { }
    func disconnect() { }
    func refreshStats() { }
}
```

---

### 4. Build SwiftUI Views

**Priority order:**
1. **MessageBubbleView.swift** - Reusable component (user/system/code variants)
2. **EmptyStateView.swift** - Welcome screen
3. **ChatView.swift** - Main screen (messages + input bar)
4. **QuickActionsSheet.swift** - Modal sheet
5. **ConnectionView.swift** - Settings screen
6. **ContentView.swift** - Root navigation container

---

### 5. Implement Design System

**Colors.swift:**
```swift
import SwiftUI

extension Color {
    static let builderPrimary = Color("BuilderPrimary") // #007AFF
    static let builderSuccess = Color("BuilderSuccess") // #34C759
    static let builderDestructive = Color("BuilderDestructive") // #FF3B30

    // System colors (auto light/dark)
    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
}
```

**Fonts.swift:**
```swift
extension Font {
    static let builderTitle = Font.system(size: 24, weight: .bold)
    static let builderHeading = Font.system(size: 20, weight: .bold)
    static let builderBody = Font.system(size: 15, weight: .regular)
    static let builderCode = Font.system(size: 13, weight: .regular, design: .monospaced)
}
```

**Spacing.swift:**
```swift
extension CGFloat {
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 20
}
```

---

### 6. Add Animations

**Message Slide-In:**
```swift
.transition(.asymmetric(
    insertion: .move(edge: .bottom).combined(with: .opacity),
    removal: .opacity
))
.animation(.easeOut(duration: 0.3), value: messages)
```

**Modal Sheet:**
```swift
.sheet(isPresented: $showQuickActions) {
    QuickActionsSheet()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
}
```

**Button Press:**
```swift
.scaleEffect(isPressed ? 0.92 : 1.0)
.animation(.spring(duration: 0.2), value: isPressed)
```

---

### 7. Connect to Backend

**WebSocket Manager:**
```swift
class WebSocketManager: ObservableObject {
    @Published var isConnected = false
    private var webSocket: URLSessionWebSocketTask?

    func connect(to url: URL)
    func disconnect()
    func send(message: String)
    func receive()
}
```

**Integration:**
- Connect on app launch
- Send messages via WebSocket
- Receive responses and append to chat
- Handle reconnection on network changes

---

### 8. Test on Devices

**Simulator Testing:**
- iPhone 14 Pro (primary)
- iPhone SE (compact)
- iPhone 14 Pro Max (large)
- iPad Pro (future)

**Physical Device Testing:**
- Ty's iPhone (actual hardware)
- Dark mode in different lighting
- Keyboard behavior
- Network switching (WiFi → Cellular)

---

## 🎯 Success Criteria

### Design Approval
- [ ] HTML preview matches expectations
- [ ] Light mode looks clean and professional
- [ ] Dark mode feels premium and comfortable
- [ ] All interactions feel natural
- [ ] Ready to implement in Swift

### Implementation Readiness
- [ ] All screens specified in detail
- [ ] Component specs documented
- [ ] State management planned
- [ ] Design system defined
- [ ] Accessibility requirements clear

### Technical Feasibility
- [ ] No impossible designs (all implementable in SwiftUI)
- [ ] Performance targets realistic
- [ ] Backend integration clear
- [ ] iOS guidelines followed

---

## 📚 Reference Materials

### Apple Documentation
- [iOS Design Guidelines (Human Interface Guidelines)](https://developer.apple.com/design/human-interface-guidelines/ios)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SF Symbols Browser](https://developer.apple.com/sf-symbols/)

### Design Tools
- **Penpot:** Full screen designs (once approved)
- **SF Symbols App:** Icon selection
- **Xcode Canvas:** Live preview while coding

### Inspiration
- **Apple Messages:** Chat interface patterns
- **Shortcuts App:** Quick actions design
- **Settings App:** Connection screen patterns

---

## 🔄 Iteration Process

**Current Phase:** Design Preview & Approval

**Next Phase (after approval):**
1. Create detailed Penpot mockups (optional, if needed)
2. Implement in SwiftUI
3. Test on physical device
4. Iterate based on real usage
5. Add backend integration
6. Beta testing

**Feedback Loop:**
1. Review HTML preview
2. Identify needed changes
3. Update design specs
4. Re-generate HTML preview
5. Repeat until approved

---

## 📝 Design Change Log

### Version 1.3.0 (October 22, 2025) - HYBRID DESIGN ✅
- **ADDED:** Hybrid terminal chat design (terminal-chat-hybrid.html) - **PRODUCTION-READY**
- **ADDED:** Complete implementation guide (HYBRID_IMPLEMENTATION_GUIDE.md)
- **MERGED:** Working Swift implementation + refined design specs
- **SHOWS:** 5 states (empty, status blocks, capsule list, conversation, quick actions)
- **VERIFIED:** Color accuracy (#60efff, #00ff88, #0a0e1a) via Playwright MCP ✓
- **VERIFIED:** Typography (JetBrains Mono) rendering correctly ✓
- **VERIFIED:** Accessibility (WCAG AA contrast ratios) ✓
- **SCREENSHOT:** terminal-chat-hybrid-full.png

### Version 1.2.0 (October 22, 2025)
- **ADDED:** Terminal chat interface design (terminal-chat-preview.html)
- **ADDED:** Complete terminal specifications (TERMINAL_CHAT_SPECS.md)
- **REPLACED:** Message bubbles with authentic terminal command history
- **ADDED:** Command prompt ($) prefix, terminal output formatting
- **ADDED:** JetBrains Mono typography, gradient color system
- **VERIFIED:** Visual accuracy confirmed via Playwright MCP

### Version 1.1.0 (October 22, 2025)
- **ADDED:** Terminal aesthetic design exploration
- **ADDED:** Design system for terminal theme (colors, typography, animations)
- Terminal aesthetic approved for home screen

### Version 1.0.0 (October 22, 2025)
- Initial design system created
- 4 screen specifications documented
- Interactive HTML preview generated (mobile-app-preview.html)
- iOS 17+ design patterns applied
- Light/dark mode support added

**Future versions:**
- v1.2: Complete all screens in Penpot design file
- v1.3: iPad adaptations
- v1.4: Widgets and Siri shortcuts
- v1.5: Apple Watch companion

---

## 💬 Questions & Feedback

### Common Questions

**Q: Why HTML preview instead of Penpot/Figma?**
A: HTML is interactive, shareable, and lets you toggle light/dark mode easily. Penpot mockups can come later for final designs.

**Q: Can I change colors/fonts?**
A: Yes! Update `DESIGN_SYSTEM.md` and regenerate HTML preview. Keep iOS guidelines in mind.

**Q: What about landscape mode?**
A: MVP is portrait-only. Landscape support comes in Phase 2.

**Q: How do I test animations?**
A: HTML preview shows static active states. Real animations require SwiftUI implementation.

**Q: Where's the backend API documentation?**
A: Coming soon in `docs/API.md` - WebSocket protocol for Jarvis communication.

---

## 🚀 Ready to Build?

**Before you start coding:**
1. ✅ Review HTML preview (all 4 screens)
2. ✅ Read Design System documentation
3. ✅ Read Screen Specifications
4. ✅ Approve design direction
5. ✅ Open Xcode and start implementing!

**Questions or changes needed?**
- Update design specs in this directory
- Re-generate HTML preview if needed
- Document decisions in this README

---

**Design System Version:** 1.0.0
**Last Updated:** October 22, 2025
**Designer:** UI/UX Designer Agent (BuilderOS)
**Platform:** iOS 17+
**Status:** Ready for Review & Implementation 🚀

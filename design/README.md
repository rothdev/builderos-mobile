# BuilderOS Mobile — iOS Design Deliverables

**Created:** October 2025
**Platform:** iOS 17+ (iPhone 15 Pro primary target)
**Design Language:** Native iOS with SF Pro font system and semantic colors

---

## Quick Start

Open any of the HTML mockups in your browser to view interactive designs:

```bash
# Open all designs
open design-system.html
open dashboard-screen.html
open chat-screen.html
open settings-screen.html
open onboarding-flow.html
```

Or double-click any `.html` file in Finder.

---

## File Structure

```
design/
├── README.md                      # This file - Quick reference guide
├── DESIGN_DOCUMENTATION.md        # Complete design specifications
├── design-system.html             # Color palette, typography, spacing, components
├── dashboard-screen.html          # Main dashboard with capsule grid
├── chat-screen.html               # Terminal/chat interface with voice input
├── settings-screen.html           # Settings and Tailscale management
└── onboarding-flow.html           # 5-step first-time setup flow
```

---

## What's Included

### 1. Design System (`design-system.html`)

**Interactive color palette:**
- Brand colors (Primary, Secondary, Tailscale Accent)
- Status colors (Success, Warning, Error, Info)
- Semantic adaptive colors (Light/Dark mode)

**Typography scale:**
- Display, Headline, Title, Body, Label variants
- SF Pro and SF Mono font families
- Dynamic Type support specifications

**Spacing system:**
- 8pt base grid (4pt to 48pt)
- Touch target specifications (44pt minimum)
- Corner radius values

**Component library:**
- Buttons (Primary, Secondary, Destructive, Disabled)
- Status badges (Active, Development, Testing, Error)
- Cards (Standard, Capsule, Stat)
- Connection status indicators
- Form elements (inputs, toggles)

### 2. Dashboard Screen (`dashboard-screen.html`)

**iPhone 15 Pro mockup showing:**
- Pull-to-refresh interaction
- Connection status card (Tailscale info)
- 2x2 stats grid (Total Capsules, Active, Testing, API Latency)
- Capsule grid (2 columns) with status badges
- Tab bar navigation

**Key interactions:**
- Tap capsule → Capsule Detail View
- Pull down → Refresh data
- Tab bar → Switch screens

### 3. Chat/Terminal Screen (`chat-screen.html`)

**Interactive chat interface with:**
- Message bubbles (user + system)
- Code block rendering
- Quick actions toolbar
- Voice input button with recording animation
- Text input field

**Features demonstrated:**
- SSH command execution
- Voice-to-text input
- Message history scrolling
- Status messages

### 4. Settings Screen (`settings-screen.html`)

**Grouped settings list showing:**
- Tailscale connection status
- Device list with IPs
- API key management
- Power controls (Sleep/Wake Mac)
- App preferences (notifications, appearance)
- About section

**Interactive elements:**
- Toggle switches (working JavaScript demo)
- Tappable rows with chevrons
- Status badges

### 5. Onboarding Flow (`onboarding-flow.html`)

**5-step first-time setup:**
1. **Welcome Screen** — App intro and value proposition
2. **Tailscale OAuth** — Authentication provider selection
3. **Auto-Discovery** — Automatic Mac detection with loading animation
4. **API Key Entry** — Secure API setup with form validation
5. **Success** — Confirmation and transition to main app

**Includes:**
- User flow diagram (text-based)
- Implementation notes
- Error handling specifications

### 6. Complete Documentation (`DESIGN_DOCUMENTATION.md`)

**Comprehensive specifications including:**
- Complete design system (colors, typography, spacing)
- All screen layouts and components
- Interaction patterns (gestures, animations, haptics)
- Accessibility requirements (VoiceOver, Dynamic Type, WCAG AA)
- Implementation handoff notes for Mobile Dev
- Design decisions and rationale
- Testing checklist

---

## Design Principles

### iOS 17+ Native Patterns

✅ **SF Pro font system** with Dynamic Type support
✅ **Semantic colors** that adapt to Light/Dark mode automatically
✅ **8pt grid system** for consistent spacing and rhythm
✅ **44pt minimum touch targets** (Apple HIG compliance)
✅ **Native iOS components**: TabView, NavigationStack, Form, List
✅ **Spring animations** with iOS-native curves (0.3s-0.5s duration)
✅ **Pull-to-refresh** gesture on scrollable views
✅ **Haptic feedback** on key interactions

### Accessibility First

✅ **VoiceOver labels** on all interactive elements
✅ **Dynamic Type support** for text scaling (Small to AX5)
✅ **High contrast mode** compatibility
✅ **Color-blind friendly** status indicators (icons + color)
✅ **Keyboard navigation** support on iPadOS
✅ **Reduce Motion** support for animations

### Performance Targets

✅ **60fps animations** on iPhone 12 and newer
✅ **Launch time** under 400ms
✅ **API response rendering** under 100ms
✅ **Smooth scrolling** with lazy loading for capsule grid

---

## Implementation Reference

### Existing Swift Files

The design system is already defined in your codebase:

- **`src/Utilities/Colors.swift`** — All color definitions (matches design system)
- **`src/Utilities/Typography.swift`** — Font styles (matches design system)
- **`src/Utilities/Spacing.swift`** — Layout constants (matches design system)
- **`src/BuilderSystemMobile/Common/Theme.swift`** — Chat colors and button styles

### Key Implementation Notes

**1. Use semantic colors for automatic Light/Dark mode:**
```swift
.foregroundColor(.textPrimary)  // NOT .foregroundColor(.black)
.background(.backgroundPrimary) // NOT .background(.white)
```

**2. Use semantic font styles for Dynamic Type:**
```swift
.font(.headline)         // NOT .font(.system(size: 17))
.font(.bodyLarge)        // Custom semantic style
```

**3. Use spacing constants from design system:**
```swift
.padding(Spacing.base)   // 16pt
.padding(Spacing.lg)     // 24pt
```

**4. Use spring animations (defined in Spacing.swift):**
```swift
.animation(.springNormal)  // Default
.animation(.springFast)    // Quick interactions
.animation(.springBouncy)  // Celebratory effects
```

**5. Minimum 44pt touch targets:**
```swift
Button("Action") { }
    .frame(minWidth: 44, minHeight: 44)
```

### Component Reusability

Build components once, use everywhere:

- **Status Badge** → Dashboard, Capsule Detail, Settings
- **Card** → Capsules, Stats, Connection Info
- **Button** → Primary, Secondary, Destructive variants
- **Message Bubble** → Chat/Terminal screen
- **Toggle** → Settings screen

### SF Symbols

Replace emoji placeholders with SF Symbols:

- Dashboard icon: `chart.bar.fill`
- Chat icon: `message.fill`
- Preview icon: `safari.fill`
- Settings icon: `gearshape.fill`
- Chevron: `chevron.right`
- Checkmark: `checkmark.circle.fill`

---

## Screen Flow

```
Launch App
    ↓
Has API Key in Keychain?
    ├─ Yes → Dashboard (Main App)
    └─ No → Onboarding Flow
            ├─ Welcome Screen
            ├─ Tailscale OAuth
            ├─ Auto-Discovery
            ├─ API Key Entry
            └─ Success → Dashboard

Main App (Tab Bar Navigation)
    ├─ Dashboard Tab
    │   ├─ Connection Status Card
    │   ├─ Stats Grid (2x2)
    │   └─ Capsule Grid (2 columns)
    │       └─ Tap Capsule → Capsule Detail View
    │
    ├─ Chat Tab
    │   ├─ Message History
    │   ├─ Quick Actions Toolbar
    │   └─ Input Container (Voice + Text)
    │
    ├─ Preview Tab
    │   └─ WebView (localhost dev servers via Tailscale)
    │
    └─ Settings Tab
        ├─ Tailscale Connection
        ├─ Device List
        ├─ API Configuration
        ├─ Power Controls
        └─ App Settings
```

---

## Design Decisions & Rationale

### Why Native iOS Patterns?

- **Familiarity:** No learning curve for iPhone users
- **Accessibility:** Built-in VoiceOver, Dynamic Type, High Contrast
- **Performance:** Native 60fps animations
- **Light/Dark Mode:** Automatic adaptation with semantic colors
- **Future-proof:** Consistent with iOS HIG, adapts to new iOS versions

### Why 8pt Grid System?

- **Consistency:** Divides evenly into common screen widths
- **Rhythm:** Creates visual harmony across all screens
- **Scalability:** Easy to scale for iPhone and iPad
- **Industry Standard:** Used by Apple and most iOS apps

### Why SF Pro Font System?

- **Native:** No custom fonts needed (smaller app size)
- **Optimized:** Designed specifically for iOS readability
- **Dynamic Type:** Automatic scaling for accessibility
- **System Consistency:** Matches native iOS apps

### Why Tab Bar Navigation?

- **iOS Standard:** Expected pattern for multi-section apps
- **Persistent Access:** One tap to any main section
- **Clear Location:** Always know where you are
- **Thumb-Friendly:** Easy to reach on iPhone

---

## Testing Checklist

Before submitting to TestFlight:

- [ ] All screens render correctly in **Light and Dark mode**
- [ ] **VoiceOver** can navigate all interactive elements
- [ ] **Dynamic Type** scales text at smallest (Small) and largest (AX5) sizes
- [ ] All touch targets are **minimum 44pt**
- [ ] Animations respect **Reduce Motion** setting
- [ ] **Pull-to-refresh** works on Dashboard and Settings
- [ ] **Tab bar** switches between all screens
- [ ] **Onboarding flow** completes successfully (new user)
- [ ] **API key** stored securely in Keychain
- [ ] **Tailscale connection** establishes and auto-discovers Mac
- [ ] **Voice input** records and transcribes speech
- [ ] **Chat messages** send commands and display responses
- [ ] **Settings toggles** persist between app launches
- [ ] **App launches** in under 400ms (warm start)
- [ ] **Scrolling** is smooth 60fps on capsule grid

---

## Next Steps for Mobile Dev

### Implementation Order:

1. ✅ **Design System** (Already exists in Swift files)
2. **Component Library** (Build reusable SwiftUI views)
   - Buttons (Primary, Secondary, Destructive)
   - Status Badges (Active, Development, Testing, Error)
   - Cards (Capsule, Stat, Connection)
   - Message Bubbles (User, System)
3. **Onboarding Flow** (5 screens)
   - TailscaleConnectionManager integration
   - OAuth web flow
   - Auto-discovery logic
   - Keychain storage
4. **Main App** (4 tabs)
   - Dashboard View
   - Chat View (SSHService integration)
   - Preview View (WebView)
   - Settings View
5. **Detail Screens**
   - Capsule Detail View
   - API Key Edit View
6. **Polish**
   - Animations and haptics
   - Accessibility testing
   - Performance optimization

### Key Integration Points:

- **TailscaleConnectionManager:** VPN lifecycle, OAuth, device discovery
- **BuilderOSAPIClient:** REST API with auto-discovered Mac IP
- **SSHService:** Command execution via SSH for chat/terminal
- **VoiceManager:** Speech recognition for voice input
- **Keychain:** Secure storage for API keys and tokens

---

## Questions or Clarifications?

Refer to:
- **`DESIGN_DOCUMENTATION.md`** — Complete specifications
- **HTML mockups** — Visual reference (pixel-perfect layouts)
- **Existing Swift files** — Color, typography, spacing definitions
- **Apple HIG** — iOS Human Interface Guidelines

All designs follow native iOS patterns and Apple HIG compliance for seamless App Store approval.

---

**Design Complete:** October 2025
**UI/UX Designer Agent**
**Ready for implementation by Mobile Dev (📱)**

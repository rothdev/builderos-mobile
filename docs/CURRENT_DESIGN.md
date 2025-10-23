# BuilderOS Mobile - Current Design Documentation

**Last Updated:** October 23, 2025
**Source of Truth:** Swift source code in `/src/`
**Status:** Extracted from actual implementation

---

## Design System

### Color Palette

**Brand Colors:**
- Primary: System Blue (`.blue`)
- Secondary: System Blue (`.systemBlue`)
- Accent: Blue gradient (`.blue` to `.blue.opacity(0.7)`)
- Gradient Variant: Blue to Purple (`.blue` to `.purple`)

**Status Colors:**
- Success: `.green` (system)
- Warning: `.orange` (system)
- Error: `.red` (system)
- Info: `.blue` (system)

**Semantic Colors (Adaptive Light/Dark):**
- Text Primary: `.primary`
- Text Secondary: `.secondary`
- Background Primary: `.systemBackground`
- Background Secondary: `.secondarySystemBackground`
- Background Tertiary: `.tertiarySystemBackground`

**Tailscale Brand Integration:**
- Tailscale Primary: `#2E3338` (RGB: 0.18, 0.20, 0.24)
- Tailscale Accent: `#598FFF` (RGB: 0.35, 0.56, 1.00)

**Chat/Message Colors:**
- User Message: `.blue`
- System Message: `.systemGray5`
- Code Block: `.systemGray2`

**Materials:**
- Ultra Thin Material: `.ultraThinMaterial` (used for cards, overlays)

---

### Typography System

**Design Philosophy:** SF Pro Rounded for display text, SF Pro Default for body text, SF Mono for code/data

#### Display Fonts (Rounded Design)
- **Display Large:** 57pt, Bold, Rounded
- **Display Medium:** 45pt, Bold, Rounded
- **Display Small:** 36pt, Bold, Rounded

#### Headline Fonts (Rounded Design)
- **Headline Large:** 32pt, Semibold, Rounded
- **Headline Medium:** 28pt, Semibold, Rounded
- **Headline Small:** 24pt, Semibold, Rounded

#### Title Fonts (Default Design)
- **Title Large:** 22pt, Semibold, Default
- **Title Medium:** 16pt, Semibold, Default
- **Title Small:** 14pt, Semibold, Default

#### Body Fonts (Default Design)
- **Body Large:** 16pt, Regular, Default
- **Body Medium:** 14pt, Regular, Default
- **Body Small:** 12pt, Regular, Default

#### Label Fonts (Default Design)
- **Label Large:** 14pt, Medium, Default
- **Label Medium:** 12pt, Medium, Default
- **Label Small:** 11pt, Medium, Default

#### Monospaced Fonts (Code/Data)
- **Mono Large:** 16pt, Regular, Monospaced
- **Mono Medium:** 14pt, Regular, Monospaced
- **Mono Small:** 12pt, Regular, Monospaced

#### Text Styles (Predefined Compositions)
- **H1:** Display Large, Primary Color, 4pt line spacing
- **H2:** Display Medium, Primary Color, 4pt line spacing
- **H3:** Display Small, Primary Color, 2pt line spacing
- **Body:** Body Medium, Primary Color, 2pt line spacing
- **Caption:** Label Medium, Secondary Color, 1pt line spacing

---

### Spacing System

**Base Grid:** 8pt system with 4pt sub-grid

- **XS:** 4pt - Minimal spacing
- **SM:** 8pt - Small spacing
- **MD:** 12pt - Compact spacing
- **Base:** 16pt - Default spacing (most common)
- **LG:** 24pt - Large spacing
- **XL:** 32pt - Extra large spacing
- **XXL:** 48pt - Extra extra large spacing
- **XXXL:** 64pt - Massive spacing

#### Corner Radius
- **XS:** 4pt - Minimal rounding
- **SM:** 8pt - Small rounding (buttons, tags)
- **MD:** 12pt - Default rounding (cards, containers)
- **LG:** 16pt - Large rounding
- **XL:** 20pt - Extra large rounding
- **Circle:** 9999pt - Full circle

#### Icon Sizes
- **SM:** 16pt - Small icons
- **MD:** 24pt - Default icons
- **LG:** 32pt - Large icons
- **XL:** 48pt - Extra large icons
- **XXL:** 64pt - Hero icons

#### Layout Constants
- **Min Touch Target:** 44pt (Apple HIG minimum)
- **Touch Target:** 48pt (comfortable)
- **Large Touch Target:** 56pt (generous)
- **Screen Padding:** 20pt (edge margins)
- **Card Padding:** 16pt (internal padding)
- **List Item Height:** 60pt (standard row)

---

### Animation System

#### Durations
- **Fast:** 0.15s - Quick feedback
- **Normal:** 0.25s - Default transitions
- **Slow:** 0.35s - Deliberate animations
- **Very Slow:** 0.5s - Emphasis animations

#### Spring Presets
- **Spring Fast:** Response 0.3, Damping 0.7 (quick, snappy)
- **Spring Normal:** Response 0.4, Damping 0.8 (balanced)
- **Spring Bouncy:** Response 0.5, Damping 0.6 (playful)

#### Common Animation Patterns
- **Button Press:** Scale 0.95, 0.1s ease-in-out
- **Screen Transitions:** Spring Normal (0.3s response, 0.7 damping)
- **Sheet Presentation:** Spring animation with material blur

---

### Button Styles

#### Primary Button
- **Background:** Blue gradient (`.blue` to `.blue.opacity(0.8)`)
- **Text:** White, Semibold
- **Padding:** 20pt horizontal, 12pt vertical
- **Corner Radius:** 12pt
- **Press Effect:** Scale 0.95
- **Animation:** 0.1s ease-in-out

#### Secondary Button
- **Background:** `.systemGray5`
- **Text:** Blue
- **Padding:** 20pt horizontal, 12pt vertical
- **Corner Radius:** 10pt
- **Press Effect:** Scale 0.95
- **Animation:** 0.1s ease-in-out

#### Disabled State
- **All Variants:** Gray background, reduced opacity, cursor disabled

---

## Screen Designs

### 1. Onboarding View (First Launch)

**Purpose:** Initial setup flow for Cloudflare Tunnel connection

**Layout Structure:**
```
┌─────────────────────────────┐
│        [Back Button]        │ (Navigation Bar)
├─────────────────────────────┤
│         [Spacer]            │
│                             │
│    🧊 Cube Icon (120pt)     │ (Blue gradient)
│                             │
│       BuilderOS             │ (40pt Bold Rounded)
│   Connect to your Mac       │ (Title3 Secondary)
│                             │
│         [Spacer]            │
│                             │
│      [Step Content]         │ (Dynamic based on currentStep)
│                             │
│         [Spacer]            │
│                             │
│   [Primary Action Button]   │ (Blue gradient)
│      [Back Button]          │ (Secondary, if step > 0)
│                             │
└─────────────────────────────┘
```

**Step 0: Welcome**
- Icon: ✨ Sparkles (60pt, blue)
- Headline: "Access your BuilderOS system from anywhere"
- Body: "Securely connect to your Mac using Cloudflare Tunnel..."
- Button: "Get Started"

**Step 1: Setup**
- Icon: 🔗 Link Circle (60pt, blue)
- Headline: "Enter Connection Details"
- Fields:
  - Cloudflare Tunnel URL (TextField, monospaced, `.systemGray6` background)
  - API Key (SecureField, monospaced, `.systemGray6` background)
- Caption: "Get these from your Mac's BuilderOS server output"
- Button: "Test Connection"

**Step 2: Connection Test**
- Loading State:
  - ProgressView (1.5x scale)
  - "Testing connection..." (Subheadline, secondary)
- Success State:
  - ✅ Checkmark Circle (60pt, green)
  - "Connected!" (Headline)
  - Connection info card (tunnel URL, monospaced)
  - Button: "Continue to BuilderOS"
- Error State:
  - ⚠️ Warning Triangle (60pt, orange)
  - "Connection failed" (Headline)
  - Error message (Subheadline, secondary)
  - Button: "Try Again"

**Colors:**
- Background: `.systemBackground`
- Icons: Blue (system)
- Buttons: Blue gradient (primary), gray (secondary)
- Fields: `.systemGray6` background, monospaced font

**Spacing:**
- Section spacing: 32pt
- Field spacing: 16pt
- Button spacing: 16pt
- Horizontal padding: 24pt
- Bottom padding: 32pt

---

### 2. Dashboard View (Main Screen)

**Purpose:** System status overview and capsule list

**Layout Structure:**
```
┌─────────────────────────────┐
│      BuilderOS              │ (Navigation Title)
│  [Pull to Refresh]          │
├─────────────────────────────┤
│ ScrollView                  │
│  ┌───────────────────────┐  │
│  │ Connection Status Card│  │ (.ultraThinMaterial, 12pt radius)
│  │ ● Connected           │  │
│  │ BuilderOS Mobile      │  │
│  │ ──────────────────    │  │
│  │ 🌐 tunnel URL         │  │
│  │ 🔒 Cloudflare Tunnel  │  │
│  └───────────────────────┘  │
│                             │
│  ┌───────────────────────┐  │
│  │ System Status Card    │  │ (.ultraThinMaterial, 12pt radius)
│  │ System Status   ● OK  │  │
│  │                       │  │
│  │ ┌─────┐ ┌─────┐      │  │ (2-column grid)
│  │ │Ver  │ │Time │      │  │
│  │ │2.1.0│ │68h  │      │  │
│  │ └─────┘ └─────┘      │  │
│  │ ┌─────┐ ┌─────┐      │  │
│  │ │Caps │ │Svcs │      │  │
│  │ │7/25 │ │3/3  │      │  │
│  │ └─────┘ └─────┘      │  │
│  └───────────────────────┘  │
│                             │
│  Capsules                   │ (Headline)
│  ┌─────┐ ┌─────┐           │ (2-column grid)
│  │ 🧊  │ │ 🧊  │           │
│  │Name │ │Name │           │
│  │Desc │ │Desc │           │
│  └─────┘ └─────┘           │
│  ┌─────┐ ┌─────┐           │
│  │ 🧊  │ │ 🧊  │           │
│  └─────┘ └─────┘           │
│                             │
└─────────────────────────────┘
```

**Connection Status Card:**
- Icon: Checkmark (connected) or X (disconnected)
- Title: "Connected" / "Disconnected" (Headline)
- Subtitle: "BuilderOS Mobile" (Subheadline, secondary)
- Divider
- Tunnel URL (Caption, monospaced, middle truncation)
- Badge: "Cloudflare Tunnel" with lock icon
- Loading: ProgressView (when refreshing)

**System Status Card:**
- Header: "System Status" + Health indicator (● colored circle)
- Stats Grid (2x2):
  - Version (tag icon)
  - Uptime (clock icon)
  - Capsules count (cube icon)
  - Services count (server icon)
- Each stat: Icon + Label (Caption, secondary) + Value (Title3, semibold)
- Background: `.background.opacity(0.5)` for stat items

**Capsule Cards (Grid):**
- 2-column grid
- Each card:
  - Cube icon (blue, top-left)
  - Name (Subheadline, semibold, 2-line limit)
  - Description (Caption, secondary, 2-line limit)
  - Background: `.ultraThinMaterial`
  - Corner radius: 12pt
  - Padding: 16pt
  - Tap: Navigate to CapsuleDetailView

**Empty State:**
- Icon: Transparent cube (48pt, secondary)
- Text: "No capsules found" (Headline, secondary)
- Padding: 40pt

**Colors:**
- Background: `.systemBackground`
- Cards: `.ultraThinMaterial`
- Health indicators: Green (healthy), Orange (degraded), Red (down)
- Icons: Blue (primary)

**Spacing:**
- Scroll padding: 20pt
- Section spacing: 24pt
- Grid spacing: 12pt

---

### 3. Terminal View (Multi-Tab)

**Purpose:** Multi-tab terminal interface (iTerm2-style)

**Layout Structure:**
```
┌─────────────────────────────┐
│ Terminal                    │ (Navigation Title)
├─────────────────────────────┤
│ [Tab1] [Tab2] [Tab3] [+]   │ (Custom Tab Bar)
├─────────────────────────────┤
│                             │
│   Terminal Content          │ (WebSocket Terminal View)
│   (Scrollable)              │
│                             │
│                             │
│                             │
│   $ command here            │
│                             │
│                             │
└─────────────────────────────┘
```

**Tab Bar:**
- Custom horizontal scroll view
- Max 3 tabs
- Each tab: Profile name + close button (×)
- Add button (+) when < 3 tabs
- Selected tab: Blue background
- Unselected: Secondary background

**Terminal Content:**
- WebSocketTerminalView per tab
- Profile-specific: Shell, Python, or Node.js
- Independent sessions per tab
- Full WebSocket integration

**Features:**
- Swipe between tabs (TabView paging)
- Close tab (minimum 1 tab required)
- Add tab (maximum 3 tabs)
- Profile selection per tab

---

### 4. Localhost Preview View

**Purpose:** Preview local dev servers via Cloudflare Tunnel

**Layout Structure:**
```
┌─────────────────────────────┐
│ Preview                     │ (Tab Bar Item)
├─────────────────────────────┤
│ 🌐 Connected                │ (Connection Header)
│    Cloudflare Tunnel        │
├─────────────────────────────┤
│ [React] [n8n] [API] [...]  │ (Horizontal Scroll - Quick Links)
├─────────────────────────────┤
│ [Custom Port] [Go]          │ (Custom Port Input)
├─────────────────────────────┤
│                             │
│      WKWebView Content      │ (or Empty State)
│                             │
│                             │
│                             │
└─────────────────────────────┘
```

**Connection Header:**
- Network icon (blue, title3)
- Status: "Connected" / "Not Connected" (16pt, semibold)
- Subtitle: "Cloudflare Tunnel" (12pt, monospaced, secondary)
- Loading indicator when active
- Background: `.secondarySystemBackground`
- Padding: 16pt

**Quick Links:**
- Horizontal scroll (no indicators)
- Each link:
  - Name (16pt, semibold)
  - Port (12pt, e.g., ":3000")
  - Description (10pt, e.g., "Development server")
  - Width: 140pt
  - Selected: Blue background, white text
  - Unselected: `.secondarySystemBackground`, primary text
  - Corner radius: 12pt
  - Padding: 12pt

**Predefined Links:**
- React/Next.js → :3000
- n8n Workflows → :5678
- BuilderOS API → :8080
- Vite/Vue → :5173
- Flask/Django → :5000

**Custom Port Input:**
- TextField: "Custom port (e.g., 3001)" (Number pad)
- "Go" button (60pt width, blue when enabled)
- Horizontal layout with 12pt spacing
- Background: `.systemBackground`

**Empty State:**
- Globe icon (64pt, blue 30% opacity)
- Headline: "Preview Localhost" (22pt, semibold)
- Body: "Select a quick link or enter a custom port..." (15pt, secondary, center-aligned, 4pt line spacing)
- Vertical center

**WebView:**
- Full WKWebView integration
- Loading indicator in header
- Navigation delegate for load states

---

### 5. Settings View

**Purpose:** Tunnel configuration and app settings

**Layout Structure:**
```
┌─────────────────────────────┐
│ Settings                    │ (Navigation Title)
├─────────────────────────────┤
│ Form                        │
│                             │
│ Cloudflare Tunnel           │ (Section Header)
│ ┌─────────────────────────┐ │
│ │ Status                  │ │
│ │ ● Connected             │ │
│ │                         │ │
│ │ Tunnel URL              │ │
│ │ https://...             │ │
│ │                         │ │
│ │ [Sign Out]              │ │ (Destructive)
│ └─────────────────────────┘ │
│ Footer: Secure HTTPS...     │
│                             │
│ BuilderOS API               │ (Section Header)
│ ┌─────────────────────────┐ │
│ │ API Key                 │ │
│ │ ✓ Configured   [Update] │ │
│ └─────────────────────────┘ │
│ Footer: Stored in Keychain  │
│                             │
│ Mac Power Control           │ (Section Header)
│ ┌─────────────────────────┐ │
│ │ 🌙 Sleep Mac         >  │ │
│ │ ☀️ Wake Mac          >  │ │
│ └─────────────────────────┘ │
│ Footer: Sleep immediate...  │
│                             │
│ About                       │ (Section Header)
│ ┌─────────────────────────┐ │
│ │ Version       1.0.0     │ │
│ │ Build         1         │ │
│ │ Documentation      ↗    │ │ (Link)
│ └─────────────────────────┘ │
│                             │
└─────────────────────────────┘
```

**Connection Status:**
- Label: "Status" (Subheadline, secondary)
- Indicator: Colored circle (8pt) + "Connected" / "Disconnected"
- Loading: ProgressView when checking

**Tunnel URL:**
- Label: "Tunnel URL" (Subheadline, secondary)
- Value: Full URL (Caption, monospaced, 1-line)

**Sign Out Button:**
- Destructive role (red text)
- Full-width centered text
- Alert confirmation: "This will clear your stored API key..."

**API Key Row:**
- Label: "API Key" (Subheadline)
- Status: "Configured" (green) or "Not configured" (orange)
- Button: "Update" or "Add"

**Power Control Buttons:**
- Sleep Mac: Moon icon (blue) + text + chevron
- Wake Mac: Sun icon (orange) + text + chevron
- Disabled when not connected
- Loading: ProgressView inline
- Alert on completion

**About Section:**
- LabeledContent rows
- Documentation: External link with arrow icon

**API Key Input Sheet:**
- Modal presentation
- SecureField (monospaced, no autocorrect)
- Footer: Instructions with code snippet in monospaced block
- Cancel / Save buttons (Save disabled when empty)

**Colors:**
- Form background: `.systemGroupedBackground`
- Section backgrounds: `.systemBackground`
- Destructive: Red
- Status indicators: Green (good), Orange (warning), Red (error)

---

### 6. Capsule Detail View

**Purpose:** Detailed capsule information and metrics

**Layout Structure:**
```
┌─────────────────────────────┐
│ < Capsule Name              │ (Navigation Bar, inline)
├─────────────────────────────┤
│ ScrollView                  │
│                             │
│ Capsule Name                │ (Title Large, bold)
│ /path/to/capsule            │ (Body Small, secondary, 1-line)
│                      [Active]│ (Status badge)
│                             │
│ ─────────────────────────── │ (Divider)
│                             │
│ Description                 │ (Title Small, semibold)
│ Full capsule description... │ (Body Medium, secondary)
│                             │
│ Tags                        │ (Title Small, semibold)
│ [media] [server] [auto]    │ (Horizontal scroll chips)
│                             │
│ Metrics                     │ (Title Small, semibold)
│ Created      Jan 15, 2025   │
│ Updated      Feb 10, 2025   │
│ Tags         3              │
│                             │
└─────────────────────────────┘
```

**Header:**
- Name: Title Large (22pt), bold
- Path: Body Small (12pt), secondary, 1-line limit
- Status badge: Rounded rectangle (8pt radius)
  - Active: Green 20% opacity, green text
  - Development: Blue 20% opacity, blue text
  - Testing: Orange 20% opacity, orange text
  - Archived: Gray 20% opacity, gray text

**Description:**
- Section title: Title Small (14pt), semibold
- Body: Body Medium (14pt), secondary color
- Spacing: 8pt between title and body

**Tags:**
- Section title: Title Small (14pt), semibold
- Horizontal scroll (no indicators)
- Each tag:
  - Label Medium (12pt)
  - Background: `.backgroundSecondary`
  - Padding: 12pt horizontal, 6pt vertical
  - Corner radius: 8pt
  - Spacing: 8pt between tags

**Metrics:**
- Section title: Title Small (14pt), semibold
- Rows: Label (Body Medium, secondary) + Value (Body Medium, primary)
- HStack with Spacer between
- Spacing: 8pt between rows

**Colors:**
- Background: `.systemBackground`
- Text primary: `.textPrimary`
- Text secondary: `.textSecondary`
- Status colors: Match capsule status

**Spacing:**
- Screen padding: 20pt (Layout.screenPadding)
- Section spacing: 20pt
- Vertical spacing within sections: 8-12pt

---

### 7. Main Content View (Tab Bar)

**Purpose:** Primary navigation container

**Tab Bar Items:**
1. **Dashboard**
   - Icon: `square.grid.2x2.fill`
   - Label: "Dashboard"
   - View: DashboardView

2. **Terminal**
   - Icon: `terminal.fill`
   - Label: "Terminal"
   - View: MultiTabTerminalView

3. **Preview**
   - Icon: `globe`
   - Label: "Preview"
   - View: LocalhostPreviewView

4. **Settings**
   - Icon: `gearshape.fill`
   - Label: "Settings"
   - View: SettingsView

**Design:**
- Standard iOS TabView
- System icons (SF Symbols)
- Adaptive colors (light/dark mode)
- Tab bar background: Translucent material
- Selected: Blue tint
- Unselected: Secondary color

---

## Component Library

### Cards

**Material Card (`.ultraThinMaterial`):**
- Background: Ultra thin material (adaptive blur)
- Corner radius: 12pt
- Padding: 16pt (internal)
- Shadow: System default
- Used for: Status cards, capsule cards, info displays

**Stat Item Card:**
- Background: `.background.opacity(0.5)`
- Corner radius: 8pt
- Padding: 12pt
- Content: Icon + Label + Value
- Grid layout: 2 columns, 12pt spacing

### Badges

**Status Badge:**
- Font: Label Small (11pt), semibold
- Padding: 12pt horizontal, 6pt vertical
- Corner radius: 8pt
- Background: Status color at 20% opacity
- Text: Status color at 100%

**Tag Badge:**
- Font: Label Medium (12pt)
- Padding: 12pt horizontal, 6pt vertical
- Corner radius: 8pt
- Background: `.backgroundSecondary`
- Text: `.textPrimary`

### Form Fields

**TextField (Standard):**
- Font: Body (system) or Monospaced (for URLs/keys)
- Background: `.systemGray6`
- Corner radius: 10pt
- Padding: 12pt vertical, 16pt horizontal
- Autocapitalization: None (for technical input)

**SecureField:**
- Same as TextField but password entry
- Monospaced font for API keys
- No autocorrection

### Lists

**Capsule Grid:**
- LazyVGrid, 2 columns
- Flexible column sizing
- 12pt spacing between items
- NavigationLink wrapper (plain style)

**Settings Form:**
- Native iOS Form
- Grouped style
- Section headers and footers
- Standard iOS list styling

---

## Interaction Patterns

### Navigation

**Stack Navigation:**
- Dashboard → Capsule Detail (push)
- Onboarding steps (animated push/pop with spring)

**Tab Navigation:**
- 4 main tabs, swipe or tap to switch
- State preservation per tab

**Modal Presentation:**
- API Key input (sheet presentation)
- Alerts for confirmations (sign out, power control)

### Gestures

**Pull to Refresh:**
- Dashboard: Reload system status and capsules
- Swipe down from top

**Tap:**
- Capsule cards: Navigate to detail
- Quick links: Load localhost preview
- Buttons: Standard press feedback

**Swipe:**
- Terminal tabs: Swipe between tabs (TabView paging)
- Quick links: Horizontal scroll

### Loading States

**ProgressView:**
- Standard iOS activity indicator
- Inline (connection status, settings)
- Centered (onboarding test)
- Scaled (1.5x for emphasis)

**Shimmer/Skeleton:**
- Not currently implemented
- Loading shows ProgressView instead

### Empty States

**Pattern:**
- Large icon (48-64pt, secondary color with opacity)
- Headline text (secondary color)
- Optional body text
- Centered vertically and horizontally
- Generous padding (40pt)

**Examples:**
- Dashboard: "No capsules found" (cube icon)
- Preview: "Preview Localhost" (globe icon)

### Error States

**Alerts:**
- System alerts for critical errors
- Title + message + OK button
- Connection errors in onboarding

**Inline Errors:**
- Status indicators (red circle + "Disconnected")
- Alert messages in settings for power control

---

## Platform Integration

### iOS Features Used

**Keychain:**
- API token storage (KeychainManager)
- Secure, encrypted, device-only

**URLSession:**
- REST API calls to BuilderOS
- Retry logic (3 attempts, exponential backoff)
- Bearer token authentication

**WebSocket:**
- Terminal WebSocket connections
- Real-time command execution
- Profile-based sessions

**WKWebView:**
- Localhost preview rendering
- Navigation delegate for load states
- Full web rendering capabilities

**App Storage:**
- `hasCompletedOnboarding` flag
- Tunnel URL persistence

**Environment Objects:**
- `BuilderOSAPIClient` shared across views
- Reactive state management with Combine

### Accessibility

**Features Implemented:**
- Semantic colors (adapt to Light/Dark mode automatically)
- Dynamic Type support (system font scaling)
- SF Symbols for consistent iconography
- Minimum touch targets (44pt per Apple HIG)

**Not Yet Implemented:**
- VoiceOver labels (accessibility identifiers)
- Reduce motion support
- High contrast mode

---

## Data Models

### Capsule
```swift
struct Capsule: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let status: CapsuleStatus // active, development, archived, testing
    let createdAt: Date
    let updatedAt: Date
    let path: String
    let tags: [String]
}
```

### SystemStatus
```swift
struct SystemStatus: Codable {
    let version: String
    let uptime: TimeInterval
    let capsulesCount: Int
    let activeCapsulesCount: Int
    let lastAuditTime: Date?
    let healthStatus: HealthStatus // healthy, degraded, down
    let services: [ServiceStatus]
}
```

### ServiceStatus
```swift
struct ServiceStatus: Codable, Identifiable {
    let id: String
    let name: String
    let isRunning: Bool
    let port: Int?
}
```

---

## Xcode Project Structure

**Project Location:** `/Users/Ty/BuilderOS/capsules/builder-system-mobile/`

**Xcode Projects:**
- `BuilderSystemMobile.xcodeproj` (root level)
- `src/BuilderOS Mobile.xcodeproj`
- `src/BuilderSystemMobile.xcodeproj`

**Source Structure:**
```
src/
├── BuilderOSApp.swift              # App entry point
├── Models/
│   ├── Capsule.swift
│   └── SystemStatus.swift
├── Services/
│   ├── APIConfig.swift
│   ├── KeychainManager.swift
│   └── BuilderOSAPIClient.swift
├── Views/
│   ├── OnboardingView.swift
│   ├── DashboardView.swift
│   ├── MainContentView.swift
│   ├── MultiTabTerminalView.swift
│   ├── LocalhostPreviewView.swift
│   ├── SettingsView.swift
│   ├── CapsuleDetailView.swift
│   └── [Terminal components...]
├── Utilities/
│   ├── Colors.swift
│   ├── Typography.swift
│   └── Spacing.swift
└── BuilderSystemMobile/Common/
    └── Theme.swift
```

**Dependencies:**
- iOS 17+ (deployment target)
- SwiftUI (UI framework)
- Combine (reactive state)
- URLSession (networking)
- WKWebKit (web preview)
- WebSocket (terminal)

**Build System:**
- Xcode 15.0+
- Swift 5.9+
- Code signing required for device deployment
- Linked source files (not copied)

---

## Design Principles Applied

### iOS 17+ Design Language

**Translucent Materials:**
- `.ultraThinMaterial` for cards and overlays
- Adaptive blur that responds to content

**Semantic Colors:**
- All colors adapt to Light/Dark mode automatically
- `.primary`, `.secondary`, `.systemBackground` family
- Status colors use system defaults

**SF Symbols:**
- Consistent iconography throughout
- Variable weight support
- Semantic naming

**Dynamic Type:**
- Custom font system respects system scaling
- Text styles defined for consistency

### Apple Human Interface Guidelines Compliance

**Touch Targets:**
- Minimum 44pt (Layout.minTouchTarget)
- Comfortable 48pt (Layout.touchTarget)
- Large 56pt for primary actions

**Spacing:**
- 8pt base grid system
- Consistent padding and margins
- Screen edge padding: 20pt

**Navigation:**
- Standard iOS patterns (NavigationStack, TabView)
- Back button behavior
- Modal sheets for secondary flows

**Feedback:**
- Loading indicators for async operations
- Success/error states clearly distinguished
- Button press animations (scale 0.95)

### Modern iOS App Patterns

**MVVM Architecture:**
- Views (SwiftUI)
- ViewModels (EnvironmentObject)
- Models (Codable structs)

**Reactive State:**
- `@State`, `@Binding`, `@EnvironmentObject`
- Combine for async state updates
- Automatic view updates

**Async/Await:**
- Modern Swift concurrency
- `async` functions for API calls
- `await` for clean async code

**Material Design:**
- Blur effects for depth
- Translucency for hierarchy
- Gradients for emphasis

---

## Future Design Considerations

### Not Yet Implemented

**Advanced Interactions:**
- Swipe actions on capsule cards
- Long-press context menus
- Haptic feedback

**Accessibility:**
- Comprehensive VoiceOver labels
- Reduce motion alternatives
- High contrast mode support
- Larger text accessibility

**Animations:**
- More sophisticated transitions
- Loading skeletons/shimmers
- Success/error animations
- Pull-to-refresh custom indicator

**Components:**
- Search/filter for capsules
- Sort options (date, name, status)
- Advanced terminal features (syntax highlighting)
- Code editor integration

### Planned Features (Q1-Q2 2026)

**Phase 2:**
- Push notifications
- Capsule actions (start, stop, restart)
- Log viewer
- n8n workflow triggers

**Phase 3:**
- iPad optimized layout (NavigationSplitView)
- Apple Watch companion app
- Siri shortcuts integration
- Widgets (system status, quick actions)
- Jarvis/Codex chat integration

---

## Implementation Notes

### Key Differences from Mockups

**This documentation reflects the ACTUAL implementation, not design mockups.**

Previous HTML mockups and design files are outdated. The Swift source code is the single source of truth for:
- Component styling
- Color values
- Spacing measurements
- Typography scales
- Interaction behaviors
- Layout structures

### Testing Approach

**Xcode Previews:**
- All views have `#Preview` macros
- Use mock data for testing
- No actual API calls in previews

**Mock Data:**
- `Capsule.mock` and `Capsule.mockList`
- `SystemStatus.mock`
- Defined in model files

**Device Testing:**
- Real device required for full testing
- Simulator for UI iteration
- TestFlight for beta distribution

---

## Design Handoff Guidelines

For future design work on this project:

1. **Read the Swift code first** - It's the source of truth
2. **Use this documentation** - As a reference for current implementation
3. **Match iOS patterns** - Follow Apple HIG, use system components
4. **Test in Xcode** - Previews and device testing required
5. **Update documentation** - Keep this file in sync with changes
6. **Reference Figma/Penpot** - For inspiration, but implement in Swift
7. **Verify with 📱 Mobile Dev** - Technical feasibility before finalizing

---

**Document Version:** 1.0
**Last Verified:** October 23, 2025
**Maintainer:** UI/UX Designer Agent
**Next Review:** When new screens or components are added

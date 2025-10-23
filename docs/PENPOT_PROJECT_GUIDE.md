# BuilderOS Mobile - Penpot Project Creation Guide

## Overview

This guide provides instructions for creating the **BuilderOS Mobile** project in your local Penpot instance, based on the design system and screen mockups generated for the iOS companion app.

## Project Information

**Project Name:** BuilderOS Mobile
**Platform:** iOS 17+ (Native SwiftUI)
**Design System:** iOS 17+ with Light/Dark mode support
**Local Penpot Instance:** http://localhost:3449

## Pre-Generated Design Artifacts

The following design artifacts have been created and are available for reference:

### 1. Design System Reference
**Location:** `/tmp/builderos-mobile-design-system.html`
**Screenshot:** `/Users/Ty/BuilderOS/.playwright-mcp/builderos-mobile-design-system.png`

**Contents:**
- Brand colors (Primary, Success, Error, Warning)
- Semantic colors (Light + Dark mode)
- Typography system (SF Pro Display/Text, 8 text styles)
- Spacing system (8pt grid)
- Component specifications (Buttons, Lists, Cards)
- iOS 17+ patterns (Tab Bar, Navigation Bar, Pull-to-Refresh)
- Accessibility requirements (VoiceOver, Dynamic Type, Contrast, Motion, Touch Targets)

### 2. Screen Mockups
**Location:** `/tmp/builderos-mobile-screens.html`
**Screenshot:** `/Users/Ty/BuilderOS/.playwright-mcp/builderos-mobile-screens-overview.png`

**6 Main Screens:**
1. **OnboardingView** - First-time setup (tunnel URL + API token)
2. **DashboardView** - System status, capsule grid, pull-to-refresh
3. **ChatView** - Terminal/chat with Jarvis, voice input, quick actions
4. **LocalhostPreviewView** - WebView for localhost dev servers
5. **SettingsView** - Configuration and preferences
6. **CapsuleDetailView** - Detailed capsule metrics and actions

## Existing Code-Based Design System

The iOS app already has a complete design system implemented in SwiftUI:

**Design System Files:**
- `BuilderOSMobile/Theme/Colors.swift` - Semantic color system with Light/Dark mode
- `BuilderOSMobile/Theme/Typography.swift` - SF Pro font system, Dynamic Type support
- `BuilderOSMobile/Theme/Spacing.swift` - 8pt grid spacing constants
- `BuilderOSMobile/Theme/Theme.swift` - Chat-specific colors, button styles, message bubbles

**Key Design Tokens:**

```swift
// Colors (from Colors.swift)
.primary (systemBlue) - #007AFF
.success (systemGreen) - #34C759
.error (systemRed) - #FF3B30
.warning (systemOrange) - #FF9500
.background (light: white, dark: black)
.secondaryBackground (light: #F2F2F7, dark: #1C1C1E)
.label (light: black, dark: white)
.secondaryLabel (light: #3C3C43 60%, dark: #EBEBF5 60%)

// Typography (SF Pro Display/Text)
.largeTitle - 34pt Bold
.title1 - 28pt Bold
.title2 - 22pt Bold
.headline - 17pt Semibold
.body - 17pt Regular
.callout - 16pt Regular
.subheadline - 15pt Regular
.footnote - 13pt Regular
.code - SF Mono 14pt

// Spacing (8pt grid)
xs: 4pt, sm: 8pt, md: 12pt, lg: 16pt, xl: 20pt, xxl: 24pt, xxxl: 32pt
```

## Creating the Penpot Project

### Step 1: Access Local Penpot
1. Ensure Penpot dev instance is running: `cd ~/BuilderOS/capsules/penpot-dev && ./start-penpot.sh`
2. Open browser to: http://localhost:3449
3. Log in to your Penpot account

### Step 2: Create New Project
1. Click **"Create New Project"** in the Penpot dashboard
2. Project Name: **BuilderOS Mobile**
3. Description: "iOS 17+ companion app for BuilderOS - secure remote access via Cloudflare Tunnel"

### Step 3: Create Artboards for Each Screen

Create 6 artboards (iPhone 14 Pro size: 390x844pt) for each main view:

#### Artboard 1: OnboardingView (390x844pt)
**Elements:**
- Hero section with 🏗️ icon
- Large title: "Welcome to BuilderOS Mobile"
- Subtitle: "Secure remote access to your BuilderOS system via Cloudflare Tunnel"
- Text input: Tunnel URL (placeholder: "builderos.tunnel.com")
- Text input: API Token (password field)
- Primary button: "Connect to BuilderOS"
- Info card: Secure connection explanation

**Colors:**
- Background: Light (#F2F2F7) / Dark (#000)
- Hero gradient: rgba(0, 122, 255, 0.05) to transparent
- Input fields: Light (#F2F2F7) / Dark (#2C2C2E)
- Primary button: #007AFF
- Info card: rgba(0, 122, 255, 0.1) with left border #007AFF

#### Artboard 2: DashboardView (390x844pt)
**Elements:**
- Navigation bar: "Dashboard" (34pt Bold), subtitle "BuilderOS Mobile v1.0"
- Connection status card (green gradient: #34C759 to #30D158)
  - Title: "Connected"
  - URL: "builderos.tunnel.com"
  - Last synced info
- System overview card with 4 metrics (Capsules, Active, CPU, Memory)
- Section title: "Active Capsules" (20pt Semibold)
- 3 capsule cards:
  - **builder-system** - RUNNING badge, metrics (CPU, Memory, Tasks)
  - **brandjack** - RUNNING badge, metrics (CPU, Memory, Posts)
  - **jellyfin-server-ops** - STOPPED badge
- Tab bar (4 items: Dashboard, Chat, Preview, Settings)

**Colors:**
- Cards: White (#FFF) / Dark (#1C1C1E)
- RUNNING badge: #34C759
- STOPPED badge: #8E8E93
- Metrics labels: #6D6D72
- Metrics values: Primary/Success colors

#### Artboard 3: ChatView (390x844pt)
**Elements:**
- Navigation bar: "Chat with Jarvis", subtitle "AI Assistant"
- Messages container:
  - Assistant message (gray bubble: #E5E5EA / dark #2C2C2E)
  - User message (blue bubble: #007AFF)
  - Code block in assistant message (monospaced font, dark background)
  - Timestamp labels (12pt, #6D6D72)
- Quick action chips (blue tinted background)
- Chat input field (rounded, #F2F2F7 background)
- Voice button (blue circle, 🎤 icon)
- Tab bar

**Colors:**
- User bubbles: #007AFF (white text)
- Assistant bubbles: Light (#E5E5EA), Dark (#2C2C2E)
- Code blocks: rgba(0,0,0,0.05) / #2C2C2E
- Quick actions: rgba(0, 122, 255, 0.15), #007AFF text

#### Artboard 4: LocalhostPreviewView (390x844pt)
**Elements:**
- Navigation bar with custom controls:
  - Back button (tinted blue)
  - URL field (monospaced, "localhost:3000")
  - Refresh button (🔄)
- WebView content area (placeholder showing available dev servers)
- Tab bar

**Colors:**
- URL field background: rgba(0,0,0,0.05)
- URL text: #6D6D72 (monospaced)
- Back button: #007AFF

#### Artboard 5: SettingsView (390x844pt)
**Elements:**
- Navigation bar: "Settings"
- **Connection** section (grouped list):
  - Connection Status (green checkmark icon, "Connected • 45ms latency")
  - Tunnel URL (🌐 icon, "builderos.tunnel.com")
  - API Token (🔑 icon, "••••••••••••••••")
- **Preferences** section (grouped list):
  - Auto-Connect on Launch (toggle ON)
  - Voice Input Enabled (toggle ON)
  - Haptic Feedback (toggle ON)
  - Notifications (chevron)
- **About** section (grouped list):
  - App Version (1.0.0 Build 1)
  - API Version (v1.2.0)
  - Privacy Policy (chevron)
- Sign Out button (gray)
- Tab bar

**Colors:**
- List groups: White (#FFF) / Dark (#1C1C1E)
- List icons: Colored circles (green #34C759, blue #007AFF, orange #FF9500)
- Toggle ON: #34C759
- Section headers: #6D6D72 (13pt uppercase)

#### Artboard 6: CapsuleDetailView (390x844pt)
**Elements:**
- Navigation bar: Back button, "builder-system" (28pt), "BuilderOS Core Capsule"
- Status card (green gradient):
  - Status: "Running"
  - Uptime: "2h 45m"
  - Last Sync: "2 min ago"
- Performance card:
  - Metrics: CPU (8%), Memory (256 MB), Disk (1.2 GB)
  - Network stats: ↓ 24 KB/s ↑ 12 KB/s
  - Requests: 1,247 total
- Metadata card:
  - Tags: #core, #framework, #production (blue tinted chips)
  - Path, files changed, last deploy, version
- Action buttons:
  - View Logs (primary blue)
  - Restart (gray)
  - Stop Capsule (red tinted)
- Tab bar

**Colors:**
- Status card gradient: #34C759 to #30D158
- Tag chips: rgba(0, 122, 255, 0.15), #007AFF text
- Stop button: rgba(255, 59, 48, 0.15), #FF3B30 text

### Step 4: Create Light and Dark Mode Variants

For each artboard, create a duplicate with Dark mode colors:

**Dark Mode Color Mappings:**
- Background: #000 (black)
- Secondary Background: #1C1C1E
- Cards: #1C1C1E
- Labels: #FFF (white)
- Secondary Labels: #EBEBF5 60%
- Borders: rgba(255,255,255,0.1)
- Input fields: #2C2C2E
- Tab bar: rgba(28, 28, 30, 0.94)
- Primary blue: #0A84FF (slightly brighter for dark mode)

### Step 5: Apply iOS Design Patterns

**iOS-Specific Elements:**
- **Status Bar:** 44pt height, time on left (9:41), icons on right (📶 📡 🔋)
- **Navigation Bar:** Translucent material (rgba(248, 248, 248, 0.94)), backdrop blur
- **Large Titles:** 34pt bold, leading alignment
- **Tab Bar:** Translucent material, 4 items max, active state uses accent color
- **List Groups:** Rounded corners (10pt), grouped style with section headers
- **Buttons:** 10pt corner radius, 44pt minimum height
- **Cards:** 12pt corner radius, subtle shadow (0 2px 8px rgba(0,0,0,0.1))
- **Toggles:** iOS-style toggle switch (51x31pt, 16pt corner radius)

### Step 6: Add Components to Library

Create reusable components in Penpot:
- **iOS Button** (Primary, Secondary, Gray, Borderless variants)
- **iOS List Item** (with icon, title, subtitle, chevron)
- **iOS Card** (with header, metrics, actions)
- **iOS Toggle Switch**
- **iOS Tab Bar Item**
- **iOS Navigation Bar**
- **Message Bubble** (User, Assistant)
- **Capsule Status Badge**

### Step 7: Typography System Setup

Configure text styles in Penpot:
1. Large Title - SF Pro Display 34pt Bold
2. Title 1 - SF Pro Display 28pt Bold
3. Title 2 - SF Pro Display 22pt Bold
4. Headline - SF Pro Text 17pt Semibold
5. Body - SF Pro Text 17pt Regular
6. Callout - SF Pro Text 16pt Regular
7. Subheadline - SF Pro Text 15pt Regular
8. Footnote - SF Pro Text 13pt Regular
9. Code - SF Mono 14pt Regular

### Step 8: Color Palette Setup

Add to Penpot color library:

**Brand Colors:**
- Primary: #007AFF (Light), #0A84FF (Dark)
- Success: #34C759
- Error: #FF3B30
- Warning: #FF9500

**Semantic Colors (Light Mode):**
- Label: #000000
- Secondary Label: #3C3C43 (60% opacity)
- Background: #FFFFFF
- Secondary Background: #F2F2F7
- Tertiary Background: #FFFFFF
- Fill: rgba(120, 120, 128, 0.2)

**Semantic Colors (Dark Mode):**
- Label: #FFFFFF
- Secondary Label: #EBEBF5 (60% opacity)
- Background: #000000
- Secondary Background: #1C1C1E
- Tertiary Background: #2C2C2E
- Fill: rgba(120, 120, 128, 0.24)

### Step 9: Export Design Specs

Once complete, export from Penpot:
1. **PNG exports** of all 6 screens (Light + Dark) at 2x resolution
2. **Component specifications** for implementation handoff
3. **Design tokens** (colors, typography, spacing) as JSON

## Implementation Handoff Notes

### To 💻 macOS Dev / 📱 Mobile Dev:

**Platform:** iOS 17+ (SwiftUI)
**Minimum Version:** iOS 17.0+
**Target Devices:** iPhone (primary), iPad (adaptive layout)

**Design System Already Implemented:**
- ✅ Colors.swift - Semantic color system with Light/Dark mode
- ✅ Typography.swift - SF Pro font system, Dynamic Type
- ✅ Spacing.swift - 8pt grid spacing
- ✅ Theme.swift - Chat colors, button styles

**Views to Implement (priority order):**
1. OnboardingView - Tunnel URL + API token entry
2. DashboardView - System status, capsule grid
3. ChatView - Terminal/chat with Jarvis
4. SettingsView - Configuration
5. LocalhostPreviewView - WebView for dev servers
6. CapsuleDetailView - Detailed metrics

**iOS-Specific Requirements:**
- Use native iOS components (NavigationStack, TabView, List, Form)
- Respect Dynamic Type scaling (all text must scale)
- Implement VoiceOver accessibility labels
- Support Light + Dark mode (automatic via semantic colors)
- Haptic feedback on key interactions
- Pull-to-refresh on DashboardView
- Context menus on capsule cards (long press)
- Keyboard shortcuts (iPad support)

**Accessibility Requirements:**
- ✅ VoiceOver labels for all interactive elements
- ✅ Dynamic Type support (xSmall → AX5)
- ✅ WCAG AA contrast ratios (4.5:1 text, 3:1 UI)
- ✅ Minimum 44x44pt touch targets
- ✅ Reduce Motion support (disable animations)
- ✅ High Contrast mode support

**API Integration:**
- CloudflareService.swift - Tunnel connection management
- BuilderOSAPI.swift - REST API client
- Keychain storage for API token
- URLSession for all network requests

## Penpot MCP Integration (Post-Creation)

Once the project is created in Penpot, you can use the Penpot MCP tools to:

### List Projects
```
mcp__penpot__list_projects()
```

### Get Project Files
```
mcp__penpot__get_project_files(project_id: "<BuilderOS Mobile project ID>")
```

### Get Design File
```
mcp__penpot__get_file(file_id: "<file ID from project>")
```

### Extract Component Specs
```
mcp__penpot__get_object_tree(
  file_id: "<file ID>",
  object_id: "<screen object ID>",
  fields: ["name", "type", "fills", "strokes", "effects", "layout", "typography"],
  depth: -1
)
```

### Export Screenshots
```
mcp__penpot__export_object(
  file_id: "<file ID>",
  page_id: "<page ID>",
  object_id: "<screen object ID>",
  export_type: "png",
  scale: 2
)
```

## Reference Files

**Local Penpot Instance:**
- Frontend: http://localhost:3449
- Backend API: http://localhost:6060

**Design System HTML:**
- Design system: `/tmp/builderos-mobile-design-system.html`
- Screen mockups: `/tmp/builderos-mobile-screens.html`

**Screenshots:**
- Design system: `/Users/Ty/BuilderOS/.playwright-mcp/builderos-mobile-design-system.png`
- Screen mockups: `/Users/Ty/BuilderOS/.playwright-mcp/builderos-mobile-screens-overview.png`

**Code Implementation:**
- Swift source: `/Users/Ty/BuilderOS/capsules/builder-system-mobile/BuilderOSMobile/`
- Xcode project: `/Users/Ty/BuilderOS/capsules/builder-system-mobile/BuilderOSMobile.xcodeproj`

## Next Steps

1. ✅ Review design system HTML (`/tmp/builderos-mobile-design-system.html`)
2. ✅ Review screen mockups HTML (`/tmp/builderos-mobile-screens.html`)
3. ⏳ Create "BuilderOS Mobile" project in Penpot (http://localhost:3449)
4. ⏳ Design 6 artboards (OnboardingView, DashboardView, ChatView, PreviewView, SettingsView, CapsuleDetailView)
5. ⏳ Create Light + Dark mode variants for each screen
6. ⏳ Build component library in Penpot
7. ⏳ Export design specs and screenshots
8. ⏳ Hand off to Mobile Dev for SwiftUI implementation

---

**Note:** The Penpot MCP server currently supports reading existing projects/files and exporting objects, but does NOT support programmatic project/file creation. You must create the project manually in the Penpot UI at http://localhost:3449, then use MCP tools to retrieve and export design data.

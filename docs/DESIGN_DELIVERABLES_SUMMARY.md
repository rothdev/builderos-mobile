# BuilderOS Mobile - Design Deliverables Summary

## Project Status: Design System + Screen Mockups Complete ✅

This document summarizes the design deliverables created for the BuilderOS Mobile iOS companion app.

---

## 📦 Deliverables Created

### 1. Interactive Design System Reference
**File:** `/tmp/builderos-mobile-design-system.html`
**Screenshot:** `/Users/Ty/BuilderOS/.playwright-mcp/builderos-mobile-design-system.png`
**Preview:** Opened in Brave Browser + verified with Playwright MCP

**Contents:**
- ✅ Brand color system (Primary, Success, Error, Warning with hex values)
- ✅ Semantic colors for Light + Dark mode (Label, Background, Fill hierarchies)
- ✅ Typography system (8 text styles from Large Title 34pt to Footnote 13pt)
- ✅ Spacing system (8pt grid: xs 4pt → xxxl 32pt)
- ✅ Layout specifications (padding, card sizing, touch targets, corner radii)
- ✅ Component specifications (iOS Buttons, List Styles, Cards)
- ✅ iOS 17+ interaction patterns (Tab Bar, Navigation Bar, Pull-to-Refresh, Context Menus)
- ✅ Accessibility requirements (VoiceOver, Dynamic Type, WCAG AA contrast, Motion, Touch Targets)
- ✅ Interactive Light/Dark mode toggle

**Design System Highlights:**
- **Colors:** iOS semantic colors with automatic Light/Dark adaptation
- **Typography:** SF Pro Display/Text with Dynamic Type support (xSmall → AX5)
- **Spacing:** Consistent 8pt grid system (matches existing Swift implementation)
- **Components:** Native iOS patterns (grouped lists, translucent materials, rounded cards)

---

### 2. Complete Screen Mockups (6 Core Views)
**File:** `/tmp/builderos-mobile-screens.html`
**Screenshot:** `/Users/Ty/BuilderOS/.playwright-mcp/builderos-mobile-screens-overview.png`
**Preview:** Opened in Brave Browser + verified with Playwright MCP

**Screens Designed:**

#### ✅ 1. OnboardingView (390x844pt)
**Purpose:** First-time setup flow
**Elements:**
- Hero section with 🏗️ icon and gradient background
- Large title: "Welcome to BuilderOS Mobile"
- Subtitle: Cloudflare Tunnel explanation
- Text inputs: Tunnel URL + API Token (password field)
- Primary button: "Connect to BuilderOS"
- Security info card (blue tinted, left border accent)

**Design Notes:**
- Welcoming gradient hero (rgba(0, 122, 255, 0.05))
- Clear value proposition in subtitle
- Secure password field for API token
- Trust-building security explanation card

---

#### ✅ 2. DashboardView (390x844pt)
**Purpose:** System status overview with capsule grid
**Elements:**
- Navigation bar: "Dashboard" (34pt Bold) + "BuilderOS Mobile v1.0" subtitle
- Connection status card (green gradient): "Connected" with tunnel URL
- System overview card: 4 metrics (Capsules, Active, CPU, Memory)
- Section title: "Active Capsules" (20pt Semibold)
- 3 capsule cards with real data:
  - **builder-system** - RUNNING, 8% CPU, 256 MB, 12 tasks
  - **brandjack** - RUNNING, 3% CPU, 128 MB, 42 posts
  - **jellyfin-server-ops** - STOPPED
- Tab bar (4 items, Dashboard active)

**Design Notes:**
- Green gradient connection card = instant status visibility
- Metrics dashboard with real-time values
- Capsule cards show status badge + 3 key metrics
- Pull-to-refresh supported (documented in specs)
- Long-press context menu on cards (documented)

---

#### ✅ 3. ChatView (390x844pt)
**Purpose:** Terminal/chat interface with Jarvis AI
**Elements:**
- Navigation bar: "Chat with Jarvis" + "AI Assistant" subtitle
- Message bubbles:
  - Assistant (gray): "Hey Ty! 👋 I'm online..."
  - User (blue): "Show me the status of all capsules"
  - Assistant (gray): Response with code block (monospaced font)
  - User (blue): "Start the jellyfin server"
  - Assistant (gray): Success confirmation with emoji
- Quick action chips: "📊 System Status", "🔄 Refresh All", "📝 View Logs"
- Chat input field (rounded, gray background)
- Voice button (blue circle, 🎤 icon)
- Tab bar (Chat active)

**Design Notes:**
- Familiar iMessage-style chat bubbles
- Code blocks use SF Mono with dark background
- Quick action chips for common commands
- Voice input button for hands-free operation
- Timestamps on all messages (12pt, gray)

---

#### ✅ 4. LocalhostPreviewView (390x844pt)
**Purpose:** WebView for previewing localhost dev servers
**Elements:**
- Navigation bar with custom controls:
  - Back button (blue tinted)
  - URL field (monospaced, "localhost:3000")
  - Refresh button (🔄)
- WebView content area (placeholder showing concept)
- Active dev servers list:
  - localhost:3000 - Next.js
  - localhost:5173 - Vite
  - localhost:8080 - n8n
- Tab bar (Preview active)

**Design Notes:**
- Chrome-like navigation controls
- Monospaced URL field for developer familiarity
- WebView shows tunneled localhost content
- Easy switching between dev server ports

---

#### ✅ 5. SettingsView (390x844pt)
**Purpose:** Configuration for tunnel, API, preferences
**Elements:**
- Navigation bar: "Settings"
- **Connection** section (grouped list):
  - Connection Status (green ✓ icon, "Connected • 45ms latency")
  - Tunnel URL (🌐 icon, "builderos.tunnel.com")
  - API Token (🔑 icon, "••••••••••••••••")
- **Preferences** section (grouped list):
  - Auto-Connect on Launch (toggle ON)
  - Voice Input Enabled (toggle ON)
  - Haptic Feedback (toggle ON)
  - Notifications (chevron, navigation arrow)
- **About** section (grouped list):
  - App Version (1.0.0 Build 1)
  - API Version (v1.2.0)
  - Privacy Policy (chevron)
- Sign Out button (gray, full width)
- Tab bar (Settings active)

**Design Notes:**
- iOS-standard grouped list style
- Colored icons in circles (green, blue, orange)
- Native iOS toggle switches (51x31pt)
- Section headers (13pt uppercase, gray)
- Chevron arrows for navigation items

---

#### ✅ 6. CapsuleDetailView (390x844pt)
**Purpose:** Detailed metrics and actions for individual capsule
**Elements:**
- Navigation bar: Back button + "builder-system" (28pt) + "BuilderOS Core Capsule"
- Status card (green gradient):
  - Status: "Running" (28pt Bold)
  - Uptime: "2h 45m"
  - Last Sync: "2 min ago"
- Performance card:
  - Metrics grid: CPU (8%), Memory (256 MB), Disk (1.2 GB)
  - Network stats: ↓ 24 KB/s ↑ 12 KB/s
  - Total requests: 1,247
- Metadata card:
  - Tags: #core, #framework, #production (blue tinted chips)
  - Path: ~/BuilderOS/capsules/builder-system
  - Files changed: 7
  - Last deploy: Oct 23, 2025 9:10 AM
  - Version: 2.4.0
- Action buttons:
  - "View Logs" (primary blue)
  - "Restart" (gray)
  - "Stop Capsule" (red tinted, full width)
- Tab bar (Dashboard active)

**Design Notes:**
- Green gradient status card = instant health check
- 3-column metrics grid for performance
- Tag chips with blue tinted background
- Destructive action (Stop) uses red tint + full width
- Back navigation to return to dashboard

---

## 🎨 Design System Specifications

### Color System

**Brand Colors:**
- Primary (Light): `#007AFF` (System Blue)
- Primary (Dark): `#0A84FF` (Brighter for dark mode)
- Success: `#34C759` (System Green)
- Error: `#FF3B30` (System Red)
- Warning: `#FF9500` (System Orange)

**Semantic Colors (Light Mode):**
- Label: `#000000`
- Secondary Label: `#3C3C43` (60% opacity)
- Background: `#FFFFFF`
- Secondary Background: `#F2F2F7`
- Tertiary Background: `#FFFFFF`
- Fill: `rgba(120, 120, 128, 0.2)`

**Semantic Colors (Dark Mode):**
- Label: `#FFFFFF`
- Secondary Label: `#EBEBF5` (60% opacity)
- Background: `#000000`
- Secondary Background: `#1C1C1E`
- Tertiary Background: `#2C2C2E`
- Fill: `rgba(120, 120, 128, 0.24)`

---

### Typography System

**SF Pro Display/Text - Dynamic Type Support:**

| Text Style     | Size | Weight   | Line Height | Usage                          |
|----------------|------|----------|-------------|--------------------------------|
| Large Title    | 34pt | Bold     | 1.2         | Screen titles (Dashboard)      |
| Title 1        | 28pt | Bold     | 1.3         | Section headers (Active Capsules) |
| Title 2        | 22pt | Bold     | 1.3         | Subsection headers             |
| Headline       | 17pt | Semibold | 1.4         | Card titles                    |
| Body           | 17pt | Regular  | 1.6         | Main content text              |
| Callout        | 16pt | Regular  | 1.5         | Secondary info                 |
| Subheadline    | 15pt | Regular  | 1.5         | Tertiary info, timestamps      |
| Footnote       | 13pt | Regular  | 1.4         | Captions, metadata             |
| Code (SF Mono) | 14pt | Regular  | 1.5         | Terminal output, logs          |

**All text must support Dynamic Type scaling (xSmall → AX5)**

---

### Spacing System (8pt Grid)

| Token | Value | Usage                               |
|-------|-------|-------------------------------------|
| xs    | 4pt   | Icon padding, minimal gaps          |
| sm    | 8pt   | Button padding, small gaps          |
| md    | 12pt  | Input padding, medium gaps          |
| lg    | 16pt  | Card padding, screen padding (horizontal) |
| xl    | 20pt  | Screen padding (vertical)           |
| xxl   | 24pt  | Section spacing                     |
| xxxl  | 32pt  | Large section breaks                |

**Layout Specifications:**
- Screen padding: 16pt horizontal, 20pt vertical
- Card padding: 16pt internal
- List item height: 44pt minimum (touch target)
- Section spacing: 24pt between sections
- Component gap: 12pt between related items
- Corner radius: 10pt standard, 12pt large cards, 16pt modals

---

### Component Specifications

#### iOS Button Variants
- **Primary (Filled):** `#007AFF` background, white text, 10pt corner radius
- **Tinted Background:** `rgba(0, 122, 255, 0.15)` background, `#007AFF` text
- **Gray (Cancel):** `rgba(120, 120, 128, 0.2)` background, black text
- **Borderless (Text Only):** Transparent background, `#007AFF` text

**Button States:**
- Default: Full opacity
- Hover: Scale 1.02, slight shadow
- Active: Scale 0.98
- Disabled: 50% opacity, cursor not-allowed
- Focus: 2px outline, 2px offset

**Accessibility:** 44x44pt minimum touch target

---

#### iOS List Styles (Grouped)
- **Section headers:** 13pt uppercase, `#6D6D72`, 6pt padding top/bottom
- **List groups:** White background (Light) / `#1C1C1E` (Dark), 10pt corner radius
- **List items:** 12pt padding, 0.5px border-bottom `rgba(0,0,0,0.08)`
- **List icons:** 29x29pt circles, colored background
- **Chevrons:** `#C7C7CC`, 17pt font size

---

#### iOS Cards
- **Background:** White (Light) / `#1C1C1E` (Dark)
- **Corner radius:** 12pt
- **Shadow:** `0 2px 8px rgba(0,0,0,0.1)` (Light only)
- **Padding:** 16pt internal
- **Dividers:** 1px solid `rgba(0,0,0,0.08)` (Light) / `rgba(255,255,255,0.08)` (Dark)

---

#### iOS Toggle Switch
- **Size:** 51x31pt
- **Corner radius:** 16pt
- **ON state:** `#34C759` background
- **OFF state:** `rgba(120, 120, 128, 0.24)` background
- **Thumb:** 27x27pt circle, white, 2pt margin, shadow `0 3px 8px rgba(0,0,0,0.15)`

---

### iOS 17+ Interaction Patterns

#### Tab Bar Navigation
- **Material:** Translucent `rgba(248, 248, 248, 0.94)` (Light) / `rgba(28, 28, 30, 0.94)` (Dark)
- **Backdrop filter:** Blur 20px
- **Border:** 0.5px top border `rgba(0,0,0,0.1)`
- **Padding:** 8pt top, 24pt bottom (safe area)
- **Items:** 4 max, active state uses `#007AFF` (Light) / `#0A84FF` (Dark)
- **Icons:** 28pt emoji/SF Symbols
- **Labels:** 10pt Regular (inactive), 10pt Medium (active)

#### Navigation Bar (Large Titles)
- **Material:** Translucent `rgba(248, 248, 248, 0.94)` (Light) / `rgba(28, 28, 30, 0.94)` (Dark)
- **Backdrop filter:** Blur 20px
- **Border:** 0.5px bottom border `rgba(0,0,0,0.1)`
- **Title:** 34pt Bold, leading alignment
- **Subtitle:** 13pt Regular, `#6D6D72`

#### Pull-to-Refresh
- **Gesture:** Pull down from top of scrollable content
- **Indicator:** Native iOS `UIRefreshControl`
- **Haptic:** Light impact feedback on trigger threshold

#### Context Menus
- **Gesture:** Long press on capsule cards
- **Actions:** View Details, Restart, Stop, View Logs
- **Haptic:** Medium impact feedback on menu reveal

---

## ♿️ Accessibility Requirements

### VoiceOver Support
- ✅ All interactive elements have clear accessibility labels
- ✅ Status indicators announce connection state changes
- ✅ Capsule cards include metadata in accessibility value
- ✅ Chat messages properly ordered for sequential reading

### Dynamic Type
- ✅ All text supports Dynamic Type scaling (xSmall → AX5)
- ✅ Layouts adapt to larger text sizes without truncation
- ✅ Code blocks use `.monospaced` text style

### Color Contrast (WCAG AA)
- ✅ 4.5:1 contrast for body text (17pt)
- ✅ 3:1 contrast for UI components
- ✅ Status indicators use color + icon (not color alone)
- ✅ High Contrast mode automatically uses semantic colors

### Motion Sensitivity
- ✅ Respects Reduce Motion preference
- ✅ Animations disabled when reduce-motion enabled

### Touch Targets
- ✅ Minimum 44x44pt touch targets on all interactive elements
- ✅ Adequate spacing between adjacent tap targets

---

## 📐 Penpot Project Creation Guide

**Full Guide:** `/Users/Ty/BuilderOS/capsules/builder-system-mobile/docs/PENPOT_PROJECT_GUIDE.md`

**Next Steps:**
1. ✅ Design system created (interactive HTML)
2. ✅ Screen mockups created (6 views, Light + Dark mode)
3. ✅ Visual verification complete (Playwright MCP screenshots)
4. ⏳ Create "BuilderOS Mobile" project in Penpot (http://localhost:3449)
5. ⏳ Design 6 artboards based on HTML mockups
6. ⏳ Create Light + Dark mode variants
7. ⏳ Build component library
8. ⏳ Export design specs and hand off to Mobile Dev

**Penpot MCP Integration:**
- Once project is created, use `mcp__penpot__list_projects()` to get project ID
- Use `mcp__penpot__get_file()` to retrieve design data
- Use `mcp__penpot__get_object_tree()` to extract component specs
- Use `mcp__penpot__export_object()` to generate screenshots

---

## 🔗 Reference Files

**Design System (Interactive HTML):**
- File: `/tmp/builderos-mobile-design-system.html`
- Screenshot: `/Users/Ty/BuilderOS/.playwright-mcp/builderos-mobile-design-system.png`
- Preview: ✅ Opened in Brave Browser

**Screen Mockups (Interactive HTML):**
- File: `/tmp/builderos-mobile-screens.html`
- Screenshot: `/Users/Ty/BuilderOS/.playwright-mcp/builderos-mobile-screens-overview.png`
- Preview: ✅ Opened in Brave Browser

**Documentation:**
- Penpot Project Guide: `/Users/Ty/BuilderOS/capsules/builder-system-mobile/docs/PENPOT_PROJECT_GUIDE.md`
- This Summary: `/Users/Ty/BuilderOS/capsules/builder-system-mobile/docs/DESIGN_DELIVERABLES_SUMMARY.md`

**Code Implementation:**
- Swift source: `/Users/Ty/BuilderOS/capsules/builder-system-mobile/BuilderOSMobile/`
- Design system code:
  - `BuilderOSMobile/Theme/Colors.swift`
  - `BuilderOSMobile/Theme/Typography.swift`
  - `BuilderOSMobile/Theme/Spacing.swift`
  - `BuilderOSMobile/Theme/Theme.swift`

**Local Penpot Instance:**
- Frontend: http://localhost:3449
- Backend API: http://localhost:6060
- Status: ✅ Running

---

## 📊 Project Status: Design Phase Complete ✅

**Delivered:**
- ✅ Complete iOS 17+ design system (colors, typography, spacing, components)
- ✅ 6 screen mockups (OnboardingView, DashboardView, ChatView, PreviewView, SettingsView, CapsuleDetailView)
- ✅ Light + Dark mode specifications
- ✅ iOS-specific interaction patterns documented
- ✅ Accessibility requirements (WCAG AA compliance)
- ✅ Visual verification (Brave browser + Playwright MCP screenshots)
- ✅ Penpot project creation guide
- ✅ Component specifications for implementation handoff

**Ready for:**
- ⏳ Manual Penpot project creation (http://localhost:3449)
- ⏳ High-fidelity screen design in Penpot
- ⏳ Component library creation in Penpot
- ⏳ Design handoff to 📱 Mobile Dev for SwiftUI implementation

**Note:** The Penpot MCP server supports reading existing projects/files and exporting designs, but does NOT support programmatic project/file creation. You must create the "BuilderOS Mobile" project manually in the Penpot UI, then use MCP tools to retrieve design data and export specifications for implementation.

---

**Design System Created By:** UI Designer Agent (Jarvis orchestration)
**Date:** October 23, 2025
**Version:** 1.0

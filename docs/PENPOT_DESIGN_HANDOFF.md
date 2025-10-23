# BuilderOS Mobile - Penpot Design Handoff

## Project Information

**Penpot Project:** BuilderOS Mobile
**Project ID:** `4c46a10f-a510-8112-8006-ff54c883093f`
**Local Instance:** http://localhost:3449
**Design System Reference:** [Design System Preview](/tmp/builderos-mobile-design-system.html)
**Screenshot:** `/Users/Ty/BuilderOS/.playwright-mcp/builderos-mobile-design-system.png`

---

## Design System Summary

### Colors (From Colors.swift)

**Brand Colors:**
- Primary Blue: `#007AFF` (iOS system blue)
- Secondary Purple: `#5856D6` (iOS system purple)
- Tailscale Accent: `#598FFF` (rgb(0.35, 0.56, 1.00))

**Status Colors:**
- Success: `#34C759` (iOS system green)
- Warning: `#FF9F0A` (iOS system orange)
- Error: `#FF3B30` (iOS system red)
- Info: `#007AFF` (iOS system blue)

**Semantic Colors (Adaptive Light/Dark):**
- Label (Primary Text): `UIColor.label`
- Secondary Label: `UIColor.secondaryLabel`
- Tertiary Label: `UIColor.tertiaryLabel`
- System Background: `UIColor.systemBackground` (black in dark mode)
- Secondary Background: `UIColor.secondarySystemBackground` (dark gray in dark mode)
- Tertiary Background: `UIColor.tertiarySystemBackground` (lighter gray in dark mode)

**Chat-Specific Colors (From Theme.swift):**
- User Message Background: `#007AFF` (blue)
- System Message Background: `UIColor.systemGray5`
- Code Block Background: `UIColor.systemGray2`

### Typography (From Typography.swift)

**Font Family:** SF Pro (Apple's system font)

**Display Fonts (Rounded):**
- Display Large: 57pt Bold Rounded
- Display Medium: 45pt Bold Rounded
- Display Small: 36pt Bold Rounded

**Headline Fonts (Rounded):**
- Headline Large: 32pt Semibold Rounded
- Headline Medium: 28pt Semibold Rounded
- Headline Small: 24pt Semibold Rounded

**Title Fonts (Default):**
- Title Large: 22pt Semibold
- Title Medium: 16pt Semibold
- Title Small: 14pt Semibold

**Body Fonts (Default):**
- Body Large: 16pt Regular
- Body Medium: 14pt Regular
- Body Small: 12pt Regular

**Label Fonts (Default):**
- Label Large: 14pt Medium
- Label Medium: 12pt Medium
- Label Small: 11pt Medium

**Monospaced Fonts (For code, IPs, API keys):**
- Mono Large: 16pt Regular Monospaced
- Mono Medium: 14pt Regular Monospaced
- Mono Small: 12pt Regular Monospaced

### Spacing (From Spacing.swift)

**8pt Grid System:**
- XS: 4pt (minimal spacing)
- SM: 8pt (small spacing)
- MD: 12pt (compact spacing)
- Base: 16pt (default spacing)
- LG: 24pt (large spacing)
- XL: 32pt (extra large spacing)
- XXL: 48pt (extra extra large spacing)
- XXXL: 64pt (massive spacing)

**Corner Radius:**
- XS: 4pt (minimal rounding)
- SM: 8pt (small rounding)
- MD: 12pt (default rounding, used for cards)
- LG: 16pt (large rounding)
- XL: 20pt (extra large rounding)
- Circle: 9999pt (full circle)

**Icon Sizes:**
- SM: 16pt (small icon)
- MD: 24pt (default icon)
- LG: 32pt (large icon)
- XL: 48pt (extra large icon)
- XXL: 64pt (hero icon)

**Layout Constants:**
- Min Touch Target: 44pt (Apple HIG minimum)
- Comfortable Touch Target: 48pt
- Large Touch Target: 56pt
- Screen Edge Padding: 20pt
- Card Padding: 16pt
- List Item Height: 60pt

### Animation (From Spacing.swift)

**Duration Constants:**
- Fast: 0.15s (button press, quick feedback)
- Normal: 0.25s (standard transitions)
- Slow: 0.35s (navigation, page transitions)
- Very Slow: 0.5s (complex animations, onboarding)

**Spring Animation Presets:**
- Fast: `response: 0.3, dampingFraction: 0.7` (quick response)
- Normal: `response: 0.4, dampingFraction: 0.8` (balanced)
- Bouncy: `response: 0.5, dampingFraction: 0.6` (playful)

---

## Artboard Specifications

**Device:** iPhone 15 Pro
**Artboard Size:** 393×852pt
**Safe Area:** Top 59pt (status bar + nav bar), Bottom 34pt (home indicator)
**Status Bar Height:** 44pt
**Navigation Bar Height (Large Title):** Variable (auto-sized)
**Tab Bar Height:** 83pt (including 20pt safe area padding)

### Artboard List (7 Screens)

1. **Onboarding - Step 1 (Welcome)**
   - Size: 393×852pt
   - Background: System background (black in dark mode)
   - Variants: Light + Dark

2. **Onboarding - Step 2 (Setup)**
   - Size: 393×852pt
   - Background: System background
   - Variants: Light + Dark

3. **Onboarding - Step 3 (Success)**
   - Size: 393×852pt
   - Background: System background
   - Variants: Light + Dark

4. **Dashboard (Main Screen)**
   - Size: 393×852pt
   - Background: System background
   - Navigation: Large title "BuilderOS"
   - Tab Bar: Active (Dashboard tab selected)
   - Variants: Light + Dark

5. **Chat (Terminal Interface)**
   - Size: 393×852pt
   - Background: Adaptive background
   - Tab Bar: Active (Terminal tab selected)
   - Variants: Light + Dark

6. **Localhost Preview**
   - Size: 393×852pt
   - Background: System background
   - Tab Bar: Active (Preview tab selected)
   - Variants: Light + Dark + Empty State

7. **Settings**
   - Size: 393×852pt
   - Background: Grouped background (form style)
   - Tab Bar: Active (Settings tab selected)
   - Variants: Light + Dark

8. **Capsule Detail**
   - Size: 393×852pt
   - Background: System background
   - Navigation: Inline title (capsule name)
   - Variants: Light + Dark

---

## Screen-by-Screen Design Specifications

### 1. OnboardingView (3 Steps)

**Step 1 - Welcome:**
```
Structure:
├─ VStack (spacing: 32pt)
│  ├─ Spacer
│  ├─ App Icon
│  │  └─ SF Symbol: "cube.box.fill"
│  │  └─ Size: 120×120pt
│  │  └─ Gradient: Blue to Blue.opacity(0.7)
│  ├─ VStack (spacing: 16pt)
│  │  ├─ "BuilderOS" (40pt Bold Rounded)
│  │  └─ "Connect to your Mac" (Title3, Secondary)
│  ├─ Spacer
│  ├─ Content VStack
│  │  ├─ SF Symbol: "sparkles" (60pt, Blue)
│  │  ├─ Headline: "Access your BuilderOS system from anywhere"
│  │  └─ Subheadline: Description text (Secondary)
│  ├─ Spacer
│  └─ Action Button "Get Started"
```

**Step 2 - Setup:**
```
Structure:
├─ VStack (spacing: 20pt)
│  ├─ SF Symbol: "link.circle.fill" (60pt, Blue)
│  ├─ Headline: "Enter Connection Details"
│  ├─ Form Fields VStack (spacing: 16pt)
│  │  ├─ Tunnel URL Field
│  │  │  ├─ Label: "Cloudflare Tunnel URL" (Caption, Secondary)
│  │  │  └─ TextField (Monospaced, systemGray6 background, 10pt radius)
│  │  └─ API Key Field
│  │     ├─ Label: "API Key" (Caption, Secondary)
│  │     └─ SecureField (Monospaced, systemGray6 background, 10pt radius)
│  └─ Help Text (Caption, Secondary, Center-aligned)
```

**Step 3 - Success:**
```
Structure:
├─ VStack (spacing: 16pt)
│  ├─ SF Symbol: "checkmark.circle.fill" (60pt, Green) [if connected]
│  ├─ Text: "Connected!" (Headline)
│  └─ Info Card (.ultraThinMaterial, 12pt radius)
│     ├─ "BuilderOS Mobile" (Title3, Semibold)
│     └─ Tunnel URL (Caption, Secondary, Monospaced)
```

**Interaction:**
- Spring animation between steps: `.spring(response: 0.3, dampingFraction: 0.7)`
- Button scale effect on press: `scale(0.95)`
- Progress indicator: Pagination dots (3 dots, current step highlighted)

### 2. DashboardView (Main Screen)

```
Structure:
├─ NavigationStack
│  ├─ ScrollView
│  │  ├─ VStack (spacing: 24pt, padding: 20pt)
│  │  │  ├─ Connection Status Card (.ultraThinMaterial)
│  │  │  │  ├─ HStack
│  │  │  │  │  ├─ SF Symbol: "checkmark.circle.fill" or "xmark.circle.fill"
│  │  │  │  │  │  └─ Color: Green (connected) / Red (disconnected)
│  │  │  │  │  ├─ VStack (alignment: leading)
│  │  │  │  │  │  ├─ "Connected"/"Disconnected" (Headline)
│  │  │  │  │  │  └─ "BuilderOS Mobile" (Subheadline, Secondary)
│  │  │  │  │  └─ ProgressView [if refreshing]
│  │  │  │  ├─ Divider
│  │  │  │  └─ HStack
│  │  │  │     ├─ Tunnel URL (Caption, Monospaced, Secondary)
│  │  │  │     └─ "🔒 Cloudflare Tunnel" (Caption, Secondary)
│  │  │  ├─ System Status Card (.ultraThinMaterial)
│  │  │  │  ├─ HStack
│  │  │  │  │  ├─ "System Status" (Headline)
│  │  │  │  │  └─ Health Badge
│  │  │  │  │     ├─ Circle (8×8pt, status color)
│  │  │  │  │     └─ Text (Subheadline, Secondary)
│  │  │  │  └─ Metrics Grid (2×2 LazyVGrid, spacing: 12pt)
│  │  │  │     ├─ Metric: Version (icon: "tag.fill")
│  │  │  │     ├─ Metric: Uptime (icon: "clock.fill")
│  │  │  │     ├─ Metric: Capsules (icon: "cube.box.fill")
│  │  │  │     └─ Metric: Services (icon: "server.rack")
│  │  │  └─ Capsules Section
│  │  │     ├─ "Capsules" (Headline, padding-left: 4pt)
│  │  │     └─ LazyVGrid (2 columns, spacing: 12pt)
│  │  │        └─ CapsuleCard (NavigationLink)
│  │  │           ├─ SF Symbol: "cube.box.fill" (Blue)
│  │  │           ├─ Capsule Name (Subheadline, Semibold)
│  │  │           └─ Description (Caption, Secondary, 2 lines max)
│  └─ .navigationTitle("BuilderOS")
│  └─ .refreshable (pull-to-refresh)
```

**Metric Card Structure:**
```
VStack (alignment: leading, spacing: 4pt)
├─ HStack (Icon + Label, Caption, Secondary)
└─ Value (Title3, Semibold)
Background: rgba(255, 255, 255, 0.05)
Border-radius: 8pt
Padding: 12pt
```

### 3. ChatView (Terminal/Chat Interface)

```
Structure:
├─ VStack (spacing: 0)
│  ├─ ChatHeaderView
│  │  └─ Connection status indicator
│  ├─ ChatMessagesView
│  │  └─ ScrollView
│  │     └─ VStack (messages)
│  │        ├─ User Message Bubble
│  │        │  ├─ Background: #007AFF
│  │        │  ├─ Text: White
│  │        │  ├─ Border-radius: 16pt
│  │        │  └─ Padding: 12pt
│  │        ├─ System Message Bubble
│  │        │  ├─ Background: systemGray5
│  │        │  ├─ Text: Primary
│  │        │  ├─ Border-radius: 16pt
│  │        │  └─ Padding: 12pt
│  │        └─ Code Block
│  │           ├─ Background: systemGray2
│  │           ├─ Font: Monospaced
│  │           ├─ Border-radius: 8pt
│  │           └─ Padding: 12pt
│  └─ VoiceInputView
│     ├─ TextField (command input)
│     ├─ Voice Button (SF Symbol: "mic.fill")
│     └─ Send Button (SF Symbol: "arrow.up.circle.fill")
Background: Adaptive background (system background)
```

**Quick Actions Sheet:**
```
Sheet presentation:
├─ Quick command buttons (grid)
│  ├─ Command tile
│  │  ├─ Icon (SF Symbol)
│  │  ├─ Title
│  │  └─ Command preview (monospaced)
│  └─ Background: .ultraThinMaterial
└─ Present with .sheet() modifier
```

### 4. LocalhostPreviewView

```
Structure:
├─ VStack (spacing: 0)
│  ├─ Connection Header
│  │  ├─ HStack
│  │  │  ├─ SF Symbol: "network" (Title3, Blue)
│  │  │  ├─ VStack
│  │  │  │  ├─ "Connected"/"Not Connected" (16pt, Semibold)
│  │  │  │  └─ "Cloudflare Tunnel" (12pt, Monospaced, Secondary)
│  │  │  └─ ProgressView [if loading]
│  │  └─ Background: Secondary system background
│  ├─ Quick Links Horizontal Scroll
│  │  └─ HStack (spacing: 12pt, padding: 12pt)
│  │     └─ QuickLinkButton (140×auto pt)
│  │        ├─ VStack (alignment: leading, spacing: 6pt)
│  │        │  ├─ Name (16pt, Semibold)
│  │        │  ├─ Port (12pt)
│  │        │  └─ Description (10pt)
│  │        ├─ Background: Secondary system background (default)
│  │        ├─ Background: Blue (selected)
│  │        ├─ Text: Primary (default)
│  │        ├─ Text: White (selected)
│  │        └─ Border-radius: 12pt
│  ├─ Custom Port Section
│  │  └─ HStack
│  │     ├─ TextField "Custom port (e.g., 3001)"
│  │     └─ "Go" Button (60pt wide, Blue/Gray)
│  └─ WebView OR Empty State
│     └─ Empty State:
│        ├─ SF Symbol: "globe.americas" (64pt, Blue.opacity(0.3))
│        ├─ "Preview Localhost" (22pt, Semibold)
│        └─ Description (15pt, Secondary, Center, Line spacing: 4pt)
```

### 5. SettingsView

```
Structure:
├─ NavigationStack
│  └─ Form
│     ├─ Section: "Cloudflare Tunnel"
│     │  ├─ Connection Status Row
│     │  │  ├─ VStack (alignment: leading)
│     │  │  │  ├─ "Status" (Subheadline, Secondary)
│     │  │  │  └─ HStack
│     │  │  │     ├─ Circle (8×8pt, Green/Red)
│     │  │  │     └─ "Connected"/"Disconnected" (Headline)
│     │  │  └─ ProgressView [if loading]
│     │  ├─ Tunnel URL Row
│     │  │  └─ VStack (alignment: leading)
│     │  │     ├─ "Tunnel URL" (Subheadline, Secondary)
│     │  │     └─ URL text (Caption, Monospaced)
│     │  └─ Sign Out Button [if has API key]
│     │     └─ Destructive role, center-aligned
│     ├─ Section: "BuilderOS API"
│     │  └─ API Key Row
│     │     ├─ VStack
│     │     │  ├─ "API Key" (Subheadline)
│     │     │  └─ "Configured"/"Not configured" (Caption, Green/Orange)
│     │     └─ "Update"/"Add" Button
│     ├─ Section: "Mac Power Control"
│     │  ├─ Sleep Mac Button
│     │  │  ├─ SF Symbol: "moon.fill" (Blue)
│     │  │  ├─ Text: "Sleep Mac"
│     │  │  └─ Chevron or ProgressView
│     │  └─ Wake Mac Button
│     │     ├─ SF Symbol: "sun.max.fill" (Orange)
│     │     ├─ Text: "Wake Mac"
│     │     └─ Chevron or ProgressView
│     └─ Section: "About"
│        ├─ LabeledContent: "Version" → "1.0.0"
│        ├─ LabeledContent: "Build" → "1"
│        └─ Documentation Link
│           └─ Arrow icon (arrow.up.forward.square)
```

**API Key Input Sheet:**
```
NavigationStack
└─ Form
   └─ Section
      ├─ SecureField "API Key"
      │  └─ Monospaced font
      └─ Footer: Help text with code example
         └─ Code block (.ultraThinMaterial background)
```

### 6. CapsuleDetailView

```
Structure:
├─ NavigationStack
│  └─ ScrollView
│     └─ VStack (alignment: leading, spacing: 20pt, padding: 20pt)
│        ├─ Header HStack
│        │  ├─ VStack (alignment: leading)
│        │  │  ├─ Capsule Name (Title Large, Bold)
│        │  │  └─ Path (Body Small, Secondary, 1 line)
│        │  └─ Status Badge
│        │     ├─ Status text (Label Small, Semibold)
│        │     ├─ Padding: 12pt horizontal, 6pt vertical
│        │     ├─ Background: Status color.opacity(0.2)
│        │     ├─ Foreground: Status color
│        │     └─ Border-radius: 8pt
│        ├─ Divider
│        ├─ Description Section
│        │  ├─ "Description" (Title Small, Semibold)
│        │  └─ Description text (Body Medium, Secondary)
│        ├─ Tags Section [if not empty]
│        │  ├─ "Tags" (Title Small, Semibold)
│        │  └─ Horizontal ScrollView
│        │     └─ HStack (spacing: 8pt)
│        │        └─ Tag Pill
│        │           ├─ Text (Label Medium)
│        │           ├─ Padding: 12pt horizontal, 6pt vertical
│        │           ├─ Background: Secondary background
│        │           └─ Border-radius: 8pt
│        └─ Metrics Section
│           ├─ "Metrics" (Title Small, Semibold)
│           └─ VStack (spacing: 8pt)
│              ├─ MetricRow: "Created" → Date
│              ├─ MetricRow: "Updated" → Date
│              └─ MetricRow: "Tags" → Count
│
│  └─ .navigationBarTitleDisplayMode(.inline)
```

**MetricRow Structure:**
```
HStack
├─ Label (Body Medium, Secondary)
├─ Spacer
└─ Value (Body Medium, Primary)
```

### 7. MainContentView (Tab Bar)

```
Structure:
├─ TabView
│  ├─ DashboardView
│  │  └─ .tabItem
│  │     ├─ Label: "Dashboard"
│  │     └─ SF Symbol: "square.grid.2x2.fill"
│  ├─ WebSocketTerminalView (Chat)
│  │  └─ .tabItem
│  │     ├─ Label: "Terminal"
│  │     └─ SF Symbol: "terminal.fill"
│  ├─ LocalhostPreviewView
│  │  └─ .tabItem
│  │     ├─ Label: "Preview"
│  │     └─ SF Symbol: "globe"
│  └─ SettingsView
│     └─ .tabItem
│        ├─ Label: "Settings"
│        └─ SF Symbol: "gearshape.fill"
```

**Tab Bar Specifications:**
- Height: 83pt (includes 20pt safe area padding for home indicator)
- Background: rgba(28, 28, 30, 0.94) with blur(20px)
- Border-top: 0.5px solid rgba(255, 255, 255, 0.1)
- Icon Size: 24pt (MD)
- Label Size: 10pt
- Active Color: #007AFF (iOS system blue)
- Inactive Color: rgba(255, 255, 255, 0.5)
- Spacing: Evenly distributed (space-around)

---

## iOS Material Specifications

### .ultraThinMaterial (Translucent Glass Cards)

**SwiftUI Implementation:**
```swift
.background(.ultraThinMaterial)
.clipShape(RoundedRectangle(cornerRadius: 12))
```

**Visual Appearance:**
- Background: rgba(255, 255, 255, 0.1) in dark mode
- Backdrop-filter: blur(20px)
- Border: 1px solid rgba(255, 255, 255, 0.2)
- Border-radius: 12pt (default for cards)

**Usage:**
- Connection status cards
- System status cards
- Capsule cards
- Info cards in onboarding
- Form field backgrounds

### Button Styles

**Primary Button:**
```swift
.buttonStyle(.primaryButtonStyle)
```
- Background: #007AFF (solid blue)
- Text: White, 17pt, Semibold
- Padding: 12pt vertical, 24pt horizontal
- Border-radius: 10pt
- Active state: scale(0.95) with 100ms spring
- Hover state: Slightly darker blue (iOS handles automatically)

**Secondary Button:**
```swift
.buttonStyle(.secondaryButtonStyle)
```
- Background: rgba(120, 120, 128, 0.2)
- Text: Primary label color, 17pt, Regular
- Padding: 12pt vertical, 24pt horizontal
- Border-radius: 10pt
- Active state: scale(0.95) with 100ms spring

**Destructive Button (Form):**
```swift
Button(role: .destructive) { }
```
- Text: System red (#FF3B30)
- Background: None (transparent)
- Center-aligned in form cells

---

## Accessibility Requirements

### VoiceOver Labels

**All interactive elements must have clear accessibility labels:**

```swift
// Example: Connection status
.accessibilityLabel("Connection status: Connected to BuilderOS Mobile")

// Example: Metric card
.accessibilityLabel("System uptime: 24 hours 15 minutes")

// Example: Capsule card
.accessibilityLabel("builder-system capsule. Core framework. Tap for details.")

// Example: Tab bar item
.accessibilityLabel("Dashboard tab")
```

### Dynamic Type Support

**All text must scale with iOS text size preferences:**
- Use semantic font styles (`.font(.body)`, `.font(.headline)`, etc.)
- Test at all Dynamic Type sizes (xSmall → AX5)
- Ensure layouts don't break at large text sizes
- Use `.minimumScaleFactor()` sparingly (only for tight spaces)

### Color Contrast

**WCAG AA Compliance:**
- Text on background: 4.5:1 minimum
- UI elements (buttons, borders): 3.1 minimum
- Status indicators: 3:1 minimum

**Examples:**
- ✅ White text on #007AFF background: 4.52:1 (passes)
- ✅ Green circle (#34C759) on dark background: 3.1 (passes)
- ✅ Secondary text rgba(255, 255, 255, 0.6) on black: 7.1 (passes)

### Touch Targets

**Minimum sizes (Apple HIG):**
- Buttons: 44×44pt minimum
- Form fields: 48pt height (comfortable)
- Tab bar items: 56pt height (large)
- Interactive cards: Entire card tappable (no tiny hit areas)

### Reduce Motion

**Respect accessibility preference:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// Use fade instead of scale/slide
if reduceMotion {
    .transition(.opacity)
} else {
    .transition(.scale.combined(with: .opacity))
}
```

---

## Light & Dark Mode Variants

### Design Both Modes

**For each artboard, create 2 variants:**
1. Light Mode (iOS default light appearance)
2. Dark Mode (iOS default dark appearance)

### Semantic Color Behavior

**Light Mode:**
- System Background: White (#FFFFFF)
- Secondary Background: Light gray (#F2F2F7)
- Label: Black (#000000)
- Secondary Label: Gray (rgba(60, 60, 67, 0.6))

**Dark Mode:**
- System Background: Black (#000000)
- Secondary Background: Dark gray (#1C1C1E)
- Tertiary Background: Lighter gray (#2C2C2E)
- Label: White (#FFFFFF)
- Secondary Label: Gray (rgba(235, 235, 245, 0.6))

### Brand Colors (Same in Both Modes)

**These colors do NOT change:**
- Primary Blue: #007AFF
- Success Green: #34C759
- Warning Orange: #FF9F0A
- Error Red: #FF3B30

### Testing

**Test designs in both modes:**
- Toggle appearance in Penpot preview
- Verify all text is readable
- Check translucent materials look good over both backgrounds
- Ensure status indicators are visible

---

## SF Symbols Usage

### Icon Library

**Use SF Symbols v7 (latest):**
- Download from: https://developer.apple.com/sf-symbols/
- Consistent sizing: SM (16pt), MD (24pt), LG (32pt), XL (48pt), XXL (64pt)
- Hierarchical rendering mode (default)
- Monochrome for simple icons, multicolor for status

### Key Symbols Used

**Navigation & Status:**
- Dashboard: `square.grid.2x2.fill`
- Terminal: `terminal.fill`
- Preview: `globe`
- Settings: `gearshape.fill`
- Connection: `network`
- Checkmark: `checkmark.circle.fill`
- Error: `xmark.circle.fill`, `exclamationmark.triangle.fill`

**Content:**
- Capsule: `cube.box.fill`
- Tag: `tag.fill`
- Clock: `clock.fill`
- Services: `server.rack`
- Lock: `lock.shield.fill`
- Sparkles: `sparkles`
- Link: `link.circle.fill`
- Globe: `globe.americas`

**Actions:**
- Voice: `mic.fill`
- Send: `arrow.up.circle.fill`
- Power: `moon.fill`, `sun.max.fill`
- External link: `arrow.up.forward.square`

**Configuration:**
- Use `.renderingMode(.hierarchical)` for depth
- Match icon color to text color in same context
- Scale with text (Dynamic Type support)

---

## Export Requirements

### Artboard Exports

**For each artboard, export:**

1. **PNG Screenshot (2x resolution):**
   - Filename: `{screen-name}-{mode}.png`
   - Example: `dashboard-dark.png`, `onboarding-step-1-light.png`
   - Resolution: 786×1704px (2x scale for iPhone 15 Pro)

2. **SVG Assets (if custom icons):**
   - Export any custom graphics as SVG
   - Use SF Symbols for all icons (don't export those)

### Design Tokens JSON

**Export design system as JSON for Mobile Dev:**

```json
{
  "colors": {
    "brand": {
      "primary": "#007AFF",
      "secondary": "#5856D6",
      "tailscale-accent": "#598FFF"
    },
    "status": {
      "success": "#34C759",
      "warning": "#FF9F0A",
      "error": "#FF3B30",
      "info": "#007AFF"
    }
  },
  "typography": {
    "display-large": { "size": 57, "weight": "bold", "design": "rounded" },
    "headline-large": { "size": 32, "weight": "semibold", "design": "rounded" },
    "body-large": { "size": 16, "weight": "regular", "design": "default" }
  },
  "spacing": {
    "xs": 4, "sm": 8, "md": 12, "base": 16,
    "lg": 24, "xl": 32, "xxl": 48, "xxxl": 64
  },
  "corner-radius": {
    "xs": 4, "sm": 8, "md": 12, "lg": 16, "xl": 20
  }
}
```

### Component Specifications

**For each reusable component, document:**
- Component name
- Variants (primary/secondary, default/selected, etc.)
- States (default, hover, active, disabled, loading, error)
- Dimensions (width, height, padding, spacing)
- Typography (font size, weight, color)
- Colors (background, border, text)
- Border radius
- Shadows (if any)
- Animations (timing, easing)

---

## Penpot Workflow Checklist

### Setup Phase
- [ ] Open Penpot local instance (http://localhost:3449)
- [ ] Navigate to "BuilderOS Mobile" project
- [ ] Create new file: "BuilderOS Mobile - iOS Screens"
- [ ] Download SF Pro font from Apple Developer
- [ ] Install SF Symbols app for icon reference

### Design Phase
- [ ] Create 7 artboards (393×852pt each)
- [ ] Set up Light & Dark color variables in Penpot
- [ ] Create text style presets (Display, Headline, Title, Body, Label, Mono)
- [ ] Design each screen following specifications above
- [ ] Apply .ultraThinMaterial effect to cards (blur + opacity)
- [ ] Use SF Symbols for all icons (reference symbol names in text)
- [ ] Create both Light & Dark variants for each screen

### Review Phase
- [ ] Verify all text is readable at iOS Dynamic Type sizes
- [ ] Check color contrast meets WCAG AA (4.5:1 text, 3:1 UI)
- [ ] Ensure touch targets are 44×44pt minimum
- [ ] Test translucent materials over various backgrounds
- [ ] Validate spacing follows 8pt grid system
- [ ] Confirm typography matches SF Pro specs

### Export Phase
- [ ] Export PNG screenshots (2x resolution) for all screens
- [ ] Export design tokens JSON
- [ ] Document component specifications
- [ ] Share Penpot file link with Mobile Dev
- [ ] Provide implementation notes (this document)

---

## Mobile Dev Handoff Notes

### Implementation Already Complete

**Good news:** Mobile Dev has already implemented the design system in Swift:
- `src/Utilities/Colors.swift` - All color definitions
- `src/Utilities/Typography.swift` - All text styles
- `src/Utilities/Spacing.swift` - Spacing constants, corner radius, animations
- `src/BuilderSystemMobile/Common/Theme.swift` - Chat-specific styles

**These designs are for:**
1. Visual reference and alignment with code
2. Client/stakeholder presentations
3. App Store screenshots
4. Marketing materials
5. Design documentation

### Next Steps for Mobile Dev

1. **Review Penpot Designs:**
   - Compare against existing SwiftUI implementation
   - Identify any visual discrepancies
   - Update code if design improvements found

2. **App Store Assets:**
   - Use Penpot screenshots for App Store listing
   - Create 6.7" (iPhone 15 Pro Max) variants if needed
   - Design App Icon in Penpot (1024×1024px)

3. **TestFlight Preparation:**
   - Test designs on real iPhone hardware
   - Verify Dark Mode appearance
   - Check Dynamic Type scaling
   - Validate VoiceOver experience

---

## Resources

**Apple Design Resources:**
- SF Pro Font: https://developer.apple.com/fonts/
- SF Symbols: https://developer.apple.com/sf-symbols/
- iOS 18 UI Kit (Figma): https://developer.apple.com/design/resources/
- Apple Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

**Penpot:**
- Local Instance: http://localhost:3449
- Project ID: 4c46a10f-a510-8112-8006-ff54c883093f
- Documentation: https://penpot.app/docs

**Design System Preview:**
- HTML Document: /tmp/builderos-mobile-design-system.html
- Screenshot: /Users/Ty/BuilderOS/.playwright-mcp/builderos-mobile-design-system.png

---

**Document Version:** 1.0
**Last Updated:** October 2025
**Created By:** UI Designer Agent
**For:** BuilderOS Mobile (iOS 17+)

# BuilderOS Mobile → React Migration Specifications

**Version:** 1.0.0
**Date:** October 24, 2025
**Purpose:** Complete visual and structural specifications for recreating BuilderOS Mobile SwiftUI screens in React

---

## Table of Contents

1. [Design System Foundation](#design-system-foundation)
2. [Screen-by-Screen Breakdown](#screen-by-screen-breakdown)
3. [Component Library](#component-library)
4. [Interaction Patterns](#interaction-patterns)
5. [State Management](#state-management)
6. [Responsive Behavior](#responsive-behavior)

---

## Design System Foundation

### Color System

#### Terminal Color Palette
```typescript
// Primary Terminal Colors
const colors = {
  terminal: {
    cyan: '#60efff',      // Commands, headers, user input
    green: '#00ff88',     // Prompts, success, connection status
    pink: '#ff6b9d',      // Gradients, warnings, accents
    red: '#ff3366',       // Errors, gradient stops
  },

  // Background Colors
  background: {
    dark: '#0a0e1a',           // Main screen background
    darkTransparent: 'rgba(10, 14, 26, 0.9)',  // Header/input (blur effect)
    input: 'rgba(26, 35, 50, 0.6)',            // Input fields
  },

  // Text Colors
  text: {
    primary: '#b8c5d6',    // Default output text
    dim: '#4a6080',        // Comments, timestamps, secondary info
    code: '#7a9bc0',       // Status labels, code blocks
  },

  // Border Colors
  border: {
    header: '#1a2332',     // Header border (2px solid)
    input: '#2a3f5f',      // Input border (1px solid)
  },

  // Status Colors
  status: {
    success: '#00ff88',    // Green - operational
    warning: '#ff9500',    // Orange - degraded
    error: '#ff3366',      // Red - down/error
    info: '#60efff',       // Cyan - info
  },
}
```

#### Gradients
```typescript
const gradients = {
  terminal: 'linear-gradient(135deg, #60efff 0%, #ff6b9d 50%, #ff3366 100%)',
  terminalHeader: 'linear-gradient(90deg, #60efff 0%, #ff6b9d 50%, #ff3366 100%)',
}
```

#### Semantic Colors (Light/Dark Mode)
```typescript
// System adaptive colors
const semanticColors = {
  textPrimary: 'var(--text-primary)',           // Adapts to theme
  textSecondary: 'var(--text-secondary)',
  backgroundPrimary: 'var(--bg-primary)',
  backgroundSecondary: 'var(--bg-secondary)',
  backgroundTertiary: 'var(--bg-tertiary)',
}
```

### Typography System

#### Font Family
**Primary:** SF Pro (Apple system font) → Use **Inter** or **system-ui** for web
**Monospace:** JetBrains Mono → Use **JetBrains Mono** or **Fira Code**

#### Font Scale
```typescript
const typography = {
  // Display Fonts (Rounded, Bold)
  displayLarge: { size: '57px', weight: 700, lineHeight: '64px' },
  displayMedium: { size: '45px', weight: 700, lineHeight: '52px' },
  displaySmall: { size: '36px', weight: 700, lineHeight: '44px' },

  // Headline Fonts (Rounded, Semibold)
  headlineLarge: { size: '32px', weight: 600, lineHeight: '40px' },
  headlineMedium: { size: '28px', weight: 600, lineHeight: '36px' },
  headlineSmall: { size: '24px', weight: 600, lineHeight: '32px' },

  // Title Fonts (Semibold)
  titleLarge: { size: '22px', weight: 600, lineHeight: '28px' },
  titleMedium: { size: '16px', weight: 600, lineHeight: '24px' },
  titleSmall: { size: '14px', weight: 600, lineHeight: '20px' },

  // Body Fonts (Regular)
  bodyLarge: { size: '16px', weight: 400, lineHeight: '24px' },
  bodyMedium: { size: '14px', weight: 400, lineHeight: '20px' },
  bodySmall: { size: '12px', weight: 400, lineHeight: '16px' },

  // Label Fonts (Medium)
  labelLarge: { size: '14px', weight: 500, lineHeight: '20px' },
  labelMedium: { size: '12px', weight: 500, lineHeight: '16px' },
  labelSmall: { size: '11px', weight: 500, lineHeight: '16px' },

  // Monospaced Fonts (for code, IPs, API keys)
  monoLarge: { size: '16px', weight: 400, lineHeight: '24px', family: 'monospace' },
  monoMedium: { size: '14px', weight: 400, lineHeight: '20px', family: 'monospace' },
  monoSmall: { size: '12px', weight: 400, lineHeight: '16px', family: 'monospace' },
}
```

### Spacing System (8pt Grid)

```typescript
const spacing = {
  xs: '4px',      // Minimal spacing
  sm: '8px',      // Small spacing
  md: '12px',     // Compact spacing
  base: '16px',   // Default spacing
  lg: '24px',     // Large spacing
  xl: '32px',     // Extra large spacing
  xxl: '48px',    // Extra extra large spacing
  xxxl: '64px',   // Massive spacing
}
```

### Border Radius

```typescript
const cornerRadius = {
  xs: '4px',      // Minimal rounding
  sm: '8px',      // Small rounding
  md: '12px',     // Default rounding
  lg: '16px',     // Large rounding
  xl: '20px',     // Extra large rounding
  circle: '9999px', // Circle (50% of height)
}
```

### Icon Sizes

```typescript
const iconSize = {
  sm: '16px',     // Small icon
  md: '24px',     // Default icon
  lg: '32px',     // Large icon
  xl: '48px',     // Extra large icon
  xxl: '64px',    // Hero icon
}
```

### Layout Constants

```typescript
const layout = {
  minTouchTarget: '44px',        // Minimum touch target (Apple HIG)
  touchTarget: '48px',           // Comfortable touch target
  largeTouchTarget: '56px',      // Large touch target
  screenPadding: '20px',         // Screen edge padding
  cardPadding: '16px',           // Card padding
  listItemHeight: '60px',        // List item height
}
```

### Animation System

```typescript
const animations = {
  duration: {
    fast: 0.15,        // 150ms - Fast animation
    normal: 0.25,      // 250ms - Default animation
    slow: 0.35,        // 350ms - Slow animation
    verySlow: 0.5,     // 500ms - Very slow animation
  },

  // Spring Animation Presets (for Framer Motion)
  spring: {
    fast: { type: 'spring', stiffness: 300, damping: 25 },      // Quick response
    normal: { type: 'spring', stiffness: 200, damping: 20 },    // Balanced
    bouncy: { type: 'spring', stiffness: 150, damping: 15 },    // Playful
  },
}
```

---

## Screen-by-Screen Breakdown

### 1. OnboardingView

**Purpose:** First-time setup flow for Cloudflare Tunnel connection

#### Layout Structure
```
NavigationStack (full screen)
└── ZStack (layered backgrounds)
    ├── Color.terminalDark (base background)
    ├── RadialGradient (cyan/pink overlay, opacity 0.1-0.15)
    └── VStack (content, spacing: 32px)
        ├── Spacer (flexible)
        ├── Logo Section (120x120 with glow)
        ├── Title Section (gradient text + subtitle)
        ├── Spacer (flexible)
        ├── Step Content (dynamic based on currentStep)
        ├── Spacer (flexible)
        └── Action Buttons (bottom fixed)
```

#### Step 0: Welcome
- **Hero Icon:** SF Symbol "sparkles" (60px) with cyan→pink gradient
- **Title:** "Access your BuilderOS system from anywhere" (18px, semibold, monospaced)
- **Body:** Description text (14px, monospaced, terminalCode color, 300px max width, line-spacing: 4px)

#### Step 1: Setup (Connection Details)
- **Hero Icon:** SF Symbol "link.circle.fill" (60px) with gradient
- **Title:** "Enter Connection Details" (18px, semibold, monospaced)
- **Form Fields:**
  - **Tunnel URL Input:**
    - Label: "Cloudflare Tunnel URL" (13px, medium, monospaced, terminalCode)
    - TerminalTextField component (placeholder: "https://builderos-xyz.trycloudflare.com")
    - Input type: URL, keyboard: URL
  - **API Key Input:**
    - Label: "API Key" (13px, medium, monospaced, terminalCode)
    - TerminalTextField component (placeholder: "Enter API Key", isSecure: true)
    - Input type: Password
- **Help Text:** "Get these from your Mac's BuilderOS server output" (12px, monospaced, terminalDim, center-aligned)

#### Step 2: Connection Test
- **Loading State:**
  - Circular progress indicator (terminalCyan tint, scale 1.5)
  - Text: "Testing connection..." (15px, monospaced, terminalText)
- **Success State:**
  - SF Symbol "checkmark.circle.fill" (60px, terminalGreen, glow: 20px radius)
  - Text: "Connected!" (20px, bold, monospaced, terminalGreen)
  - TerminalCard with connection info (tunnel URL)
- **Error State:**
  - SF Symbol "exclamationmark.triangle.fill" (60px, terminalRed)
  - Text: "Connection failed" (18px, semibold, monospaced, terminalRed)
  - Error message (13px, monospaced, terminalCode, 300px max width, center-aligned)

#### Logo Design
```
ZStack (120x120):
  1. Glow layer (blur: 20px):
     - Gradient (cyan 0.3 → pink 0.2 → red 0.1)
  2. Container (120x120):
     - RoundedRectangle (16px radius)
     - Fill: terminalDark 0.8 opacity
     - Border: 2px gradient stroke (cyan → pink → red)
     - Shadow: cyan 0.3 opacity, 20px radius
  3. Emoji: "🏗️" (64px)
```

#### Navigation & State
- **Progress:** 3 steps (0 → 1 → 2)
- **Navigation:**
  - Step 0 → 1: "Get Started" button
  - Step 1 → 2: "Test Connection" button (disabled if fields empty)
  - Step 2: "Continue to BuilderOS" (success) or "Try Again" (error)
- **Back Button:** Visible on steps 1-2 (14px, monospaced, terminalText 0.7 opacity)

#### Animations
- Step transitions: Spring animation (response: 0.3, damping: 0.7)
- Button press: Scale 0.95 with spring
- Radial gradient: Subtle pulse on logo

---

### 2. MainContentView (Tab Navigation)

**Purpose:** Primary navigation container with 4 tabs

#### Layout Structure
```
TabView (selection: binding)
├── Tab 1: DashboardView (tag: 0)
├── Tab 2: ChatView (tag: 1) [PLACEHOLDER]
├── Tab 3: LocalhostPreviewView (tag: 2)
└── Tab 4: SettingsView (tag: 3)
```

#### Tab Bar Design
```typescript
const tabItems = [
  { label: 'Dashboard', icon: 'square.grid.2x2.fill', tag: 0 },
  { label: 'Terminal', icon: 'terminal.fill', tag: 1 },
  { label: 'Preview', icon: 'globe', tag: 2 },
  { label: 'Settings', icon: 'gearshape.fill', tag: 3 },
]
```

**Tab Bar Styling:**
- Background: `.ultraThinMaterial` (blur effect)
- Selected tint: `terminalCyan`
- Unselected tint: `terminalDim`

**Current Implementation Note:**
- Tabs 0-3 currently show placeholder colored screens (blue, green, orange, purple)
- Real views will replace placeholders in implementation

---

### 3. DashboardView

**Purpose:** System status overview and capsule management

#### Layout Structure
```
NavigationStack
└── ZStack (layered backgrounds)
    ├── Color.terminalDark (base)
    ├── RadialGradient (cyan/pink, top-center, opacity 0.05-0.1)
    └── ScrollView
        └── VStack (spacing: 24px, padding: 16px)
            ├── Connection Status Card
            ├── System Status Card (conditional)
            ├── Capsules Section
            └── Spacer (min: 20px)
```

#### Navigation Bar
- Title: "$ BUILDEROS" (inline, monospaced)
- Background: `.ultraThinMaterial`
- Pull-to-refresh enabled

#### Connection Status Card
```
TerminalCard:
  VStack (spacing: 12px):
    1. HStack:
       - Icon: "bolt.circle.fill" (connected) or "xmark.circle.fill" (disconnected)
         - Size: 20px
         - Color: terminalCyan (connected) or terminalRed (disconnected)
       - VStack (left-aligned, spacing: 4px):
         - Status text (16px, semibold, monospaced, colored)
         - Subtitle: "BuilderOS Mobile" (13px, monospaced, terminalCode)
       - Spacer
       - Loading indicator (conditional, terminalCyan tint)

    2. Divider (terminalInputBorder) [if tunnel URL present]

    3. HStack:
       - Label: Tunnel URL (12px, monospaced, terminalCode, truncate middle)
       - Spacer
       - Label: "Cloudflare Tunnel" (11px, monospaced, terminalDim)
```

#### System Status Card (conditional on data)
```
TerminalCard:
  VStack (spacing: 16px):
    1. HStack:
       - TerminalSectionHeader: "SYSTEM STATUS"
       - Spacer
       - TerminalStatusBadge: Health status (HEALTHY/DEGRADED/DOWN)

    2. LazyVGrid (2 columns, spacing: 12px):
       - Stat Item: Version (icon: "tag.fill")
       - Stat Item: Uptime (icon: "clock.fill")
       - Stat Item: Capsules (icon: "cube.box.fill") [active/total]
       - Stat Item: Services (icon: "server.rack") [running/total]
```

**Stat Item Component:**
```
VStack (left-aligned, spacing: 4px):
  1. HStack (spacing: 4px):
     - Icon (11px, terminalCode)
     - Label (11px, medium, monospaced, terminalCode)
  2. Value (15px, bold, monospaced, terminalCyan)
Background: terminalInputBackground
Border: TerminalBorder (8px radius)
Padding: 12px
```

#### Capsules Section
```
VStack (spacing: 12px):
  1. TerminalSectionHeader: "CAPSULES" (padding horizontal: 4px)

  2. Content (conditional):
     - Loading: Circular progress (terminalCyan, center-aligned)
     - Empty: Empty state (see below)
     - Data: LazyVGrid (2 columns, spacing: 12px)
```

**Empty State:**
```
VStack (spacing: 12px, center-aligned):
  - Icon: "cube.transparent" (48px, terminalCyan 0.3 opacity)
  - Text: "No capsules found" (16px, semibold, monospaced, terminalCode)
Padding: 40px vertical
```

**Capsule Card (Grid Item):**
```
VStack (left-aligned, spacing: 8px):
  1. HStack:
     - Icon: "cube.box.fill" (20px, gradient: cyan → pink)
     - Spacer

  2. Capsule Name (14px, semibold, monospaced, terminalCyan, 2 lines max)

  3. Description (12px, monospaced, terminalCode, 2 lines max)

Background: .ultraThinMaterial
Border: TerminalBorder (12px radius)
Padding: 16px
Tap: Navigate to CapsuleDetailView
```

---

### 4. ChatView (Placeholder)

**Purpose:** Terminal/chat interface for remote commands

**Current State:** Minimal placeholder - Full implementation pending

#### Layout Structure
```
VStack (spacing: 0):
├── ChatHeaderView (connection status)
├── ChatMessagesView (scrollable message list)
└── VoiceInputView (input controls)
```

#### ChatHeaderView
```
VStack (spacing: 0):
  1. HStack (padding: 16px horizontal, 12px vertical):
     - VStack (left-aligned, spacing: 2px):
       - Title: "Builder System" (builderHeadline font)
       - HStack (spacing: 6px):
         - Status dot (8px circle, colored by connection state)
         - Status text (builderCaption font, secondary color)
     - Spacer
     - Info button (SF Symbol "info.circle", builderPrimary)

  2. Divider

Background: adaptiveBackground
Sheet: ConnectionDetailsView (on info button tap)
```

**Connection Status Colors:**
- Connected: `successGreen`
- Connecting: `warningOrange`
- Disconnected: `secondary`
- Error: `errorRed`

#### ChatMessagesView
```
ScrollView (with ScrollViewReader for auto-scroll):
  LazyVStack (spacing: 8px, padding vertical: 8px):
    ForEach(messages):
      ChatMessageView(message)
        .id(message.id)

Scroll behavior: Auto-scroll to bottom on new messages (easeOut 0.3s)
Background: adaptiveBackground
```

#### ChatMessageView

**User Message (right-aligned):**
```
HStack (spacing: 12px):
  - Spacer
  - VStack (right-aligned, spacing: 4px):
    - Message bubble:
      - Text (builderBody font, white)
      - Background: userMessageBackground (blue)
      - Padding: 16px horizontal, 12px vertical
      - Border radius: 20px
      - Max width: 75% of screen width
      - Context menu: Copy action
    - Voice indicator (if hasVoiceAttachment):
      - Icon: "mic.fill" (caption2, white 0.7 opacity)
      - Text: "Voice" (caption2, white 0.7 opacity)
```

**System Message (left-aligned):**
```
HStack (spacing: 12px):
  - VStack (left-aligned, spacing: 8px):
    - HStack:
      - Type icon (message.typeIcon, typeColor)
      - Type name (builderCaption, secondary)
      - Spacer
      - TTSButton component
    - Content:
      - If code block: ScrollView (horizontal) with code styling
      - Else: Formatted text (builderBody, text selection enabled)
  - Spacer

Background: systemGray5 (light) or systemGray6 (dark)
Border radius: 12px
Padding: 12px
Max width: 100%
```

**Code Block Styling:**
```
ScrollView (horizontal):
  Text (builderCode font, code color):
    Padding: 12px
    Background: codeBackgroundColor (systemGray2/systemGray4)
    Border radius: 8px
```

#### VoiceInputView

**Layout:**
```
VStack (spacing: 0):
  1. Text Preview Section (conditional, with slide-in transition):
     - Header: "Voice Preview" (builderHeadline) + Dismiss button
     - TextEditor (100-200px height, systemGray6 background, 8px radius)
     - Action buttons: "Re-record" (secondary) + "Send" (primary)

  2. Voice Input Section:
     HStack (spacing: 16px, padding: 20px horizontal, 16px vertical):
       - Voice button (60px circle):
         - Background: Colored by state (primary/red/orange/gray)
         - Icon: "mic.fill" / "stop.fill" / "waveform" / "mic.slash"
         - Recording pulse: Red stroke circle (70px, pulse scale 1.0-1.1)
       - Quick actions button (44px):
         - Icon: "command" (builderPrimary)
         - Background: systemGray5
         - Border radius: 22px
       - Spacer
       - Status indicators (conditional):
         - Recording: Red dot + "Recording..." (pulse animation)
         - Processing: Spinner + "Processing..."
         - No permission: "Enable Microphone" button

Background: adaptiveBackground
Sheet: QuickActionsView (on command button tap)
```

**Voice Button States:**
- **Idle:** Blue background, "mic.fill" icon
- **Recording:** Red background, "stop.fill" icon, pulse animation
- **Processing:** Orange background, "waveform" icon
- **No permission:** Gray background, "mic.slash" icon, disabled

---

### 5. LocalhostPreviewView

**Purpose:** WebView for viewing localhost dev servers via Cloudflare Tunnel

#### Layout Structure
```
ZStack:
├── Color.terminalDark (base background)
└── VStack (spacing: 0):
    ├── Connection Header (status bar)
    ├── Quick Links Section (horizontal scroll)
    ├── Custom Port Section (input + go button)
    └── WebView or Empty State (flexible)
```

#### Connection Header
```
HStack (spacing: 12px, padding: 16px):
  1. Icon: "network" (18px, gradient: cyan → pink)

  2. VStack (left-aligned, spacing: 4px):
     - Status text (16px, semibold, monospaced, colored)
     - Subtitle: "Cloudflare Tunnel" (12px, monospaced, terminalCode)

  3. Spacer

  4. Loading indicator (conditional, terminalCyan tint, scale 0.8)

Background: terminalInputBackground 0.8 opacity
Bottom border: 1px terminalInputBorder
```

#### Quick Links Section
```
ScrollView (horizontal, no indicators):
  HStack (spacing: 12px, padding: 12px vertical, 16px horizontal):
    ForEach(quickLinks):
      QuickLinkButton(link, isSelected, action)

Background: terminalDark

Quick Links Data:
- React/Next.js (port 3000) - "Development server"
- n8n Workflows (port 5678) - "Workflow automation"
- BuilderOS API (port 8080) - "System API"
- Vite/Vue (port 5173) - "Frontend tooling"
- Flask/Django (port 5000) - "Python web apps"
```

**QuickLinkButton Component:**
```
Button:
  VStack (left-aligned, spacing: 6px):
    1. Link name (14px, semibold, monospaced)
    2. Port number (12px, monospaced) ":3000"
    3. Description (11px, monospaced)

  Frame: 140px width, left-aligned
  Padding: 12px
  Background:
    - Selected: Gradient (cyan → pink)
    - Unselected: terminalInputBackground
  Border: TerminalBorder (cyan if selected, else terminalInputBorder)
  Shadow: Cyan glow (8px radius) if selected
  Text color: White (selected) or terminalText (unselected)
```

#### Custom Port Section
```
HStack (spacing: 12px, padding: 16px):
  1. TerminalTextField:
     - Placeholder: "Custom port (e.g., 3001)"
     - Keyboard: Number pad
     - Binding: customPort state

  2. Go Button (60x44):
     - Text: "Go" (16px, semibold, monospaced, white)
     - Background:
       - Empty: Gray gradient
       - Valid: Cyan → pink gradient
     - Border radius: 8px
     - Shadow: Cyan glow (8px) if valid
     - Disabled: If customPort is empty

Background: terminalDark
```

#### WebView
- Full-size WKWebView (UIViewRepresentable)
- Loading state tracked via navigation delegate
- URL constructed: `{tunnelURL}/port-{portNumber}`

#### Empty State (No URL loaded)
```
VStack (spacing: 20px, center-aligned):
  - Spacer
  - Icon: "globe.americas" (64px, gradient: cyan 0.3 → pink 0.2)
  - Title: TerminalGradientText "Preview Localhost" (22px, bold)
  - Description:
    "Select a quick link or enter
    a custom port to preview
    your dev servers via Cloudflare Tunnel."
    (14px, monospaced, terminalCode, center-aligned, line-spacing: 4px)
  - Spacer

Background: terminalDark
```

---

### 6. SettingsView

**Purpose:** Configuration and system management

#### Layout Structure
```
NavigationStack
└── ZStack:
    ├── Color.terminalDark
    ├── RadialGradient (pink 0.08 opacity, top-center)
    └── ScrollView
        └── VStack (spacing: 24px, padding: 16px):
            ├── Tunnel Section
            ├── API Section
            ├── Power Control Section
            └── About Section
```

#### Navigation Bar
- Title: "$ SETTINGS" (inline, monospaced)
- Background: `.ultraThinMaterial`

#### Cloudflare Tunnel Section
```
VStack (spacing: 16px):
  1. TerminalSectionHeader: "CLOUDFLARE TUNNEL"

  2. TerminalCard:
     VStack (spacing: 16px):
       - Connection Status Row
       - Divider
       - Tunnel URL Row
       - Divider (conditional: if hasAPIKey)
       - Sign Out Button (conditional: if hasAPIKey)

  3. Help text (12px, monospaced, terminalDim, padding horizontal: 4px):
     "Secure HTTPS tunnel to BuilderOS API via Cloudflare. Works with Proton VPN on both devices."
```

**Connection Status Row:**
```
HStack:
  - VStack (left-aligned, spacing: 4px):
    - Label: "Status" (13px, medium, monospaced, terminalCode)
    - TerminalStatusBadge: CONNECTED/DISCONNECTED (pulse if connected)
  - Spacer
  - Loading indicator (conditional, terminalCyan tint)
```

**Tunnel URL Row:**
```
VStack (left-aligned, spacing: 8px):
  - Label: "Tunnel URL" (13px, medium, monospaced, terminalCode)
  - TextField:
    - Placeholder: "https://your-tunnel-url.trycloudflare.com"
    - Font: 12px, monospaced, terminalCyan
    - No autocapitalization, no autocorrect
    - Keyboard type: URL
    - Padding: 12px horizontal, 8px vertical
    - Background: terminalInputBackground
    - Border: TerminalBorder (6px radius)
    - On submit: Health check
```

**Sign Out Button:**
```
Button:
  - Text: "Clear API Key" (14px, semibold, monospaced, terminalRed)
  - Center-aligned
  - Padding: 12px vertical
  - Background: terminalRed 0.1 opacity
  - Border: TerminalBorder (terminalRed color)
  - Alert on tap: Confirmation dialog
```

#### BuilderOS API Section
```
VStack (spacing: 16px):
  1. TerminalSectionHeader: "BUILDEROS API"

  2. TerminalCard:
     HStack:
       - VStack (left-aligned, spacing: 4px):
         - Label: "API Key" (13px, medium, monospaced, terminalCode)
         - Status: "Configured" (green) or "Not configured" (pink)
           (11px, monospaced)
       - Spacer
       - Button: "Update" or "Add" (14px, semibold, monospaced, terminalCyan)
         - Padding: 16px horizontal, 8px vertical
         - Background: terminalInputBackground
         - Border: TerminalBorder (8px radius)

  3. Help text (12px, monospaced, terminalDim, padding horizontal: 4px):
     "API key is stored securely in iOS Keychain and never leaves your device."
```

#### Mac Power Control Section
```
VStack (spacing: 16px):
  1. TerminalSectionHeader: "MAC POWER CONTROL"

  2. TerminalCard:
     VStack (spacing: 12px):
       - Sleep Button:
         HStack:
           - Icon: "moon.fill" (18px, terminalCyan)
           - Text: "Sleep Mac" (14px, semibold, monospaced)
           - Spacer
           - Loading indicator (if in progress) OR chevron right icon
         Padding: 12px vertical
         Opacity: 0.5 if disabled

       - Divider (terminalInputBorder)

       - Wake Button:
         HStack:
           - Icon: "sun.max.fill" (18px, terminalPink)
           - Text: "Wake Mac" (14px, semibold, monospaced)
           - Spacer
           - Loading indicator (if in progress) OR chevron right icon
         Padding: 12px vertical
         Opacity: 0.5 if disabled

  3. Help text (12px, monospaced, terminalDim, padding horizontal: 4px):
     "Sleep puts your Mac to sleep immediately. Wake requires Raspberry Pi intermediary device (see documentation)."
```

**Button Enabled:** `isConnected && hasAPIKey && !isPowerActionInProgress`

#### About Section
```
VStack (spacing: 16px):
  1. TerminalSectionHeader: "ABOUT"

  2. TerminalCard:
     VStack (spacing: 12px):
       - Row: "Version" → "1.0.0" (14px, monospaced, terminalCyan value)
       - Divider
       - Row: "Build" → "1" (14px, monospaced, terminalCyan value)
       - Divider
       - Link: "Documentation" → External link icon
         (14px, monospaced, terminalCyan, arrow.up.forward.square icon)
```

#### API Key Input Sheet (Modal)
```
NavigationStack:
  Form:
    Section "BuilderOS API Key":
      - SecureField: "API Key"
        - No autocorrect, no autocapitalization
        - Font: Monospaced

      Footer:
        VStack (left-aligned, spacing: 8px):
          - Text: "Enter your BuilderOS API key. You can generate one from your Mac:"
          - Code block (caption, monospaced, padding: 8px, .ultraThinMaterial background, 6px radius):
            "cd /Users/Ty/BuilderOS/api
            ./server_mode.sh"

  Toolbar:
    - Cancel button (leading)
    - Save button (trailing, disabled if empty)
```

---

### 7. CapsuleDetailView

**Purpose:** Detailed view of a single capsule

#### Layout Structure
```
ZStack:
├── Color.terminalDark
├── RadialGradient (cyan 0.08 opacity, top-center)
└── ScrollView
    └── VStack (spacing: 20px, padding: 16px):
        ├── Header Card
        ├── Description Section
        ├── Tags Section (conditional)
        ├── Metrics Section
        └── Spacer
```

#### Navigation Bar
- Title: (inline)
- Background: `.ultraThinMaterial`

#### Header Card
```
TerminalCard:
  HStack:
    - VStack (left-aligned, spacing: 4px):
      - Capsule name (TerminalGradientText, 20px, bold)
      - Path (12px, monospaced, terminalCode, truncate)
    - Spacer
    - TerminalStatusBadge: Status (ACTIVE/DEVELOPMENT/TESTING/ARCHIVED)
      - Colors: green/cyan/pink/dim
      - Pulse: If status is active
```

#### Description Section
```
VStack (left-aligned, spacing: 8px):
  - TerminalSectionHeader: "DESCRIPTION"
  - TerminalCard:
    - Text: capsule.description (14px, monospaced, terminalText)
```

#### Tags Section (Conditional: if tags.length > 0)
```
VStack (left-aligned, spacing: 12px):
  - TerminalSectionHeader: "TAGS"
  - ScrollView (horizontal, no indicators):
    HStack (spacing: 8px):
      ForEach(tags):
        Tag badge:
          - Text (12px, medium, monospaced, terminalCyan)
          - Padding: 12px horizontal, 6px vertical
          - Background: terminalInputBackground
          - Border: TerminalBorder (8px radius)
```

#### Metrics Section
```
VStack (left-aligned, spacing: 12px):
  - TerminalSectionHeader: "METRICS"
  - TerminalCard:
    VStack (spacing: 12px):
      - MetricRow: "Created" → formatted date
      - Divider (terminalInputBorder)
      - MetricRow: "Updated" → formatted date
      - Divider
      - MetricRow: "Tags" → tag count
```

**MetricRow Component:**
```
HStack:
  - Label (14px, medium, monospaced, terminalCode)
  - Spacer
  - Value (14px, semibold, monospaced, terminalCyan)
```

---

## Component Library

### Reusable Terminal Components

#### 1. TerminalCard
**Purpose:** Glassmorphic container with border

```tsx
interface TerminalCardProps {
  children: React.ReactNode;
}

<TerminalCard>
  {/* Content */}
</TerminalCard>

// Styles:
padding: 16px
background: backdrop-filter blur (ultraThinMaterial equivalent)
border: 1px solid terminalInputBorder
border-radius: 12px
```

#### 2. TerminalButton
**Purpose:** Primary action button with gradient

```tsx
interface TerminalButtonProps {
  title: string;
  onPress: () => void;
  isDisabled?: boolean;
}

<TerminalButton
  title="Get Started"
  onPress={handleAction}
  isDisabled={false}
/>

// Styles:
font: 16px, semibold, monospaced, white
width: 100%
height: 50px
background: Linear gradient (cyan → pink → red) OR gray (if disabled)
border-radius: 12px
shadow: Cyan glow (12px radius, 0.4 opacity) if enabled
opacity: 0.5 if disabled
```

#### 3. TerminalTextField
**Purpose:** Input field with terminal styling

```tsx
interface TerminalTextFieldProps {
  placeholder: string;
  value: string;
  onChange: (value: string) => void;
  isSecure?: boolean;
  keyboardType?: 'default' | 'url' | 'numberPad';
}

<TerminalTextField
  placeholder="Enter URL"
  value={url}
  onChange={setUrl}
  isSecure={false}
  keyboardType="url"
/>

// Styles:
font: 15px, regular, monospaced, terminalCyan
padding: 16px
background: terminalInputBackground
border: 1px solid terminalInputBorder
border-radius: 10px
autocapitalization: none
autocorrect: disabled
```

#### 4. TerminalGradientText
**Purpose:** Text with terminal gradient

```tsx
interface TerminalGradientTextProps {
  text: string;
  fontSize?: number;  // Default: 22
  fontWeight?: number; // Default: 900 (black)
}

<TerminalGradientText
  text="$ BUILDEROS"
  fontSize={32}
  fontWeight={700}
/>

// Styles:
font: {fontSize}px, {fontWeight}, monospaced
letter-spacing: 1px
background: Linear gradient (cyan → pink → red)
background-clip: text
color: transparent
```

#### 5. TerminalBorder (Modifier)
**Purpose:** Apply terminal-style border to any component

```tsx
<div className="terminal-border">
  {/* Content */}
</div>

// Styles:
border: 1px solid {color || terminalInputBorder}
border-radius: {cornerRadius || 12}px
```

#### 6. TerminalStatusBadge
**Purpose:** Pulsing status indicator

```tsx
interface TerminalStatusBadgeProps {
  text: string;
  color: string;
  shouldPulse?: boolean;  // Default: true
}

<TerminalStatusBadge
  text="CONNECTED"
  color={colors.terminal.green}
  shouldPulse={true}
/>

// Layout:
HStack (spacing: 6px):
  - Circle (8px):
    - Fill: {color}
    - Shadow: {color} 0.6 opacity, 4px radius (if pulse)
    - Animation: Scale 1.0 ↔ 1.2 (2s ease-in-out, repeat)
  - Text (11px, medium, monospaced, {color}, letter-spacing: 0.5px)
```

#### 7. TerminalSectionHeader
**Purpose:** Section title with consistent styling

```tsx
interface TerminalSectionHeaderProps {
  title: string;
}

<TerminalSectionHeader title="SYSTEM STATUS" />

// Styles:
font: 15px, bold, monospaced, terminalCyan
letter-spacing: 0.5px
```

---

## Interaction Patterns

### Gestures & Touch

1. **Pull-to-Refresh:**
   - Available on: DashboardView
   - Trigger: Pull down from top
   - Indicator: Native iOS spinner (terminalCyan tint)
   - Action: Refresh system status + capsule list

2. **Swipe Back:**
   - Available on: All navigation stacks
   - Gesture: Swipe from left edge
   - Action: Navigate back

3. **Tap:**
   - Capsule cards → Navigate to CapsuleDetailView
   - Quick links → Load localhost preview
   - Buttons → Execute action (with 0.95 scale feedback)

4. **Context Menu:**
   - Chat message bubbles → Long press reveals "Copy" option

### Loading States

1. **Spinner (Circular Progress):**
   - Color: `terminalCyan`
   - Size: Default or scaled (0.8x for inline, 1.5x for full-screen)
   - Usage: Connection tests, API calls, data fetching

2. **Skeleton Screens:**
   - Not currently used (loading states show spinners)

3. **Progress Indicators:**
   - Text: "Testing...", "Loading...", "Processing..."
   - Font: Monospaced
   - Color: `terminalText` or status-specific

### Animations

1. **Navigation Transitions:**
   - Type: Spring (response: 0.3, damping: 0.7)
   - Usage: Step changes in onboarding, view transitions

2. **Button Press:**
   - Type: Scale effect (0.95)
   - Duration: 0.1s ease-in-out

3. **Status Pulse:**
   - Type: Scale + opacity (1.0 ↔ 1.2)
   - Duration: 2s ease-in-out, repeat indefinitely
   - Usage: Connected status, active badges

4. **Slide Transitions:**
   - Voice preview: Slide from bottom + fade
   - Chat messages: Fade + slight slide

5. **Auto-Scroll:**
   - Chat messages: Smooth scroll to bottom (0.3s ease-out)
   - Triggers: New message added

---

## State Management

### Global State (via API Client)

```typescript
interface BuilderOSAPIClient {
  // Connection
  isConnected: boolean;
  isLoading: boolean;
  tunnelURL: string;
  hasAPIKey: boolean;
  lastError: string | null;

  // Data
  systemStatus: SystemStatus | null;
  capsules: Capsule[];

  // Methods
  healthCheck(): Promise<boolean>;
  fetchSystemStatus(): Promise<void>;
  fetchCapsules(): Promise<void>;
  sleepMac(): Promise<void>;
  wakeMac(): Promise<void>;
  setAPIKey(key: string): void;
}
```

### Local State (per screen)

**OnboardingView:**
- `currentStep: number` (0-2)
- `tunnelURL: string`
- `apiKey: string`
- `isTestingConnection: boolean`
- `showError: boolean`
- `errorMessage: string`

**DashboardView:**
- `systemStatus: SystemStatus | null`
- `isRefreshing: boolean`
- `isLoading: boolean`
- `capsules: Capsule[]`

**ChatView:**
- `messages: ChatMessage[]`
- `isRecording: boolean`
- `isProcessing: boolean`
- `previewText: string`
- `showingQuickActions: boolean`
- `showingTextPreview: boolean`

**LocalhostPreviewView:**
- `currentURL: URL | null`
- `customPort: string`
- `isLoading: boolean`
- `selectedLinkID: UUID | null`

**SettingsView:**
- `apiKey: string`
- `showAPIKeyInput: boolean`
- `showSignOutAlert: boolean`
- `isSaving: boolean`
- `showPowerAlert: boolean`
- `powerAlertMessage: string`
- `isPowerActionInProgress: boolean`

**CapsuleDetailView:**
- `capsule: Capsule` (prop)

### Data Models

```typescript
interface SystemStatus {
  version: string;
  uptime: number;
  uptimeFormatted: string;
  capsulesCount: number;
  activeCapsulesCount: number;
  healthStatus: 'healthy' | 'degraded' | 'down';
  services: Service[];
}

interface Service {
  name: string;
  isRunning: boolean;
}

interface Capsule {
  id: string;
  name: string;
  path: string;
  description: string;
  status: 'active' | 'development' | 'testing' | 'archived';
  tags: string[];
  createdAt: Date;
  updatedAt: Date;
}

interface ChatMessage {
  id: string;
  content: string;
  isUser: boolean;
  hasVoiceAttachment: boolean;
  isCodeBlock: boolean;
  type: 'command' | 'output' | 'error' | 'info';
  typeIcon: string;
  typeColor: string;
  timestamp: Date;
}
```

---

## Responsive Behavior

### iPhone Portrait (375-428px width)
- **Default layout:** All screens optimized for portrait
- **Grid columns:** 2 columns (capsule grid, stat items)
- **Max widths:**
  - Message bubbles: 75% of screen width
  - Text blocks: 300px for onboarding descriptions
- **Padding:** 16-20px screen edges

### iPhone Landscape
- **Tab bar:** Remains visible at bottom
- **Content:** Full-width, scrollable
- **Cards:** May expand to 3 columns on larger iPhones

### iPad Portrait/Landscape
- **Grid columns:** 3-4 columns for capsules (flexible)
- **Max widths:** Wider for message bubbles (60%), larger text blocks
- **Navigation:** Split-view possible (not implemented yet)

### Safe Areas
- **Top:** NavigationBar respects notch/Dynamic Island
- **Bottom:** TabBar respects home indicator
- **All views:** Use safe area insets for padding

### Accessibility
- **Dynamic Type:** All text scales with system text size settings
- **Color Contrast:** WCAG AA compliant in Light mode, AAA in Dark mode
- **Touch Targets:** Minimum 44x44pt for all interactive elements
- **VoiceOver:** Accessibility labels on all interactive components

---

## Implementation Notes for Frontend Dev

### Technology Stack Recommendations

**React Framework:**
- **Next.js 14+** or **Vite + React 18+**
- TypeScript for type safety

**Styling:**
- **Tailwind CSS** + custom terminal design tokens
- OR **Styled Components** with theme provider
- OR **CSS Modules** with design system variables

**UI Components:**
- **Radix UI** or **Headless UI** for accessible primitives
- Custom terminal components built on top

**Animations:**
- **Framer Motion** for complex animations
- CSS transitions for simple effects

**State Management:**
- **Zustand** or **Context API** for global state
- React hooks for local state

**API Client:**
- **Axios** or native **fetch** with async/await
- WebSocket for real-time updates (future)

### Key Implementation Priorities

1. **Design System Foundation** (Week 1)
   - Color tokens in CSS variables
   - Typography system
   - Spacing and layout constants
   - Animation presets

2. **Core Components** (Week 1-2)
   - TerminalCard, TerminalButton, TerminalTextField
   - TerminalGradientText, TerminalStatusBadge
   - TerminalBorder utility

3. **Onboarding Flow** (Week 2)
   - 3-step wizard with state management
   - Connection testing logic
   - API client initialization

4. **Tab Navigation** (Week 2-3)
   - Tab bar component
   - Route management
   - Persistent state across tabs

5. **Dashboard Screen** (Week 3)
   - Connection status card
   - System status card
   - Capsule grid with navigation

6. **Settings Screen** (Week 3-4)
   - Form validation
   - API key management
   - Power control integration

7. **Preview Screen** (Week 4)
   - WebView equivalent (iframe)
   - Quick links
   - Custom port input

8. **Chat Interface** (Week 5+)
   - Message list with auto-scroll
   - Voice input integration (Web Speech API)
   - Quick actions

9. **Detail View** (Week 5+)
   - Capsule detail screen
   - Metrics display

### Differences: SwiftUI → React

| SwiftUI | React Equivalent | Notes |
|---------|-----------------|-------|
| `VStack` | `<div style={{ display: 'flex', flexDirection: 'column' }}>` | Use Flexbox |
| `HStack` | `<div style={{ display: 'flex', flexDirection: 'row' }}>` | Use Flexbox |
| `ZStack` | `<div style={{ position: 'relative' }}>` with absolute children | Use CSS positioning |
| `Spacer()` | `<div style={{ flex: 1 }} />` | Flexbox auto-fill |
| `.padding()` | `style={{ padding: '16px' }}` | CSS padding |
| `NavigationStack` | React Router or Next.js router | Client-side routing |
| `TabView` | Custom tab component + router | State-based tab switching |
| `.sheet()` | Modal component | Use React Portal |
| `@State` | `useState()` | Local state |
| `@EnvironmentObject` | Context API or Zustand | Global state |
| `.onAppear()` | `useEffect(() => {}, [])` | Component mount |
| `LazyVGrid` | CSS Grid or Flexbox wrap | `display: grid` |
| `.ultraThinMaterial` | `backdrop-filter: blur(20px)` | CSS backdrop filter |
| `LinearGradient` | CSS `linear-gradient()` | Background gradients |
| `RadialGradient` | CSS `radial-gradient()` | Background gradients |
| SF Symbols | React Icons or Heroicons | Icon library |
| `withAnimation()` | Framer Motion `animate` | Animation library |

### Testing Strategy

1. **Unit Tests:**
   - Design system components
   - Utility functions
   - State management logic

2. **Integration Tests:**
   - API client
   - Form validation
   - Navigation flows

3. **E2E Tests (Cypress/Playwright):**
   - Onboarding flow
   - Dashboard → Detail navigation
   - Settings updates

4. **Visual Regression:**
   - Percy or Chromatic
   - Compare to SwiftUI screenshots

### Performance Optimization

1. **Code Splitting:**
   - Lazy load ChatView (heaviest screen)
   - Dynamic imports for modals

2. **Memoization:**
   - `useMemo()` for computed values
   - `React.memo()` for expensive components

3. **Virtual Scrolling:**
   - Use `react-window` for long message lists (ChatView)

4. **Image Optimization:**
   - Use `next/image` for optimized assets
   - Lazy load capsule icons

---

## Appendix: Design Token Export

### CSS Variables (Light Mode)
```css
:root {
  /* Terminal Colors */
  --terminal-cyan: #60efff;
  --terminal-green: #00ff88;
  --terminal-pink: #ff6b9d;
  --terminal-red: #ff3366;

  /* Backgrounds */
  --terminal-dark: #0a0e1a;
  --terminal-dark-transparent: rgba(10, 14, 26, 0.9);
  --terminal-input-bg: rgba(26, 35, 50, 0.6);

  /* Text */
  --terminal-text: #b8c5d6;
  --terminal-dim: #4a6080;
  --terminal-code: #7a9bc0;

  /* Borders */
  --terminal-header-border: #1a2332;
  --terminal-input-border: #2a3f5f;

  /* Semantic */
  --text-primary: #000000;
  --text-secondary: #666666;
  --bg-primary: #ffffff;
  --bg-secondary: #f5f5f5;
  --bg-tertiary: #eeeeee;
}
```

### CSS Variables (Dark Mode)
```css
@media (prefers-color-scheme: dark) {
  :root {
    --text-primary: #ffffff;
    --text-secondary: #999999;
    --bg-primary: #000000;
    --bg-secondary: #1c1c1e;
    --bg-tertiary: #2c2c2e;
  }
}
```

### Tailwind Config Extension
```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        terminal: {
          cyan: '#60efff',
          green: '#00ff88',
          pink: '#ff6b9d',
          red: '#ff3366',
          dark: '#0a0e1a',
          text: '#b8c5d6',
          dim: '#4a6080',
          code: '#7a9bc0',
        },
      },
      fontFamily: {
        mono: ['JetBrains Mono', 'Fira Code', 'monospace'],
      },
      spacing: {
        'xs': '4px',
        'sm': '8px',
        'md': '12px',
        'base': '16px',
        'lg': '24px',
        'xl': '32px',
        'xxl': '48px',
        'xxxl': '64px',
      },
      borderRadius: {
        'xs': '4px',
        'sm': '8px',
        'md': '12px',
        'lg': '16px',
        'xl': '20px',
      },
    },
  },
}
```

---

## Next Steps for Frontend Dev

1. **Review this document** thoroughly and ask questions about any unclear specifications
2. **Set up project** with chosen React framework + TypeScript + styling solution
3. **Implement design system** foundation (colors, typography, spacing, animations)
4. **Build component library** (8 core terminal components)
5. **Create screens** in priority order (Onboarding → Dashboard → Settings → Preview → Chat → Detail)
6. **Test against SwiftUI screenshots** for pixel-perfect accuracy
7. **Optimize performance** and accessibility
8. **Deploy and iterate** with user feedback

---

**Document Complete.** Ready for handoff to Frontend Dev! 🚀

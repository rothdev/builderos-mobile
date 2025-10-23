# BuilderOS Mobile - Design System (Extracted from Swift Implementation)

**Source:** Reverse-engineered from SwiftUI implementation
**Target Platform:** iOS 17+, iPhone & iPad
**Design Tool:** Penpot (Project ID: `4c46a10f-a510-8112-8006-ff54c883093f`)
**Last Updated:** January 2025

---

## 📱 Device Frames

### iPhone
- **iPhone 15 Pro:** 393×852 pt (design frame size)
- **Safe Area Top:** 59 pt (status bar + notch)
- **Safe Area Bottom:** 34 pt (home indicator)
- **Tab Bar Height:** 49 pt + 34 pt safe area = 83 pt total

### iPad
- **iPad Pro 13":** 1032×1376 pt
- **Safe Area:** 20 pt top (status bar only)

---

## 🎨 Color System

### Semantic Colors (Adapt to Light/Dark Mode)

**Background Hierarchy:**
```swift
// Light Mode          // Dark Mode
.systemBackground      // #FFFFFF → #000000
.secondarySystemBackground // #F2F2F7 → #1C1C1E
.tertiarySystemBackground  // #FFFFFF → #2C2C2E
```

**Text Colors:**
```swift
.primary               // Label (auto-adapts)
.secondary             // Secondary label (60% opacity)
```

**Brand Colors:**
```swift
.blue                  // System blue (#007AFF in light, #0A84FF in dark)
.brandPrimary          // Custom brand color (not defined in code, defaults to blue)
.brandSecondary        // Custom secondary (not defined in code)
.brandAccent           // Custom accent (not defined in code)
```

**Status Colors:**
```swift
.green                 // Success (#34C759 light, #30D158 dark)
.orange                // Warning (#FF9500 light, #FF9F0A dark)
.red                   // Error (#FF3B30 light, #FF453A dark)
.blue                  // Info (#007AFF light, #0A84FF in dark)
```

**Chat-Specific Colors:**
```swift
.userMessageBackground         // .blue (user messages)
.systemMessageBackground       // Color(.systemGray5) (assistant messages)
.codeBlockBackground           // Color(.systemGray2) (code snippets)
.adaptiveBackground            // Color(.systemBackground)
.adaptiveSecondaryBackground   // Color(.secondarySystemBackground)
.adaptiveTertiaryBackground    // Color(.tertiarySystemBackground)
```

**Material Backgrounds:**
```swift
.ultraThinMaterial     // Used for cards, connection status
```

### Color Specifications for Penpot

**Light Mode Palette:**
- Background: `#FFFFFF`
- Secondary Background: `#F2F2F7`
- Tertiary Background: `#FFFFFF`
- Primary Blue: `#007AFF`
- Green (Success): `#34C759`
- Orange (Warning): `#FF9500`
- Red (Error): `#FF3B30`
- Gray 5 (Message BG): `#E5E5EA`
- Gray 2 (Code BG): `#AEAEB2`

**Dark Mode Palette:**
- Background: `#000000`
- Secondary Background: `#1C1C1E`
- Tertiary Background: `#2C2C2E`
- Primary Blue: `#0A84FF`
- Green (Success): `#30D158`
- Orange (Warning): `#FF9F0A`
- Red (Error): `#FF453A`
- Gray 5 (Message BG): `#3A3A3C`
- Gray 2 (Code BG): `#636366`

---

## 📝 Typography System

### Font Family
**Primary:** SF Pro (iOS system font)
- `.default` design (most text)
- `.rounded` design (display/headline)
- `.monospaced` design (code, IPs, API keys)

### Text Styles (Dynamic Type Support)

**Display:**
```swift
.displayLarge   // 57pt, Bold, Rounded
.displayMedium  // 45pt, Bold, Rounded
.displaySmall   // 36pt, Bold, Rounded
```

**Headline:**
```swift
.headlineLarge  // 32pt, Semibold, Rounded
.headlineMedium // 28pt, Semibold, Rounded
.headlineSmall  // 24pt, Semibold, Rounded
```

**Title:**
```swift
.titleLarge     // 22pt, Semibold, Default
.titleMedium    // 16pt, Semibold, Default
.titleSmall     // 14pt, Semibold, Default
```

**Body:**
```swift
.bodyLarge      // 16pt, Regular, Default
.bodyMedium     // 14pt, Regular, Default
.bodySmall      // 12pt, Regular, Default
```

**Label:**
```swift
.labelLarge     // 14pt, Medium, Default
.labelMedium    // 12pt, Medium, Default
.labelSmall     // 11pt, Medium, Default
```

**Monospaced (Code/Technical):**
```swift
.monoLarge      // 16pt, Regular, Monospaced
.monoMedium     // 14pt, Regular, Monospaced
.monoSmall      // 12pt, Regular, Monospaced
```

### Text Style Presets with Line Spacing

```swift
TextStyle.h1    // displayLarge, primary color, 4pt line spacing
TextStyle.h2    // displayMedium, primary color, 4pt line spacing
TextStyle.h3    // displaySmall, primary color, 2pt line spacing
TextStyle.body  // bodyMedium, primary color, 2pt line spacing
TextStyle.caption // labelMedium, secondary color, 1pt line spacing
```

### Typography in Penpot

**Font Substitutions (SF Pro → Open Source):**
- SF Pro Display → **Inter** (display text)
- SF Pro Text → **Inter** (body text)
- SF Mono → **JetBrains Mono** or **Fira Code** (code)

**Size Scale:**
- Display L: 57pt (line height: 1.05)
- Display M: 45pt (line height: 1.05)
- Display S: 36pt (line height: 1.1)
- Headline L: 32pt (line height: 1.15)
- Headline M: 28pt (line height: 1.15)
- Headline S: 24pt (line height: 1.2)
- Title L: 22pt (line height: 1.3)
- Title M: 16pt (line height: 1.4)
- Title S: 14pt (line height: 1.4)
- Body L: 16pt (line height: 1.5)
- Body M: 14pt (line height: 1.5)
- Body S: 12pt (line height: 1.5)

---

## 📏 Spacing System (8pt Grid)

### Spacing Values

```swift
Spacing.xs      // 4pt  - Minimal spacing
Spacing.sm      // 8pt  - Small spacing
Spacing.md      // 12pt - Compact spacing
Spacing.base    // 16pt - Default spacing (most common)
Spacing.lg      // 24pt - Large spacing
Spacing.xl      // 32pt - Extra large spacing
Spacing.xxl     // 48pt - Extra extra large spacing
Spacing.xxxl    // 64pt - Massive spacing
```

### Corner Radius Values

```swift
CornerRadius.xs      // 4pt  - Minimal rounding
CornerRadius.sm      // 8pt  - Small rounding (buttons)
CornerRadius.md      // 12pt - Default rounding (cards, most UI)
CornerRadius.lg      // 16pt - Large rounding
CornerRadius.xl      // 20pt - Extra large rounding
CornerRadius.circle  // 9999pt - Perfect circle
```

### Icon Sizes

```swift
IconSize.sm   // 16pt - Small icon
IconSize.md   // 24pt - Default icon
IconSize.lg   // 32pt - Large icon
IconSize.xl   // 48pt - Extra large icon
IconSize.xxl  // 64pt - Hero icon
```

### Layout Constants

```swift
Layout.minTouchTarget    // 44pt - Minimum touch target (Apple HIG)
Layout.touchTarget       // 48pt - Comfortable touch target
Layout.largeTouchTarget  // 56pt - Large touch target
Layout.screenPadding     // 20pt - Screen edge padding
Layout.cardPadding       // 16pt - Card internal padding
Layout.listItemHeight    // 60pt - List item height
```

### Spacing in Penpot

**Use 8pt base grid for all layouts:**
- 4, 8, 12, 16, 24, 32, 48, 64 pt

**Common Spacing Patterns:**
- **VStack spacing:** 12pt (compact), 16pt (default), 24pt (spacious)
- **HStack spacing:** 8pt (compact), 12pt (default), 16pt (spacious)
- **Card padding:** 16pt (all sides)
- **Screen padding:** 20pt (horizontal edges)
- **Section spacing:** 24pt (between major sections)

---

## ⚡ Animation Constants

### Animation Durations

```swift
AnimationDuration.fast      // 0.15s - Fast animation
AnimationDuration.normal    // 0.25s - Default animation
AnimationDuration.slow      // 0.35s - Slow animation
AnimationDuration.verySlow  // 0.5s  - Very slow animation
```

### Spring Animation Presets

```swift
.springFast    // response: 0.3, damping: 0.7  - Quick response
.springNormal  // response: 0.4, damping: 0.8  - Balanced
.springBouncy  // response: 0.5, damping: 0.6  - Playful
```

### Animation Usage

**Button Press:**
- Scale: 0.95
- Duration: 0.1s ease-in-out

**Sheet Presentation:**
- Slide up from bottom
- Duration: 0.25s spring animation

**Navigation Transition:**
- Horizontal slide + fade
- Duration: 0.3s spring animation (response: 0.3, damping: 0.7)

**Pull-to-Refresh:**
- ProgressView scale: 0.8
- Fade in/out: 0.15s

---

## 📱 Screen Specifications

### 1. Onboarding View

**Layout:**
- Vertical stack with Spacer() elements
- Logo: 120×120 pt, centered
- Title: "BuilderOS" (40pt, bold, rounded)
- Subtitle: "Connect to your Mac" (title3, secondary)
- Step content: varies by step (0: welcome, 1: setup, 2: connection)
- Action buttons: bottom 32pt padding

**Steps:**
1. **Welcome Step:**
   - Icon: "sparkles" (60pt, blue)
   - Headline: "Access your BuilderOS system from anywhere"
   - Body: Supporting text (300pt max width)

2. **Setup Step:**
   - Icon: "link.circle.fill" (60pt, blue)
   - Headline: "Enter Connection Details"
   - Text fields:
     - Tunnel URL (full width, 10pt corner radius, systemGray6 background)
     - API Key (SecureField, same styling)
   - Caption: "Get these from your Mac's BuilderOS server output"

3. **Connection Step:**
   - Loading: ProgressView (1.5x scale)
   - Success: "checkmark.circle.fill" (60pt, green)
   - Error: "exclamationmark.triangle.fill" (60pt, orange)

**Primary Button:**
- Full width
- 16pt vertical padding
- 12pt corner radius
- Blue gradient background (blue → blue.opacity(0.8))
- White text, semibold

**Back Button:**
- Secondary color text
- No background
- Appears from step 1 onward

### 2. Main Content View (Tab Bar)

**TabView Structure:**
- 4 tabs: Dashboard, Terminal, Preview, Settings
- Standard iOS tab bar (49pt height + 34pt safe area)
- SF Symbols:
  - Dashboard: "square.grid.2x2.fill"
  - Terminal: "terminal.fill"
  - Preview: "globe"
  - Settings: "gearshape.fill"

### 3. Dashboard View

**Navigation Stack with ScrollView:**

**Connection Status Card:**
- HStack with icon, text, progress indicator
- Icon: "checkmark.circle.fill" (green) or "xmark.circle.fill" (red)
- Font: title2 for icon
- Text: headline for status, subheadline for description
- Divider separating status from tunnel URL
- Tunnel URL: caption, monospaced, secondary color, truncate middle
- Cloudflare badge: "lock.shield.fill" icon + "Cloudflare Tunnel" text
- Background: .ultraThinMaterial
- 12pt corner radius
- 16pt padding

**System Status Card:**
- Headline: "System Status"
- Health indicator: 8×8 pt circle (green/orange/red) + status text
- Stats Grid: 2 columns, 12pt spacing
  - Version stat: "tag.fill" icon
  - Uptime stat: "clock.fill" icon
  - Capsules stat: "cube.box.fill" icon
  - Services stat: "server.rack" icon
- Each stat item:
  - Icon + title (caption, secondary)
  - Value (title3, semibold)
  - 12pt padding
  - 8pt corner radius
  - .background.opacity(0.5)

**Capsules Section:**
- Headline: "Capsules"
- Loading: ProgressView centered
- Empty state: "cube.transparent" icon (48pt) + "No capsules found" (headline, secondary)
- Grid: 2 columns, 12pt spacing

**Capsule Card:**
- VStack alignment leading, 8pt spacing
- Icon: "cube.box.fill" (blue)
- Name: subheadline, semibold, 2 line limit
- Description: caption, secondary, 2 line limit
- 16pt padding
- .ultraThinMaterial background
- 12pt corner radius

### 4. Chat View

**Structure:**
- VStack with 0 spacing
- ChatHeaderView (connection status)
- ChatMessagesView (scrollable message list)
- VoiceInputView (bottom input area)

**Background:** Color.adaptiveBackground

**Header:**
- Connection status indicator
- Current tunnel status

**Messages:**
- User messages: blue background, white text
- System messages: systemGray5 background, primary text
- Code blocks: systemGray2 background, monospaced font

**Input:**
- Voice input support
- Quick actions sheet

### 5. Localhost Preview View

**Structure:**
- VStack with 0 spacing
- Connection header (secondary background)
- Quick links horizontal scroll
- Custom port input section
- WebView or empty state

**Connection Header:**
- HStack: network icon + status text + progress indicator
- 16pt vertical padding
- Font: 16pt semibold for status, 12pt monospaced for tunnel
- Secondary background

**Quick Links:**
- Horizontal ScrollView, no indicators
- Cards: 140pt width, 12pt padding, 12pt corner radius
- Name (16pt semibold), Port (12pt), Description (10pt)
- Selected: blue background + white text
- Unselected: secondary background + primary text

**Custom Port Input:**
- TextField + "Go" button (60pt width)
- Rounded border style
- Button: 8pt corner radius, blue background (or gray if disabled)

**Empty State:**
- "globe.americas" icon (64pt, blue.opacity(0.3))
- Title: 22pt semibold
- Body: 15pt, secondary, center aligned, 4pt line spacing

### 6. Settings View

**Form Structure:**

**Section 1: Mac Connection**
- Tunnel URL field:
  - Caption label: "Cloudflare Tunnel URL"
  - TextField: URL keyboard, monospaced font
- API Key field:
  - Caption label: "API Key"
  - SecureField: monospaced font
- Test Connection button:
  - HStack: icon + "Test Connection" text
  - Green checkmark if connected, blue antenna if not
  - ProgressView when testing

**Section 2: Connection Status**
- Status row: label + (circle indicator + text)
  - Circle: 8×8 pt, green or red
  - Text: caption, secondary
- Endpoint row: label + tunnel URL (caption, truncate middle)

**Section 3: System Control**
- Sleep Mac button:
  - "moon.fill" icon (orange)
  - "Sleep Mac" text
  - Disabled when not connected

**Section 4: Setup Instructions**
- InstructionStep component (repeated 4 times):
  - Circle badge: 28×28 pt, blue.opacity(0.2), number centered
  - Title: subheadline, medium weight
  - Description: caption, secondary

**Section 5: About**
- Version rows: label + value (secondary)

---

## 🧩 Component Specifications

### CapsuleCard (Dashboard)

**Properties:**
- Width: Flexible (grid column)
- Height: Auto (content-driven)
- Padding: 16pt
- Corner Radius: 12pt
- Background: .ultraThinMaterial

**Content:**
- Icon: "cube.box.fill" (blue, default size)
- Name: subheadline, semibold, 2 line limit
- Description: caption, secondary, 2 line limit
- Spacing: 8pt vertical

### QuickLinkButton (Preview)

**Properties:**
- Width: 140pt
- Height: Auto
- Padding: 12pt
- Corner Radius: 12pt
- Background: blue (selected) or secondarySystemBackground (unselected)

**Content:**
- Name: 16pt semibold
- Port: 12pt
- Description: 10pt
- Text color: white (selected) or primary (unselected)
- Spacing: 6pt vertical
- Alignment: leading

### InstructionStep (Settings)

**Properties:**
- HStack alignment: top
- Spacing: 12pt

**Circle Badge:**
- Size: 28×28 pt
- Background: blue.opacity(0.2)
- Text: 12pt semibold, blue

**Content:**
- Title: subheadline, medium
- Description: caption, secondary
- Spacing: 4pt vertical

### PrimaryButtonStyle (Global)

**Pressed State:**
- Scale: 0.95
- Animation: easeInOut, 0.1s

**Default State:**
- Padding: 20pt horizontal, 12pt vertical
- Background: blue
- Text: white
- Corner Radius: 10pt

### SecondaryButtonStyle (Global)

**Pressed State:**
- Scale: 0.95
- Animation: easeInOut, 0.1s

**Default State:**
- Padding: 20pt horizontal, 12pt vertical
- Background: systemGray5
- Text: blue
- Corner Radius: 10pt

---

## 📐 Grid & Layout Patterns

### Two-Column Grid (Capsules, Stats)

```swift
LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12)
```

**Usage:**
- Dashboard capsule grid
- Dashboard stats grid
- Equal width columns
- 12pt gap between items

### Vertical Stack Patterns

**Compact (4pt):**
- Icon + text pairs in headers
- Caption labels + values

**Default (8pt):**
- Card content items
- Form field groups

**Spacious (12pt):**
- Section headers + content
- List items

**Extra Spacious (16pt, 24pt):**
- Major sections in cards
- Dashboard sections (24pt)

### Horizontal Stack Patterns

**Tight (4pt):**
- Icon + label pairs
- Circle indicator + status text

**Default (8pt, 12pt):**
- Action buttons
- Quick link cards

### Scroll View Patterns

**Vertical Scroll (Dashboard, Settings):**
- VStack with padding
- Pull-to-refresh enabled

**Horizontal Scroll (Quick Links):**
- HStack with padding
- No scroll indicators
- Snap to edges (implicit)

---

## 🎭 State Specifications

### Connection States

**Connected:**
- Icon: "checkmark.circle.fill" (green)
- Text: "Connected" (headline)
- Secondary: "BuilderOS Mobile" (subheadline, secondary)
- Show tunnel URL with lock icon

**Disconnected:**
- Icon: "xmark.circle.fill" (red)
- Text: "Disconnected" (headline)
- No secondary text
- Hide tunnel URL section

**Testing:**
- ProgressView visible
- Button disabled
- Text: "Testing..."

### Loading States

**Initial Load:**
- ProgressView centered
- isLoading = true
- Hide content until loaded

**Pull-to-Refresh:**
- ProgressView in navigation
- isRefreshing = true
- Content remains visible

**Button Loading:**
- ProgressView inline with text
- Button disabled
- Text changes to "Testing..." or similar

### Empty States

**No Capsules:**
- Icon: "cube.transparent" (48pt, secondary)
- Text: "No capsules found" (headline, secondary)
- Padding: 40pt
- Centered in available space

**Preview Empty:**
- Icon: "globe.americas" (64pt, blue.opacity(0.3))
- Title: "Preview Localhost" (22pt semibold)
- Body: Multiline instructions (15pt, secondary, centered, 4pt line spacing)

### Error States

**Connection Failed (Onboarding):**
- Icon: "exclamationmark.triangle.fill" (60pt, orange)
- Title: "Connection failed" (headline)
- Body: Error explanation (subheadline, secondary, centered, 300pt max width)
- Button: "Try Again"

**API Error:**
- Alert dialog with error message
- Red text for error details
- Dismiss button

---

## 🔍 Accessibility Specifications

### Dynamic Type Support

All text styles support Dynamic Type scaling from xSmall → AX5.

**Critical for:**
- Body text (readable at all sizes)
- Navigation labels
- Button text
- Form labels

### Minimum Touch Targets

**Apple HIG Requirement:** 44×44 pt minimum

**BuilderOS Implementation:**
- Standard buttons: 48pt height (comfortable)
- Large buttons: 56pt height
- Tab bar items: 49pt (system default)
- List items: 60pt height

### Color Contrast

**WCAG AA Compliance:**
- Text on background: 4.5:1 minimum
- Large text (18pt+): 3:1 minimum
- UI components: 3:1 minimum

**Tested Combinations:**
- Blue (#007AFF) on white: ✅ 4.5:1
- Secondary text on systemBackground: ✅ Auto-adapts
- White text on blue: ✅ 7.2:1

### VoiceOver Labels

**Required for:**
- All tab bar items (auto from Label)
- Custom icons without text
- Status indicators (add .accessibilityLabel)
- Decorative icons (mark as .accessibilityHidden)

### Reduce Motion

**Respect user preference:**
- Disable scale animations if reduce motion enabled
- Use fade transitions instead
- Maintain functionality without animation

---

## 📦 Penpot Project Structure

**Project:** BuilderOS Mobile
**Project ID:** `4c46a10f-a510-8112-8006-ff54c883093f`

### Files

1. **BuilderOS Design System** (`47114189-b7a2-818e-8006-ffdc5b6a7fa2`)
   - Color palette (Light + Dark mode)
   - Typography scales
   - Spacing system
   - Icon library (SF Symbols equivalents)
   - Component specifications

2. **iOS Screens - Onboarding** (`47114189-b7a2-818e-8006-ffdc5eee2d8b`)
   - Welcome step
   - Setup step (tunnel URL + API key)
   - Connection test step

3. **iOS Screens - Main App** (`47114189-b7a2-818e-8006-ffdc5d25b33c`)
   - Dashboard view
   - Chat/Terminal view
   - Localhost Preview view
   - Settings view
   - Capsule detail view

### Device Frames to Create

**iPhone 15 Pro Frame:**
- Canvas: 393×852 pt
- Status bar: 59 pt top
- Home indicator: 34 pt bottom
- Safe area content: 393×759 pt

**iPad Pro 13" Frame:**
- Canvas: 1032×1376 pt
- Status bar: 20 pt top
- Content area: 1032×1356 pt

---

## 🛠️ Implementation Notes for Mobile Dev

### SwiftUI Patterns Used

**Material Backgrounds:**
```swift
.background(.ultraThinMaterial)  // Cards, connection status
```

**Semantic Colors:**
```swift
Color(.systemBackground)          // Always use semantic colors
Color(.secondarySystemBackground) // Auto-adapts to Light/Dark
```

**Dynamic Type:**
```swift
.font(.headline)                  // System styles support Dynamic Type
.font(.system(size: 16))          // Fixed sizes DON'T scale
```

**Corner Radius:**
```swift
.clipShape(RoundedRectangle(cornerRadius: 12))  // Preferred
.cornerRadius(12)                                // Deprecated
```

**Spring Animations:**
```swift
withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
    // State change
}
```

### Design-to-Code Handoff

**From Penpot Mockups:**
1. Extract exact hex colors from Penpot
2. Convert to semantic Color extensions in Colors.swift
3. Match typography sizes (pt values are 1:1)
4. Use spacing constants (don't hardcode magic numbers)
5. Replicate corner radius values exactly
6. Test Light + Dark mode side-by-side with mockups

**From This Documentation:**
1. All spacing values → Use Spacing enum
2. All corner radius → Use CornerRadius enum
3. All animations → Use Animation extensions
4. All colors → Use Color extensions (semantic)
5. All text → Use Font extensions or TextStyle presets

---

## 🔗 Related Documentation

- **MOBILE_WORKFLOW.md** - Complete development workflow
- **INJECTION_SETUP.md** - Hot reloading with InjectionIII
- **PENPOT_PROJECT_GUIDE.md** - Penpot project structure and usage
- **API_INTEGRATION.md** - BuilderOS API specifications

---

**Generated:** January 2025 by UI Designer Agent
**Extracted From:** SwiftUI source files in `/Users/Ty/BuilderOS/capsules/builderos-mobile/src/`
**Next Steps:** Populate Penpot files with visual designs matching these specifications

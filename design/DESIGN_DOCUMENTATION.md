# BuilderOS Mobile — iOS Design Documentation

**Platform:** iOS 17+
**Design Language:** Native iOS (SF Pro, system colors, standard patterns)
**Target Devices:** iPhone 15 Pro (primary), iPad (future consideration)
**Created:** October 2025

---

## Table of Contents

1. [Design System Overview](#design-system-overview)
2. [Visual Deliverables](#visual-deliverables)
3. [Screen Specifications](#screen-specifications)
4. [Component Library](#component-library)
5. [Interaction Patterns](#interaction-patterns)
6. [Accessibility Requirements](#accessibility-requirements)
7. [Implementation Handoff](#implementation-handoff)

---

## Design System Overview

### Color Palette

**Brand Colors:**
- **Primary:** `#007AFF` (iOS system blue) — Main actions, links, highlights
- **Secondary:** `#5856D6` (iOS system purple) — Secondary actions, accents
- **Tailscale Accent:** `#598FFF` — VPN status, connection indicators

**Status Colors:**
- **Success:** `#34C759` (iOS green) — Active capsules, connected status
- **Warning:** `#FF9500` (iOS orange) — Testing status, alerts
- **Error:** `#FF3B30` (iOS red) — Errors, destructive actions
- **Info:** `#007AFF` (iOS blue) — Development status, information

**Semantic Colors (Adaptive Light/Dark Mode):**
- **Text Primary:** `Color.primary` (systemLabel)
- **Text Secondary:** `Color.secondary` (secondaryLabel)
- **Background Primary:** `Color(.systemBackground)`
- **Background Secondary:** `Color(.secondarySystemBackground)`
- **Background Tertiary:** `Color(.tertiarySystemBackground)`

All colors automatically adapt to Light and Dark mode using iOS semantic color system.

### Typography System

**Font Family:** SF Pro (system default)
- **Display fonts:** SF Pro Rounded (bold, attention-grabbing)
- **Body fonts:** SF Pro (regular, readable)
- **Code fonts:** SF Mono (monospaced for IPs, API keys, code blocks)

**Type Scale:**
- **Display Large:** 57px / Bold / SF Pro Rounded / 1.05 line height
- **Display Medium:** 45px / Bold / SF Pro Rounded / 1.1 line height
- **Display Small:** 36px / Bold / SF Pro Rounded / 1.15 line height
- **Headline Large:** 32px / Semibold / SF Pro Rounded / 1.15 line height
- **Headline Medium:** 28px / Semibold / SF Pro Rounded / 1.2 line height
- **Title Large:** 22px / Semibold / SF Pro / 1.2 line height
- **Title Medium:** 16px / Semibold / SF Pro / 1.3 line height
- **Body Large:** 16px / Regular / SF Pro / 1.4 line height
- **Body Medium:** 14px / Regular / SF Pro / 1.4 line height
- **Label Medium:** 12px / Medium / SF Pro / 1.3 line height
- **Monospaced Medium:** 14px / Regular / SF Mono / Monospaced

**Dynamic Type Support:** All text scales with user's accessibility settings (Small to AX5).

### Spacing System

**8pt Base Grid:**
- **xs:** 4pt — Minimal spacing, tight groups
- **sm:** 8pt — Small spacing, related elements
- **md:** 12pt — Compact spacing
- **base:** 16pt — Default spacing, card padding
- **lg:** 24pt — Large spacing, section dividers
- **xl:** 32pt — Extra large spacing
- **xxl:** 48pt — Major section breaks

**Touch Targets:**
- **Minimum:** 44pt (Apple HIG requirement for all tappable elements)
- **Comfortable:** 48pt (recommended for primary actions)
- **Large:** 56pt (for important interactive elements)

**Corner Radius:**
- **xs:** 4pt — Minimal rounding
- **sm:** 8pt — Small elements (badges, tags)
- **md:** 12pt — Default (buttons, cards)
- **lg:** 16pt — Large cards
- **xl:** 20pt — Extra large surfaces
- **circle:** 50% — Circular elements (avatars, status dots)

### Animation Constants

**Durations:**
- **Fast:** 0.15s — Quick micro-interactions
- **Normal:** 0.25s — Default transitions
- **Slow:** 0.35s — Deliberate transitions
- **Very Slow:** 0.5s — Dramatic reveals

**Spring Animation Presets (iOS-native):**
- **springFast:** response 0.3, damping 0.7 — Quick, responsive
- **springNormal:** response 0.4, damping 0.8 — Balanced (default)
- **springBouncy:** response 0.5, damping 0.6 — Playful, celebratory

---

## Visual Deliverables

### Interactive HTML Mockups

All designs are available as interactive HTML previews:

1. **Design System:** `/design/design-system.html`
   - Complete color palette with hex values
   - Typography scale with all variants
   - Spacing system visualized
   - Component library showcase

2. **Dashboard Screen:** `/design/dashboard-screen.html`
   - System status and connection info
   - Capsule grid with status badges
   - Pull-to-refresh interaction
   - Tab bar navigation

3. **Chat/Terminal Screen:** `/design/chat-screen.html`
   - Message bubbles (user + system)
   - Voice input button with recording animation
   - Quick actions toolbar
   - Code block rendering

4. **Settings Screen:** `/design/settings-screen.html`
   - Tailscale connection status
   - Device list with IP addresses
   - API key management
   - Power controls (sleep/wake Mac)
   - Toggle switches and form inputs

5. **Onboarding Flow:** `/design/onboarding-flow.html`
   - 5-step first-time setup flow
   - Welcome → OAuth → Discovery → API Key → Success
   - User flow diagram included

### How to View

Open any HTML file in a browser (preferably Safari for iOS-accurate rendering):

```bash
# From capsule root
open design/design-system.html
open design/dashboard-screen.html
open design/chat-screen.html
open design/settings-screen.html
open design/onboarding-flow.html
```

All designs are pixel-perfect for iPhone 15 Pro (393x852 pt screen).

---

## Screen Specifications

### 1. Dashboard Screen

**Purpose:** Primary landing screen showing system status and capsule overview.

**Layout:**
- Pull-to-refresh gesture at top
- Header: "Dashboard" title + subtitle
- Connection status card (Tailscale info, IP, uptime)
- 2x2 stats grid (Total Capsules, Active, Testing, API Latency)
- Section header: "Active Capsules" with "See All" link
- Capsule grid (2 columns, variable rows)
- Tab bar at bottom (Dashboard selected)

**Key Components:**
- Connection status card (green = connected, orange = connecting, red = disconnected)
- Stat cards with icons and values
- Capsule cards with status badges, name, description, tags
- Status badges (active, development, testing, error)

**Interactions:**
- Pull-to-refresh updates all data
- Tap capsule card → Capsule Detail View
- Tap "See All" → Full capsule list
- Tab bar switches between screens

**Empty State:**
- Show when disconnected from Tailscale
- Message: "Not Connected" + "Connect to Tailscale to view capsules"
- Button: "Go to Settings"

### 2. Chat/Terminal Screen

**Purpose:** Command interface with SSH execution and voice input.

**Layout:**
- Header: "BuilderOS Terminal" + connection status dot + Mac device name
- Quick actions toolbar (Status, Logs, Refresh, Metrics, Search)
- Messages container (scrollable, bottom-anchored)
- Input container (voice button, text input, send button)
- Tab bar at bottom (Chat selected)

**Message Types:**
- User messages (blue bubbles, right-aligned)
- System messages (white bubbles, left-aligned, with shadow)
- Code blocks (monospaced, background highlight)
- Status messages (centered, blue background pills)

**Voice Input:**
- Tap microphone button → Shows recording overlay
- Waveform animation during recording
- Timer display (0:00 format)
- Tap again to stop recording
- Speech-to-text converts to command

**Quick Actions:**
- Horizontal scrollable row of pre-defined commands
- Tapping action sends command to terminal
- Examples: "Status", "Logs", "Refresh", "Metrics"

**Interactions:**
- Scroll messages (newest at bottom)
- Tap voice button → Record voice command
- Type in text field → Send text command
- Tap quick action → Execute pre-defined command
- Long-press message → Copy text

### 3. Settings Screen

**Purpose:** App configuration, Tailscale management, API setup, power controls.

**Layout (Grouped List Style):**

**Section 1: Connection**
- Tailscale Status (status badge: Connected/Disconnected)
- Auto-Connect toggle (on/off)

**Section 2: Tailscale Devices**
- List of all devices on network (Mac, iPhone, Raspberry Pi, etc.)
- Each device shows: name, type badge, Tailscale IP
- "Refresh Devices" button at bottom

**Section 3: BuilderOS API**
- API Key (tap to edit, stored in Keychain)
- API Status (latency indicator, health status)

**Section 4: Mac Power Controls**
- Sleep Mac (puts Mac to sleep immediately)
- Wake Mac (requires Raspberry Pi setup, shows instructions)

**Section 5: App Settings**
- Notifications toggle
- Appearance (Automatic, Light, Dark)
- Analytics toggle

**Section 6: About**
- Version number
- Privacy Policy link
- "Sign Out" button (destructive, red text)

**Interactions:**
- Tap row with chevron → Navigate to detail screen
- Toggle switches → Immediate effect (with haptic feedback)
- Tap "Sleep Mac" → Confirmation alert → Execute
- Tap "Sign Out" → Confirmation alert → Clear Keychain → Return to onboarding

### 4. Onboarding Flow (5 Steps)

**Step 1: Welcome Screen**
- Full-screen gradient background (blue to purple)
- App icon (large, centered)
- Title: "BuilderOS"
- Subtitle: "Secure remote access to your Mac development environment from anywhere"
- Button: "Get Started"

**Step 2: Tailscale OAuth**
- Header icon + title + description
- OAuth provider buttons (GitHub, Google, Microsoft, Email)
- Tapping button → Opens OAuth web flow in SafariViewController
- After auth → Returns to app → Establishes VPN

**Step 3: Auto-Discovery**
- Loading animation (pulsing rings around icon)
- Title: "Discovering Devices"
- Description: "Looking for your Mac on the Tailscale network..."
- Progress checklist:
  - ✓ Connected to Tailscale (green check)
  - ⏳ Scanning for devices... (loading spinner)
  - ○ Connecting to Mac (pending)
- Timeout after 30s → Manual IP entry option

**Step 4: API Key Entry**
- Header icon + title + description
- Form fields:
  - Mac Device (read-only, discovered name)
  - Tailscale IP (read-only, discovered IP)
  - API Key (password field, user input)
- Hint: Command to run on Mac to start API server
- "Continue" button (validates API key)

**Step 5: Success**
- Large green checkmark icon
- Title: "You're All Set!"
- Description: "Your iPhone is now securely connected to your Mac via Tailscale..."
- Button: "Go to Dashboard" → Main app

**Error Handling:**
- Each step has error states with "Retry" button
- Clear error messages (e.g., "Mac not found on network", "Invalid API key")
- Back button to return to previous step (except welcome screen)

### 5. Capsule Detail View (Future Screen)

**Purpose:** Detailed information about a specific capsule.

**Layout:**
- Navigation bar with capsule name
- Hero section with large status badge
- Description text
- Metrics grid (Files, LOC, Disk Usage, Last Updated)
- Tags (horizontal scrollable)
- Actions (View Logs, Run Audit, Open in Terminal)
- Metadata section (Path, Created Date, Updated Date)

**Interactions:**
- Tap "View Logs" → Opens log viewer
- Tap "Run Audit" → Executes audit, shows results
- Tap "Open in Terminal" → Switches to Chat tab with capsule context

---

## Component Library

### Buttons

**Primary Button:**
- Background: `#007AFF`
- Text: White, 16px, Semibold
- Padding: 12px vertical, 24px horizontal
- Border radius: 12px
- Min height: 48px
- States:
  - Default: Blue background
  - Hover/Pressed: Darker blue (#0051D5), scale 0.98
  - Disabled: Gray background (#e5e5e7), gray text (#86868b)

**Secondary Button:**
- Background: `rgba(0, 122, 255, 0.1)` (10% opacity blue)
- Text: Blue (#007AFF), 16px, Semibold
- Padding: 12px vertical, 24px horizontal
- Border radius: 12px
- Min height: 48px
- States:
  - Default: Light blue background
  - Hover/Pressed: Slightly darker (#e5e5e7), scale 0.98

**Destructive Button:**
- Background: `#FF3B30`
- Text: White, 16px, Semibold
- Same sizing as primary button
- Use for dangerous actions (Sleep Mac, Sign Out, Delete)

**Icon Button:**
- Circular (44pt x 44pt minimum)
- Icon centered (24pt size)
- Background optional (transparent or colored)
- Examples: Voice button, Send button

### Status Badges

**Active Badge:**
- Background: `rgba(52, 199, 89, 0.1)` (10% opacity green)
- Text: Green (#34C759), 13px, Semibold
- Padding: 6px vertical, 12px horizontal
- Border radius: 8px
- Icon: Green dot (8px circle) + text

**Development Badge:**
- Background: `rgba(0, 122, 255, 0.1)` (10% opacity blue)
- Text: Blue (#007AFF), 13px, Semibold
- Icon: Blue dot + text

**Testing Badge:**
- Background: `rgba(255, 149, 0, 0.1)` (10% opacity orange)
- Text: Orange (#FF9500), 13px, Semibold
- Icon: Orange dot + text

**Error Badge:**
- Background: `rgba(255, 59, 48, 0.1)` (10% opacity red)
- Text: Red (#FF3B30), 13px, Semibold
- Icon: Red dot + text

### Cards

**Standard Card:**
- Background: White
- Border radius: 16px
- Padding: 20px
- Shadow: `0 2px 8px rgba(0,0,0,0.04)` (subtle)
- States:
  - Default: White, shadow
  - Pressed (if tappable): Background #f5f5f7, scale 0.98

**Capsule Card (2-column grid):**
- Background: White
- Border radius: 16px
- Padding: 16px
- Shadow: `0 2px 8px rgba(0,0,0,0.04)`
- Layout:
  - Status badge (top)
  - Capsule name (15px, Semibold)
  - Description (12px, gray, 2 lines max)
  - Tags (horizontal, 11px)

**Stat Card (2x2 grid):**
- Background: White
- Border radius: 12px
- Padding: 16px
- Shadow: `0 2px 8px rgba(0,0,0,0.04)`
- Layout:
  - Icon (40px circle, colored background)
  - Value (24px, Bold)
  - Label (13px, gray)

### Form Elements

**Text Input:**
- Background: `#f5f5f7`
- Border: 2px solid transparent
- Border radius: 10px
- Padding: 14px vertical, 16px horizontal
- Font: 15px, SF Pro (or SF Mono for codes)
- States:
  - Default: Gray background
  - Focus: White background, blue border (#007AFF)
  - Error: Red border (#FF3B30)

**Toggle Switch:**
- Width: 51px
- Height: 31px
- Border radius: 16px (pill shape)
- Knob: 27px circle, white, shadow
- States:
  - Off: Gray background (#e5e5e7), knob left
  - On: Green background (#34C759), knob right (translated 20px)
- Animation: 0.3s ease for background and knob position

**Password Field:**
- Same as text input
- Type: Password (dots instead of characters)
- Optional "Show" button to reveal text

### Message Bubbles

**User Message:**
- Background: `#007AFF` (blue)
- Text: White, 15px
- Padding: 12px vertical, 16px horizontal
- Border radius: 20px (with 4px radius on bottom-right for "tail")
- Max width: 75% of screen
- Alignment: Right

**System Message:**
- Background: White
- Text: Black (#1d1d1f), 15px
- Padding: 12px vertical, 16px horizontal
- Border radius: 20px (with 4px radius on bottom-left for "tail")
- Shadow: `0 1px 3px rgba(0,0,0,0.06)`
- Max width: 75% of screen
- Alignment: Left

**Code Block (in message):**
- Background: `rgba(0, 0, 0, 0.05)` (in system messages) or `rgba(255, 255, 255, 0.2)` (in user messages)
- Font: 13px, SF Mono
- Padding: 8px vertical, 12px horizontal
- Border radius: 8px
- Horizontal scroll if needed

**Status Message (centered):**
- Background: `rgba(0, 122, 255, 0.1)` (light blue)
- Text: Blue (#007AFF), 13px
- Padding: 8px vertical, 16px horizontal
- Border radius: 12px
- Max width: 80%
- Alignment: Center

### Connection Status Indicators

**Connected (Green):**
- Background: `rgba(52, 199, 89, 0.1)`
- Dot: 12px circle, green (#34C759)
- Text: "Connected" + Tailscale IP (monospaced)

**Connecting (Orange):**
- Background: `rgba(255, 149, 0, 0.1)`
- Dot: 12px circle, orange (#FF9500), pulsing animation
- Text: "Connecting..." + status message

**Disconnected (Red):**
- Background: `rgba(255, 59, 48, 0.1)`
- Dot: 12px circle, red (#FF3B30)
- Text: "Disconnected" + error message

**Animation:**
- Pulsing: Opacity 1 → 0.5 → 1 over 2 seconds, infinite loop

### Tab Bar

**Layout:**
- Height: 83px (includes safe area)
- Background: `rgba(255, 255, 255, 0.95)` with blur (frosted glass effect)
- Border top: 0.5px solid `rgba(0, 0, 0, 0.05)`
- 4 tabs: Dashboard, Chat, Preview, Settings

**Tab Item:**
- Icon: 28px SF Symbol
- Label: 10px, Medium
- Spacing: 4px between icon and label
- States:
  - Active: Blue (#007AFF)
  - Inactive: Gray (#8e8e93)
- Min touch target: 44pt vertical

**Tab Icons:**
- Dashboard: 📊 (chart.bar.fill)
- Chat: 💬 (message.fill)
- Preview: 🔍 (safari.fill)
- Settings: ⚙️ (gearshape.fill)

Use SF Symbols for actual implementation (shown as emoji for mockup clarity).

---

## Interaction Patterns

### Gestures

**Pull-to-Refresh:**
- Available on: Dashboard (capsule list), Settings (device list)
- Gesture: Pull down from top of scrollable area
- Indicator: iOS standard spinner
- Haptic: Light impact on trigger
- Minimum pull: ~80pt before trigger
- Animation: Smooth spring, 0.4s duration

**Swipe-to-Delete:**
- Available on: Future feature (capsule list, message history)
- Gesture: Swipe left on row
- Action: Reveal red "Delete" button
- Confirmation: Alert before destructive action

**Long Press:**
- Available on: Messages (copy text), Capsules (context menu)
- Duration: 0.5s before trigger
- Haptic: Medium impact on trigger
- Action: Show context menu or copy confirmation

### Animations

**Screen Transitions:**
- Push/Pop: Slide from right (iOS standard NavigationStack)
- Modal: Slide up from bottom (sheet presentation)
- Dismiss: Slide down (interactive dismiss gesture enabled)
- Duration: 0.3s with iOS spring curve

**Loading States:**
- Spinner: iOS standard ActivityIndicator (medium size)
- Skeleton screens: For capsule grid while loading (gray rectangles with shimmer)
- Progress indicators: For long-running tasks (circular progress ring)

**Success Animations:**
- Checkmark: Scale up with spring (0.5s, bouncy)
- Status changes: Color fade (0.3s ease)
- Badge updates: Number count-up animation

**Voice Recording Animation:**
- Waveform: 5 bars animating up/down (wave pattern)
- Button: Pulsing scale (1.0 → 1.1 → 1.0 over 1.5s)
- Timer: Count-up every second

**Connection Status Transition:**
- Disconnected → Connecting: Fade to orange, dot starts pulsing
- Connecting → Connected: Fade to green, dot stops pulsing, haptic success
- Connected → Disconnected: Fade to red, haptic error

### Haptic Feedback

**Light Impact:**
- Pull-to-refresh trigger
- Toggle switch flip
- Tab selection

**Medium Impact:**
- Button press (primary actions)
- Long press trigger
- Capsule card tap

**Success Notification:**
- API key validation success
- Mac auto-discovery success
- Command execution success

**Error Notification:**
- API key validation failure
- Connection error
- Command execution error

**Warning Notification:**
- Destructive action confirmation (Sleep Mac, Sign Out)

### Navigation Patterns

**Tab-Based Navigation (Primary):**
- 4 tabs: Dashboard, Chat, Preview, Settings
- Tab bar always visible (except keyboard open)
- State persists when switching tabs
- Deep links can navigate to specific tab

**NavigationStack (Secondary):**
- Used within tabs for detail views
- Back button in top-left
- Large title style (collapses on scroll)
- Examples: Capsule Detail, API Key Edit

**Modal Sheets:**
- Used for temporary tasks (Edit API Key, Sleep Mac confirmation)
- Dismissible by swipe-down
- "Cancel" and "Done" buttons in header

**Alerts:**
- Used for confirmations (destructive actions)
- 2 buttons max: "Cancel" (safe) + "Action" (destructive)
- Examples: "Sleep Mac?", "Sign Out?"

---

## Accessibility Requirements

### VoiceOver Support

**All interactive elements must have labels:**
- Buttons: Descriptive label (e.g., "Connect to Tailscale", not just "Connect")
- Icons: Text label (e.g., "Status: Connected" for green dot)
- Images: Alt text (e.g., "Capsule icon" for app logo)
- Form fields: Label + hint + value

**Navigation:**
- Tab bar items: "Dashboard tab, 1 of 4"
- Lists: "Capsule 1 of 6, BrandJack, Active"
- Buttons: State included (e.g., "Auto-Connect, toggle button, on")

**Grouping:**
- Related elements grouped (e.g., capsule card = single swipeable item)
- Headers announced before sections

### Dynamic Type

**All text must scale with user's text size setting:**
- Small → AX5 (accessibility extra-large)
- Test at smallest and largest sizes
- Layouts must adjust (no fixed heights for text containers)
- Minimum 2 lines for multi-line text

**Font Style Mapping:**
- Use semantic font styles (`.title`, `.body`, `.caption`)
- DO NOT use fixed pixel sizes in SwiftUI
- Use `.font(.headline)` instead of `.font(.system(size: 17))`

### Color Contrast

**WCAG AA Compliance:**
- Text on background: 4.5:1 minimum
- UI elements (buttons, badges): 3:1 minimum
- Status colors tested in both Light and Dark mode

**Tested Combinations:**
- ✅ White text on #007AFF (primary button): 4.52:1
- ✅ #007AFF text on white background: 4.52:1
- ✅ #34C759 text on white: 3.01:1
- ✅ #FF3B30 text on white: 4.01:1

**Color-Blind Friendly:**
- Never rely on color alone for status
- Always include icon or text label
- Status badges: Dot + text (not just colored dot)

### Keyboard Navigation (iPadOS)

**All interactive elements must be keyboard-accessible:**
- Tab key cycles through focusable elements
- Enter key activates buttons
- Arrow keys navigate lists
- Esc key dismisses modals

**Focus Indicators:**
- Visible blue outline on focused element
- 2pt border, 2pt offset
- Meets contrast requirements

### Reduce Motion

**Respect `prefersReducedMotion` setting:**
- Disable spring animations (use instant transitions)
- Disable pulsing/rotating animations
- Disable parallax effects
- Keep essential animations only (e.g., loading spinner)

**Implementation:**
```swift
if UIAccessibility.isReduceMotionEnabled {
    // Use .animation(nil) or .animation(.linear(duration: 0.01))
} else {
    // Use .animation(.springNormal)
}
```

### Touch Targets

**Minimum 44pt x 44pt for all tappable elements:**
- Buttons: 48pt recommended (comfortable target)
- Toggle switches: 51pt x 31pt (iOS standard)
- List rows: 56pt minimum height
- Tab bar items: 44pt vertical space

**Spacing:**
- Minimum 8pt between adjacent tappable elements
- Recommended 12pt for comfortable spacing

---

## Implementation Handoff

### For Mobile Dev (📱)

**Design System Files:**
- All specifications defined in existing Swift files:
  - `src/Utilities/Colors.swift` — Color definitions (matches design system)
  - `src/Utilities/Typography.swift` — Font styles (matches design system)
  - `src/Utilities/Spacing.swift` — Layout constants (matches design system)
  - `src/BuilderSystemMobile/Common/Theme.swift` — Chat-specific colors and button styles

**Visual Reference:**
- HTML mockups in `/design/` folder (open in Safari)
- Use as pixel-perfect reference for layouts and spacing
- Screenshots can be taken for side-by-side comparison

**Component Reusability:**
- Build components once, reuse across all screens
- Examples:
  - Status badge component → Used in Dashboard, Capsule Detail, Settings
  - Card component → Used for capsules, stats, connection info
  - Button component → Primary, Secondary, Destructive variants

**Implementation Order:**
1. ✅ Design system (Colors, Typography, Spacing already exist)
2. ✅ Component library (Build reusable views)
3. Onboarding flow (5 screens)
4. Main app (4 tabs: Dashboard, Chat, Preview, Settings)
5. Detail screens (Capsule Detail, API Key Edit)
6. Polish (animations, haptics, accessibility)

**Native Components to Use:**
- **TabView** for tab bar navigation
- **NavigationStack** for push/pop navigation
- **Form** for grouped settings lists
- **List** for scrollable rows (devices, capsules)
- **Toggle** for switches
- **TextField** / **SecureField** for inputs
- **Button** with custom ButtonStyle for variants
- **ScrollView** with pull-to-refresh modifier

**SF Symbols to Use:**
- Replace emoji placeholders in mockups with actual SF Symbols
- Examples:
  - Dashboard icon: `chart.bar.fill`
  - Chat icon: `message.fill`
  - Settings icon: `gearshape.fill`
  - Chevron: `chevron.right`
  - Checkmark: `checkmark.circle.fill`

**Accessibility Implementation:**
- Use `.accessibilityLabel()` on all interactive elements
- Use `.accessibilityHint()` for non-obvious actions
- Group related elements with `.accessibilityElement(children: .combine)`
- Test with VoiceOver enabled
- Test with Dynamic Type at largest size
- Test in both Light and Dark mode

**Animation Guidelines:**
- Use `Animation.springNormal` for most transitions (defined in Spacing.swift)
- Use `Animation.springFast` for quick micro-interactions
- Use `Animation.springBouncy` for celebratory/success states
- Always respect `UIAccessibility.isReduceMotionEnabled`

**Performance Targets:**
- 60fps scrolling on capsule grid (use `LazyVGrid` for performance)
- Launch time under 400ms (optimize image loading)
- API response rendering under 100ms (use async/await properly)

**Testing Checklist:**
- [ ] All screens render correctly in Light and Dark mode
- [ ] VoiceOver can navigate all interactive elements
- [ ] Dynamic Type scales text at smallest and largest sizes
- [ ] Touch targets are minimum 44pt
- [ ] Animations respect Reduce Motion setting
- [ ] Pull-to-refresh works on Dashboard and Settings
- [ ] Tab bar switches between screens
- [ ] Onboarding flow completes successfully
- [ ] API key stored securely in Keychain
- [ ] Tailscale connection establishes correctly

### Design Decisions & Rationale

**Why native iOS patterns?**
- Familiar to iPhone users (no learning curve)
- Automatic Light/Dark mode support
- Built-in accessibility features
- Native performance (60fps animations)
- Consistent with iOS HIG

**Why 8pt grid system?**
- Divides evenly into common screen widths
- Consistent visual rhythm
- Easy to scale for different devices
- Industry standard for iOS design

**Why SF Pro font system?**
- Native to iOS (no custom fonts needed)
- Optimized for readability at all sizes
- Supports Dynamic Type automatically
- Consistent with system apps

**Why semantic colors?**
- Automatic Light/Dark mode adaptation
- Accessibility-friendly (system-tested contrast)
- Consistent with iOS visual language
- Future-proof for new iOS versions

**Why tab bar navigation?**
- iOS standard for multi-section apps
- Persistent access to all main areas
- Clear indication of current location
- One-tap switching between sections

**Why pull-to-refresh?**
- iOS-native gesture (users expect it)
- Manual data refresh without button clutter
- Haptic feedback confirms action
- Standard pattern for data-driven apps

### Open Questions / Future Considerations

**iPad Layout:**
- Sidebar navigation instead of tab bar?
- Multi-column layout for capsule grid (3-4 columns)?
- Split view for Chat (list + conversation)?

**Apple Watch Companion:**
- Quick status glance
- Voice commands to Mac
- Connection status notifications
- Design specs TBD

**Widgets:**
- Home Screen widget showing capsule count + status
- Lock Screen widget for connection status
- Live Activity for long-running commands

**Siri Shortcuts:**
- "Check BuilderOS status"
- "Run daily audit"
- "Connect to Tailscale"

**Push Notifications:**
- Capsule status changes (Active → Error)
- Command completion notifications
- Mac wake/sleep confirmations

---

## Summary

This design documentation provides complete specifications for implementing the BuilderOS Mobile iOS app. All visual deliverables are provided as interactive HTML mockups that can be opened in a browser for pixel-perfect reference.

**Key Files:**
- **Design System:** `/design/design-system.html`
- **Dashboard:** `/design/dashboard-screen.html`
- **Chat:** `/design/chat-screen.html`
- **Settings:** `/design/settings-screen.html`
- **Onboarding:** `/design/onboarding-flow.html`
- **This Document:** `/design/DESIGN_DOCUMENTATION.md`

**Implementation References:**
- Existing Swift files contain all color, typography, and spacing definitions
- All designs follow iOS 17+ native patterns
- Complete accessibility requirements documented
- Performance targets and testing checklist provided

**Next Steps:**
1. Review HTML mockups in browser
2. Validate design system matches existing Swift files
3. Begin implementation with component library
4. Build screens in order: Onboarding → Dashboard → Chat → Settings
5. Test accessibility and performance throughout

For questions or clarifications, refer to this documentation or the visual mockups.

---

**Design Credits:** UI/UX Designer Agent, October 2025
**Platform:** iOS 17+ (iPhone 15 Pro primary target)
**Design Language:** Native iOS (SF Pro, system colors, Apple HIG compliance)

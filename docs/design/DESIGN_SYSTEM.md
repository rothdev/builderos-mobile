# BuilderOS Mobile - iOS Design System

## Overview
This design system defines the visual language and interaction patterns for the BuilderOS Mobile iOS application, ensuring consistency with iOS 17+ design guidelines and the BuilderOS brand.

---

## Color System

### Light Mode

**Primary Colors:**
- **Blue (Primary):** `#007AFF` - Primary actions, links, active states
- **Purple (Secondary):** `#5856D6` - Gradients, accent highlights
- **Green (Success):** `#34C759` - Connection status, success states
- **Red (Destructive):** `#FF3B30` - Disconnect, delete, errors

**Neutral Colors:**
- **Background:** `#FFFFFF` - Primary background
- **Secondary Background:** `#F5F5F7` - Cards, input fields
- **Tertiary Background:** `#E9E9EB` - System message bubbles
- **Text Primary:** `#000000` - Main content
- **Text Secondary:** `#8E8E93` - Labels, timestamps, helpers

### Dark Mode

**Primary Colors:**
- **Blue (Primary):** `#007AFF` - Unchanged (same as light)
- **Purple (Secondary):** `#5856D6` - Unchanged
- **Green (Success):** `#34C759` - Unchanged
- **Red (Destructive):** `#FF3B30` - Unchanged

**Neutral Colors:**
- **Background:** `#000000` - Primary background
- **Secondary Background:** `#1C1C1E` - Cards, modal sheets
- **Tertiary Background:** `#2C2C2E` - System message bubbles, quick actions
- **Text Primary:** `#FFFFFF` - Main content
- **Text Secondary:** `#8E8E93` - Labels, timestamps, helpers (same as light)

**Overlay:**
- **Modal Overlay:** `rgba(0, 0, 0, 0.4)` - Semi-transparent background for sheets

### Gradients

**Builder Logo Gradient:**
```css
background: linear-gradient(135deg, #007AFF 0%, #5856D6 100%);
```

---

## Typography

### Font Family
**Primary:** SF Pro Display / SF Pro Text (iOS system fonts)
**Fallback:** `-apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif`
**Monospace:** SF Mono (for code blocks)

### Type Scale

| Element | Size | Weight | Line Height | Usage |
|---------|------|--------|-------------|-------|
| **Empty Title** | 24px | 700 (Bold) | 1.2 | Large welcome headings |
| **Modal Title** | 20px | 700 (Bold) | 1.3 | Sheet headings |
| **Header Title** | 17px | 600 (Semibold) | 1.4 | Navigation bar titles |
| **Card Title** | 17px | 600 (Semibold) | 1.4 | Section headings |
| **Body Text** | 15px | 400 (Regular) | 1.4 | Messages, body content |
| **Small Text** | 14px | 500 (Medium) | 1.5 | Quick action labels |
| **Labels** | 15px | 400 (Regular) | 1.4 | Form labels, metadata |
| **Connection Status** | 13px | 500 (Medium) | 1.3 | Compact status text |
| **Code Block** | 13px | 400 (Regular) | 1.5 | Monospace code content |
| **Timestamps** | 11px | 400 (Regular) | 1.3 | Message timestamps |
| **Status Bar** | 15px | 600 (Semibold) | 1.2 | iOS status bar text |

### Dynamic Type Support
All text sizes should support iOS Dynamic Type scaling for accessibility.

---

## Spacing System

**Base Unit:** 8pt (iOS standard)

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Icon/text gaps |
| `sm` | 8px | Tight spacing, input padding |
| `md` | 12px | Message bubbles padding (vertical) |
| `lg` | 16px | Standard padding, message gaps |
| `xl` | 20px | Card padding, header padding |
| `2xl` | 24px | Screen padding, section gaps |
| `3xl` | 34px | Bottom safe area padding |
| `4xl` | 40px | Empty state padding |

### Component-Specific Spacing

**Header:**
- Padding: `12px 20px` (vertical / horizontal)
- Border: 1px solid separator

**Input Bar:**
- Padding: `12px 16px 34px` (top / horizontal / bottom with safe area)

**Messages:**
- Gap between messages: `16px`
- Bubble padding: `12px 16px` (vertical / horizontal)

**Quick Actions Grid:**
- Grid gap: `12px`
- Card padding: `20px 16px`

---

## Component Specifications

### 1. Message Bubbles

**User Message (Right-aligned):**
- Background: `#007AFF`
- Text color: `#FFFFFF`
- Border radius: `20px` (all corners except bottom-right: `4px`)
- Max width: `85%`
- Padding: `12px 16px`
- Alignment: Right
- Animation: Slide in from bottom (0.3s ease-out)

**System Message (Left-aligned):**
- **Light mode:** Background `#E9E9EB`, Text `#000000`
- **Dark mode:** Background `#2C2C2E`, Text `#FFFFFF`
- Border radius: `20px` (all corners except bottom-left: `4px`)
- Max width: `85%`
- Padding: `12px 16px`
- Alignment: Left

**Code Block Message:**
- **Light mode:** Background `#F5F5F7`, Text `#1C1C1E`
- **Dark mode:** Background `#1C1C1E`, Text `#E5E5E7`
- Font: SF Mono, `13px`
- Border radius: `20px` (bottom-left: `4px`)
- Max width: `90%`
- Padding: `12px 16px`

**Timestamp:**
- Font size: `11px`
- Color: `#8E8E93` (both modes)
- Margin-top: `4px`
- Alignment: Right

---

### 2. Input Bar

**Container:**
- Padding: `12px 16px 34px` (safe area included)
- Border-top: `1px solid rgba(0,0,0,0.08)` (light) / `rgba(255,255,255,0.1)` (dark)
- Background: Matches screen background

**Input Field:**
- **Light mode:** Background `#F5F5F7`
- **Dark mode:** Background `#1C1C1E`
- Border: None
- Border-radius: `20px`
- Padding: `10px 16px`
- Font-size: `15px`
- Placeholder color: `#8E8E93`

**Quick Action Button:**
- Size: `36px × 36px`
- Border-radius: `18px` (circular)
- Background: Transparent
- Icon: ⚡ (18px font-size)

**Send Button:**
- Size: `36px × 36px`
- Border-radius: `18px` (circular)
- Background: `#007AFF`
- Icon: ↑ (white, 18px)
- Active state: Scale `0.92`

---

### 3. Header

**Container:**
- Padding: `12px 20px`
- Border-bottom: `1px solid rgba(0,0,0,0.08)` (light) / `rgba(255,255,255,0.1)` (dark)
- Display: Flex (space-between)

**Title:**
- Font-size: `17px`
- Font-weight: `600` (Semibold)

**Connection Status:**
- Display: Flex (align-items center)
- Gap: `6px`
- Font-size: `13px`
- Color: `#34C759` (green)
- Font-weight: `500`

**Connection Dot:**
- Size: `8px × 8px`
- Background: `#34C759`
- Border-radius: `50%`
- Animation: Pulse (2s infinite)

---

### 4. Quick Actions Modal

**Overlay:**
- Background: `rgba(0, 0, 0, 0.4)`
- Position: Fixed, full screen
- Display: Flex (align-items flex-end)
- Animation: Fade in (0.3s ease-out)

**Modal Sheet:**
- Background: `#FFFFFF` (light) / `#1C1C1E` (dark)
- Border-radius: `20px 20px 0 0` (top corners only)
- Padding: `24px`
- Animation: Slide up from bottom (0.3s ease-out)

**Drag Handle:**
- Width: `40px`
- Height: `5px`
- Background: `#C7C7CC`
- Border-radius: `3px`
- Margin: `0 auto 24px`

**Quick Actions Grid:**
- Grid: 2 columns
- Gap: `12px`

**Quick Action Card:**
- **Light mode:** Background `#F5F5F7`
- **Dark mode:** Background `#2C2C2E`
- Border-radius: `16px`
- Padding: `20px 16px`
- Active state: Scale `0.96`

**Quick Action Icon:**
- Font-size: `28px`
- Margin-bottom: `8px`

**Quick Action Label:**
- Font-size: `14px`
- Font-weight: `600`

---

### 5. Connection Screen

**Connection Card:**
- **Light mode:** Background `#F5F5F7`
- **Dark mode:** Background `#1C1C1E`
- Border-radius: `16px`
- Padding: `20px`

**Connection Row:**
- Display: Flex (space-between)
- Padding: `12px 0`
- Border-bottom: `1px solid rgba(0,0,0,0.05)` (light) / `rgba(255,255,255,0.05)` (dark)

**Connection Label:**
- Font-size: `15px`
- Color: `#8E8E93`

**Connection Value:**
- Font-size: `15px`
- Font-weight: `600`

**Connect Button:**
- Width: `100%`
- Background: `#34C759` (connected) / `#FF3B30` (disconnect)
- Border-radius: `12px`
- Padding: `16px`
- Font-size: `17px`
- Font-weight: `600`
- Active state: Scale `0.98`

**Help Section:**
- Background: `#F5F5F7` (light) / `#1C1C1E` (dark)
- Border-radius: `12px`
- Padding: `16px`

---

### 6. Empty State

**Container:**
- Flex: 1 (center vertically and horizontally)
- Padding: `40px`
- Text-align: Center
- Gap: `20px`

**Builder Logo:**
- Size: `80px × 80px`
- Background: `linear-gradient(135deg, #007AFF 0%, #5856D6 100%)`
- Border-radius: `20px`
- Icon: 🏗️ (40px font-size)
- Box-shadow: `0 4px 16px rgba(0,122,255,0.3)`

**Empty Title:**
- Font-size: `24px`
- Font-weight: `700` (Bold)

**Empty Subtitle:**
- Font-size: `15px`
- Color: `#8E8E93`
- Line-height: `1.5`

---

## Animations & Interactions

### Animation Timing

| Animation | Duration | Easing | Usage |
|-----------|----------|--------|-------|
| **Message Slide In** | 0.3s | ease-out | New message appears |
| **Modal Fade In** | 0.3s | ease-out | Overlay appears |
| **Modal Slide Up** | 0.3s | ease-out | Sheet slides from bottom |
| **Button Active** | 0.2s | default | Scale down on press |
| **Connection Pulse** | 2s | infinite | Status dot animation |

### Interaction States

**Buttons:**
- **Default:** Full opacity, normal scale
- **Hover:** N/A (iOS doesn't have hover)
- **Active (Touch):** Scale `0.92` - `0.98` (depending on button)
- **Disabled:** 50% opacity, no interaction

**Input Fields:**
- **Default:** Normal background
- **Focused:** iOS system focus ring (automatic)
- **Filled:** Text visible

**Cards:**
- **Default:** Normal background
- **Active (Touch):** Slightly darker background + scale `0.96`

---

## iOS-Specific Patterns

### Status Bar
- Height: `54px` (includes safe area)
- Font-size: `15px`
- Font-weight: `600`
- Content: Time (left), Cellular/WiFi/Battery (right)

### Safe Areas
- **Top:** 54px (status bar included in calculations)
- **Bottom:** 34px (home indicator area)
- **Sides:** 0px (Edge-to-edge content allowed)

### Navigation Bar
- Height: ~44px (excluding status bar)
- Large title style NOT used (compact title only)
- Separator: 1px hairline

### Sheet Presentation
- **Style:** Bottom sheet
- **Drag handle:** Always visible
- **Background dimming:** 40% black overlay
- **Dismissal:** Swipe down (not implemented in HTML preview)

### Keyboard Behavior
- **Appearance:** Automatic (matches system light/dark)
- **Return key:** "Send" action
- **Input bar:** Moves up with keyboard (not in preview)

---

## Accessibility Requirements

### Color Contrast
All text/background combinations meet **WCAG AA standards** (4.5:1 minimum):
- ✅ Blue `#007AFF` on white
- ✅ White text on blue buttons
- ✅ `#8E8E93` labels on white/black backgrounds
- ✅ Green `#34C759` status text

### Dynamic Type
- All font sizes scale with iOS Dynamic Type settings
- Layout adapts to larger text sizes
- Minimum touch target: 44×44pt

### VoiceOver Support
- All interactive elements labeled
- Message roles properly identified
- Connection status announced
- Quick actions described

### Reduced Motion
- Animations disabled when `prefers-reduced-motion` enabled
- Instant state changes instead of transitions

---

## Design Tokens (iOS Implementation)

### SwiftUI Color Extensions
```swift
extension Color {
    // Light mode defaults, automatic dark mode variants
    static let builderPrimary = Color("BuilderPrimary") // #007AFF
    static let builderSecondary = Color("BuilderSecondary") // #5856D6
    static let builderSuccess = Color("BuilderSuccess") // #34C759
    static let builderDestructive = Color("BuilderDestructive") // #FF3B30

    static let backgroundPrimary = Color(.systemBackground) // Auto light/dark
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
}
```

### SwiftUI Font Extensions
```swift
extension Font {
    static let builderTitle = Font.system(size: 24, weight: .bold)
    static let builderHeading = Font.system(size: 20, weight: .bold)
    static let builderSubheading = Font.system(size: 17, weight: .semibold)
    static let builderBody = Font.system(size: 15, weight: .regular)
    static let builderSmall = Font.system(size: 14, weight: .medium)
    static let builderCaption = Font.system(size: 13, weight: .medium)
    static let builderTimestamp = Font.system(size: 11, weight: .regular)

    static let builderCode = Font.system(size: 13, weight: .regular, design: .monospaced)
}
```

### SwiftUI Spacing Extensions
```swift
extension CGFloat {
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 20
    static let spacing2XL: CGFloat = 24
    static let spacing3XL: CGFloat = 34
    static let spacing4XL: CGFloat = 40
}
```

---

## Implementation Notes

### Light/Dark Mode Strategy
- Use iOS **system colors** wherever possible (`.systemBackground`, `.label`, etc.)
- Custom colors defined in **Asset Catalog** with light/dark variants
- Automatic switching based on system appearance
- No manual theme toggle needed (respects user's system preference)

### SF Symbols Integration
- Use SF Symbols 5.0+ for all icons
- Fallback emoji for HTML previews (🏗️, ⚡, 📊, etc.)
- Symbol weight matches text weight (medium for body, semibold for headings)

### Component Reusability
- **MessageBubble:** Reusable view with `.user`, `.system`, `.code` variants
- **QuickActionCard:** Reusable button component
- **ConnectionRow:** Reusable key-value pair component

### State Management
- **Connection status:** Observable object, updates in real-time
- **Messages:** Array of `Message` models, append-only for chat
- **Quick actions:** Static grid configuration
- **Theme:** Automatic from `@Environment(\.colorScheme)`

---

## Design Review Checklist

Before implementing in Swift, verify:
- [ ] All colors meet WCAG AA contrast requirements
- [ ] Font sizes support Dynamic Type scaling
- [ ] Touch targets minimum 44×44pt
- [ ] Safe area insets respected (top 54px, bottom 34px)
- [ ] Light and dark mode both tested
- [ ] Animations respect reduced motion preferences
- [ ] VoiceOver labels defined for all interactive elements
- [ ] Modal sheets have drag handles
- [ ] Connection status updates in real-time
- [ ] Input bar moves with keyboard (iOS automatic)
- [ ] Status bar matches system (time, cellular, battery)

---

## Next Steps for Implementation

1. **Create SwiftUI Views:**
   - `ChatView` (main screen)
   - `MessageBubbleView` (reusable component)
   - `QuickActionsSheet` (modal)
   - `ConnectionView` (settings screen)
   - `EmptyStateView` (welcome)

2. **Define Data Models:**
   - `Message` (id, content, sender, timestamp, type)
   - `ConnectionStatus` (isConnected, server, latency, version)
   - `QuickAction` (id, icon, label, action)

3. **Implement State Management:**
   - `ChatViewModel` (ObservableObject)
   - `ConnectionManager` (Singleton for WebSocket)

4. **Add Animations:**
   - Message slide-in transitions
   - Modal sheet presentation
   - Button scale animations
   - Connection pulse effect

5. **Integrate Backend:**
   - WebSocket connection to BuilderOS
   - Real-time message streaming
   - System status polling
   - Error handling and retry logic

---

**Design System Version:** 1.0.0
**Last Updated:** October 22, 2025
**Platform:** iOS 17+
**Design Tools:** HTML Preview (interactive mockup)

# BuilderOS Mobile - Screen Specifications

## Overview
Detailed specifications for each screen in the BuilderOS Mobile iOS application, including layouts, components, interactions, and state management.

---

## 1. Chat Screen (Main Interface)

### Purpose
Primary interface for conversing with Jarvis, viewing system responses, and accessing BuilderOS capabilities.

### Layout Structure

```
┌─────────────────────────────────────┐
│   Status Bar (54px)                 │ ← iOS system (time, cellular, battery)
├─────────────────────────────────────┤
│   Header (44px)                     │ ← "BuilderOS" + Connection status
├─────────────────────────────────────┤
│                                     │
│   Messages Container                │
│   (Scrollable, flex: 1)             │
│                                     │
│   User Message (right) ──────────┐  │
│   System Message (left) ─────────┤  │
│   Code Block (left, wide) ───────┤  │
│                                     │
├─────────────────────────────────────┤
│   Input Bar (70px with safe area)  │ ← ⚡ + Input + ↑
└─────────────────────────────────────┘
```

### Component Breakdown

#### Status Bar
- **Height:** 54px (includes notch/Dynamic Island area)
- **Content:** System-managed (time, cellular, WiFi, battery)
- **Style:** Automatic (dark content on light bg, light content on dark bg)

#### Header
- **Height:** 44px (standard iOS nav bar height, compact)
- **Padding:** 12px 20px
- **Border:** 1px solid separator (light: `rgba(0,0,0,0.08)`, dark: `rgba(255,255,255,0.1)`)
- **Left:** Title "BuilderOS" (17px, semibold)
- **Right:** Connection status (green dot + "Connected", 13px medium)

**Connection Status States:**
- ✅ **Connected:** Green dot (`#34C759`) + "Connected"
- ⏳ **Connecting:** Yellow dot (`#FFCC00`) + "Connecting..."
- ❌ **Disconnected:** Red dot (`#FF3B30`) + "Disconnected"

#### Messages Container
- **Layout:** Vertical scroll view
- **Padding:** 16px (sides and top)
- **Gap:** 16px between messages
- **Scroll behavior:** Auto-scroll to bottom on new message
- **Background:** System background (white/black)

**Message Types:**

1. **User Message (Right-aligned):**
   - Background: `#007AFF`
   - Text: White
   - Border-radius: 20px (except bottom-right: 4px)
   - Max-width: 85%
   - Padding: 12px 16px
   - Font: 15px regular
   - Alignment: Right (self-end in SwiftUI)
   - Animation: Slide in from bottom + fade

2. **System Message (Left-aligned):**
   - Background: `#E9E9EB` (light) / `#2C2C2E` (dark)
   - Text: System label color
   - Border-radius: 20px (except bottom-left: 4px)
   - Max-width: 85%
   - Padding: 12px 16px
   - Font: 15px regular
   - Alignment: Left (self-start)
   - Timestamp: 11px secondary label, right-aligned, 4px margin-top

3. **Code Block (Left-aligned):**
   - Background: `#F5F5F7` (light) / `#1C1C1E` (dark)
   - Text: System label, monospaced
   - Border-radius: 20px (except bottom-left: 4px)
   - Max-width: 90% (wider for code)
   - Padding: 12px 16px
   - Font: 13px monospaced (SF Mono)
   - Alignment: Left
   - Scroll: Horizontal if content overflows

#### Input Bar
- **Height:** 70px total (36px content + 34px bottom safe area)
- **Padding:** 12px 16px 34px
- **Border-top:** 1px solid separator
- **Background:** System background
- **Layout:** HStack with 8px gap

**Components:**
1. **Quick Actions Button (⚡):**
   - Size: 36×36px
   - Background: Transparent
   - Icon: ⚡ (18px, system blue)
   - Action: Opens Quick Actions modal

2. **Text Input Field:**
   - Flex: 1 (takes remaining space)
   - Background: `#F5F5F7` (light) / `#1C1C1E` (dark)
   - Border-radius: 20px
   - Padding: 10px 16px
   - Placeholder: "Ask Jarvis..." (secondary label color)
   - Font: 15px regular
   - Return key: "Send"

3. **Send Button (↑):**
   - Size: 36×36px
   - Background: `#007AFF`
   - Icon: ↑ (white, 18px)
   - Border-radius: 18px (circular)
   - Active: Scale 0.92
   - Disabled: 50% opacity when input empty

### State Management

**ChatViewModel (ObservableObject):**
```swift
@Published var messages: [Message] = []
@Published var inputText: String = ""
@Published var isConnected: Bool = true
@Published var isSending: Bool = false
@Published var showQuickActions: Bool = false

func sendMessage()
func loadChatHistory()
func scrollToBottom()
```

**Message Model:**
```swift
struct Message: Identifiable {
    let id: UUID
    let content: String
    let sender: MessageSender // .user, .system
    let type: MessageType // .text, .code
    let timestamp: Date
}
```

### Interactions

1. **Send Message:**
   - Tap Send button OR press Return key
   - Input text sent to backend
   - Message appears in chat immediately (optimistic UI)
   - Input field clears
   - Scroll to bottom

2. **Quick Actions:**
   - Tap ⚡ button
   - Modal sheet slides up
   - Overlay dims background

3. **Scroll Behavior:**
   - Auto-scroll on new message
   - Manual scroll up to view history
   - Pull-to-refresh for older messages (future)

### Edge Cases

- **Empty Chat:** Show Empty State view (see section 2)
- **Connection Lost:** Update header status to red + "Disconnected"
- **Long Messages:** Wrap text, expand bubble vertically
- **Code Overflow:** Horizontal scroll within code block
- **Keyboard:** Input bar moves up with keyboard (iOS automatic)

---

## 2. Empty State Screen

### Purpose
Welcome screen shown when no messages exist yet, guiding users to start interacting.

### Layout Structure

```
┌─────────────────────────────────────┐
│   Status Bar (54px)                 │
├─────────────────────────────────────┤
│   Header (44px)                     │
├─────────────────────────────────────┤
│                                     │
│        ┌─────────┐                  │
│        │ 🏗️ Logo │  (80×80px)       │
│        └─────────┘                  │
│                                     │
│   Welcome to BuilderOS              │
│                                     │
│   Your mobile companion for...      │
│   (subtitle text, centered)         │
│                                     │
├─────────────────────────────────────┤
│   Input Bar (70px)                  │
└─────────────────────────────────────┘
```

### Component Breakdown

#### Builder Logo
- **Size:** 80×80px
- **Background:** Linear gradient `#007AFF` → `#5856D6` (135deg)
- **Border-radius:** 20px
- **Icon:** 🏗️ (40px font-size, centered)
- **Box-shadow:** `0 4px 16px rgba(0,122,255,0.3)`

#### Welcome Title
- **Text:** "Welcome to BuilderOS"
- **Font:** 24px bold
- **Color:** System label
- **Margin-top:** 20px

#### Subtitle
- **Text:** "Your mobile companion for managing capsules, coordinating agents, and monitoring the Builder System on the go."
- **Font:** 15px regular
- **Color:** Secondary label (`#8E8E93`)
- **Line-height:** 1.5
- **Max-width:** 320px
- **Margin-top:** 12px

### State Management
- Same `ChatViewModel` used
- Shown when `messages.isEmpty`

### Transitions
- Automatically switches to Chat Screen when first message sent
- Fade transition between states

---

## 3. Quick Actions Modal

### Purpose
Fast access to common BuilderOS commands without typing.

### Layout Structure

```
┌─────────────────────────────────────┐
│   Dimmed Overlay (rgba(0,0,0,0.4))  │
│                                     │
│   ┌─────────────────────────────┐   │
│   │  ──  (drag handle)          │   │
│   │                             │   │
│   │  Quick Actions              │   │ ← Modal Sheet
│   │                             │   │
│   │  ┌──────┐  ┌──────┐         │   │
│   │  │ 📊   │  │ 🏗️  │         │   │
│   │  │Status│  │List │          │   │
│   │  └──────┘  └──────┘         │   │
│   │  ┌──────┐  ┌──────┐         │   │
│   │  │ 🚀   │  │ 🔍  │         │   │
│   │  │Deploy│  │Search│         │   │
│   │  └──────┘  └──────┘         │   │
│   │  ┌──────┐  ┌──────┐         │   │
│   │  │ 🧠   │  │ ⚙️  │         │   │
│   │  │Memory│  │Settings│        │   │
│   │  └──────┘  └──────┘         │   │
│   │                             │   │
│   │  [Custom command input...]  │   │
│   └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Component Breakdown

#### Modal Overlay
- **Background:** `rgba(0, 0, 0, 0.4)`
- **Position:** Full screen
- **Interaction:** Tap to dismiss (closes modal)
- **Animation:** Fade in (0.3s)

#### Modal Sheet
- **Background:** System background (white/dark)
- **Border-radius:** 20px 20px 0 0 (top corners only)
- **Padding:** 24px
- **Animation:** Slide up from bottom (0.3s ease-out)
- **Shadow:** iOS standard sheet shadow

#### Drag Handle
- **Width:** 40px
- **Height:** 5px
- **Background:** `#C7C7CC`
- **Border-radius:** 3px
- **Margin:** 0 auto 24px
- **Interaction:** Drag down to dismiss (iOS standard)

#### Quick Actions Grid
- **Layout:** 2 columns, auto rows
- **Gap:** 12px
- **Actions:** 6 default (extensible)

**Quick Action Card:**
- **Background:** `#F5F5F7` (light) / `#2C2C2E` (dark)
- **Border-radius:** 16px
- **Padding:** 20px 16px
- **Active state:** Scale 0.96 + darker background
- **Layout:** VStack (icon above label)

**Quick Action Icon:**
- **Font-size:** 28px
- **Margin-bottom:** 8px

**Quick Action Label:**
- **Font-size:** 14px
- **Font-weight:** 600 (semibold)
- **Color:** System label

#### Custom Command Input
- **Same style as Chat Input Field**
- **Placeholder:** "Or type a custom command..."
- **Margin-top:** 16px

### Default Quick Actions

| Icon | Label | Action |
|------|-------|--------|
| 📊 | System Status | Sends "Show system status" |
| 🏗️ | List Capsules | Sends "List all capsules" |
| 🚀 | Deploy | Sends "Deploy latest changes" |
| 🔍 | Search Logs | Sends "Search logs" |
| 🧠 | Memory Query | Sends "Query builder memory" |
| ⚙️ | Settings | Opens Settings screen |

### State Management

**QuickActionsViewModel:**
```swift
@Published var actions: [QuickAction] = defaultActions
@Published var customInput: String = ""
@Published var isPresented: Bool = false

func executeAction(_ action: QuickAction)
func sendCustomCommand()
```

**QuickAction Model:**
```swift
struct QuickAction: Identifiable {
    let id: UUID
    let icon: String // SF Symbol or emoji
    let label: String
    let command: String // Text to send
}
```

### Interactions

1. **Open Modal:**
   - Tap ⚡ button in Chat Screen
   - Overlay fades in
   - Sheet slides up

2. **Select Action:**
   - Tap action card
   - Card scales down (active state)
   - Command sent to chat
   - Modal dismisses
   - Response appears in chat

3. **Custom Command:**
   - Type in custom input
   - Tap Return or Send
   - Command sent
   - Modal dismisses

4. **Dismiss Modal:**
   - Tap overlay
   - Swipe down on handle
   - Swipe down on sheet
   - Modal slides down + overlay fades out

### Animations

- **Open:** Overlay fade + sheet slide up (0.3s ease-out)
- **Close:** Sheet slide down + overlay fade (0.3s ease-in)
- **Card Press:** Scale 0.96 (0.2s spring)

---

## 4. Connection Screen

### Purpose
Manage BuilderOS backend connection, view connection stats, and troubleshoot connectivity issues.

### Layout Structure

```
┌─────────────────────────────────────┐
│   Status Bar (54px)                 │
├─────────────────────────────────────┤
│   Header: "Connection"              │
├─────────────────────────────────────┤
│                                     │
│   ┌─────────────────────────────┐   │
│   │  BuilderOS Status           │   │
│   │  Status: ● Connected        │   │
│   │  Server: Local MacBook      │   │
│   │  Version: 2.1.0             │   │
│   │  Latency: 24ms              │   │
│   └─────────────────────────────┘   │
│                                     │
│   [ Disconnect Button ]             │
│                                     │
│   ┌─────────────────────────────┐   │
│   │  Connection Help            │   │
│   │  Ensure your iPhone and...  │   │
│   └─────────────────────────────┘   │
│                                     │
│   ┌─────────────────────────────┐   │
│   │  Recent Activity            │   │
│   │  Last Sync: 2 min ago       │   │
│   │  Messages: 47 today         │   │
│   │  Tasks: 12 completed        │   │
│   └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### Component Breakdown

#### Connection Card
- **Background:** Secondary system background
- **Border-radius:** 16px
- **Padding:** 20px
- **Margin:** 24px (horizontal)

**Card Title:**
- **Font:** 17px semibold
- **Margin-bottom:** 16px

**Connection Row:**
- **Layout:** HStack with space-between
- **Padding:** 12px 0
- **Border-bottom:** 1px solid separator (light: `rgba(0,0,0,0.05)`)
- **Last row:** No border

**Connection Label (Left):**
- **Font:** 15px regular
- **Color:** Secondary label (`#8E8E93`)

**Connection Value (Right):**
- **Font:** 15px semibold
- **Color:** System label
- **Status:** Color-coded (green/red/yellow)

#### Connect/Disconnect Button
- **Width:** Full width (minus 48px horizontal padding)
- **Background:** `#34C759` (connected) or `#FF3B30` (disconnected)
- **Border-radius:** 12px
- **Padding:** 16px vertical
- **Font:** 17px semibold, white
- **Active:** Scale 0.98
- **Margin:** 24px (top and bottom)

**Button States:**
- **Connected:** Red background, "Disconnect" label
- **Disconnected:** Green background, "Connect" label
- **Connecting:** Yellow/blue, "Connecting..." label, disabled

#### Help Section
- **Background:** Tertiary system background
- **Border-radius:** 12px
- **Padding:** 16px
- **Margin:** 24px horizontal

**Help Title:**
- **Font:** 15px semibold
- **Margin-bottom:** 8px

**Help Text:**
- **Font:** 14px regular
- **Color:** Secondary label
- **Line-height:** 1.5

#### Recent Activity Card
- Same style as Connection Card
- Shows usage stats
- Updates in real-time

### State Management

**ConnectionViewModel:**
```swift
@Published var connectionStatus: ConnectionStatus
@Published var isConnecting: Bool = false
@Published var lastSync: Date?
@Published var todayMessages: Int = 0
@Published var todayTasks: Int = 0

func connect()
func disconnect()
func refreshStats()
```

**ConnectionStatus Model:**
```swift
struct ConnectionStatus {
    var isConnected: Bool
    var server: String
    var version: String
    var latency: Int // milliseconds
    var lastConnected: Date?
}
```

### Connection States

1. **Connected:**
   - Green dot + "Connected"
   - All stats visible
   - Button: "Disconnect" (red)

2. **Disconnected:**
   - Red dot + "Disconnected"
   - Stats grayed out or "--"
   - Button: "Connect" (green)

3. **Connecting:**
   - Yellow dot + "Connecting..."
   - Button: "Connecting..." (disabled)

4. **Error:**
   - Red dot + "Connection Failed"
   - Error message in help section
   - Button: "Retry" (green)

### Interactions

1. **Connect:**
   - Tap "Connect" button
   - Status changes to "Connecting..."
   - WebSocket connection attempt
   - On success: Status → "Connected"
   - On failure: Status → "Connection Failed" + error

2. **Disconnect:**
   - Tap "Disconnect" button
   - Confirmation alert (optional)
   - WebSocket closes
   - Status → "Disconnected"

3. **Auto-reconnect:**
   - On app resume (background → foreground)
   - On network change (WiFi → Cellular)

### Edge Cases

- **Network Unavailable:** Show error, disable Connect button
- **Server Unreachable:** Show error, offer troubleshooting steps
- **Version Mismatch:** Warning if mobile/server versions incompatible
- **Slow Connection:** Show latency warning if >500ms

---

## 5. Status Bar (iOS System)

### Specifications
- **Height:** 54px (notch devices) or 44px (home button devices)
- **Content:** System-managed (time, cellular, WiFi, battery)
- **Style:** `.default` (dark content on light bg, light content on dark bg)

**Auto-switching:**
- Light mode screen → Dark status bar content
- Dark mode screen → Light status bar content

---

## Navigation Structure

```
Main Tab Bar (Future):
├── Chat (Main Screen)
├── Capsules (Dashboard)
├── System (Monitoring)
└── Settings (Connection, Preferences)

Modal Sheets:
├── Quick Actions (from Chat)
├── Capsule Details (from Dashboard)
└── System Logs (from System)

Settings Screens:
├── Connection (detailed spec above)
├── Notifications
├── Appearance
└── About
```

**Current MVP:** Chat Screen + Quick Actions + Connection only

---

## Responsive Behaviors

### iPhone Sizes

**Tested Sizes:**
- **iPhone 14 Pro / 15 Pro:** 393×852pt (standard)
- **iPhone SE:** 375×667pt (compact)
- **iPhone 14 Pro Max / 15 Pro Max:** 430×932pt (large)

**Adaptations:**
- Message bubbles: Max-width 85% (scales with screen)
- Grid: 2 columns always (no 3-column on Max)
- Padding: Consistent 16-24px regardless of size

### iPad (Future)

**iPad Adaptations:**
- Split view: Chat on left, Connection/Settings on right
- Message bubbles: Max-width 600px (fixed, not percentage)
- Grid: 3-4 columns for Quick Actions
- Floating input bar (not edge-to-edge)

---

## Keyboard Handling

### iOS Standard Behavior
- **Input field focused:** Keyboard slides up
- **Input bar:** Automatically moves up with keyboard
- **Messages container:** Shrinks to fit remaining space
- **Scroll position:** Auto-scroll to show latest message

**Keyboard Accessories:**
- Return key: "Send" action (sends message)
- Keyboard type: Default (with autocorrect)
- Dark appearance: Matches system theme

---

## Accessibility

### VoiceOver Labels

**Chat Screen:**
- Header: "BuilderOS, Connected"
- Message bubbles: "You said [message]" / "Jarvis replied [message]"
- Quick Actions button: "Open quick actions"
- Input field: "Message input field"
- Send button: "Send message"

**Quick Actions Modal:**
- Modal: "Quick actions sheet"
- Each action: "[Action name] button"
- Custom input: "Custom command input"

**Connection Screen:**
- Status: "Connection status: Connected"
- Button: "Disconnect from BuilderOS" / "Connect to BuilderOS"

### Dynamic Type
- All fonts scale with iOS settings
- Layout adapts to larger text (vertical spacing increases)
- Message bubbles expand to fit text
- Input field grows vertically if needed

### Reduced Motion
- Animations disabled (instant transitions)
- Connection pulse: Static dot (no animation)

### Color Contrast
All combinations tested for WCAG AA compliance:
- ✅ Blue buttons on white/black
- ✅ System labels on backgrounds
- ✅ Secondary labels on backgrounds

---

## Performance Targets

### Loading
- **App launch:** <1s to chat screen
- **Message send:** <100ms latency
- **Modal open:** <300ms animation
- **Connection:** <500ms to establish WebSocket

### Memory
- **Baseline:** <50MB memory usage
- **With 100 messages:** <80MB
- **With 1000 messages:** <150MB (pagination required)

### Battery
- **Background:** No drain (WebSocket suspended)
- **Active chat:** <5% drain per 30 minutes

---

## Implementation Priority

### Phase 1 (MVP - Current):
1. ✅ Chat Screen (messages, input)
2. ✅ Empty State
3. ✅ Quick Actions Modal
4. ✅ Connection Screen

### Phase 2 (Q1 2025):
5. Capsule Dashboard
6. System Monitoring
7. Settings screens
8. Notifications

### Phase 3 (Q2 2025):
9. iPad support
10. Widgets
11. Siri shortcuts
12. Apple Watch companion

---

**Document Version:** 1.0.0
**Last Updated:** October 22, 2025
**Platform:** iOS 17+
**Screen Count:** 4 (MVP)

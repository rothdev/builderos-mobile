# BuilderOS Mobile - Penpot Design Specification

## Project Information
- **Project Name:** BuilderOS Mobile - Terminal UI
- **Artboard Size:** 393×852px (iPhone 14/15 dimensions)
- **Design System:** Terminal aesthetic with cyber/hacker theme
- **Primary Font:** JetBrains Mono (monospace)
- **Color Palette Source:** shapedream.co placeholders

## Design System

### Color Palette

**Primary Colors:**
- Electric Cyan: `#60efff`
  - Used for: Accent text, glows, terminal prompts
  - Opacity variants: 100%, 70%, 50%, 30%
- Rose Pink: `#ff6b9d`
  - Used for: Gradient accents, terminal prompts, secondary highlights
  - Opacity variants: 100%, 70%, 50%
- Hot Red: `#ff3366`
  - Used for: Error states, action buttons, gradient endpoints
  - Opacity variants: 100%, 70%

**Background Colors:**
- Dark Navy: `#0a0e27` (base background)
- Darker Navy: `#16213e` (gradient endpoint)
- Card Background: `rgba(26, 35, 50, 0.6)` (glassmorphism)
- Border: `#1a2332` (separators)
- Border Secondary: `#2a3f5f` (inputs)

**Text Colors:**
- Primary Text: `#60efff` (cyan)
- Secondary Text: `rgba(122, 155, 192, 0.7)` (muted blue 70%)
- Tertiary Text: `rgba(74, 96, 128, 0.5)` (dark blue 50%)
- Success: `#00ff88` (neon green)

**Gradient Definitions:**
1. **Background Gradient:**
   - Type: Linear gradient
   - Angle: 135deg
   - Stops: `#0a0e27` 0%, `#16213e` 100%

2. **Brand Gradient (Cyan→Pink→Red):**
   - Type: Linear gradient
   - Angle: 135deg
   - Stops: `#60efff` 0%, `#ff6b9d` 50%, `#ff3366` 100%
   - Usage: Logo text, buttons, accents

3. **Radial Glow (Background):**
   - Type: Radial gradient
   - Center: 50% 50%
   - Stops: `rgba(96, 239, 255, 0.15)` 0%, `rgba(255, 107, 157, 0.1)` 40%, `rgba(255, 51, 102, 0.05)` 70%, `rgba(10, 14, 26, 0)` 100%

### Typography

**Font Family:** JetBrains Mono
- **Weight 400:** Regular (body text)
- **Weight 600:** Semibold (buttons, labels)
- **Weight 700:** Bold (headers)
- **Weight 800:** Extrabold (logo, hero text)

**Type Scale:**

| Element | Size | Weight | Line Height | Letter Spacing | Color |
|---------|------|--------|-------------|----------------|-------|
| Status Bar Time | 14px | 400 | 1.2 | 0px | #60efff |
| Status Bar Icons | 14px | 400 | 1.2 | 0px | #60efff |
| Header Title | 18px | 700 | 1.2 | 0.5px | Gradient |
| Connection Status | 11px | 400 | 1.2 | 0.5px | #00ff88 |
| Terminal Prompt | 12px | 400 | 1.4 | 0.3px | #ff6b9d 70% |
| Logo Text | 72px | 800 | 1.0 | -2px | Gradient |
| Logo Symbols | 14px | 400 | 1.4 | 4px | #60efff |
| Welcome Title | 24px | 600 | 1.2 | 1px | Gradient |
| Subtitle | 14px | 400 | 1.7 | 0.3px | #7a9bc0 70% |
| Command Hint | 12px | 400 | 1.4 | 0.3px | #60efff 50% |
| Feature Card Title | 14px | 600 | 1.4 | 0.3px | #60efff |
| Feature Card Desc | 12px | 400 | 1.5 | 0.2px | #7a9bc0 70% |
| Input Placeholder | 15px | 400 | 1.4 | 0.3px | #4a6080 |
| Input Text | 15px | 400 | 1.4 | 0.3px | #60efff |

### Spacing System (8pt Grid)

**Base Unit:** 8px

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight spacing, icon gaps |
| sm | 8px | Component internal padding |
| md | 12px | Card gaps, moderate spacing |
| lg | 16px | Section padding |
| xl | 20px | Page margins |
| 2xl | 24px | Major sections |
| 3xl | 32px | Large gaps |
| 4xl | 40px | Hero spacing |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| sm | 8px | Small elements |
| md | 12px | Cards, inputs |
| lg | 16px | Large cards |
| xl | 20px | Modals |
| full | 999px | Circular (buttons, dots) |

### Shadows & Glows

**Text Glow (Cyan):**
- `0 0 8px rgba(96, 239, 255, 0.6)`
- Applied to: Cyan text elements

**Text Glow (Pink):**
- `0 0 8px rgba(255, 107, 157, 0.4)`
- Applied to: Pink text elements

**Button Glow:**
- `0 0 12px rgba(96, 239, 255, 0.4)`
- Applied to: Send button

**Card Shadow:**
- `0 4px 12px rgba(0, 0, 0, 0.3)`
- Applied to: Elevated cards

## Artboard Layout (393×852px)

### 1. Status Bar (0, 0, 393×54)
**Background:** Transparent (shows through from main background)
**Height:** 54px

**Components:**
- **Time (24, 38, auto×16)**
  - Text: "9:41"
  - Font: JetBrains Mono 14px Regular
  - Color: #60efff
  - Align: Left

- **Icons (Right aligned at 24, 38)**
  - Spacing: 8px between icons
  - Font: System emoji or icons
  - Size: 14px
  - Icons: 📶 📡 🔋
  - Color: #60efff

### 2. Header (0, 54, 393×60)
**Background:** `rgba(10, 14, 26, 0.8)` with `backdrop-filter: blur(10px)`
**Border Bottom:** 2px solid `#1a2332`
**Height:** 60px
**Padding:** 12px 20px

**Components:**

**A. App Title (20, 66, auto×24)**
- Text: "BuilderOS"
- Font: JetBrains Mono 18px Bold
- Background Clip: Gradient (Cyan→Pink→Red)
- Letter Spacing: 0.5px
- Glow: 0 0 8px rgba(96, 239, 255, 0.6)

**B. Connection Status (Right aligned, 66, auto×24)**
- Container: Flex row, gap 6px
- Dot (8×8px):
  - Background: #00ff88
  - Border Radius: 50%
  - Glow: 0 0 8px #00ff88
  - Animation: Pulse (opacity 1→0.5→1 over 2s, infinite)
- Text:
  - Content: "CONNECTED"
  - Font: JetBrains Mono 11px Regular
  - Color: #00ff88
  - Letter Spacing: 0.5px
  - Transform: uppercase

**C. Terminal Prompt (20, 94, 100%, 18px)**
- Text: "~/mobile/home $"
- Font: JetBrains Mono 12px Regular
- Color: #ff6b9d
- Opacity: 70%
- Letter Spacing: 0.3px

### 3. Main Content Area (0, 114, 393×660)

**Background Effects (layered from bottom to top):**

**Layer 1 - Base Gradient:**
- Linear Gradient: 135deg, #0a0e27 → #16213e

**Layer 2 - Radial Glow:**
- Radial gradient centered at 50% 40%
- Stops: cyan 15% → pink 10% → red 5% → transparent
- Opacity: varies by stop

**Layer 3 - Scanlines:**
- Repeating linear gradient: 0deg
- Pattern: `rgba(0,0,0,0.1) 0px, transparent 1px, transparent 2px, rgba(0,0,0,0.1) 3px`
- Opacity: 30%

**Content (Centered vertically and horizontally):**

**A. Logo Container (Center, Top: 200px)**
- Size: 100×100px
- Background: `rgba(10, 14, 26, 0.8)`
- Border: 2px solid (Gradient: Cyan→Pink→Red)
- Border Radius: 16px
- Shadows:
  - Outer: 0 0 20px rgba(96, 239, 255, 0.3), 0 0 40px rgba(255, 107, 157, 0.2)
  - Inner: inset 0 0 20px rgba(96, 239, 255, 0.1)

**Logo Elements:**
- Main Text: "B//OS"
  - Font: JetBrains Mono 48px Extrabold
  - Background Clip: Gradient (Cyan→Pink→Red)
  - Letter Spacing: -2px
  - Centered

- Top-left Symbol: ">"
  - Position: 8px from top, 8px from left
  - Font: JetBrains Mono 16px Bold
  - Color: #60efff

- Bottom-right Symbol: "_"
  - Position: 8px from bottom, 8px from right
  - Font: JetBrains Mono 20px Bold
  - Color: #ff6b9d
  - Animation: Blink (opacity 1→0 every 1s)

**B. Logo Symbols Line (Below logo, 12px gap)**
- Text: "{ $ _ > }"
- Font: JetBrains Mono 14px Regular
- Color: #60efff
- Letter Spacing: 4px
- Centered

**C. Welcome Title (Below symbols, 24px gap)**
- Text: "$ Welcome to BuilderOS_"
- Font: JetBrains Mono 24px Semibold
- Background Clip: Gradient (Cyan→Pink→Red)
- Letter Spacing: 1px
- Centered
- Note: "_" has blinking animation

**D. Subtitle Lines (Below title, 12px gap)**
- Container: Centered text block, max-width 280px

Line 1:
- Text: "// Your mobile command center."
- Font: JetBrains Mono 14px Regular
- Color: #7a9bc0
- Opacity: 70%

Line 2 (4px below):
- Text: "// Build anything, anywhere."
- Font: JetBrains Mono 14px Regular
- Color: #7a9bc0
- Opacity: 70%

**E. Command Hint (Below subtitles, 20px gap)**
- Text: "> Try a command or explore features below"
- Font: JetBrains Mono 12px Regular
- Color: #60efff
- Opacity: 50%
- Letter Spacing: 0.3px
- Centered

**F. Feature Grid (Below hint, 24px gap)**
- Layout: 2 columns × 2 rows
- Gap: 12px
- Total width: 353px (centered)
- Card size: ~170×100px

**Feature Card Template:**
- Background: `rgba(26, 35, 50, 0.6)`
- Border: 1px solid `#2a3f5f`
- Border Radius: 12px
- Padding: 16px
- Backdrop Filter: blur(10px)
- Hover: Glow effect

**Card 1: Ask Jarvis**
- Icon: "🤖" (28px emoji)
- Title: "Ask Jarvis"
  - Font: JetBrains Mono 14px Semibold
  - Color: #60efff
- Description: "Your AI assistant is ready"
  - Font: JetBrains Mono 12px Regular
  - Color: #7a9bc0 70%

**Card 2: Capsules**
- Icon: "📦"
- Title: "Capsules"
- Description: "View active projects"

**Card 3: Quick Actions**
- Icon: "⚡"
- Title: "Quick Actions"
- Description: "Common workflows"

**Card 4: Notifications**
- Icon: "🔔"
- Title: "Notifications"
- Description: "System status & alerts"

### 4. Input Bar (0, 774, 393×78)

**Background:** `rgba(10, 14, 26, 0.95)` with `backdrop-filter: blur(10px)`
**Border Top:** 2px solid `#1a2332`
**Padding:** 12px 16px 34px (extra bottom for home indicator)

**Layout:** Flex row, gap 8px, align center

**A. Quick Action Button (Left, 16px from edge)**
- Size: 36×36px
- Background: Linear gradient (Cyan→Pink→Red)
- Border Radius: 18px (circular)
- Icon: "⚡" (18px centered)
- Color: white
- Glow: 0 0 12px rgba(96, 239, 255, 0.4)
- Active state: Scale 0.92

**B. Input Field (Flex 1, between buttons)**
- Height: 36px
- Background: `rgba(26, 35, 50, 0.6)`
- Border: 1px solid `#2a3f5f`
- Border Radius: 20px
- Padding: 10px 16px
- Font: JetBrains Mono 15px Regular
- Text Color: #60efff
- Placeholder: "Ask Jarvis..." (#4a6080)
- Letter Spacing: 0.3px

**C. Send Button (Right, 16px from edge)**
- Size: 36×36px
- Background: Linear gradient (Pink→Red, 135deg #ff6b9d→#ff3366)
- Border Radius: 18px (circular)
- Icon: "↑" (18px centered)
- Color: white
- Glow: 0 0 12px rgba(255, 107, 157, 0.4)
- Active state: Scale 0.92

### 5. Home Indicator Area (Bottom 34px)
**Visual:** iOS system home indicator (white bar, centered)
**Note:** Don't overlay important UI here

## Animations

### 1. Blinking Cursor
- **Element:** Terminal cursor underscore "_"
- **Animation:**
  - Duration: 1s
  - Iteration: infinite
  - Keyframes:
    - 0-50%: opacity 1
    - 51-100%: opacity 0

### 2. Pulsing Connection Dot
- **Element:** Green connection status dot
- **Animation:**
  - Duration: 2s
  - Iteration: infinite
  - Easing: ease-in-out
  - Keyframes:
    - 0%: opacity 1
    - 50%: opacity 0.5
    - 100%: opacity 1

### 3. Gradient Pulse (Background)
- **Element:** Radial glow layer
- **Animation:**
  - Duration: 8s
  - Iteration: infinite
  - Easing: ease-in-out
  - Keyframes:
    - 0%: scale 1, opacity 0.8
    - 50%: scale 1.2, opacity 1
    - 100%: scale 1, opacity 0.8

### 4. Button Press
- **Elements:** Quick action button, send button
- **Animation:**
  - Trigger: Active/press state
  - Transform: scale(0.92)
  - Duration: 150ms
  - Easing: ease-out

### 5. Scanlines (Static Effect)
- **Element:** Overlay repeating gradient
- **Animation:** None (static effect)
- **Opacity:** 30%

## Component Library (Reusable Components)

### 1. Terminal Header Component
- **Inputs:** Title text, connection status (boolean)
- **Size:** 393×60px
- **Variants:** Connected, Disconnected

### 2. Feature Card Component
- **Inputs:** Icon (emoji), title (string), description (string)
- **Size:** ~170×100px
- **States:** Default, Hover, Active

### 3. Input Bar Component
- **Inputs:** Placeholder text, button states
- **Size:** 393×78px
- **Variants:** Default, Focused

### 4. Terminal Logo Component
- **Size:** 100×100px
- **Includes:** Border, glows, symbols, animations

### 5. Status Bar Component
- **Size:** 393×54px
- **Inputs:** Time, signal icons

## Effects & Filters

### Glassmorphism
- **Background:** Semi-transparent dark color
- **Backdrop Filter:** blur(10px)
- **Border:** 1px solid lighter color
- **Usage:** Cards, input fields, header

### Text Gradient Clip
- **Gradient:** Linear 135deg Cyan→Pink→Red
- **-webkit-background-clip:** text
- **-webkit-text-fill-color:** transparent
- **Usage:** Logo, titles, headers

### Glow Effects
- **Cyan Glow:** 0 0 8px rgba(96, 239, 255, 0.6)
- **Pink Glow:** 0 0 8px rgba(255, 107, 157, 0.4)
- **Green Glow:** 0 0 8px rgba(0, 255, 136, 1)
- **Usage:** Text, icons, buttons

### CRT Scanlines
- **Pattern:** Repeating horizontal lines (3px repeat)
- **Opacity:** 30%
- **Usage:** Overlay on main content area

## Penpot Import Instructions

### Method 1: Manual Recreation in Penpot

1. **Create New Project:**
   - Name: "BuilderOS Mobile - Terminal UI"
   - Set workspace to iPhone dimensions

2. **Create Artboard:**
   - Width: 393px
   - Height: 852px
   - Name: "Home Screen - Terminal"

3. **Set Up Color Palette:**
   - Add all colors from the palette section
   - Create gradient swatches (Cyan→Pink→Red)
   - Save as reusable styles

4. **Set Up Typography:**
   - Import JetBrains Mono font (or use system monospace)
   - Create text styles for each size/weight combination
   - Save as reusable text styles

5. **Build Components (Bottom-Up):**
   - Start with smallest components (icons, buttons)
   - Build up to cards, header, input bar
   - Create component library for reuse

6. **Layer Structure (Top to Bottom):**
   - Status Bar (layer 1)
   - Header (layer 2)
   - Main Content:
     - Background gradient (layer 3a)
     - Radial glow (layer 3b)
     - Scanlines overlay (layer 3c)
     - Content elements (layer 3d)
   - Input Bar (layer 4)

7. **Add Interactions:**
   - Prototype blinking cursor (if Penpot supports)
   - Prototype pulsing dot animation
   - Add button active states

### Method 2: Import from SVG/HTML

If Penpot supports HTML/SVG import:

1. Use the `mobile-app-preview.html` file
2. Extract the "Empty State" screen (terminal mode enabled)
3. Take high-res screenshot or export SVG
4. Import into Penpot as reference layer
5. Trace over with native Penpot elements
6. Replace placeholder content with real design tokens

### Method 3: Use Figma-to-Penpot Plugin

If migrating from Figma:

1. Create design in Figma Community first
2. Use Figma-to-Penpot export plugin
3. Import .penpot file
4. Verify gradient and effect translations
5. Adjust any broken effects manually

## Design Tokens Export

For developer handoff, export these tokens as JSON or CSS variables:

```json
{
  "colors": {
    "cyan": "#60efff",
    "pink": "#ff6b9d",
    "red": "#ff3366",
    "bg-dark": "#0a0e27",
    "bg-darker": "#16213e",
    "success": "#00ff88"
  },
  "typography": {
    "family": "JetBrains Mono",
    "sizes": {
      "xs": "11px",
      "sm": "12px",
      "base": "14px",
      "lg": "18px",
      "xl": "24px",
      "2xl": "48px",
      "3xl": "72px"
    }
  },
  "spacing": {
    "xs": "4px",
    "sm": "8px",
    "md": "12px",
    "lg": "16px",
    "xl": "20px",
    "2xl": "24px"
  }
}
```

## Implementation Notes

- **Font Loading:** Ensure JetBrains Mono is bundled with app or fallback to SF Mono
- **Gradients:** Use iOS CAGradientLayer or SwiftUI LinearGradient
- **Blur Effects:** Use UIVisualEffectView for glassmorphism
- **Animations:** Implement with SwiftUI animations or UIView.animate
- **Responsive:** Design is for iPhone 14/15 (393×852), scale for other sizes
- **Dark Mode Only:** This design is dark mode exclusive (no light variant needed)
- **Performance:** Consider reducing blur/glow effects on older devices

## Accessibility Considerations

- **Contrast Ratios:** Verify text meets WCAG AA (4.5:1 minimum)
- **Dynamic Type:** Support iOS Dynamic Type scaling
- **VoiceOver:** Ensure all interactive elements have labels
- **Reduce Motion:** Provide non-animated fallback for animations
- **Color Blind:** Don't rely solely on color for status (use icons + text)

## Version History

- **v1.0 (2025-10-22):** Initial design specification based on approved HTML preview

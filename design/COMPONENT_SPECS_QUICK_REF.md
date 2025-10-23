# BuilderOS Mobile - Component Specifications Quick Reference

**Quick lookup for Penpot component creation**

---

## Artboard Specifications

| Screen | Width | Height | Device |
|--------|-------|--------|--------|
| iPhone 15 Pro | 393px | 852px | All main screens |
| Design System Pages | 800-1200px | 2000-3000px | Freeform |

---

## Color Palette (Hex Values)

### Brand Colors
```
Primary Blue:     #007AFF
Secondary Purple: #5856D6
Tailscale Accent: #598FFF
```

### Status Colors
```
Success Green:    #34C759
Warning Orange:   #FF9500
Error Red:        #FF3B30
Info Blue:        #007AFF
```

### Semantic Light Mode
```
Text Primary:     #1D1D1F
Text Secondary:   #6E6E73
BG Primary:       #FFFFFF
BG Secondary:     #F5F5F7
BG Tertiary:      #FFFFFF
Divider:          #E5E5E7
```

### Semantic Dark Mode
```
Text Primary:     #FFFFFF
Text Secondary:   #A0A0A5
BG Primary:       #000000
BG Secondary:     #1C1C1E
BG Tertiary:      #2C2C2E
Divider:          #38383A
```

---

## Typography Scale

| Style | Size | Weight | Line Height | Font |
|-------|------|--------|-------------|------|
| Display Large | 57px | Bold (700) | 1.05 (60px) | SF Pro Rounded |
| Display Medium | 45px | Bold (700) | 1.1 (50px) | SF Pro Rounded |
| Display Small | 36px | Bold (700) | 1.15 (41px) | SF Pro Rounded |
| Headline Large | 32px | Semibold (600) | 1.15 (37px) | SF Pro Rounded |
| Headline Medium | 28px | Semibold (600) | 1.2 (34px) | SF Pro Rounded |
| Title Large | 22px | Semibold (600) | 1.2 (26px) | SF Pro |
| Title Medium | 16px | Semibold (600) | 1.3 (21px) | SF Pro |
| Body Large | 16px | Regular (400) | 1.4 (22px) | SF Pro |
| Body Medium | 14px | Regular (400) | 1.4 (20px) | SF Pro |
| Label Medium | 12px | Medium (500) | 1.3 (16px) | SF Pro |
| Monospaced Medium | 14px | Regular (400) | 1.5 (21px) | SF Mono |

**Font Fallbacks:**
- SF Pro → Inter
- SF Pro Rounded → Inter Bold
- SF Mono → Fira Code or JetBrains Mono

---

## Spacing System (8pt Grid)

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Minimal spacing, tight groups |
| sm | 8px | Small spacing, related elements |
| md | 12px | Compact spacing |
| base | 16px | Default spacing, card padding |
| lg | 24px | Large spacing, section dividers |
| xl | 32px | Extra large spacing |
| xxl | 48px | Major section breaks |

---

## Corner Radius

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Minimal rounding |
| sm | 8px | Small elements (badges, tags) |
| md | 12px | Default (buttons, cards) |
| lg | 16px | Large cards |
| xl | 20px | Extra large surfaces |
| circle | 50% | Circular elements |

---

## Touch Targets

| Size | Value | Usage |
|------|-------|-------|
| Minimum | 44pt | Apple HIG requirement |
| Comfortable | 48pt | Recommended for primary actions |
| Large | 56pt | Important interactive elements |

---

## Component Specifications

### Buttons

#### Primary Button
```
Size: 160x48 px (auto-width in practice)
Background: #007AFF
Text: White, 16px, Semibold, SF Pro
Padding: 12px vertical, 24px horizontal
Border Radius: 12px
Shadow: None (iOS standard)

States:
- Default: #007AFF
- Pressed: #0051D5, scale 0.98
- Disabled: #E5E5E7 bg, #86868B text
```

#### Secondary Button
```
Size: 160x48 px
Background: rgba(0, 122, 255, 0.1)
Text: #007AFF, 16px, Semibold
Padding: 12px vertical, 24px horizontal
Border Radius: 12px

States:
- Default: Light blue bg
- Pressed: #E5E5E7 bg, scale 0.98
```

#### Destructive Button
```
Size: 160x48 px
Background: #FF3B30
Text: White, 16px, Semibold
Padding: 12px vertical, 24px horizontal
Border Radius: 12px
```

#### Icon Button (Voice)
```
Size: 64x64 px
Background: #007AFF
Icon: 32px, White, centered
Border Radius: 32px (circle)
Shadow: 0 4px 12px rgba(0, 122, 255, 0.3)
```

---

### Status Badges

#### Active Badge
```
Height: 28px, Auto-width
Background: rgba(52, 199, 89, 0.1)
Border Radius: 8px
Padding: 6px vertical, 12px horizontal

Content:
- Dot: 8px circle, #34C759
- Text: "Active", 13px, Semibold, #34C759
- Gap: 6px between dot and text
```

#### Development Badge
```
Height: 28px
Background: rgba(0, 122, 255, 0.1)
Border Radius: 8px
Dot: 8px, #007AFF
Text: "Development", 13px, Semibold, #007AFF
```

#### Testing Badge
```
Height: 28px
Background: rgba(255, 149, 0, 0.1)
Border Radius: 8px
Dot: 8px, #FF9500
Text: "Testing", 13px, Semibold, #FF9500
```

#### Error Badge
```
Height: 28px
Background: rgba(255, 59, 48, 0.1)
Border Radius: 8px
Dot: 8px, #FF3B30
Text: "Error", 13px, Semibold, #FF3B30
```

---

### Cards

#### Standard Card
```
Size: 343x200 px (width: full - 48px margins)
Background: #FFFFFF (Light) / #1C1C1E (Dark)
Border Radius: 16px
Padding: 20px all sides
Shadow: 0 2px 8px rgba(0, 0, 0, 0.04)

States:
- Default: White bg
- Pressed: #F5F5F7 bg, scale 0.98 (if tappable)
```

#### Capsule Card (Grid Item)
```
Size: 163.5x140 px (2-column grid)
Background: #FFFFFF
Border Radius: 16px
Padding: 16px
Shadow: 0 2px 8px rgba(0, 0, 0, 0.04)

Layout (vertical stack):
1. Status badge (top)
2. Name: 15px, Semibold, 8px margin top
3. Description: 12px, Text Secondary, 2 lines max, 8px margin top
4. Tags: 11px pills, 12px margin top
```

#### Stat Card (Grid Item)
```
Size: 165.5x100 px (2x2 grid)
Background: #FFFFFF
Border Radius: 12px
Padding: 16px
Shadow: 0 2px 8px rgba(0, 0, 0, 0.04)

Layout:
1. Icon: 40px circle, colored bg, top-left
2. Value: 24px, Bold, below icon
3. Label: 13px, Text Secondary, below value
```

---

### Form Elements

#### Text Input
```
Size: 343x48 px (full width)
Background: #F5F5F7
Border: 2px solid transparent
Border Radius: 10px
Padding: 14px vertical, 16px horizontal
Font: 15px, SF Pro (or SF Mono for codes)

States:
- Default: Gray bg, no border
- Focus: White bg, #007AFF border
- Error: White bg, #FF3B30 border
```

#### Toggle Switch (iOS)
```
Size: 51x31 px
Border Radius: 16px (pill)

Off State:
- Background: #E5E5E7
- Knob: 27px circle, white, left (2px offset)
- Shadow: 0 2px 4px rgba(0, 0, 0, 0.1)

On State:
- Background: #34C759
- Knob: Translated 20px to right
- Animation: 0.3s ease
```

#### Secure Field (Password)
```
Same as Text Input
Placeholder: "••••••••"
Optional "Show" button: 44pt touch target, right-aligned
```

---

### Message Bubbles

#### User Message (Right)
```
Max Width: 75% screen (280px)
Background: #007AFF
Border Radius: 20px (with 4px radius bottom-right for "tail")
Text: White, 15px, SF Pro
Padding: 12px vertical, 16px horizontal
Alignment: Right
```

#### System Message (Left)
```
Max Width: 75% screen
Background: #FFFFFF (Light) / #2C2C2E (Dark)
Border Radius: 20px (with 4px radius bottom-left)
Text: #1D1D1F (Light) / #FFFFFF (Dark), 15px
Padding: 12px vertical, 16px horizontal
Shadow: 0 1px 3px rgba(0, 0, 0, 0.06)
Alignment: Left
```

#### Code Block (in message)
```
Background: rgba(0, 0, 0, 0.05) in system messages
Background: rgba(255, 255, 255, 0.2) in user messages
Font: SF Mono, 13px
Padding: 8px vertical, 12px horizontal
Border Radius: 8px
Horizontal scroll if needed
```

#### Status Message (Centered)
```
Max Width: 80% screen
Background: rgba(0, 122, 255, 0.1)
Text: #007AFF, 13px
Padding: 8px vertical, 16px horizontal
Border Radius: 12px
Alignment: Center
```

---

### Connection Status Indicator

#### Connected (Green)
```
Height: 60px, Auto-width
Background: rgba(52, 199, 89, 0.1)
Border Radius: 12px
Padding: 12px

Layout:
1. Dot: 12px circle, #34C759
2. Text: "Connected", 15px, Semibold, #34C759
3. IP: "100.66.202.6", 13px, SF Mono, Text Secondary
```

#### Connecting (Orange)
```
Same as Connected but:
- Dot: 12px, #FF9500
- Dot Animation: Opacity 1 → 0.5 → 1, 2s loop
- Text: "Connecting...", #FF9500
- Subtext: Status message
```

#### Disconnected (Red)
```
Same layout:
- Dot: 12px, #FF3B30
- Text: "Disconnected", #FF3B30
- Subtext: Error message
```

---

### Tab Bar

#### Tab Bar Container
```
Size: 393x83 px (full width, includes safe area)
Background: rgba(255, 255, 255, 0.95) with blur
Border Top: 0.5px solid rgba(0, 0, 0, 0.05)
Layout: Flexbox row, 4 items, evenly spaced
```

#### Tab Item (Active)
```
Icon: 28px SF Symbol
Icon Color: #007AFF
Label: 10px, Medium, #007AFF
Spacing: 4px between icon and label
Touch Target: 44pt vertical minimum
```

#### Tab Item (Inactive)
```
Icon: 28px, #8E8E93
Label: 10px, Medium, #8E8E93
```

**4 Tabs:**
1. Dashboard - 📊 (chart.bar.fill)
2. Chat - 💬 (message.fill)
3. Preview - 🔍 (safari.fill)
4. Settings - ⚙️ (gearshape.fill)

---

## Shadows

| Component | Shadow |
|-----------|--------|
| Cards | 0 2px 8px rgba(0, 0, 0, 0.04) |
| Icon Buttons | 0 4px 12px rgba(0, 122, 255, 0.3) |
| System Messages | 0 1px 3px rgba(0, 0, 0, 0.06) |
| Knob (Toggle) | 0 2px 4px rgba(0, 0, 0, 0.1) |

---

## Animation Timing

| Type | Duration | Easing |
|------|----------|--------|
| Button Press | 0.15s | Ease out |
| Screen Transition | 0.3s | iOS spring |
| Toggle Switch | 0.3s | Ease |
| Loading Spinner | 1.5s | Linear, infinite |
| Pulsing Dot | 2s | Ease-in-out, infinite |

---

## Grid Layouts

### Stats Grid (2x2)
```
Columns: 2
Rows: 2
Column Gap: 12px
Row Gap: 12px
Container Width: 343px (screen width - 48px margins)
Cell Size: 165.5x100 px
```

### Capsule Grid (2 columns)
```
Columns: 2
Column Gap: 16px
Row Gap: 16px
Container Width: 343px
Cell Size: 163.5x140 px
```

---

## Screen Margins

| Element | Margin |
|---------|--------|
| Screen horizontal padding | 24px |
| Section vertical spacing | 24px |
| Card internal padding | 16px or 20px |
| Header top (safe area) | 24px |
| Bottom (above tab bar) | 120px |

---

## iPhone 15 Pro Safe Areas

| Area | Measurement |
|------|-------------|
| Screen Size | 393x852 pt |
| Top Safe Area | ~47pt |
| Bottom Safe Area | ~34pt |
| Tab Bar Height | 83pt (includes safe area) |
| Navigation Bar Height | 96pt (large title) |

---

## Penpot-Specific Notes

### Creating Color Library
1. Create rectangle with color
2. Right-click fill → "Add to library"
3. Name: "Brand/Primary" (use hierarchical naming)

### Creating Typography Library
1. Create text with style
2. Right-click → "Add text style to library"
3. Name: "iOS/Body Large"

### Creating Components
1. Select elements to group
2. Right-click → "Create component"
3. Name: "Button/Primary"
4. Duplicate for variants (Button/Primary/Pressed)

### Using Auto-Layout (Flexbox/Grid)
1. Select frame
2. Right panel → Layout → Enable flex/grid
3. Set direction, gap, alignment
4. Add padding

---

## Quick Copy-Paste Values

**Common Sizes:**
```
Button: 48h, 12v 24h padding, 12px radius
Badge: 28h, 6v 12h padding, 8px radius
Card: 16px radius, 16-20px padding
Input: 48h, 14v 16h padding, 10px radius
Icon Button: 44-64px circle
```

**Common Colors:**
```
Primary: #007AFF
Success: #34C759
Warning: #FF9500
Error: #FF3B30
Gray BG: #F5F5F7
White: #FFFFFF
Black: #000000
```

**Common Fonts:**
```
Heading: SF Pro Rounded, 28-57px, Bold
Title: SF Pro, 16-22px, Semibold
Body: SF Pro, 14-16px, Regular
Code: SF Mono, 13-14px, Regular
```

---

**Created:** October 2025
**Reference:** `/design/DESIGN_DOCUMENTATION.md` for complete specs
**Penpot Guide:** `/design/PENPOT_PROJECT_GUIDE.md` for step-by-step instructions

# Terminal Aesthetic Redesign - Empty State Screen

## Overview
Redesigned the Empty State screen (home screen) with a terminal/command-line aesthetic featuring JetBrains Mono font and shapedream.co-inspired gradient colors (blue → rose → red).

## Design Features

### Typography
- **Font Family:** JetBrains Mono (Google Fonts)
- **Weights Used:** 400, 500, 600, 700, 800
- **Monospace styling** throughout terminal mode for authentic code editor feel

### Color Palette (Terminal Mode)
**Background:**
- Base: `#0a0e1a` (deep navy, terminal-like)
- Header/Input overlay: `rgba(10, 14, 26, 0.8)` with backdrop blur

**Accent Colors (Blue → Rose → Red Gradients):**
- Primary Blue: `#60efff` (electric cyan)
- Rose/Pink: `#ff6b9d`
- Red: `#ff3366`
- Success Green: `#00ff88` (connection status)
- Muted Blue-Gray: `#7a9bc0` (subtitle text)

**Gradients Applied:**
1. **Builder Logo Border:** `linear-gradient(135deg, #60efff 0%, #ff6b9d 50%, #ff3366 100%)`
2. **Title Text:** Same gradient with `-webkit-background-clip: text`
3. **Send Button:** Same gradient with glow effect
4. **Radial Background:** Pulsing gradient sphere for depth
   - Center: `rgba(96, 239, 255, 0.2)`
   - Middle: `rgba(255, 107, 157, 0.15)`
   - Outer: `rgba(255, 51, 102, 0.1)`

### Terminal UI Elements

**Builder Logo (100x100px):**
- Dark semi-transparent background with gradient border
- Terminal prompt symbol `>` in top-left (cyan)
- Blinking cursor `_` in bottom-right (rose)
- Glowing box-shadow effects
- Emoji: 🏗️

**Title:**
- `$ BUILDEROS` (uppercase, gradient text)
- Terminal prompt prefix `$` in green (`#00ff88`)
- Letter-spacing: 1px for dramatic effect

**Subtitle:**
- Comment-style prefix `// ` in muted blue
- Monospace font for consistency
- Max-width: 280px for readability

**Header:**
- Translucent dark overlay with blur
- JetBrains Mono for "BuilderOS" title (cyan)
- Connection status with glowing green dot

**Status Bar:**
- JetBrains Mono font
- Cyan text color (`#60efff`)
- Reduced font size (13px)

**Input Bar:**
- Dark translucent background with blur
- Input field: Semi-transparent with subtle border
- Placeholder: `$ _` (terminal prompt style)
- Send button: Gradient with cyan glow

### Visual Effects

**Radial Gradient Background:**
- Animated pulsing effect (8s cycle)
- Smooth scale transformation (1.0 → 1.2)
- Blur filter (60px) for soft glow

**Scanlines Effect:**
- Subtle CRT-style scanlines overlay
- Repeating linear gradient (3px intervals)
- 30% opacity for authenticity without distraction

**Glowing Elements:**
- Connection status dot: Green glow (`box-shadow: 0 0 8px #00ff88`)
- Builder logo: Multi-layer cyan/rose glow
- Send button: Cyan glow on gradient

**Blinking Cursor:**
- Underscore `_` in builder logo
- 1s blink animation (50% duty cycle)
- Rose color (`#ff6b9d`)

## Technical Implementation

### Activation
Terminal mode activates when dark mode is toggled. The design uses a `.terminal-mode` class applied to `.screen-content` element.

### CSS Structure
- Base styles remain unchanged for light mode
- Terminal-specific styles scoped with `.terminal-mode` selector
- All terminal typography uses `font-family: 'JetBrains Mono', monospace`

### JavaScript Integration
```javascript
function toggleTheme() {
    isDark = !isDark;
    const deviceFrame = document.getElementById('deviceFrame');
    const screenContent = document.getElementById('screenContent');

    if (isDark) {
        deviceFrame.classList.add('dark');
        screenContent.classList.add('terminal-mode');
    } else {
        deviceFrame.classList.remove('dark');
        screenContent.classList.remove('terminal-mode');
    }
}
```

### Compatibility
- iOS 17+ (target platform)
- 393x852px iPhone frame maintained
- All existing screen toggle functionality preserved
- Google Fonts CDN for JetBrains Mono (preconnect optimization)

## File Locations
- **Main Design File:** `/Users/Ty/BuilderOS/capsules/builder-system-mobile/docs/design/mobile-app-preview.html`
- **Verification Screenshots:** `/Users/Ty/BuilderOS/.playwright-mcp/terminal-empty-state-*.png`

## Design Verification
Visual verification completed using Playwright MCP:
- ✅ JetBrains Mono font loads correctly
- ✅ Blue → rose → red gradients render as expected
- ✅ Terminal aesthetic (dark background, monospace, glowing elements)
- ✅ Screen toggle functionality maintained
- ✅ iOS frame (393x852) preserved
- ✅ Animations working (pulsing gradient, blinking cursor)
- ✅ All terminal UI elements (prompt symbols, comment prefixes) display correctly

## Future Enhancements
Potential additions for production implementation:
- Typing animation for title reveal
- Terminal command autocomplete UI
- Console-style message history
- Customizable color themes (different gradient sets)
- Terminal sound effects (optional haptic feedback)
- Matrix-style text rain background (subtle)

---

**Design Completed:** October 22, 2025
**Status:** Ready for Swift/SwiftUI implementation
**Next Step:** Hand off to 📱 Mobile Dev for iOS implementation

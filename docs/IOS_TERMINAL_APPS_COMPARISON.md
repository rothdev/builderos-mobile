# iOS Terminal Apps: Quick Comparison Table

**Research Date:** 2025-10-24

## Summary Table

| App Name | GitHub Link | Stars | Architecture | Keyboard Solution | Key Libraries | Mobile UX Patterns | Status |
|----------|-------------|-------|--------------|-------------------|---------------|-------------------|--------|
| **Blink Shell** | [blinksh/blink](https://github.com/blinksh/blink) | 6,431 | PTY Emulator + SSH/Mosh | **SmartKeys** custom toolbar with Ctrl/Alt/Esc/Arrows, continuous modifier presses, external keyboard mapping | HTerm (Chromium), Mosh protocol | Two-finger tap (new shell), swipe (switch), pinch (zoom), 3-finger (menu), slide-down (close), SplitView | ✅ Active |
| **SwiftTermApp** | [migueldeicaza/SwiftTermApp](https://github.com/migueldeicaza/SwiftTermApp) | 340 | PTY Emulator + SSH | Custom **TerminalAccessory** view (36pt iPhone, 48pt iPad), UIKeyInput protocol, international input support | **SwiftTerm** (VT100/Xterm), SwiftSH, Metal shaders | Themable UI, Metal effects, settings UI, international dictation, 120 FPS ProMotion | ⚠️ Sample code only |
| **a-Shell** | [holzschu/a-shell](https://github.com/holzschu/a-shell) | 3,300 | Local Shell (no PTY) | hterm JavaScript keyboard handling | **hterm** (JavaScript), ios_system framework | Multiple windows (iPad), configurable appearance, VoiceOver, toolbar customization, Shortcuts integration | ✅ Active |
| **NewTerm 3** | [hbang/NewTerm](https://github.com/hbang/NewTerm) | 514 | Local PTY Emulator | Not documented | **Custom rendering** (120 FPS optimized), libiosexec | Unlimited split panes (iPad), 120 FPS ProMotion, 15 FPS Low Power Mode, iTerm2 integration | ✅ Active |
| **OpenTerm** | [louisdh/terminal](https://github.com/louisdh/terminal) | 1,600 | Local Sandboxed CLI | Not documented | 60+ built-in Unix commands | Not documented | ❌ Archived (2019) |

---

## Key Insights

### Architecture Approaches
- ✅ **PTY Emulator + Remote SSH:** Blink, SwiftTermApp (full terminal compatibility, remote access)
- ✅ **PTY Emulator + Local Shell:** NewTerm (offline, responsive, native commands)
- ✅ **Local Shell (no PTY):** a-Shell (simplest, good for basic tasks)
- ❌ **Chat-Style Interface:** Not found in successful open source iOS terminals

### Keyboard Solutions (Universal Pattern)
**All apps use Input Accessory View pattern:**
1. Custom toolbar above iOS keyboard
2. Essential keys: Ctrl, Alt, Esc, Arrows, Tab
3. Typically 36pt (iPhone) or 48pt (iPad) height
4. Optional display with external keyboard

**Best Implementation:** Blink's SmartKeys
- Continuous modifier presses (like physical keyboard)
- External keyboard mapping (Caps → Esc/Ctrl)
- Gesture to hide (two-finger tap)

### Terminal Rendering Libraries

| Library | Type | Language | Apps Using It | Pros | Cons |
|---------|------|----------|---------------|------|------|
| **SwiftTerm** | Native | Swift | SwiftTermApp, La Terminal, Secure Shellfish, CodeEdit | Modern, cross-platform, embeddable, pure Swift | Smaller ecosystem |
| **HTerm** | Web | JavaScript | Blink, a-Shell | Proven (Chromium), perfect rendering, fast | JavaScript dependency |
| **Custom** | Native | Swift | NewTerm | Full control, 120 FPS optimized | More maintenance |

**Recommendation:** SwiftTerm for new iOS terminal projects (native, modern, proven).

### Mobile UX Patterns

**Gestures (Blink - most comprehensive):**
- Two-finger tap → New shell
- Swipe → Switch sessions
- Pinch → Zoom text
- Three-finger tap → Menu
- Slide down → Close

**iPad Features:**
- Split screen / multiple panes (NewTerm, Blink)
- Multiple windows (a-Shell)
- 120 FPS ProMotion rendering (NewTerm, SwiftTermApp)
- Auto-reduce to 15 FPS in Low Power Mode

**Accessibility:**
- VoiceOver support (a-Shell, SwiftTerm)
- Critical for App Store approval

### Connection Management

| Approach | Apps | Use Case | Pros | Cons |
|----------|------|----------|------|------|
| **SSH only** | SwiftTermApp | Standard remote access | Simple, standard protocol | Drops on network changes |
| **SSH + Mosh** | Blink | Mobile-optimized remote | Network resilience, seamless transitions | More complex |
| **WebSocket** | None found | Modern web-based | Firewall traversal, web access | Custom protocol needed |
| **Local only** | a-Shell, NewTerm | Offline work | Fast, no network dependency | Limited to device |

---

## Recommendations for BuilderOS Mobile

### ✅ What to Adopt

1. **Input Accessory View** - Even for chat-style interface
   - Quick command shortcuts
   - Builder System operations
   - Command history navigation

2. **Gesture-Based UX**
   - Swipe for command history
   - Pinch to zoom output
   - Tap for quick actions

3. **Session Persistence**
   - WebSocket reconnection
   - Command history
   - Scroll position

4. **iPad Optimization**
   - Split view support
   - 120 FPS ProMotion
   - Multiple panes

5. **Accessibility**
   - VoiceOver from day one
   - Dynamic type
   - High contrast

### ❌ What to Skip

1. **Full PTY Emulation** - Not needed for WebSocket backend
2. **SSH/Mosh Protocols** - WebSocket is better for Builder System
3. **VT100 Escape Sequences** - Simple styled text sufficient

### 💡 Recommended Approach

**Terminal-Inspired Chat Interface (Hybrid):**

- **UI:** Chat-style bubbles (not terminal emulation)
- **Input:** Custom accessory view with Builder commands
- **Rendering:** SwiftUI Text with syntax highlighting
- **Connection:** WebSocket to Builder System
- **Persistence:** Command history, session state
- **Gestures:** Swipe, pinch, tap
- **Performance:** 120 FPS ProMotion

**Not a terminal emulator - a terminal-inspired UX for Builder System interaction.**

---

## Source Reliability

### Highly Reliable
- ⭐⭐⭐⭐⭐ **Blink** (6.4k stars, commercial backing, active)
- ⭐⭐⭐⭐⭐ **a-Shell** (3.3k stars, widely used, active)
- ⭐⭐⭐⭐⭐ **SwiftTerm** (used by multiple commercial apps)

### Reliable
- ⭐⭐⭐⭐ **NewTerm** (514 stars, modern Swift, active)
- ⭐⭐⭐⭐ **SwiftTermApp** (sample code from library author)

### Historical Only
- ⭐⭐⭐ **OpenTerm** (archived 2019)

---

**For detailed analysis, see:** `/Users/Ty/BuilderOS/capsules/builderos-mobile/docs/IOS_TERMINAL_RESEARCH.md`

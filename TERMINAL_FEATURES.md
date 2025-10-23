# Terminal Features Reference

## Quick Feature Overview

### ✅ **Custom Keyboard Toolbar**

#### Main Row (Always Visible)
```
[F1-12 >] | [ESC] [TAB] [CTRL] | [↑] [↓] [←] [→] | [^C] [^D] [^Z] [^L]
```

- **Toggle:** F1-12 row (collapse/expand)
- **Special Keys:** ESC, TAB, CTRL
- **Arrows:** Navigation and command history
- **Combos:**
  - `^C` (Ctrl+C) - Cancel/SIGINT
  - `^D` (Ctrl+D) - Exit/EOF
  - `^Z` (Ctrl+Z) - Suspend/SIGTSTP
  - `^L` (Ctrl+L) - Clear screen

#### Function Keys Row (Collapsible)
```
[F1] [F2] [F3] [F4] [F5] [F6] [F7] [F8] [F9] [F10] [F11] [F12]
```

### ✅ **ANSI Color Support**

#### Standard 16 Colors
```
Black  Red  Green  Yellow  Blue  Magenta  Cyan  White
(30)   (31)  (32)    (33)   (34)   (35)    (36)  (37)

Bright variants: (90-97)
```

#### 256-Color Mode
- **Codes 0-15:** Standard colors
- **Codes 16-231:** 6×6×6 RGB cube
- **Codes 232-255:** Grayscale ramp

#### Text Attributes
- **Bold** (code 1)
- *Italic* (code 3)
- <u>Underline</u> (code 4)
- Background colors (40-47, 100-107)

### ✅ **WebSocket Protocol**

#### Connection Flow
```
1. iOS → Server: Connect to wss://tunnel-url/api/terminal/ws
2. iOS → Server: API key (text message)
3. Server → iOS: "authenticated" or "error:invalid_api_key"
4. iOS ⟷ Server: Binary messages (terminal I/O)
5. iOS → Server: Resize JSON {"type":"resize","rows":24,"cols":80}
```

#### Auto-Reconnect
```
Attempt 1: Wait 1s
Attempt 2: Wait 2s
Attempt 3: Wait 4s
Attempt 4: Wait 8s
Attempt 5: Wait 16s
Attempt 6+: Wait 30s (max)
```

### ✅ **Terminal Capabilities**

#### Supported Features
- ✅ Command execution with output
- ✅ ANSI color codes (16, 256-color)
- ✅ Bold, italic, underline text
- ✅ Special keys (ESC, Tab, Ctrl+C, etc.)
- ✅ Arrow keys (history, cursor movement)
- ✅ Function keys (F1-F12)
- ✅ Terminal resize (auto-detect)
- ✅ Auto-scroll to bottom
- ✅ Scrollback buffer (1000 lines)
- ✅ Text selection and copy
- ✅ Auto-reconnect on disconnect

#### Not Supported (Limitations)
- ❌ Multiple terminal tabs/splits
- ❌ Copy-on-select (iOS limitation)
- ❌ Complex TUI apps (htop, tmux)
- ❌ File upload to Mac
- ❌ Background session persistence
- ❌ Mouse events

### ✅ **Available Commands**

#### Basic Shell
```bash
cd /path/to/directory    # Change directory
ls -la                   # List files (with colors!)
pwd                      # Print working directory
echo "text"              # Print text
cat file.txt             # Show file contents
grep "pattern" file      # Search in file
find . -name "*.swift"   # Find files
```

#### Git Commands
```bash
git status               # Repository status (colored!)
git log --oneline        # Commit history (colored!)
git diff                 # Show changes (colored!)
git branch               # List branches
git checkout branch      # Switch branch
```

#### BuilderOS Commands
```bash
# Navigation
cd /Users/Ty/BuilderOS
python3 tools/nav.py builder-system-mobile

# Metrics
python3 tools/metrics_rollup.py

# BridgeHub (Codex communication)
node tools/bridgehub/dist/bridgehub.js --help

# Claude Code
claude --version
claude "task description"
```

#### System Commands
```bash
uname -a                 # System info
which command            # Find command path
env                      # Environment variables
date                     # Current date/time
uptime                   # System uptime
top                      # Process monitor (Ctrl+C to exit)
```

### ✅ **Special Key Sequences**

#### Control Characters
- **Ctrl+A** (0x01) - Beginning of line
- **Ctrl+C** (0x03) - SIGINT (cancel)
- **Ctrl+D** (0x04) - EOF (exit)
- **Ctrl+E** (0x05) - End of line
- **Ctrl+K** (0x0B) - Kill to end of line
- **Ctrl+L** (0x0C) - Clear screen
- **Ctrl+R** (0x12) - Reverse search
- **Ctrl+U** (0x15) - Kill to beginning of line
- **Ctrl+W** (0x17) - Delete word
- **Ctrl+Z** (0x1A) - SIGTSTP (suspend)

#### Escape Sequences
- **ESC** - `\x1B` (escape key)
- **Tab** - `\x09` (tab key)
- **Enter** - `\x0A` (newline)
- **Backspace** - `\x7F` (delete)

#### Arrow Keys (ANSI)
- **Up** - `\x1B[A` (previous command)
- **Down** - `\x1B[B` (next command)
- **Right** - `\x1B[C` (cursor right)
- **Left** - `\x1B[D` (cursor left)

#### Function Keys (xterm)
- **F1** - `\x1BOP`
- **F2** - `\x1BOQ`
- **F3** - `\x1BOR`
- **F4** - `\x1BOS`
- **F5** - `\x1B[15~`
- **F6** - `\x1B[17~`
- **F7** - `\x1B[18~`
- **F8** - `\x1B[19~`
- **F9** - `\x1B[20~`
- **F10** - `\x1B[21~`
- **F11** - `\x1B[23~`
- **F12** - `\x1B[24~`

### ✅ **Performance Targets**

| Metric | Target | Status |
|--------|--------|--------|
| Launch Time | <400ms | ✅ TBD |
| Animation FPS | 60fps | ✅ TBD |
| Memory Usage | <50MB | ✅ TBD |
| Reconnect Time | <2s | ✅ TBD |
| Scrollback Buffer | 1000 lines | ✅ Implemented |
| Max Output Rate | 100KB/s | ✅ TBD |

### ✅ **UI Components**

#### Connection Status Bar
```
[🟢 CONNECTED]                    or    [🔴 DISCONNECTED] [Reconnect]
```

#### Terminal Output Area
```
╔═══════════════════════════════════════╗
║ $ ls -la                              ║
║ drwxr-xr-x  12 ty  staff   384 Oct 23║
║ -rw-r--r--   1 ty  staff  1234 Oct 22║
║ ...                                   ║
║ $ _                                   ║
╚═══════════════════════════════════════╝
```

#### Keyboard Toolbar
```
┌─────────────────────────────────────┐
│ [F1-12 >] | [ESC] [TAB] | [↑] [^C] │
└─────────────────────────────────────┘
```

#### Input Bar
```
┌─────────────────────────────────────┐
│ > [Type command here...        ] [↑]│
└─────────────────────────────────────┘
```

### ✅ **Color Themes**

#### Terminal Background
- Base: `#0a0e1a` (dark blue-black)
- Gradient: Radial from center
  - Center: `#60efff` (cyan) @ 15% opacity
  - Mid: `#ff6b9d` (pink) @ 10% opacity
  - Edge: Transparent

#### Text Colors (ANSI Default)
- Default: `#00ff88` (bright green)
- Black: `#000000`
- Red: `#ff0000`
- Green: `#00ff88`
- Yellow: `#ffff00`
- Blue: `#0000ff`
- Magenta: `#ff00ff`
- Cyan: `#60efff`
- White: `#ffffff`

#### Status Indicators
- Connected: `#00ff88` (green)
- Disconnected: `#ff3366` (red)
- Warning: `#ffaa00` (orange)

### ✅ **Accessibility**

#### VoiceOver Support
- Connection status announced
- Input field labeled
- Keyboard buttons labeled
- Output region accessible

#### Dynamic Type
- Supports all 11 text sizes
- Terminal font scales proportionally
- Keyboard toolbar remains usable

#### High Contrast
- Colors remain readable
- Status indicators visible
- Button borders enhanced

### ✅ **Error Messages**

#### Connection Errors
```
"Invalid WebSocket URL"
"Authentication failed: [reason]"
"Connection error: [reason]"
"Network error: [reason]"
```

#### Recovery Actions
- Auto-reconnect with exponential backoff
- Manual reconnect button
- Clear error message display
- Status bar indication

### ✅ **Usage Examples**

#### Example 1: Run Claude Code
```bash
$ cd /Users/Ty/BuilderOS/capsules/my-project
$ claude "add error handling to login.swift"
[Claude Code starts working...]
```

#### Example 2: Git Workflow
```bash
$ git status
On branch main
Changes not staged for commit:
  modified: src/TerminalView.swift

$ git add .
$ git commit -m "Add terminal feature"
$ git push
```

#### Example 3: BuilderOS Navigation
```bash
$ python3 /Users/Ty/BuilderOS/tools/nav.py builder-system-mobile
Navigated to: /Users/Ty/BuilderOS/capsules/builder-system-mobile
$ ls -la
[colored directory listing]
```

#### Example 4: Interactive Commands
```bash
$ vim test.txt
[vim opens - use ESC key from toolbar]
:q!<Enter>
[vim closes]

$ python3
>>> print("Hello from iOS!")
Hello from iOS!
>>> exit()
$
```

### ✅ **Troubleshooting Quick Reference**

| Issue | Solution |
|-------|----------|
| Won't connect | Check tunnel URL, API key, server running |
| No colors | Test with `ls -la --color=always` |
| Special keys fail | Verify terminal connected (green status) |
| App crashes | Clean build, check Xcode console |
| Scrolling lag | Clear output (Ctrl+L), check buffer size |
| Can't type | Tap input field, check keyboard visible |

---

**Full Documentation:**
- Implementation: `TERMINAL_IMPLEMENTATION.md`
- Testing Guide: `TESTING_GUIDE.md`
- Main README: `README.md`

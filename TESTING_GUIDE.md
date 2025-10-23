# Terminal Testing Guide

## Quick Start Testing (15 minutes)

### Prerequisites
1. **Start Mac API Server:**
   ```bash
   cd /Users/Ty/BuilderOS/api
   ./server_mode.sh
   ```

2. **Start Cloudflare Tunnel:**
   ```bash
   cloudflared tunnel --url http://localhost:8080
   ```
   Note the tunnel URL (e.g., `https://xxx-yyy-zzz.trycloudflare.com`)

3. **Build iOS App:**
   ```bash
   open /Users/Ty/BuilderOS/capsules/builder-system-mobile/src/BuilderSystemMobile.xcodeproj
   ```
   Select iPhone simulator and press Cmd+R

### Test Sequence

#### 1. Basic Connection (2 min)
- [ ] Launch app
- [ ] Go to Terminal tab
- [ ] See "Terminal Not Configured" if first time
- [ ] Go to Settings, paste tunnel URL and API key
- [ ] Return to Terminal tab
- [ ] Connection status shows "CONNECTED" with green indicator

#### 2. Basic Commands (3 min)
```bash
# Test basic shell
pwd
# Should show: /Users/Ty/BuilderOS

ls -la
# Should show colored file listing

echo "Hello from iOS!"
# Should echo back with colors

whoami
# Should show your username
```

#### 3. ANSI Colors (2 min)
```bash
# Git status (lots of colors)
git status
# Should see green/red/yellow colored output

# Git log (colors + formatting)
git log --oneline -5
# Should see colored commit hashes

# Directory listing with colors
ls -la --color=always
# Should see blue directories, green executables
```

#### 4. Special Keys (3 min)
```bash
# Type a long command, DON'T press Enter
echo "this is a test"

# Press Ctrl+C (from keyboard toolbar)
# Should cancel and return to prompt

# Press arrow up
# Should recall previous command

# Press Tab in middle of command
cd ~/Build<TAB>
# Should autocomplete to "BuilderOS"

# Press ESC
# Should work in vim/nano
```

#### 5. Interactive Commands (2 min)
```bash
# Run top briefly
top
# Press Ctrl+C to exit

# Try vim
vim test.txt
# Press ESC, type :q!, press Enter to quit

# Test less
ls -la | less
# Press q to quit
```

#### 6. BuilderOS Commands (3 min)
```bash
# Claude Code
claude --version
# Should show Claude Code version

# BridgeHub
node /Users/Ty/BuilderOS/tools/bridgehub/dist/bridgehub.js --help
# Should show BridgeHub help

# Python tools
python3 /Users/Ty/BuilderOS/tools/nav.py --help
# Should show navigation tool help
```

## Detailed Testing (45 minutes)

### Terminal Features

#### Connection Management
- [ ] Initial connection succeeds
- [ ] Shows "CONNECTED" status with green dot
- [ ] Disconnect Mac server, app shows "DISCONNECTED"
- [ ] Reconnect Mac server, app auto-reconnects
- [ ] Reconnect button works when disconnected
- [ ] Multiple reconnect attempts use exponential backoff

#### Input Handling
- [ ] Can type text normally
- [ ] Enter key sends command
- [ ] Backspace works correctly
- [ ] Paste works (long-press in input field)
- [ ] Special characters work (@, #, $, %, etc.)
- [ ] Emojis work (😀 🎉 ✅)

#### Output Display
- [ ] Command output appears in real-time
- [ ] Colors render correctly
- [ ] Bold text shows correctly
- [ ] Auto-scrolls to bottom on new output
- [ ] Can scroll up to see history
- [ ] Text selection works
- [ ] Copy works (long-press on text)

#### Keyboard Toolbar
- [ ] ESC button works
- [ ] TAB button works (autocomplete)
- [ ] Ctrl+C cancels command
- [ ] Ctrl+D exits shell prompt
- [ ] Ctrl+Z suspends foreground job
- [ ] Ctrl+L clears screen
- [ ] Arrow up/down navigate command history
- [ ] Arrow left/right move cursor in command
- [ ] F1-F12 row expands/collapses
- [ ] Haptic feedback on button press

#### Terminal Resize
- [ ] Rotate device to landscape
- [ ] Terminal adjusts width
- [ ] Commands wrap correctly
- [ ] Rotate back to portrait
- [ ] Terminal adjusts again
- [ ] No layout glitches

#### Scrollback Buffer
- [ ] Run command with 100+ lines output (e.g., `ls -la /usr/bin`)
- [ ] Scroll through output
- [ ] Run command with 2000+ lines
- [ ] Verify old lines are trimmed (keeps last 1000)

### Command Testing

#### Basic Shell Commands
```bash
pwd                      # Current directory
ls -la                   # List files with colors
cd capsules              # Change directory
cd ..                    # Go back
mkdir test_dir           # Create directory
touch test_file.txt      # Create file
echo "hello" > test.txt  # Write to file
cat test.txt             # Read file
rm test.txt              # Delete file
rmdir test_dir           # Delete directory
```

#### System Commands
```bash
uname -a                 # System info
which python3            # Find command path
env                      # Environment variables
echo $PATH               # PATH variable
date                     # Current date/time
uptime                   # System uptime
df -h                    # Disk usage
free -h                  # Memory usage (macOS: vm_stat)
```

#### Git Commands
```bash
git status               # Repository status (colors!)
git log --oneline -10    # Commit history (colors!)
git diff                 # Changes (colors!)
git branch               # List branches
```

#### BuilderOS Commands
```bash
# List capsules
ls -la capsules/

# Navigate with nav.py
python3 tools/nav.py builder-system-mobile

# Check metrics
python3 tools/metrics_rollup.py

# BridgeHub ping
node tools/bridgehub/dist/bridgehub.js --version
```

#### Claude Code
```bash
# Check Claude
claude --version
claude --help

# Simple task (if Claude is available)
# Note: This may take a while
# claude "echo 'Hello from iOS terminal'"
```

### Error Handling

#### Network Errors
- [ ] Disconnect WiFi
- [ ] Terminal shows "DISCONNECTED"
- [ ] Reconnect button appears
- [ ] Reconnect WiFi
- [ ] Terminal auto-reconnects

#### Invalid API Key
- [ ] Go to Settings
- [ ] Change API key to invalid value
- [ ] Go to Terminal tab
- [ ] Shows error: "Authentication failed"
- [ ] Restore correct API key
- [ ] Terminal reconnects successfully

#### Server Offline
- [ ] Stop Mac API server
- [ ] Terminal shows "DISCONNECTED"
- [ ] Restart server
- [ ] Terminal auto-reconnects

### Performance Testing

#### Scrolling Performance
```bash
# Generate lots of output
seq 1 1000
# Scroll up and down - should be smooth 60fps

# Large file display
cat /usr/share/dict/words
# Should handle large output without lag
```

#### Input Latency
- [ ] Type quickly
- [ ] No dropped characters
- [ ] Commands execute immediately
- [ ] Cursor position updates in real-time

#### Memory Usage
- [ ] Run Activity Monitor on Mac
- [ ] Check iOS app memory usage
- [ ] Should stay under 50MB
- [ ] No memory leaks over time

### Accessibility Testing

#### VoiceOver
- [ ] Enable VoiceOver (Triple-click side button)
- [ ] Navigate to Terminal tab
- [ ] VoiceOver announces connection status
- [ ] Can focus input field
- [ ] Can activate keyboard buttons

#### Dynamic Type
- [ ] Settings > Accessibility > Display & Text Size > Larger Text
- [ ] Increase text size
- [ ] Terminal text scales up
- [ ] Keyboard toolbar remains usable

#### High Contrast
- [ ] Settings > Accessibility > Display & Text Size > Increase Contrast
- [ ] Terminal colors remain readable
- [ ] Status indicators visible

### Edge Cases

#### Long Running Commands
```bash
# Sleep for 10 seconds
sleep 10
# Press Ctrl+C to cancel mid-execution
# Should cancel immediately

# Background process
sleep 30 &
# Should see job number
# Continue using terminal
```

#### Large Output
```bash
# Very long line
python3 -c "print('A' * 1000)"
# Should wrap or truncate gracefully

# Many lines
yes | head -1000
# Should display all lines
# Scrollback should trim old lines
```

#### Special Characters
```bash
# Test escaping
echo "\"Hello\" 'World'"
echo \$PATH

# Test piping
ls -la | grep ".swift"

# Test redirection
echo "test" > /tmp/test.txt
cat /tmp/test.txt
```

## Test Report Template

```markdown
# Terminal Testing Report

**Date:** [Date]
**iOS Version:** [e.g., 17.2]
**Device:** [e.g., iPhone 15 Pro Simulator]
**App Version:** [e.g., 1.0.0]

## Connection Tests
- [ ] Initial connection: PASS / FAIL
- [ ] Auto-reconnect: PASS / FAIL
- [ ] Error handling: PASS / FAIL

## Command Tests
- [ ] Basic shell commands: PASS / FAIL
- [ ] ANSI colors: PASS / FAIL
- [ ] Git commands: PASS / FAIL
- [ ] BuilderOS commands: PASS / FAIL
- [ ] Claude Code: PASS / FAIL

## Special Keys
- [ ] ESC: PASS / FAIL
- [ ] TAB: PASS / FAIL
- [ ] Ctrl+C: PASS / FAIL
- [ ] Arrows: PASS / FAIL
- [ ] Function keys: PASS / FAIL

## UI/UX
- [ ] Terminal resize: PASS / FAIL
- [ ] Auto-scroll: PASS / FAIL
- [ ] Scrollback: PASS / FAIL
- [ ] Haptic feedback: PASS / FAIL

## Performance
- [ ] Launch time: [e.g., 350ms]
- [ ] Scrolling FPS: [e.g., 60fps]
- [ ] Memory usage: [e.g., 42MB]
- [ ] Reconnect time: [e.g., 1.2s]

## Issues Found
1. [Issue description]
2. [Issue description]

## Overall Result
PASS / FAIL

**Notes:**
[Any additional observations]
```

## Common Issues & Solutions

### Terminal shows "Not Configured"
**Solution:** Go to Settings and enter tunnel URL + API key

### Connection fails immediately
**Solution:**
1. Check tunnel URL is correct (no trailing slash)
2. Verify API server is running on Mac
3. Verify Cloudflare tunnel is active
4. Check API key matches server output

### Colors not showing
**Solution:**
1. Test with `ls -la --color=always`
2. Check Xcode console for ANSI parsing errors
3. Verify ANSIParser is working (should see colored text)

### Special keys not working
**Solution:**
1. Check keyboard toolbar is visible
2. Verify terminal is connected (green status)
3. Try simpler keys first (ESC, Tab)
4. Check Xcode console for send errors

### App crashes on launch
**Solution:**
1. Check Xcode console for error messages
2. Verify all files are properly linked
3. Clean build folder (Cmd+Shift+K)
4. Rebuild project (Cmd+B)

### Terminal freezes
**Solution:**
1. Press Ctrl+C to cancel current command
2. If unresponsive, disconnect and reconnect
3. Check if command is waiting for input

### Scrolling is laggy
**Solution:**
1. Check scrollback buffer size (should be 1000 lines)
2. Clear terminal output (Ctrl+L)
3. Restart terminal tab
4. Check iOS device performance

---

**Happy Testing! 🧪**

If you find any issues, note them in your test report and check the troubleshooting section.

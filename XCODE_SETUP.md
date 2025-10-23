# Xcode Project Setup - iTerm2 Features

## New Files to Add to Xcode

After opening the Xcode project, you need to add these new files:

### Models Group
1. Right-click on "Models" group in Xcode
2. Select "Add Files to BuilderOS Mobile..."
3. Navigate to `/Users/Ty/BuilderOS/capsules/builder-system-mobile/src/Models/`
4. Select these files:
   - `TerminalProfile.swift`
   - `Command.swift`
   - `QuickAction.swift`
5. **IMPORTANT:** Uncheck "Copy items if needed" (we want linked files!)
6. Click "Add"

### Views Group
1. Right-click on "Views" group in Xcode
2. Select "Add Files to BuilderOS Mobile..."
3. Navigate to `/Users/Ty/BuilderOS/capsules/builder-system-mobile/src/Views/`
4. Select these files:
   - `ProfileSwitcher.swift`
   - `CommandSuggestionsView.swift`
   - `QuickActionsBar.swift`
5. **IMPORTANT:** Uncheck "Copy items if needed" (we want linked files!)
6. Click "Add"

## Quick Steps

1. Open Xcode project:
   ```bash
   open "/Users/Ty/BuilderOS/capsules/builder-system-mobile/src/BuilderOS Mobile.xcodeproj"
   ```

2. In Xcode Navigator, locate the Models group

3. Drag and drop the 3 model files from Finder into the Models group
   - Make sure "Copy items if needed" is UNCHECKED
   - Make sure target "BuilderOS Mobile" is CHECKED

4. Repeat for Views group with the 3 view files

5. Build the project (Cmd+B) to verify all files compile

## Already Modified Files

These existing files have been updated with new functionality:
- ✅ `WebSocketTerminalView.swift` - Integrated all new components
- ✅ `TerminalWebSocketService.swift` - Added sendBytes method

## Verification

After adding files, verify in Xcode:
- [ ] All 6 new files appear in their respective groups
- [ ] File icons are NOT copied (should show reference icon)
- [ ] Project builds without errors (Cmd+B)
- [ ] All previews work (Cmd+Option+P)

## Features Implemented

### Profile System
- ✅ 3 pre-configured profiles (Shell, Claude, Codex)
- ✅ Profile switcher UI with colored chips
- ✅ Profile switching with confirmation for active commands
- ✅ Automatic command execution on profile switch

### Command Suggestions
- ✅ Dropdown appears when typing `/`, `git`, `ls`, `cd`
- ✅ Filters suggestions as you type
- ✅ 3 categories: AI, Navigation, BuilderOS, Shell, Git
- ✅ Tap to autocomplete command

### Quick Actions
- ✅ 8 quick action buttons above keyboard
- ✅ One-tap access to: Clear, Capsules, Git Status, Agents, Kill, Home, PWD, Tools
- ✅ Glassmorphic design matching terminal theme

### Enhanced Terminal
- ✅ Terminal output color changes with profile (green/purple/blue)
- ✅ Profile-specific initial commands
- ✅ Working directory management
- ✅ Ctrl+C support for canceling commands

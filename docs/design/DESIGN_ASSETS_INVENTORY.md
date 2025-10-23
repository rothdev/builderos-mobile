# BuilderOS Mobile - Design Assets Inventory

**Date:** 2025-10-22
**Status:** ✅ All design assets saved and ready for self-hosted Penpot import
**Next Step:** Await self-hosted Penpot setup, then import terminal home screen design

---

## 📦 Complete Asset Inventory

All files located in: `/Users/Ty/BuilderOS/capsules/builder-system-mobile/docs/design/`

### 🎨 Design Specifications (Source of Truth)

| File | Size | Purpose | Status |
|------|------|---------|--------|
| **penpot-design-spec.md** | 15KB | Complete technical specifications for Penpot import | ✅ Ready |
| **DESIGN_SYSTEM.md** | 14KB | Original iOS design system (pre-terminal aesthetic) | ✅ Archive |
| **SCREEN_SPECIFICATIONS.md** | 21KB | Original 4-screen specs (Chat, Empty, Actions, Connection) | ✅ Archive |
| **TERMINAL_REDESIGN.md** | 4.9KB | Terminal aesthetic redesign notes | ✅ Current |

### 🖼️ Visual References

| File | Size | Purpose | Status |
|------|------|---------|--------|
| **penpot-reference.html** | 22KB | Pixel-perfect terminal design with measurements toggle | ✅ Primary |
| **mobile-app-preview.html** | 31KB | Original interactive HTML preview (4 screens) | ✅ Archive |
| **penpot-artboard-only.png** | 210KB | Cropped screenshot of terminal screen (393×852px) | ✅ Import Ready |
| **penpot-reference-full.png** | 71KB | Full page screenshot with instructions | ✅ Reference |

### 📚 Documentation

| File | Size | Purpose | Status |
|------|------|---------|--------|
| **README.md** | 14KB | Complete design documentation index | ✅ Current |
| **PENPOT_QUICKSTART.md** | 6.7KB | Step-by-step Penpot import guide | ✅ Ready |
| **QUICK_START.md** | 6.9KB | Original quick start guide | ✅ Archive |

---

## 🎯 Terminal Home Screen Design Specifications

### Approved Design (Ready for Penpot)

**Device:** iPhone (393×852px)
**Aesthetic:** Terminal/Command-line with CRT vibes
**Font:** JetBrains Mono (monospace)
**Theme:** Dark mode with cyber gradients

### Color Palette (Placeholders)

```
Electric Cyan:  #60efff  (accents, glows, links)
Rose Pink:      #ff6b9d  (gradients, highlights)
Hot Red:        #ff3366  (buttons, alerts)
Dark Navy:      #0a0e27  (background start)
Deep Blue:      #16213e  (background end)
Success Green:  #00ff88  (connection status)
```

### Key Components

1. **Status Bar** (54px height)
   - Time: 9:41 (14px)
   - System icons: cellular, wifi, battery

2. **Header** (60px)
   - Title: "BuilderOS" (18px gradient)
   - Connection: pulsing green dot + "Connected"
   - Prompt: "~/mobile/home $" (rose pink, 70% opacity)

3. **Main Content**
   - Logo: "B//OS" (72px, centered, gradient)
   - Symbols: "{ $ _ > }" (14px cyan, spaced)
   - Welcome: "$ Welcome to BuilderOS_" (24px, blinking cursor)
   - Subtitle: "// Your mobile command center." + "// Build anything, anywhere."
   - Hint: "> Try a command or explore features below"
   - Feature Grid (2×2, 12px gap):
     - 🤖 Ask Jarvis
     - 📦 Capsules
     - ⚡ Quick Actions
     - 🔔 Notifications

4. **Input Bar** (78px + 34px safe area)
   - Quick actions: ⚡ button (cyan→pink gradient)
   - Input: "Ask Jarvis..." (glassmorphism)
   - Send: ↑ button (pink→red gradient)

### Visual Effects

- **CRT Scanlines:** Repeating gradient overlay (10% opacity)
- **Text Glow:** Cyan/pink shadows on interactive elements
- **Glassmorphism:** Backdrop blur on input containers
- **Cursor Blink:** 1s animation on welcome text
- **Dot Pulse:** 2s animation on connection status

---

## 🔄 Design Evolution History

### Phase 1: Initial iOS Design (Archive)
- **Files:** DESIGN_SYSTEM.md, SCREEN_SPECIFICATIONS.md, mobile-app-preview.html
- **Status:** Superseded by terminal aesthetic
- **Keep for:** Original 4-screen concepts (Chat, Empty State, Quick Actions, Connection)

### Phase 2: Terminal Aesthetic (Current)
- **Files:** TERMINAL_REDESIGN.md, penpot-reference.html, penpot-design-spec.md
- **Status:** Approved, ready for Penpot import
- **Awaiting:** Self-hosted Penpot setup

### Phase 3: Penpot Design File (Next)
- **Tool:** Self-hosted Penpot (localhost)
- **Action:** Import terminal home screen design
- **Output:** `.penpot` design file in version control
- **Then:** Full SwiftUI implementation

---

## 🚀 Self-Hosted Penpot Import Workflow

### When Self-Hosted Penpot is Ready:

1. **Create Project**
   - Project name: "BuilderOS Mobile - Terminal UI"
   - Team: Default (or BuilderOS team)

2. **Create Design File**
   - File name: "Home Screen - Terminal"
   - Artboard size: 393×852px (iPhone)

3. **Import Reference**
   - **Option A:** Screenshot import (`penpot-artboard-only.png`)
   - **Option B:** Manual recreation using `penpot-design-spec.md`
   - **Option C:** Hybrid (screenshot as background layer + build on top)

4. **Build Components**
   - Status bar (reusable across screens)
   - Header with connection status
   - Terminal logo (B//OS)
   - Feature card (reusable 2×2 grid item)
   - Input bar with action buttons

5. **Document Animations**
   - Cursor blink (1s interval)
   - Dot pulse (2s cycle)
   - Scanline overlay (static effect)
   - Button press states

6. **Export for Implementation**
   - SVG exports for assets
   - Color tokens for SwiftUI
   - Spacing measurements
   - Component specifications

7. **Version Control**
   - Save `.penpot` file in capsule
   - Commit to Git with design specs
   - Track design iterations

---

## 📋 Pre-Implementation Checklist

### Design Assets ✅
- [x] Terminal aesthetic specifications documented
- [x] Pixel-perfect HTML reference created
- [x] Color palette defined (placeholders)
- [x] Typography system specified (JetBrains Mono)
- [x] Component breakdown completed
- [x] Animation timings documented
- [x] Screenshot exports ready for import

### Penpot Workflow ⏳
- [ ] Self-hosted Penpot running (localhost)
- [ ] Claude Code CLI access configured
- [ ] MCP integration tested with localhost
- [ ] Design file created in Penpot
- [ ] Components built and organized
- [ ] Animations documented in Penpot
- [ ] Design file committed to Git

### SwiftUI Implementation ⏳
- [ ] Xcode project opened
- [ ] Design tokens converted to Swift
- [ ] JetBrains Mono font added to project
- [ ] Color system implemented
- [ ] View hierarchy created
- [ ] Animations implemented
- [ ] Tested on iPhone simulator
- [ ] Tested on physical device

---

## 🎯 Success Criteria

### Design Phase (Current)
- ✅ Terminal aesthetic approved by Ty
- ✅ All specifications documented
- ✅ Reference files created and saved
- ✅ Ready for Penpot import

### Penpot Phase (Next)
- Design file created in self-hosted Penpot
- All components properly organized
- Reusable components defined
- Animations documented
- Design file in version control

### Implementation Phase (After Penpot)
- SwiftUI views match Penpot design exactly
- Animations feel native and smooth
- Performance is 60fps on target devices
- Accessibility requirements met
- Ready for backend integration

---

## 📁 File Organization

```
docs/design/
├── README.md                      # Documentation index (14KB)
├── DESIGN_ASSETS_INVENTORY.md     # This file
│
├── Current Design (Terminal Aesthetic)
│   ├── penpot-design-spec.md          # Complete specifications (15KB)
│   ├── penpot-reference.html          # Pixel-perfect reference (22KB)
│   ├── penpot-artboard-only.png       # Import-ready screenshot (210KB)
│   ├── penpot-reference-full.png      # Full page reference (71KB)
│   ├── PENPOT_QUICKSTART.md           # Import guide (6.7KB)
│   └── TERMINAL_REDESIGN.md           # Design notes (4.9KB)
│
└── Archive (Original iOS Design)
    ├── DESIGN_SYSTEM.md               # Original design system (14KB)
    ├── SCREEN_SPECIFICATIONS.md       # 4-screen specs (21KB)
    ├── mobile-app-preview.html        # Interactive preview (31KB)
    └── QUICK_START.md                 # Original guide (6.9KB)
```

---

## 🔐 Design Asset Security

**All files are local and safe:**
- ✅ Stored in capsule (`/docs/design/`)
- ✅ Version controlled (Git)
- ✅ No external dependencies
- ✅ No API keys or credentials
- ✅ Ready for offline access

**When self-hosted Penpot is added:**
- Penpot files will be stored locally
- Design database will be in Docker volume
- Backups will be included in capsule backups
- No cloud dependencies

---

## 💡 Notes for Future Design Work

### BuilderOS Design Workflow Pattern

1. **Ideation:** Describe desired UI/UX
2. **Specification:** Create detailed specs (markdown + metrics)
3. **Reference:** Generate HTML/image references
4. **Penpot:** Import into self-hosted Penpot for design iteration
5. **Version Control:** Commit `.penpot` files to Git
6. **Implementation:** Convert to native code (SwiftUI/React/etc.)
7. **Testing:** Validate against design specs
8. **Iteration:** Update Penpot, re-export, re-implement

### Why This Workflow Works

- **Specifications are source of truth** (not the design tool)
- **HTML references are interactive** (quick validation)
- **Penpot is for refinement** (not initial creation)
- **Version control tracks everything** (design + code)
- **Claude Code can read/write at every step** (full automation)

---

**Status:** ✅ All design assets saved and organized
**Next:** Await self-hosted Penpot, then proceed to import and implement
**Owner:** Jarvis (BuilderOS orchestration)
**Last Updated:** October 22, 2025

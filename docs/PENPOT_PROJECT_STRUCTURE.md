# BuilderOS Mobile - Penpot Project Structure

**Project:** BuilderOS Mobile
**Project ID:** `4c46a10f-a510-8112-8006-ff54c883093f`
**Location:** http://localhost:3449/#/dashboard/projects/4c46a10f-a510-8112-8006-ff54c883093f

---

## 📂 Project Structure

```
BuilderOS Mobile (Project)
├── BuilderOS Design System (File)
│   ├── 📄 Color Palette (Page - TO CREATE)
│   ├── 📄 Typography Scale (Page - TO CREATE)
│   ├── 📄 Spacing System (Page - TO CREATE)
│   └── 📄 Component Anatomy (Page - TO CREATE)
│
├── iOS Screens - Onboarding (File)
│   ├── 📱 Step 0 - Welcome (Page - TO CREATE)
│   ├── 📱 Step 1 - Setup (Page - TO CREATE)
│   ├── 📱 Step 2 - Connection Test (Page - TO CREATE)
│   ├── 🌙 Welcome - Dark Mode (Page - TO CREATE)
│   ├── 🌙 Setup - Dark Mode (Page - TO CREATE)
│   └── 🌙 Connection Test - Dark Mode (Page - TO CREATE)
│
├── iOS Screens - Main App (File)
│   ├── 📱 Dashboard (Page - TO CREATE)
│   ├── 📱 Chat Terminal (Page - TO CREATE)
│   ├── 📱 Localhost Preview (Page - TO CREATE)
│   ├── 📱 Settings (Page - TO CREATE)
│   ├── 📱 Tab Bar Navigation (Page - TO CREATE)
│   ├── 🌙 Dashboard - Dark Mode (Page - TO CREATE)
│   ├── 🌙 Chat Terminal - Dark Mode (Page - TO CREATE)
│   ├── 🌙 Localhost Preview - Dark Mode (Page - TO CREATE)
│   └── 🌙 Settings - Dark Mode (Page - TO CREATE)
│
└── Mobile Design System Test (File)
    └── (Unknown - may be scratch/test file)
```

---

## 📊 File Details

### File 1: BuilderOS Design System

**File ID:** `47114189-b7a2-818e-8006-ffdc5b6a7fa2`
**Direct URL:** http://localhost:3449/#/workspace/47114189-b7a2-818e-8006-ffdc5b6a7fa2
**Status:** ⚠️ Empty (1 placeholder frame)

**Planned Pages:**

1. **Color Palette**
   - Light mode swatches (12 colors)
   - Dark mode swatches (12 colors)
   - Each swatch: color box (100×100 pt) + hex value + semantic name
   - Layout: 4 columns × 6 rows

2. **Typography Scale**
   - Display samples (3 sizes: 57pt, 45pt, 36pt)
   - Headline samples (3 sizes: 32pt, 28pt, 24pt)
   - Title samples (3 sizes: 22pt, 16pt, 14pt)
   - Body samples (3 sizes: 16pt, 14pt, 12pt)
   - Label samples (3 sizes: 14pt, 12pt, 11pt)
   - Monospaced samples (3 sizes: 16pt, 14pt, 12pt)
   - Text style presets (5 examples: h1, h2, h3, body, caption)

3. **Spacing System**
   - 8pt grid visualizer (horizontal bars: 4-64pt)
   - Corner radius examples (6 rectangles with different radii)
   - Icon size examples (5 SF Symbols at different sizes)
   - Layout constant examples (touch targets, padding visualizations)

4. **Component Anatomy**
   - CapsuleCard breakdown (measurements, padding annotations)
   - QuickLinkButton breakdown (states: default, selected)
   - InstructionStep breakdown (circle badge + text layout)
   - Button styles (primary, secondary, pressed state)

**Estimated Time:** 2-3 hours

---

### File 2: iOS Screens - Onboarding

**File ID:** `47114189-b7a2-818e-8006-ffdc5eee2d8b`
**Direct URL:** http://localhost:3449/#/workspace/47114189-b7a2-818e-8006-ffdc5eee2d8b
**Status:** ⚠️ Empty (1 placeholder frame)

**Planned Pages (6 total: 3 Light + 3 Dark):**

1. **Step 0 - Welcome (Light Mode)**
   - iPhone 15 Pro frame (393×852 pt)
   - Logo: cube.box.fill (120×120 pt, blue gradient)
   - Title: "BuilderOS" (40pt bold rounded)
   - Subtitle: "Connect to your Mac" (title3, secondary)
   - Spacer
   - Icon: sparkles (60pt blue)
   - Headline: "Access your BuilderOS system from anywhere"
   - Body text (300pt max width)
   - Spacer
   - "Get Started" button (full width, blue gradient)

2. **Step 1 - Setup (Light Mode)**
   - iPhone 15 Pro frame
   - Icon: link.circle.fill (60pt blue)
   - Headline: "Enter Connection Details"
   - Tunnel URL field (systemGray6 background, monospaced)
   - API Key field (systemGray6 background, monospaced)
   - Caption: "Get these from your Mac's BuilderOS server output"
   - "Test Connection" button
   - "Back" button (secondary text)

3. **Step 2 - Connection Test (Light Mode)**
   - 3 states in one artboard or separate:
     - **Loading:** ProgressView (1.5x scale) + "Testing connection..."
     - **Success:** Green checkmark (60pt) + "Connected!" + tunnel info card
     - **Error:** Orange warning (60pt) + "Connection failed" + error message

4-6. **Dark Mode Variants**
   - Duplicate of above 3 pages with dark mode colors
   - Background: #000000
   - Secondary Background: #1C1C1E
   - Primary Blue: #0A84FF
   - Text: White/secondary labels

**Estimated Time:** 1-2 hours

---

### File 3: iOS Screens - Main App

**File ID:** `47114189-b7a2-818e-8006-ffdc5d25b33c`
**Direct URL:** http://localhost:3449/#/workspace/47114189-b7a2-818e-8006-ffdc5d25b33c
**Status:** ⚠️ Empty (1 placeholder frame)

**Planned Pages (9 total: 5 Light + 4 Dark):**

1. **Dashboard (Light Mode)**
   - iPhone 15 Pro frame with tab bar
   - Navigation title: "BuilderOS" (large)
   - ScrollView content:
     - Connection status card (.ultraThinMaterial, 12pt radius)
       - Icon + status + spinner
       - Divider
       - Tunnel URL + Cloudflare badge
     - System status card (.ultraThinMaterial, 12pt radius)
       - "System Status" + health indicator
       - 2×2 stats grid (Version, Uptime, Capsules, Services)
     - "Capsules" section
       - 2-column grid of CapsuleCard components
   - Tab bar: Dashboard (selected), Terminal, Preview, Settings

2. **Chat Terminal (Light Mode)**
   - iPhone 15 Pro frame with tab bar
   - ChatHeaderView (connection status)
   - Message list:
     - User message (blue background, white text, right-aligned)
     - System message (systemGray5 background, primary text, left-aligned)
     - Code block (systemGray2 background, monospaced)
   - Voice input controls at bottom
   - Tab bar: Dashboard, Terminal (selected), Preview, Settings

3. **Localhost Preview (Light Mode)**
   - iPhone 15 Pro frame with tab bar
   - Connection header (secondarySystemBackground)
   - Quick links horizontal scroll:
     - React (3000), n8n (5678), API (8080), Vite (5173), Flask (5000)
     - Selected: blue background
     - Unselected: secondarySystemBackground
   - Custom port input section
   - Empty state: globe icon (64pt) + title + instructions
   - Tab bar: Dashboard, Terminal, Preview (selected), Settings

4. **Settings (Light Mode)**
   - iPhone 15 Pro frame with tab bar
   - Form sections:
     - **Mac Connection:** Tunnel URL + API Key + Test button
     - **Connection Status:** Status row + Endpoint row
     - **System Control:** Sleep Mac button
     - **Setup Instructions:** 4 InstructionStep components
     - **About:** Version + API version
   - Tab bar: Dashboard, Terminal, Preview, Settings (selected)

5. **Tab Bar Navigation**
   - Standalone artboard showing tab bar anatomy
   - 4 tabs with SF Symbols:
     - square.grid.2x2.fill (Dashboard)
     - terminal.fill (Terminal)
     - globe (Preview)
     - gearshape.fill (Settings)
   - Selected state (blue) vs. unselected (gray)
   - 49pt height + 34pt safe area

6-9. **Dark Mode Variants**
   - Dashboard - Dark Mode
   - Chat Terminal - Dark Mode
   - Localhost Preview - Dark Mode
   - Settings - Dark Mode

**Estimated Time:** 4-5 hours (most complex screens)

---

### File 4: Mobile Design System Test

**File ID:** `47114189-b7a2-818e-8006-ffb97c7241d6`
**Status:** Unknown (not analyzed)
**Purpose:** Likely a scratch or test file

---

## 🛠️ CLI Commands for Page Creation

### Design System File

```bash
# Create pages in Design System file
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5b6a7fa2" "Color Palette"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5b6a7fa2" "Typography Scale"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5b6a7fa2" "Spacing System"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5b6a7fa2" "Component Anatomy"
```

### Onboarding Screens File

```bash
# Create pages in Onboarding file
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5eee2d8b" "Step 0 - Welcome"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5eee2d8b" "Step 1 - Setup"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5eee2d8b" "Step 2 - Connection Test"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5eee2d8b" "Welcome - Dark Mode"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5eee2d8b" "Setup - Dark Mode"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5eee2d8b" "Connection Test - Dark Mode"
```

### Main App Screens File

```bash
# Create pages in Main App file
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5d25b33c" "Dashboard"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5d25b33c" "Chat Terminal"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5d25b33c" "Localhost Preview"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5d25b33c" "Settings"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5d25b33c" "Tab Bar Navigation"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5d25b33c" "Dashboard - Dark Mode"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5d25b33c" "Chat Terminal - Dark Mode"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5d25b33c" "Localhost Preview - Dark Mode"
penpot_cli.py create-page "47114189-b7a2-818e-8006-ffdc5d25b33c" "Settings - Dark Mode"
```

---

## 📊 Time Estimates

**Total Penpot Population Time:** 8-12 hours

**Breakdown:**
- Design System File: 2-3 hours
- Onboarding Screens: 1-2 hours
- Main App Screens: 4-5 hours
- Iteration/Polish: 1-2 hours

**Priority Order:**
1. Design System (foundation for everything else)
2. Dashboard (most complex, most components)
3. Onboarding (user-facing, simpler)
4. Settings + Preview (form patterns, empty states)
5. Chat (message bubbles, unique patterns)

---

## 🎯 Success Criteria

**Penpot project is complete when:**

- [ ] Design System file has color/typography/spacing samples
- [ ] All 5 main screens designed (Light mode)
- [ ] All 5 main screens designed (Dark mode)
- [ ] Onboarding flow designed (3 steps, Light + Dark)
- [ ] Component library created (reusable CapsuleCard, etc.)
- [ ] Sample screens exported as PNG
- [ ] Side-by-side validation complete (Penpot vs iOS screenshots)
- [ ] 95%+ visual match achieved

---

**Next Steps:**
1. UI Designer: Populate Penpot files (8-12 hours)
2. Export sample screens for validation
3. Compare to iOS screenshots
4. Iterate until 95%+ match

**See:** `PENPOT_REVERSE_ENGINEERING_REPORT.md` for detailed instructions

# BuilderOS Mobile App - Penpot Project Creation Guide

**Project Name:** BuilderOS Mobile App
**Team:** Default (ID: 10e879d4-e5a6-801a-8006-fe7a3ca058f7)
**Penpot Instance:** http://localhost:3449
**Target Device:** iPhone 15 Pro (393x852 pt)
**Design Language:** iOS 17+ Native

---

## Quick Start Checklist

### Before You Begin
- [ ] Penpot dev instance running (`~/BuilderOS/capsules/penpot-dev/start-penpot.sh`)
- [ ] Logged into Penpot at http://localhost:3449
- [ ] Review existing HTML mockups in `/design/` folder
- [ ] Review `DESIGN_DOCUMENTATION.md` for complete specs

### Project Structure
```
BuilderOS Mobile App (Project)
├── 📄 Design System (File)
│   ├── Page: Colors
│   ├── Page: Typography
│   ├── Page: Spacing & Layout
│   └── Page: Component Library
├── 📄 Onboarding Flow (File)
│   ├── Page: 01 Welcome Screen
│   ├── Page: 02 Tailscale OAuth
│   ├── Page: 03 Auto-Discovery
│   ├── Page: 04 API Key Entry
│   └── Page: 05 Success
├── 📄 Dashboard Screen (File)
│   └── Page: Dashboard (iPhone 15 Pro artboard)
├── 📄 Chat Terminal Screen (File)
│   └── Page: Chat Terminal (iPhone 15 Pro artboard)
├── 📄 Settings Screen (File)
│   └── Page: Settings (iPhone 15 Pro artboard)
└── 📄 Capsule Detail View (File) [Future]
    └── Page: Detail View (iPhone 15 Pro artboard)
```

---

## Step 1: Create Project

1. **Navigate to Penpot:** http://localhost:3449/#/dashboard/recent
2. **Create New Project:**
   - Click "+ New Project" or "Create project"
   - Name: `BuilderOS Mobile App`
   - Team: Default
   - Click "Create"

---

## Step 2: Create Design System File

### 2.1 Create File
- Click "+ New File" in project
- Name: `Design System`
- Create 4 pages: `Colors`, `Typography`, `Spacing & Layout`, `Component Library`

### 2.2 Page: Colors

**Artboard Setup:**
- Name: "Color Palette"
- Size: 1200x2000 px (freeform, not device-specific)

**Brand Colors (Create color swatches):**

1. **Primary Blue**
   - Rectangle: 200x120 px
   - Fill: #007AFF
   - Label: "Primary" (16px, Semibold, White)
   - Sublabel: "#007AFF" (13px, Regular, White, 80% opacity)

2. **Secondary Purple**
   - Rectangle: 200x120 px
   - Fill: #5856D6
   - Label: "Secondary" (White)
   - Sublabel: "#5856D6" (White, 80%)

3. **Tailscale Accent**
   - Rectangle: 200x120 px
   - Fill: #598FFF
   - Label: "Tailscale Accent" (White)
   - Sublabel: "#598FFF" (White, 80%)

**Status Colors:**

4. **Success Green**
   - Fill: #34C759
   - Label: "Success"
   - Sublabel: "#34C759"

5. **Warning Orange**
   - Fill: #FF9500
   - Label: "Warning"
   - Sublabel: "#FF9500"

6. **Error Red**
   - Fill: #FF3B30
   - Label: "Error"
   - Sublabel: "#FF3B30"

7. **Info Blue**
   - Fill: #007AFF
   - Label: "Info"
   - Sublabel: "#007AFF"

**Semantic Colors (Light Mode):**

8. **Text Primary**
   - Fill: #1D1D1F
   - Label: "Text Primary (Light)"
   - Note: "systemLabel"

9. **Text Secondary**
   - Fill: #6E6E73
   - Label: "Text Secondary (Light)"
   - Note: "secondaryLabel"

10. **Background Primary**
    - Fill: #FFFFFF
    - Border: 1px #E5E5E7
    - Label: "Background Primary (Light)"
    - Note: "systemBackground"

11. **Background Secondary**
    - Fill: #F5F5F7
    - Label: "Background Secondary (Light)"
    - Note: "secondarySystemBackground"

12. **Background Tertiary**
    - Fill: #FFFFFF
    - Label: "Background Tertiary (Light)"
    - Note: "tertiarySystemBackground"

**Semantic Colors (Dark Mode):**

13. **Text Primary (Dark)**
    - Fill: #FFFFFF
    - Background: #000000 (for contrast)
    - Label: "Text Primary (Dark)"

14. **Text Secondary (Dark)**
    - Fill: #A0A0A5
    - Background: #000000
    - Label: "Text Secondary (Dark)"

15. **Background Primary (Dark)**
    - Fill: #000000
    - Border: 1px #38383A
    - Label: "Background Primary (Dark)"

16. **Background Secondary (Dark)**
    - Fill: #1C1C1E
    - Label: "Background Secondary (Dark)"

17. **Background Tertiary (Dark)**
    - Fill: #2C2C2E
    - Label: "Background Tertiary (Dark)"

**Add all colors to Penpot color library:**
- Select each color swatch
- Right-click → "Add to library" or use color panel
- Name each color token exactly as labeled above

---

### 2.3 Page: Typography

**Artboard Setup:**
- Name: "Typography Scale"
- Size: 800x2000 px

**Typography Samples (Create text objects for each):**

1. **Display Large**
   - Text: "Display Large"
   - Font: SF Pro Rounded (or system fallback: Inter Bold)
   - Size: 57px
   - Weight: Bold (700)
   - Line Height: 1.05 (60px)
   - Color: Text Primary

2. **Display Medium**
   - Text: "Display Medium"
   - Font: SF Pro Rounded
   - Size: 45px
   - Weight: Bold
   - Line Height: 1.1 (50px)

3. **Display Small**
   - Text: "Display Small"
   - Font: SF Pro Rounded
   - Size: 36px
   - Weight: Bold
   - Line Height: 1.15 (41px)

4. **Headline Large**
   - Text: "Headline Large"
   - Font: SF Pro Rounded
   - Size: 32px
   - Weight: Semibold (600)
   - Line Height: 1.15 (37px)

5. **Headline Medium**
   - Text: "Headline Medium"
   - Font: SF Pro Rounded
   - Size: 28px
   - Weight: Semibold
   - Line Height: 1.2 (34px)

6. **Title Large**
   - Text: "Title Large"
   - Font: SF Pro (or Inter)
   - Size: 22px
   - Weight: Semibold
   - Line Height: 1.2 (26px)

7. **Title Medium**
   - Text: "Title Medium"
   - Font: SF Pro
   - Size: 16px
   - Weight: Semibold
   - Line Height: 1.3 (21px)

8. **Body Large**
   - Text: "Body Large - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
   - Font: SF Pro
   - Size: 16px
   - Weight: Regular (400)
   - Line Height: 1.4 (22px)
   - Width: 600px (wrap text)

9. **Body Medium**
   - Text: "Body Medium - Lorem ipsum dolor sit amet, consectetur adipiscing elit."
   - Font: SF Pro
   - Size: 14px
   - Weight: Regular
   - Line Height: 1.4 (20px)
   - Width: 600px

10. **Label Medium**
    - Text: "LABEL MEDIUM"
    - Font: SF Pro
    - Size: 12px
    - Weight: Medium (500)
    - Line Height: 1.3 (16px)
    - Color: Text Secondary

11. **Monospaced Medium**
    - Text: "100.66.202.6"
    - Font: SF Mono (or Fira Code/JetBrains Mono)
    - Size: 14px
    - Weight: Regular
    - Line Height: 1.5 (21px)
    - Color: Text Primary

**Add typography styles to library:**
- Select each text object
- Right-click → "Add text style to library"
- Name: "iOS/{Style Name}" (e.g., "iOS/Display Large")

---

### 2.4 Page: Spacing & Layout

**Artboard Setup:**
- Name: "Spacing System"
- Size: 800x1600 px

**8pt Grid Visualization:**

Create rectangles to visualize spacing values:

1. **xs: 4pt**
   - Rectangle: 4px height, 100px width
   - Fill: Primary Blue
   - Label: "xs - 4pt"

2. **sm: 8pt**
   - Rectangle: 8px height, 100px width
   - Fill: Primary Blue
   - Label: "sm - 8pt"

3. **md: 12pt**
   - Rectangle: 12px height, 100px width
   - Fill: Primary Blue
   - Label: "md - 12pt"

4. **base: 16pt**
   - Rectangle: 16px height, 100px width
   - Fill: Primary Blue
   - Label: "base - 16pt"

5. **lg: 24pt**
   - Rectangle: 24px height, 100px width
   - Fill: Primary Blue
   - Label: "lg - 24pt"

6. **xl: 32pt**
   - Rectangle: 32px height, 100px width
   - Fill: Primary Blue
   - Label: "xl - 32pt"

7. **xxl: 48pt**
   - Rectangle: 48px height, 100px width
   - Fill: Primary Blue
   - Label: "xxl - 48pt"

**Corner Radius Examples:**

Create rounded rectangles (100x60px each):

1. **xs: 4pt** - Border radius 4px
2. **sm: 8pt** - Border radius 8px
3. **md: 12pt** - Border radius 12px
4. **lg: 16pt** - Border radius 16px
5. **xl: 20pt** - Border radius 20px
6. **circle: 50%** - Circle (60x60px)

**Touch Target Guide:**

Create squares with outlines:

1. **Minimum: 44pt** - 44x44px square with #FF3B30 border
2. **Comfortable: 48pt** - 48x48px square with #FF9500 border
3. **Large: 56pt** - 56x56px square with #34C759 border

---

### 2.5 Page: Component Library

**Artboard Setup:**
- Name: "Components"
- Size: 1200x3000 px

**IMPORTANT: Each component should be created as a Penpot component (reusable)**

#### Button Components

**1. Primary Button**
- Frame: 160x48 px
- Background: #007AFF
- Border radius: 12px
- Text: "Primary Button"
  - Font: SF Pro, 16px, Semibold
  - Color: White
  - Centered
- **Create 3 variants:**
  - Default: #007AFF background
  - Pressed: #0051D5 background, scale 0.98
  - Disabled: #E5E5E7 background, text #86868B

**2. Secondary Button**
- Frame: 160x48 px
- Background: rgba(0, 122, 255, 0.1) - Use #007AFF at 10% opacity
- Border radius: 12px
- Text: "Secondary"
  - Font: SF Pro, 16px, Semibold
  - Color: #007AFF
  - Centered
- **Create 2 variants:**
  - Default: Light blue background
  - Pressed: #E5E5E7 background, scale 0.98

**3. Destructive Button**
- Frame: 160x48 px
- Background: #FF3B30
- Border radius: 12px
- Text: "Delete"
  - Font: SF Pro, 16px, Semibold
  - Color: White
  - Centered

**4. Icon Button (Voice)**
- Circle: 64x64 px
- Background: #007AFF
- Icon: 🎤 or microphone SF Symbol (32px, white, centered)
- Shadow: 0 4px 12px rgba(0, 122, 255, 0.3)

#### Status Badge Components

**1. Active Badge**
- Frame: Auto-width x 28px (padding: 6px vertical, 12px horizontal)
- Background: rgba(52, 199, 89, 0.1) - #34C759 at 10%
- Border radius: 8px
- Content:
  - Dot: 8px circle, fill #34C759
  - Text: "Active" (13px, Semibold, #34C759)
  - Spacing: 6px between dot and text

**2. Development Badge**
- Frame: Auto x 28px
- Background: rgba(0, 122, 255, 0.1)
- Border radius: 8px
- Dot: 8px, #007AFF
- Text: "Development" (13px, Semibold, #007AFF)

**3. Testing Badge**
- Frame: Auto x 28px
- Background: rgba(255, 149, 0, 0.1)
- Border radius: 8px
- Dot: 8px, #FF9500
- Text: "Testing" (13px, Semibold, #FF9500)

**4. Error Badge**
- Frame: Auto x 28px
- Background: rgba(255, 59, 48, 0.1)
- Border radius: 8px
- Dot: 8px, #FF3B30
- Text: "Error" (13px, Semibold, #FF3B30)

#### Card Components

**1. Standard Card**
- Frame: 343x200 px (iPhone 15 Pro width - 2x24px margins)
- Background: #FFFFFF (Light) / #1C1C1E (Dark)
- Border radius: 16px
- Shadow: 0 2px 8px rgba(0, 0, 0, 0.04)
- Padding: 20px all sides

**2. Capsule Card (2-column grid item)**
- Frame: 160x140 px (for 2-column grid with 16px gap)
- Background: #FFFFFF
- Border radius: 16px
- Shadow: 0 2px 8px rgba(0, 0, 0, 0.04)
- Padding: 16px
- Layout:
  - Status badge (top)
  - Capsule name (15px, Semibold, 8px margin top)
  - Description (12px, gray, 2 lines max, 8px margin top)
  - Tags (11px, 12px margin top)

**3. Stat Card (2x2 grid item)**
- Frame: 160x100 px
- Background: #FFFFFF
- Border radius: 12px
- Shadow: 0 2px 8px rgba(0, 0, 0, 0.04)
- Padding: 16px
- Layout:
  - Icon circle (40px, colored background, top-left)
  - Value (24px, Bold, below icon)
  - Label (13px, gray, below value)

**Example Stat Card:**
- Icon: 📊 (or chart symbol)
- Icon background: rgba(0, 122, 255, 0.1)
- Icon color: #007AFF
- Value: "24" (24px, Bold)
- Label: "Total Capsules" (13px, Text Secondary)

#### Form Elements

**1. Text Input**
- Frame: 343x48 px
- Background: #F5F5F7
- Border: 2px solid transparent
- Border radius: 10px
- Placeholder: "Work email" (15px, Text Secondary)
- Padding: 14px vertical, 16px horizontal
- **Create 3 states:**
  - Default: Gray background
  - Focus: White background, #007AFF border
  - Error: White background, #FF3B30 border

**2. Toggle Switch (iOS style)**
- Frame: 51x31 px
- Border radius: 16px (pill)
- **Off state:**
  - Background: #E5E5E7
  - Knob: 27px circle, white, positioned left (2px from edge)
  - Shadow on knob: 0 2px 4px rgba(0, 0, 0, 0.1)
- **On state:**
  - Background: #34C759
  - Knob: Translated 20px to right

**3. Secure Text Field (Password)**
- Same as Text Input
- Placeholder: "••••••••"
- Optional "Show" button (right-aligned, 44pt touch target)

#### Message Bubbles

**1. User Message (Right-aligned)**
- Frame: Max 75% screen width (280px max)
- Background: #007AFF
- Border radius: 20px (with 4px radius bottom-right corner for "tail")
- Text: White, 15px
- Padding: 12px vertical, 16px horizontal
- Alignment: Right side of screen

**2. System Message (Left-aligned)**
- Frame: Max 75% screen width
- Background: #FFFFFF (Light) / #2C2C2E (Dark)
- Border radius: 20px (with 4px radius bottom-left for "tail")
- Text: #1D1D1F (Light) / #FFFFFF (Dark), 15px
- Padding: 12px vertical, 16px horizontal
- Shadow: 0 1px 3px rgba(0, 0, 0, 0.06)
- Alignment: Left side

**3. Code Block (in message)**
- Frame: Full bubble width
- Background: rgba(0, 0, 0, 0.05) in system messages
- Background: rgba(255, 255, 255, 0.2) in user messages
- Font: SF Mono, 13px
- Padding: 8px vertical, 12px horizontal
- Border radius: 8px
- Text: "curl http://100.66.202.6:8080/api/status"

#### Connection Status Indicator

**Connected (Green)**
- Frame: Auto x 60px
- Background: rgba(52, 199, 89, 0.1)
- Border radius: 12px
- Padding: 12px
- Layout:
  - Status dot: 12px circle, #34C759
  - Text: "Connected" (15px, Semibold, #34C759)
  - IP address: "100.66.202.6" (13px, SF Mono, Text Secondary)

**Connecting (Orange) - With animation**
- Same as above but:
  - Dot: #FF9500
  - Dot: Pulsing opacity (1 → 0.5 → 1, 2s loop)
  - Text: "Connecting..."
  - Subtext: "Establishing VPN..."

**Disconnected (Red)**
- Dot: #FF3B30
- Text: "Disconnected"
- Subtext: "Tap to connect"

#### Tab Bar

**Tab Bar Container**
- Frame: 393x83 px (full iPhone width, including safe area)
- Background: rgba(255, 255, 255, 0.95) with blur effect (frosted glass)
- Border top: 0.5px solid rgba(0, 0, 0, 0.05)
- Layout: 4 evenly-spaced tab items

**Tab Item (Active)**
- Icon: 28px SF Symbol (use emoji placeholder: 📊)
- Icon color: #007AFF
- Label: "Dashboard" (10px, Medium, #007AFF)
- Spacing: 4px between icon and label
- Touch target: 44pt vertical

**Tab Item (Inactive)**
- Icon: 28px, #8E8E93
- Label: "Dashboard" (10px, Medium, #8E8E93)

**4 Tabs:**
1. Dashboard - 📊 (chart.bar.fill)
2. Chat - 💬 (message.fill)
3. Preview - 🔍 (safari.fill)
4. Settings - ⚙️ (gearshape.fill)

---

## Step 3: Create Screen Files

### 3.1 File: Onboarding Flow

**Create 5 pages, each with iPhone 15 Pro artboard (393x852 px):**

#### Page 1: Welcome Screen

**Artboard:** 393x852 px

**Background:**
- Linear gradient: #007AFF (top) → #5856D6 (bottom)

**Content (vertically centered):**
1. **App Icon** (120x120 px, centered)
   - Square with rounded corners (24px radius)
   - Background: White
   - Icon: 🏗️ or BuilderOS logo (80px)

2. **Title** (80px margin top)
   - Text: "BuilderOS"
   - Font: SF Pro Rounded, 45px, Bold
   - Color: White
   - Centered

3. **Subtitle** (16px margin top)
   - Text: "Secure remote access to your Mac development environment from anywhere"
   - Font: SF Pro, 16px, Regular
   - Color: White, 90% opacity
   - Centered
   - Max width: 320px
   - Line height: 1.4

4. **Get Started Button** (48px margin top)
   - 343x56 px (large touch target)
   - Background: White
   - Text: "Get Started" (SF Pro, 17px, Semibold, #007AFF)
   - Border radius: 16px
   - Centered horizontally
   - Position: 60px from bottom of safe area

#### Page 2: Tailscale OAuth

**Artboard:** 393x852 px
**Background:** System Background (white/black adaptive)

**Content:**
1. **Icon** (top, 48px from safe area)
   - 🔒 or lock icon (64px)
   - Centered

2. **Title** (24px margin top)
   - Text: "Connect to Tailscale"
   - SF Pro Rounded, 28px, Semibold
   - Centered

3. **Description** (12px margin top)
   - Text: "Sign in with your Tailscale account to create a secure VPN connection to your Mac."
   - SF Pro, 15px, Regular, Text Secondary
   - Centered, max width 320px, line height 1.5

4. **OAuth Buttons** (40px margin top, vertically stacked, 16px gap)
   - **GitHub Button:**
     - 343x52 px
     - Background: #24292E
     - Text: "Continue with GitHub" (White, 16px, Semibold)
     - Icon: GitHub logo (24px, left-aligned)
     - Border radius: 12px

   - **Google Button:**
     - Background: White
     - Border: 1px solid #E5E5E7
     - Text: "Continue with Google" (Text Primary, 16px, Semibold)
     - Icon: Google logo (24px)

   - **Microsoft Button:**
     - Background: #00A4EF
     - Text: "Continue with Microsoft" (White)
     - Icon: Microsoft logo

   - **Email Button:**
     - Background: #007AFF
     - Text: "Continue with Email" (White)
     - Icon: ✉️ (24px)

5. **Privacy Note** (bottom, 24px from safe area)
   - Text: "Your Tailscale credentials are never stored on this device"
   - SF Pro, 12px, Text Secondary
   - Centered, max width 300px

#### Page 3: Auto-Discovery

**Artboard:** 393x852 px
**Background:** System Background

**Content:**
1. **Loading Animation** (centered vertically)
   - 3 concentric circles (pulsing):
     - Inner: 80px, #007AFF, opacity 1.0
     - Middle: 120px, #007AFF, opacity 0.6
     - Outer: 160px, #007AFF, opacity 0.3
   - Animate: Scale from 0.9 to 1.1, 1.5s loop
   - Center icon: 📡 or radar (48px, white)

2. **Title** (80px below animation)
   - Text: "Discovering Devices"
   - SF Pro Rounded, 28px, Semibold
   - Centered

3. **Description** (12px margin top)
   - Text: "Looking for your Mac on the Tailscale network..."
   - SF Pro, 15px, Text Secondary
   - Centered

4. **Progress Checklist** (40px margin top)
   - **Step 1:**
     - ✅ "Connected to Tailscale" (15px, #34C759)
   - **Step 2:**
     - ⏳ "Scanning for devices..." (15px, #FF9500) + spinner
   - **Step 3:**
     - ○ "Connecting to Mac" (15px, Text Secondary, pending)
   - Vertical spacing: 16px between steps
   - Left-aligned, centered horizontally (max width 280px)

5. **Manual Entry Link** (bottom, 32px from safe area)
   - Text: "Enter Mac IP manually"
   - SF Pro, 15px, #007AFF
   - Centered
   - Underline on press

#### Page 4: API Key Entry

**Artboard:** 393x852 px
**Background:** System Background

**Content:**
1. **Icon** (top, 48px from safe area)
   - 🔑 or key icon (64px)
   - Centered

2. **Title** (24px margin top)
   - Text: "Enter API Key"
   - SF Pro Rounded, 28px, Semibold
   - Centered

3. **Description** (12px margin top)
   - Text: "Run the API server on your Mac and enter the key shown below."
   - SF Pro, 15px, Text Secondary
   - Centered, max width 320px

4. **Form Fields** (40px margin top)
   - **Mac Device** (read-only input)
     - Label: "Mac Device" (13px, Text Secondary, margin bottom 8px)
     - Input: 343x48 px
     - Text: "Roth MacBook Pro" (15px, Text Primary)
     - Background: #F5F5F7
     - Border radius: 10px
     - Disabled state (gray text)

   - **Tailscale IP** (read-only, 16px margin top)
     - Label: "Tailscale IP"
     - Input: "100.66.202.6" (SF Mono, 15px)
     - Same styling as above

   - **API Key** (user input, 16px margin top)
     - Label: "API Key"
     - Input: Secure field (password dots)
     - Placeholder: "Enter API key"
     - Background: #FFFFFF (Light) / #2C2C2E (Dark)
     - Border: 2px solid #E5E5E7
     - On focus: Border #007AFF

5. **Command Hint** (24px margin top)
   - Background: #F5F5F7 (Light) / #1C1C1E (Dark)
   - Padding: 12px
   - Border radius: 8px
   - Text: "cd /Users/Ty/BuilderOS/api && ./server_mode.sh"
   - Font: SF Mono, 12px
   - Color: Text Secondary
   - Copy button: Right-aligned (32px, #007AFF)

6. **Continue Button** (32px margin top)
   - Primary button: 343x52 px
   - Text: "Continue"
   - Disabled until API key entered

7. **Back Button** (top-left, 16px from edges)
   - Text: "< Back"
   - SF Pro, 17px, #007AFF

#### Page 5: Success

**Artboard:** 393x852 px
**Background:** System Background

**Content (vertically centered):**
1. **Success Icon**
   - Circle: 120x120 px
   - Background: rgba(52, 199, 89, 0.1)
   - Icon: ✅ or checkmark (72px, #34C759)
   - Centered
   - Animate: Scale from 0 to 1 with bounce

2. **Title** (40px margin top)
   - Text: "You're All Set!"
   - SF Pro Rounded, 32px, Bold
   - Color: #34C759
   - Centered

3. **Description** (16px margin top)
   - Text: "Your iPhone is now securely connected to your Mac via Tailscale. You can now access BuilderOS from anywhere."
   - SF Pro, 15px, Text Secondary
   - Centered, max width 320px, line height 1.5

4. **Feature List** (32px margin top)
   - 3 rows (icon + text):
     - 🔒 "End-to-end encrypted connection"
     - ⚡ "Auto-connect on app launch"
     - 📱 "Real-time capsule monitoring"
   - Spacing: 16px vertical between rows
   - Icon: 28px
   - Text: 15px, Text Primary
   - Left-aligned, centered horizontally (max width 280px)

5. **Go to Dashboard Button** (bottom, 32px from safe area)
   - Primary button: 343x56 px
   - Text: "Go to Dashboard"
   - SF Pro, 17px, Semibold

---

### 3.2 File: Dashboard Screen

**Page:** Dashboard (393x852 px artboard)

**Layout from top to bottom:**

1. **Pull-to-Refresh Indicator** (top, hidden until pull)
   - iOS standard spinner
   - 20px diameter
   - Centered horizontally
   - 12px from top of content

2. **Header** (24px from safe area top)
   - Large Title: "Dashboard" (34px, Bold)
   - Subtitle: "Last updated: 2m ago" (13px, Text Secondary)
   - Padding: 0 24px

3. **Connection Status Card** (24px margin top)
   - Frame: 343x80 px
   - Background: White (card component)
   - Border radius: 16px
   - Shadow: 0 2px 8px rgba(0,0,0,0.04)
   - Padding: 16px
   - Layout:
     - Status indicator: Connected (green dot + text)
     - Tailscale IP: "100.66.202.6" (SF Mono, 13px)
     - Uptime: "Active for 2h 34m" (12px, Text Secondary)

4. **Stats Grid** (16px margin top)
   - 2x2 grid of stat cards
   - Gap: 12px horizontal, 12px vertical
   - Each card: 165.5x100 px (to fit 343px width with 12px gap)

   **Card 1: Total Capsules**
   - Icon: 📦 in blue circle background
   - Value: "24"
   - Label: "Total Capsules"

   **Card 2: Active**
   - Icon: ✅ in green circle background
   - Value: "18"
   - Label: "Active"

   **Card 3: Testing**
   - Icon: 🧪 in orange circle background
   - Value: "4"
   - Label: "Testing"

   **Card 4: API Latency**
   - Icon: ⚡ in purple circle background
   - Value: "24ms"
   - Label: "API Latency"

5. **Section Header** (24px margin top)
   - Text: "Active Capsules" (22px, Semibold)
   - Right: "See All" link (15px, #007AFF)
   - Padding: 0 24px

6. **Capsule Grid** (16px margin top)
   - 2-column grid
   - Gap: 16px horizontal, 16px vertical
   - Each card: 163.5x140 px
   - Padding: 0 24px (outer container)

   **Example Capsule Cards:**

   **Card 1: BrandJack**
   - Status badge: Active (green)
   - Name: "BrandJack" (15px, Semibold)
   - Description: "Instagram automation" (12px, Text Secondary, 2 lines)
   - Tags: "automation" "social" (11px pills)

   **Card 2: BuilderOS Mobile**
   - Status badge: Development (blue)
   - Name: "BuilderOS Mobile"
   - Description: "iOS companion app"
   - Tags: "mobile" "ios"

   **Card 3: Jellyfin Server**
   - Status badge: Active (green)
   - Name: "Jellyfin Server"
   - Description: "Media streaming"
   - Tags: "media" "server"

   **Card 4: E-commerce**
   - Status badge: Testing (orange)
   - Name: "E-commerce"
   - Description: "Shopify store"
   - Tags: "shop" "web"

7. **Tab Bar** (bottom, fixed)
   - Use Tab Bar component from Component Library
   - Dashboard tab: Active state
   - 3 other tabs: Inactive state

---

### 3.3 File: Chat Terminal Screen

**Page:** Chat Terminal (393x852 px artboard)

**Layout:**

1. **Header** (fixed, top safe area)
   - Height: 56px
   - Background: System Background with blur
   - Border bottom: 0.5px solid rgba(0,0,0,0.05)
   - Padding: 0 16px
   - Layout:
     - Title: "BuilderOS Terminal" (17px, Semibold)
     - Subtitle: "🟢 Roth MacBook Pro" (13px, Text Secondary)

2. **Quick Actions Toolbar** (below header)
   - Height: 64px
   - Background: System Background Secondary
   - Padding: 12px 16px
   - Horizontal scroll (if needed)
   - Pills (auto-width, 36px height):
     - "Status" (#007AFF background, white text)
     - "Logs" (light gray background, text primary)
     - "Refresh" (light gray background)
     - "Metrics" (light gray background)
     - "Search" (light gray background)
   - Border radius: 18px per pill
   - Gap: 8px between pills
   - Padding: 6px horizontal, 8px vertical per pill
   - Font: 14px, Medium

3. **Messages Container** (scrollable, fills space)
   - Background: System Background
   - Padding: 16px horizontal, 12px vertical
   - Bottom-anchored (newest messages at bottom)

   **Example Messages:**

   **System Message 1:**
   - "Connected to BuilderOS API at 100.66.202.6:8080"
   - White bubble, left-aligned, shadow
   - Timestamp: "2:34 PM" (11px, gray, below bubble)

   **User Message 1:**
   - "Show me the status of all capsules"
   - Blue bubble, right-aligned
   - Timestamp: "2:34 PM" (below bubble, right-aligned)

   **System Message 2:**
   - "Executing: curl http://100.66.202.6:8080/api/capsules/status"
   - Code block inside bubble (gray background, SF Mono)

   **System Message 3:**
   - "Found 24 capsules: 18 active, 4 testing, 2 inactive"
   - White bubble with check icon

   **Status Message (centered):**
   - "Command completed successfully"
   - Light blue pill, centered, 13px text

4. **Input Container** (fixed, bottom)
   - Height: 88px (includes safe area)
   - Background: System Background with blur
   - Border top: 0.5px solid rgba(0,0,0,0.05)
   - Padding: 12px 16px (+ safe area)
   - Layout (horizontal):
     - **Voice Button** (left)
       - Circle: 44x44 px
       - Background: #007AFF
       - Icon: 🎤 (24px, white)
       - Shadow: 0 2px 8px rgba(0,122,255,0.3)

     - **Text Input** (middle, flex-grow)
       - Height: 44px
       - Background: #F5F5F7
       - Border radius: 22px
       - Placeholder: "Type a command..." (15px)
       - Padding: 0 16px
       - Margin: 0 8px (left/right)

     - **Send Button** (right)
       - Circle: 44x44 px
       - Background: #007AFF (if text entered) / #E5E5E7 (empty)
       - Icon: ➤ or paper airplane (24px, white)

5. **Recording Overlay** (modal, shown when recording)
   - Full screen overlay
   - Background: rgba(0, 0, 0, 0.8) blur
   - Center content:
     - **Waveform Animation:**
       - 5 vertical bars (8px width, variable height)
       - Colors: #007AFF
       - Animate: Up/down wave pattern
       - Height range: 20-80px
       - Spacing: 6px between bars
     - **Timer** (below waveform, 24px margin)
       - Text: "0:12" (SF Mono, 32px, White)
     - **Stop Button** (below timer, 40px margin)
       - Circle: 80x80 px
       - Border: 4px solid white
       - Center square: 32x32 px, red (#FF3B30)
       - Tap to stop recording

6. **Tab Bar** (bottom)
   - Chat tab: Active state

---

### 3.4 File: Settings Screen

**Page:** Settings (393x852 px artboard)

**Layout:** iOS grouped list style

1. **Header** (top safe area)
   - Large Title: "Settings" (34px, Bold)
   - Padding: 24px horizontal

2. **Scrollable Content** (system background)

**Section 1: Connection**
- Header: "CONNECTION" (13px, uppercase, Text Secondary, padding 16px)
- Background: White rounded rectangle (16px radius)
- Rows:

  **Row 1: Tailscale Status**
  - Left: "Tailscale Status"
  - Right: Connected badge (green)
  - Height: 56px
  - No chevron

  **Row 2: Auto-Connect**
  - Left: "Auto-Connect"
  - Right: Toggle switch (ON state, green)
  - Height: 56px
  - Divider line above (0.5px, rgba(0,0,0,0.05), padding 16px left)

**Section 2: Tailscale Devices** (24px margin top)
- Header: "TAILSCALE DEVICES"
- Background: White rounded rectangle
- Rows:

  **Row 1: Mac**
  - Left:
    - Name: "Roth MacBook Pro" (15px, Semibold)
    - IP: "100.66.202.6" (SF Mono, 13px, Text Secondary)
  - Right: "💻" badge (Mac type)
  - Chevron: >
  - Height: 64px

  **Row 2: iPhone**
  - Name: "Ty's iPhone 15 Pro"
  - IP: "100.120.45.201"
  - Right: "📱" badge
  - Divider above

  **Row 3: Raspberry Pi**
  - Name: "Wake Pi"
  - IP: "100.88.12.94"
  - Right: "🍓" badge
  - Divider above

**Refresh Button** (below section)
- Text: "Refresh Devices" (15px, #007AFF)
- Centered
- 48px height touch target
- Margin: 12px top

**Section 3: BuilderOS API** (24px margin top)
- Header: "BUILDEROS API"
- Background: White rounded rectangle
- Rows:

  **Row 1: API Key**
  - Left: "API Key"
  - Right: "••••••••••••" (13px, SF Mono, Text Secondary)
  - Chevron: >
  - Tap to edit modal
  - Height: 56px

  **Row 2: API Status**
  - Left: "API Status"
  - Right:
    - Text: "24ms" (13px, #34C759)
    - Icon: ✅
  - No chevron
  - Divider above

**Section 4: Mac Power Controls** (24px margin top)
- Header: "MAC POWER CONTROLS"
- Background: White rounded rectangle
- Rows:

  **Row 1: Sleep Mac**
  - Left: "Sleep Mac" (15px, #FF3B30 - destructive)
  - Right: Chevron
  - Tap: Confirmation alert
  - Height: 56px

  **Row 2: Wake Mac**
  - Left: "Wake Mac" (15px, Text Primary)
  - Right: Chevron
  - Tap: Instructions sheet (requires Raspberry Pi)
  - Divider above

**Section 5: App Settings** (24px margin top)
- Header: "APP SETTINGS"
- Background: White rounded rectangle
- Rows:

  **Row 1: Notifications**
  - Left: "Notifications"
  - Right: Toggle (ON)
  - Height: 56px

  **Row 2: Appearance**
  - Left: "Appearance"
  - Right: "Automatic" (13px, Text Secondary) + Chevron
  - Divider above

  **Row 3: Analytics**
  - Left: "Send Analytics"
  - Right: Toggle (OFF)
  - Divider above

**Section 6: About** (24px margin top)
- Header: "ABOUT"
- Background: White rounded rectangle
- Rows:

  **Row 1: Version**
  - Left: "Version"
  - Right: "1.0.0 (Build 1)" (13px, Text Secondary)
  - No chevron
  - Height: 56px

  **Row 2: Privacy Policy**
  - Left: "Privacy Policy"
  - Right: Chevron
  - Divider above

  **Row 3: Sign Out**
  - Center: "Sign Out" (15px, #FF3B30, Semibold)
  - No chevron
  - Tap: Confirmation alert
  - Divider above

**Bottom Padding:** 120px (for tab bar + safe area)

3. **Tab Bar** (bottom)
   - Settings tab: Active state

---

## Step 4: Export and Documentation

### 4.1 Export Artboards

For each screen file:
1. Select artboard
2. Right-click → "Export"
3. Format: PNG
4. Scale: 2x (for Retina)
4. Name: `{screen-name}-{variant}.png`

**Export List:**
- `onboarding-01-welcome.png`
- `onboarding-02-oauth.png`
- `onboarding-03-discovery.png`
- `onboarding-04-api-key.png`
- `onboarding-05-success.png`
- `dashboard-default.png`
- `dashboard-empty-state.png` (no capsules)
- `chat-terminal-default.png`
- `chat-terminal-recording.png`
- `settings-default.png`

### 4.2 Share Project

**Penpot Share Link:**
1. Open project in Penpot
2. Click "Share" button (top-right)
3. Enable "Anyone with the link can view"
4. Copy link
5. Format: `http://localhost:3449/#/view/{project-id}/{file-id}`

**Alternative: Direct file links**
- Design System: `http://localhost:3449/#/workspace/{file-id}`
- Dashboard: `http://localhost:3449/#/workspace/{file-id}`
- etc.

---

## Design System Token Export

### Color Tokens (JSON format for import)

```json
{
  "colors": {
    "brand": {
      "primary": "#007AFF",
      "secondary": "#5856D6",
      "tailscale": "#598FFF"
    },
    "status": {
      "success": "#34C759",
      "warning": "#FF9500",
      "error": "#FF3B30",
      "info": "#007AFF"
    },
    "semantic": {
      "light": {
        "textPrimary": "#1D1D1F",
        "textSecondary": "#6E6E73",
        "backgroundPrimary": "#FFFFFF",
        "backgroundSecondary": "#F5F5F7",
        "backgroundTertiary": "#FFFFFF"
      },
      "dark": {
        "textPrimary": "#FFFFFF",
        "textSecondary": "#A0A0A5",
        "backgroundPrimary": "#000000",
        "backgroundSecondary": "#1C1C1E",
        "backgroundTertiary": "#2C2C2E"
      }
    }
  }
}
```

### Typography Tokens

```json
{
  "typography": {
    "displayLarge": {
      "fontSize": "57px",
      "lineHeight": "1.05",
      "fontWeight": "700",
      "fontFamily": "SF Pro Rounded"
    },
    "displayMedium": {
      "fontSize": "45px",
      "lineHeight": "1.1",
      "fontWeight": "700",
      "fontFamily": "SF Pro Rounded"
    },
    "titleLarge": {
      "fontSize": "22px",
      "lineHeight": "1.2",
      "fontWeight": "600",
      "fontFamily": "SF Pro"
    },
    "bodyLarge": {
      "fontSize": "16px",
      "lineHeight": "1.4",
      "fontWeight": "400",
      "fontFamily": "SF Pro"
    },
    "monospacedMedium": {
      "fontSize": "14px",
      "lineHeight": "1.5",
      "fontWeight": "400",
      "fontFamily": "SF Mono"
    }
  }
}
```

### Spacing Tokens

```json
{
  "spacing": {
    "xs": "4px",
    "sm": "8px",
    "md": "12px",
    "base": "16px",
    "lg": "24px",
    "xl": "32px",
    "xxl": "48px"
  },
  "cornerRadius": {
    "xs": "4px",
    "sm": "8px",
    "md": "12px",
    "lg": "16px",
    "xl": "20px",
    "circle": "50%"
  }
}
```

---

## Tips for Efficient Penpot Workflow

### 1. Use Components
- Create each UI element as a reusable component
- Button variants as component states
- Drag components from library to screens

### 2. Use Styles Library
- Add all colors to color library (right-click color → "Add to library")
- Add all text styles to typography library
- Reuse consistently across all files

### 3. Use Layouts (Flexbox/Grid)
- Tab bar: Flexbox row, space-evenly
- Stats grid: Grid 2 columns, 12px gap
- Capsule grid: Grid 2 columns, 16px gap

### 4. Use Auto-layout
- Buttons: Padding 12px vertical, 24px horizontal
- Cards: Padding 16px or 20px
- Message bubbles: Padding 12px vertical, 16px horizontal

### 5. Layer Naming
- Use descriptive names: "Button/Primary/Default"
- Group related elements: "Header Group", "Stats Grid"
- Use folders for organization

### 6. Symbols and Nested Components
- Tab Bar Item as component (2 states: active/inactive)
- Reuse across all screens
- Update once, changes everywhere

---

## Verification Checklist

**Before considering project complete:**

- [ ] All 6 files created (Design System + 5 screens)
- [ ] All colors added to library (17 colors)
- [ ] All typography styles added (11 styles)
- [ ] All components created as reusable (15+ components)
- [ ] iPhone 15 Pro artboards correct size (393x852 px)
- [ ] Light AND Dark mode versions for key screens
- [ ] All text uses library styles (not custom)
- [ ] All colors use library tokens (not hex)
- [ ] Component variants created (button states, badge types)
- [ ] Exports generated (PNG 2x for all screens)
- [ ] Share links created and documented
- [ ] Project accessible at http://localhost:3449

---

## Next Steps After Creation

1. **Review with Mobile Dev:**
   - Share Penpot link
   - Walk through design system
   - Explain component usage
   - Clarify interaction patterns

2. **Generate Implementation Specs:**
   - Use Penpot MCP to extract object trees
   - Generate SwiftUI view specifications
   - Export design tokens for Swift code

3. **Iterate Based on Feedback:**
   - Adjust spacing/sizing as needed
   - Refine component states
   - Add missing variants

4. **Keep in Sync with Code:**
   - Update Penpot when design changes
   - Reference Penpot as source of truth
   - Export updated assets when needed

---

## Troubleshooting

**Q: Colors don't match iOS exactly**
- Use iOS color picker to sample exact values
- Reference Apple HIG color documentation
- Test in simulator for accuracy

**Q: SF Pro fonts not available in Penpot**
- Use Inter as fallback for SF Pro
- Use Fira Code for SF Mono
- Note in docs: "Use SF Pro in actual implementation"

**Q: How to create component variants?**
- Create first version (e.g., Button/Primary/Default)
- Duplicate → Modify → Group as variants
- OR use Penpot's component variant feature (if available)

**Q: Artboard sizes not precise?**
- Enter exact values: 393x852
- Use Penpot's measurement tools
- Verify with ruler guides

**Q: Can't see project in MCP tools?**
- Refresh Penpot instance
- Check project permissions
- Verify MCP server connection

---

## Resources

**Reference Documentation:**
- `/design/DESIGN_DOCUMENTATION.md` - Complete design specs
- `/design/*.html` - Interactive mockups
- `src/Utilities/Colors.swift` - Color definitions
- `src/Utilities/Typography.swift` - Typography styles
- `src/Utilities/Spacing.swift` - Spacing system

**Design References:**
- Apple Human Interface Guidelines (iOS 17)
- SF Symbols App (macOS)
- iOS 17 UI Kit (Figma Community - view only)

**Penpot Resources:**
- Penpot Documentation: https://help.penpot.app
- Penpot YouTube Channel: Tutorials
- Penpot Community Forum

---

**Created:** October 2025
**Version:** 1.0
**Maintained by:** UI/UX Designer Agent
**Project:** builder-system-mobile (BuilderOS Capsule)

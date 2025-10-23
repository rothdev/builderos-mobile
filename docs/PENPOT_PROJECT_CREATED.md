# Penpot Project Created: BuilderOS Mobile

## ✅ Project Creation Status: SUCCESS

**Date:** October 23, 2025
**Time:** 02:50 AM PST

---

## 📋 Project Details

| Property | Value |
|----------|-------|
| **Project Name** | BuilderOS Mobile |
| **Project ID** | `4c46a10f-a510-8112-8006-ff54c883093f` |
| **Team** | Default Team |
| **Team ID** | `9eeee28b-306e-80a2-8006-feeda886d52e` |
| **Created** | October 23, 2025 02:50:00 AM |
| **Status** | Active |
| **Files** | 0 (empty project, ready for design work) |

---

## 🔗 Access Links

**Penpot Dashboard:**
http://localhost:3449/#/dashboard/team/projects/4c46a10f-a510-8112-8006-ff54c883093f

**Main Projects View:**
http://localhost:3449/#/dashboard/recent

---

## 🎨 Next Steps: Design Workflow

### 1. Create Design Files

Navigate to the project in Penpot and create design files for:

- **iPhone Screens** (375x812pt - iPhone 13/14/15 Pro)
  - Onboarding screens
  - Dashboard view
  - Chat/Terminal interface
  - Localhost preview
  - Settings screen
  - Capsule detail view

- **iPad Screens** (834x1194pt - iPad Pro 11")
  - Split-view layouts
  - Enhanced dashboard
  - Multi-column views

### 2. Design System Components

Create a shared design library with:
- **Colors:** iOS semantic colors (Light + Dark mode)
- **Typography:** SF Pro Display/Text font system
- **Spacing:** 8pt grid system
- **Components:** Buttons, cards, inputs, navigation bars, tab bars
- **Icons:** SF Symbols integration

### 3. Recommended Penpot Templates

Available in Penpot to accelerate iOS design:

1. **Black & White Mobile Templates** - Clean iOS-style starting point
2. **UI mockup example** - Reference for mobile layouts
3. **Wireframe library** - Low-fidelity wireframing
4. **Prototype template** - Interactive prototyping patterns

### 4. iOS Design Guidelines Reference

**Apple Human Interface Guidelines:**
https://developer.apple.com/design/human-interface-guidelines/ios

**Key iOS 17+ Design Patterns:**
- **Navigation:** Large titles, inline navigation, tab bars
- **Materials:** Translucent backgrounds, vibrancy effects
- **Typography:** Dynamic Type support (accessibility)
- **Colors:** System colors that adapt to Light/Dark mode
- **Touch Targets:** Minimum 44x44pt for interactive elements
- **Gestures:** Swipe back, pull-to-refresh, long-press menus

---

## 🛠️ Integration with Development

### Exporting Designs to iOS

1. **Design in Penpot** (this project)
2. **Export assets** via Penpot MCP tools:
   ```python
   # Export component as PNG
   api.export_object(
       file_id="your-file-id",
       page_id="your-page-id",
       object_id="component-id",
       export_type="png",
       scale=2  # @2x for Retina
   )
   ```

3. **Use Penpot MCP for specs extraction:**
   - `mcp__penpot__get_object_tree` - Component hierarchy + screenshot
   - `mcp__penpot__export_object` - High-res image exports
   - `mcp__penpot__get_file` - Complete design data

4. **Handoff to iOS Developer:**
   - Design specs (spacing, colors, typography)
   - Component screenshots
   - Interactive prototype link
   - Penpot file access

### Design Tokens Export

Extract design tokens programmatically:

```python
from penpot_mcp.api.penpot_api import PenpotAPI

api = PenpotAPI(base_url="http://localhost:3449/api")
api.login_with_password()

# Get design file
file_data = api.get_file(file_id="your-file-id")

# Extract colors, typography, spacing
# (Custom script to parse Penpot JSON and generate Swift code)
```

---

## 📊 Project Management

### Current State
- ✅ Project created and verified
- ✅ Accessible via Penpot UI
- ✅ MCP tools can access project
- ⏳ No design files yet (ready to start)

### Workflow

1. **Design Phase** (Penpot)
   - Create screens in Penpot
   - Build component library
   - Create interactive prototypes

2. **Export Phase** (Penpot MCP)
   - Extract design specs
   - Export component images
   - Generate design tokens

3. **Implementation Phase** (Xcode)
   - Implement in SwiftUI
   - Reference Penpot designs
   - Match visual specs exactly

4. **Iteration Phase**
   - Designer updates Penpot
   - Developer syncs changes
   - Continuous refinement

---

## 🔍 Verification Commands

**List all projects:**
```bash
cd /Users/Ty/BuilderOS/global/penpot-mcp-extended
source .venv/bin/activate
python3 -c "
from penpot_mcp.api.penpot_api import PenpotAPI
from dotenv import load_dotenv
load_dotenv()
api = PenpotAPI(base_url='http://localhost:3449/api')
api.login_with_password()
projects = api.list_projects()
for p in projects:
    print(f\"{p['name']}: {p['id']}\")
"
```

**Get project files:**
```bash
python3 tools/create_penpot_project.py --list-files
```

---

## 📝 Notes

- **Local Penpot Instance:** Running at http://localhost:3449
- **Penpot MCP Server:** Available via Claude Code MCP integration
- **Design System Reference:** iOS 17+ Human Interface Guidelines
- **Target Devices:** iPhone (iOS 17+), iPad (iPadOS 17+)
- **Design Language:** Native iOS SwiftUI patterns

---

## ✨ Success Metrics

- [x] Project created successfully
- [x] Verified in Penpot UI (screenshot taken)
- [x] Accessible via Penpot MCP API
- [x] Ready for design work
- [ ] First design file created (next step)
- [ ] Component library established (future)
- [ ] Interactive prototype ready (future)
- [ ] Design handoff to iOS dev (future)

---

**Project successfully created and ready for iOS app design work!**

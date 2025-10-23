# Penpot Design File - Quick Start

## Status: Ready for Manual Import

The Penpot MCP server is currently unavailable, but all design files are ready for manual import into Penpot.

## 📦 What You Have

### Design Specifications
- **`penpot-design-spec.md`** (15KB) - Complete technical specifications
  - 393×852px artboard dimensions
  - Full color palette with exact hex values
  - Typography scale (JetBrains Mono font)
  - Spacing system (8pt grid)
  - Component specifications
  - Animation details
  - 3 import methods documented

### Visual References
- **`penpot-reference.html`** (22KB) - Interactive pixel-perfect reference
  - View in browser for exact visual reference
  - Toggle measurements on/off
  - Live animations preview
  
- **`penpot-artboard-only.png`** (215KB) - Screenshot of artboard
  - 393×852px iPhone dimensions
  - Terminal aesthetic (dark mode)
  - Ready to import as reference layer

- **`penpot-reference-full.png`** (73KB) - Full page with instructions

## 🚀 Quick Import (3 Methods)

### Method 1: Screenshot Import (Fastest - 5 minutes)

1. **Open Penpot** (penpot.app or self-hosted)
2. **Create Project:** "BuilderOS Mobile - Terminal UI"
3. **Create Artboard:** 393×852px
4. **Import Screenshot:**
   - Drag `penpot-artboard-only.png` into artboard
   - Use as reference layer
5. **Trace Components:**
   - Build native Penpot elements on top
   - Match colors, fonts, spacing exactly
   - Reference `penpot-design-spec.md` for exact values

**Time estimate:** 5-10 minutes for basic import, 1-2 hours for complete recreation

---

### Method 2: Manual Recreation (Most Accurate - 2-3 hours)

1. **Set Up Project**
   - Open `penpot-design-spec.md` in separate window
   - Create new Penpot project
   - Set artboard to 393×852px

2. **Import Design System**
   - Add color swatches:
     - Electric Cyan: `#60efff`
     - Rose Pink: `#ff6b9d`
     - Hot Red: `#ff3366`
     - Dark Navy: `#0a0e27`
     - Success Green: `#00ff88`
   - Create gradient swatch: Cyan→Pink→Red (135deg)
   - Import JetBrains Mono font (or use monospace fallback)
   - Create text styles for each size/weight

3. **Build Components (Bottom-Up)**
   - Start with smallest: buttons (36×36px circular)
   - Build cards: feature cards (170×100px with glassmorphism)
   - Build sections: header (393×60px), input bar (393×78px)
   - Build logo: 100×100px with border gradient
   - Assemble full artboard

4. **Add Effects**
   - Glassmorphism: backdrop-filter blur
   - Text gradients: use gradient fill + clip to text
   - Glows: outer shadow with color glow
   - Scanlines: overlay pattern (optional)

**Time estimate:** 2-3 hours for complete pixel-perfect recreation

---

### Method 3: HTML-to-Penpot (Experimental)

If Penpot supports HTML/SVG import:

1. Open `penpot-reference.html` in browser
2. Use browser dev tools to export as SVG
3. Import SVG into Penpot
4. Clean up and convert to native elements

**Note:** May require manual cleanup of effects and gradients.

---

## 🎨 Design Tokens (Quick Reference)

### Colors
```
Cyan:    #60efff
Pink:    #ff6b9d
Red:     #ff3366
BG Dark: #0a0e27
Success: #00ff88
```

### Typography (JetBrains Mono)
```
Logo:     72px / 800 (extrabold) / -2px letter-spacing
Title:    24px / 600 (semibold) / 1px letter-spacing
Body:     14px / 400 (regular) / 0.3px letter-spacing
Small:    12px / 400 (regular) / 0.3px letter-spacing
Status:   11px / 400 (regular) / 0.5px letter-spacing
```

### Spacing (8pt Grid)
```
xs:  4px
sm:  8px
md:  12px
lg:  16px
xl:  20px
2xl: 24px
```

### Component Sizes
```
Artboard:       393×852px
Status Bar:     393×54px
Header:         393×60px
Main Content:   393×660px
Input Bar:      393×78px
Logo:           100×100px
Feature Card:   ~170×100px
Button:         36×36px (circular)
```

---

## 📋 Import Checklist

Before you start:
- [ ] Have Penpot account ready (penpot.app or self-hosted)
- [ ] Downloaded JetBrains Mono font (or plan to use monospace fallback)
- [ ] Opened `penpot-design-spec.md` for reference
- [ ] Have `penpot-artboard-only.png` ready for import

During import:
- [ ] Created project: "BuilderOS Mobile - Terminal UI"
- [ ] Set artboard to 393×852px
- [ ] Imported color palette (5 colors + gradient)
- [ ] Set up text styles (6 sizes)
- [ ] Imported reference screenshot OR building from spec

After import:
- [ ] All colors match exactly (verify hex values)
- [ ] Typography scales correctly
- [ ] Spacing follows 8pt grid
- [ ] Gradients render smoothly (Cyan→Pink→Red)
- [ ] Components are reusable (buttons, cards, etc.)
- [ ] Exported design tokens for iOS implementation

---

## 🔧 Next Steps After Penpot Import

1. **Create Additional Screens**
   - Capsule list view
   - Agent coordination interface
   - System monitoring dashboard
   - Settings screen

2. **Export for iOS Implementation**
   - Design tokens → Swift code
   - Component specifications → SwiftUI views
   - Color palette → Color.xcassets
   - Typography → Font.swift

3. **Handoff to Mobile Dev**
   - Share Penpot file link
   - Provide design specs
   - Document interaction patterns
   - Define animation timing

---

## 🆘 Troubleshooting

**Problem:** JetBrains Mono font not available in Penpot
**Solution:** Use system monospace font as fallback (Courier, Monaco, SF Mono)

**Problem:** Gradients don't look right
**Solution:** Verify 135deg angle, check color stops at 0%, 50%, 100%

**Problem:** Glassmorphism effect not working
**Solution:** Use semi-transparent background + blur effect (if Penpot supports)

**Problem:** Can't match exact spacing
**Solution:** Use 8pt grid system, round to nearest 4px/8px increment

---

## 📞 Need Help?

**Resources:**
- Penpot Documentation: https://help.penpot.app/
- Design Spec: `penpot-design-spec.md` (complete specifications)
- Visual Reference: `penpot-reference.html` (open in browser)
- Original Preview: `mobile-app-preview.html` (see dark mode)

**When MCP is available:**
- Penpot MCP tools will enable programmatic design file creation
- Check MCP connection: Test with `list_projects` tool
- Re-run automated import when MCP is working

---

## ✅ Success Criteria

Your Penpot import is complete when:
- [ ] Artboard is exactly 393×852px
- [ ] All 5 main colors are accurate (verify hex values)
- [ ] Typography uses JetBrains Mono (or approved fallback)
- [ ] Spacing follows 8pt grid system
- [ ] Logo has gradient border (Cyan→Pink→Red)
- [ ] Feature cards have glassmorphism effect
- [ ] Components are reusable (button, card, header, input bar)
- [ ] Design tokens documented for export
- [ ] File is shareable with Mobile Dev for implementation

---

**Created:** 2025-10-22
**Status:** Ready for Manual Import
**Estimated Time:** 5 minutes (screenshot) to 3 hours (full recreation)
**MCP Status:** Unavailable (use manual methods)

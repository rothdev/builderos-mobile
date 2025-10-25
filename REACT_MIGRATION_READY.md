# BuilderOS Mobile → React Migration: Ready for Handoff

**Status:** ✅ Complete Design Specifications Ready
**Date:** October 24, 2025
**Next Agent:** 🎨 Frontend Dev (React/TypeScript specialist)

---

## What Was Completed

I've analyzed all SwiftUI screens and extracted complete design specifications for React migration. Everything Frontend Dev needs to recreate the app pixel-perfect is now documented.

### Documents Created

1. **`docs/REACT_MIGRATION_SPECS.md`** (600+ lines)
   - Complete design system foundation
   - Screen-by-screen breakdown (7 screens)
   - Component library specifications (8 reusable components)
   - Interaction patterns and animations
   - State management structure
   - Responsive behavior guidelines
   - SwiftUI → React translation guide

---

## What Frontend Dev Gets

### 1. Design System Foundation ✅

**Complete specifications for:**
- Color palette (12 terminal colors + semantic colors)
- Typography system (4 font families, 15 text styles)
- Spacing (8pt grid with 8 sizes)
- Border radius (6 presets)
- Icon sizes (5 sizes)
- Layout constants (touch targets, padding, heights)
- Animation system (durations + spring presets)

**Export formats included:**
- TypeScript constants
- CSS variables (light + dark mode)
- Tailwind config extension

### 2. Screen Specifications ✅

**All 7 screens fully documented:**

1. **OnboardingView** (3-step wizard)
   - Layout structure with ZStack layers
   - Step-by-step component breakdown
   - Logo design (glow + gradient border)
   - Form fields with validation states
   - Animation specifications

2. **MainContentView** (Tab navigation)
   - 4-tab layout
   - Tab bar styling
   - Navigation behavior

3. **DashboardView** (System overview)
   - Connection status card
   - System status card with 4-stat grid
   - Capsule grid (2 columns)
   - Empty states
   - Pull-to-refresh

4. **ChatView** (Terminal interface)
   - Header with connection status
   - Message list (user + system bubbles)
   - Voice input controls
   - Quick actions
   - Auto-scroll behavior

5. **LocalhostPreviewView** (WebView)
   - Connection header
   - Quick links (horizontal scroll)
   - Custom port input
   - WebView integration
   - Empty state

6. **SettingsView** (Configuration)
   - Tunnel configuration
   - API key management
   - Mac power controls
   - About section
   - Modal forms

7. **CapsuleDetailView** (Detail screen)
   - Header card
   - Description
   - Tags (horizontal scroll)
   - Metrics grid

### 3. Component Library ✅

**8 reusable terminal components fully specified:**

1. `TerminalCard` - Glassmorphic container
2. `TerminalButton` - Gradient action button
3. `TerminalTextField` - Styled input field
4. `TerminalGradientText` - Rainbow gradient text
5. `TerminalBorder` - Border utility modifier
6. `TerminalStatusBadge` - Pulsing status indicator
7. `TerminalSectionHeader` - Section title

**Each component includes:**
- TypeScript interface
- Usage example
- Complete styling specifications
- Behavior notes

### 4. Implementation Guidance ✅

**Provided:**
- Technology stack recommendations (Next.js, Tailwind, Framer Motion)
- 9-week implementation roadmap
- SwiftUI → React translation table (20+ mappings)
- Testing strategy (unit, integration, E2E, visual regression)
- Performance optimization tips
- Accessibility guidelines

### 5. State Management ✅

**Documented:**
- Global state structure (API client)
- Local state for each screen
- Data models (TypeScript interfaces)
- State update patterns

### 6. Interaction Patterns ✅

**Specified:**
- Gestures (pull-to-refresh, swipe-back, tap, long-press)
- Loading states (spinners, text indicators)
- Animations (navigation, button press, pulse, slide)
- Touch feedback

---

## Key Highlights

### Design System Extraction

✅ **Color System:**
- 4 primary terminal colors (cyan, green, pink, red)
- 3 background colors (dark, dark-transparent, input)
- 3 text colors (primary, dim, code)
- 2 border colors (header, input)
- 4 status colors (success, warning, error, info)
- Semantic colors for light/dark mode

✅ **Typography System:**
- 15 text styles (display, headline, title, body, label, mono)
- Font family mappings (SF Pro → Inter/system-ui)
- Monospace fonts (JetBrains Mono → JetBrains Mono/Fira Code)

✅ **Spacing System:**
- 8pt base grid
- 8 sizes (4px → 64px)
- Layout constants (touch targets, padding, heights)

✅ **Animation System:**
- 4 duration presets (150ms → 500ms)
- 3 spring presets (fast, normal, bouncy)
- Framer Motion equivalents

### Screen Analysis

✅ **OnboardingView:**
- 3-step wizard flow
- Logo with glow + gradient border (120x120)
- Form validation states
- Connection testing UI

✅ **DashboardView:**
- Connection status card (expandable)
- System status card (4-stat grid)
- Capsule grid (2 columns, flexible)
- Empty state illustration

✅ **ChatView:**
- Message bubbles (user: 75% width, right-aligned)
- System messages (full width, left-aligned)
- Voice input with pulse animation
- Auto-scroll to bottom

✅ **LocalhostPreviewView:**
- 5 quick links (horizontal scroll)
- Custom port input + go button
- WebView integration (iframe equivalent)
- Empty state with globe icon

✅ **SettingsView:**
- 4 sections (tunnel, API, power, about)
- Form inputs with validation
- Power controls (sleep/wake)
- Modal API key input

### Component Library

✅ **8 Components Specified:**
- `TerminalCard` - 16px padding, ultraThinMaterial blur, 12px radius
- `TerminalButton` - Gradient background, 50px height, cyan glow
- `TerminalTextField` - Cyan text, dark background, 10px radius
- `TerminalGradientText` - Cyan → pink → red gradient, letter-spacing 1px
- `TerminalBorder` - 1px border utility, customizable color/radius
- `TerminalStatusBadge` - 8px dot + text, pulse animation
- `TerminalSectionHeader` - 15px bold cyan uppercase

---

## Next Steps for Frontend Dev

### Phase 1: Setup (Week 1)
1. Review `REACT_MIGRATION_SPECS.md` thoroughly
2. Ask clarifying questions
3. Set up Next.js/Vite project with TypeScript
4. Configure Tailwind CSS with design tokens
5. Install Framer Motion for animations

### Phase 2: Design System (Week 1)
1. Create color tokens (CSS variables)
2. Set up typography system
3. Configure spacing and layout constants
4. Create animation presets

### Phase 3: Component Library (Week 1-2)
1. Build 8 core terminal components
2. Create Storybook stories
3. Test in isolation
4. Document usage

### Phase 4: Screens (Week 2-5)
1. **Week 2:** OnboardingView + Tab Navigation
2. **Week 3:** DashboardView + SettingsView
3. **Week 4:** LocalhostPreviewView
4. **Week 5:** ChatView + CapsuleDetailView

### Phase 5: Polish (Week 5-6)
1. Responsive behavior (iPhone, iPad)
2. Accessibility (VoiceOver, Dynamic Type)
3. Performance optimization
4. Visual regression testing

---

## Technical Details

### SwiftUI → React Mappings

| SwiftUI | React | Implementation |
|---------|-------|----------------|
| `VStack` | Flexbox | `display: flex; flex-direction: column` |
| `HStack` | Flexbox | `display: flex; flex-direction: row` |
| `ZStack` | Positioning | `position: relative` with absolute children |
| `Spacer()` | Flex | `flex: 1` |
| `NavigationStack` | Router | React Router / Next.js router |
| `TabView` | State | Custom tab component + router |
| `.sheet()` | Portal | React Portal for modals |
| `@State` | Hook | `useState()` |
| `@EnvironmentObject` | Context | Context API / Zustand |
| `.onAppear()` | Effect | `useEffect(() => {}, [])` |
| `LazyVGrid` | Grid | `display: grid` |
| `.ultraThinMaterial` | Blur | `backdrop-filter: blur(20px)` |
| `LinearGradient` | CSS | `linear-gradient()` |
| SF Symbols | Icons | React Icons / Heroicons |
| `withAnimation()` | Framer | Framer Motion `animate` |

### Recommended Stack

**Core:**
- Next.js 14+ or Vite + React 18+
- TypeScript for type safety

**Styling:**
- Tailwind CSS + custom design tokens
- PostCSS for CSS variables

**UI:**
- Radix UI or Headless UI (accessible primitives)
- Framer Motion (animations)
- React Icons (SF Symbol equivalents)

**State:**
- Zustand or Context API (global)
- React hooks (local)

**API:**
- Axios or fetch with async/await
- React Query (optional, for caching)

**Testing:**
- Jest + React Testing Library (unit)
- Cypress or Playwright (E2E)
- Percy or Chromatic (visual regression)

---

## Design Assets Included

### In `REACT_MIGRATION_SPECS.md`:

✅ **Color Palette:**
- TypeScript constants
- CSS variables (light + dark)
- Tailwind config

✅ **Typography:**
- 15 text styles with sizes, weights, line-heights
- Font family mappings

✅ **Component Specs:**
- TypeScript interfaces
- Usage examples
- Complete styling

✅ **Screen Layouts:**
- ASCII-style layout trees
- Component hierarchies
- Spacing specifications

✅ **Animation Definitions:**
- Duration constants
- Spring configurations (Framer Motion)
- Transition specifications

---

## Questions to Answer Before Starting

1. **React Framework:** Next.js (SSR/SSG) or Vite (SPA)?
2. **Styling:** Tailwind CSS, Styled Components, or CSS Modules?
3. **State Management:** Zustand, Context API, or Redux?
4. **Routing:** React Router or Next.js router?
5. **Icon Library:** React Icons, Heroicons, or Lucide?
6. **Testing:** Jest + RTL + Cypress, or Vitest + Playwright?
7. **Deployment:** Vercel, Netlify, or custom?

---

## Success Criteria

✅ **Visual Parity:**
- All screens match SwiftUI screenshots pixel-perfect
- Colors, fonts, spacing identical
- Animations smooth and accurate

✅ **Functional Parity:**
- All interactions work (tap, swipe, scroll)
- Navigation flows correctly
- Forms validate properly
- API integration works

✅ **Performance:**
- First Contentful Paint < 1s
- Time to Interactive < 2s
- 60fps animations

✅ **Accessibility:**
- WCAG AA compliance
- Keyboard navigation
- Screen reader support
- Dynamic Type scaling

✅ **Responsiveness:**
- iPhone portrait (375-428px)
- iPhone landscape
- iPad portrait/landscape
- Safe area handling

---

## Contact & Support

**Document Location:**
`/Users/Ty/BuilderOS/capsules/builderos-mobile/docs/REACT_MIGRATION_SPECS.md`

**Screenshots Reference:**
`.playwright-mcp/*.png` (existing SwiftUI screenshots)

**Penpot Designs:**
http://localhost:3449/#/dashboard/projects/builderos-mobile

**Original SwiftUI Code:**
`src/Views/*.swift`
`src/Components/*.swift`
`src/Utilities/*.swift`

---

**Ready to delegate to 🎨 Frontend Dev!**

Frontend Dev has everything needed to recreate the BuilderOS Mobile app in React with pixel-perfect accuracy. All design decisions are documented, all components are specified, and a complete implementation roadmap is provided.

Next step: Frontend Dev reviews the specs, asks clarifying questions, and begins implementation. 🚀

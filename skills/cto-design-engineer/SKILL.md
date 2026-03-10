# Design Engineer Sub-Skill

> Activated by the CTO orchestrator when a task involves UI/UX review, accessibility, design systems, component architecture, or frontend performance. You bridge the gap between design and engineering — you care about both how it looks AND how it's built.

---

## Trigger

Routed here by the CTO orchestrator for tasks involving:
- UI/UX review and improvement suggestions
- Accessibility audits (WCAG 2.1)
- Design system consistency checks
- Component architecture review
- Frontend performance optimization (Core Web Vitals)
- Mobile responsiveness assessment
- Visual regression and polish

---

## UI/UX Review

When reviewing a user interface or user experience:

### UX Review Framework

Evaluate in this order (most impactful first):

#### 1. Task Completion
- Can the user accomplish their primary goal without confusion?
- Are there dead ends where the user gets stuck with no clear next step?
- Is the happy path obvious and the error path graceful?
- How many clicks/steps does the primary flow take? Can it be fewer?

#### 2. Information Hierarchy
- Is the most important information the most visually prominent?
- Can a user scan the page and understand its purpose in 3 seconds?
- Are related items grouped together? Are unrelated items visually separated?
- Is there too much information competing for attention?

#### 3. Interaction Feedback
- Does every action provide feedback? (button click, form submit, loading state)
- Are loading states informative? (skeleton screens > spinners > nothing)
- Are error messages helpful? ("Email is required" > "Validation error" > red border with no text)
- Are success states clear? (confirmation message, visual change, redirect)

#### 4. Consistency
- Are similar elements styled consistently across pages?
- Do interactive elements (buttons, links, inputs) behave the same everywhere?
- Is the visual language consistent (spacing, typography, color usage)?
- Does the vocabulary match across the app? (same thing is never called two different names)

#### 5. Edge Cases
- What happens with empty states? (no data, first-time user, no results)
- What happens with very long content? (overflow, truncation, responsive behavior)
- What happens with very short content? (does the layout hold up?)
- What does it look like on slow connections? (progressive loading, image placeholders)

### UX Review Report Format

```
## UX Review: [Page/Feature Name]

### What Works Well
- [Positive observation with specific reference]
- [Positive observation with specific reference]

### Issues Found
1. **[Issue title]** — Severity: [Critical/High/Medium/Low]
   - Location: [where in the UI]
   - Problem: [what's wrong and why it matters]
   - Recommendation: [specific fix]

### Recommendations
- Quick wins (< 1 hour each): [list]
- Medium effort (1-4 hours each): [list]
- Larger improvements (> 4 hours each): [list]
```

---

## Accessibility Audit (WCAG 2.1)

When performing an accessibility review:

### Accessibility Checklist

#### Perceivable (Can users perceive the content?)

- [ ] **Images:** All `<img>` tags have meaningful `alt` text (decorative images use `alt=""`). Icons used as buttons have accessible labels.
- [ ] **Color contrast:** Text meets minimum contrast ratios (4.5:1 for normal text, 3:1 for large text). Check with a contrast checker tool.
- [ ] **Color independence:** Information is not conveyed by color alone (e.g., form errors use icon + text, not just red border).
- [ ] **Text sizing:** Text can be resized to 200% without loss of content or functionality. No text in images.
- [ ] **Media:** Videos have captions. Audio has transcripts. Animations have pause controls.
- [ ] **Responsive:** Content reflows properly at 320px width without horizontal scrolling.

#### Operable (Can users operate the interface?)

- [ ] **Keyboard navigation:** All interactive elements are reachable and operable via keyboard (Tab, Enter, Space, Arrow keys, Escape).
- [ ] **Focus indicators:** Visible focus outlines on all interactive elements. Never `outline: none` without a replacement.
- [ ] **Skip links:** "Skip to content" link available for keyboard users to bypass navigation.
- [ ] **No keyboard traps:** Users can Tab into and out of every component (modals, dropdowns, date pickers).
- [ ] **Timing:** No time limits on interactions, or users can extend/disable them. No auto-advancing content without pause control.
- [ ] **Motion:** Reduced motion media query respected (`prefers-reduced-motion`). No content that flashes more than 3 times per second.

#### Understandable (Can users understand the content?)

- [ ] **Language:** Page `lang` attribute is set correctly. Language changes in content are marked.
- [ ] **Form labels:** Every input has a visible, associated `<label>`. Placeholder text does not replace labels.
- [ ] **Error identification:** Form errors are specific ("Email must include @ symbol"), appear near the field, and are announced to screen readers.
- [ ] **Consistent navigation:** Navigation is in the same location and order across pages. Interactive elements behave predictably.
- [ ] **Error prevention:** For critical actions (delete, payment, legal), provide confirmation dialogs or undo capability.

#### Robust (Is it built to last?)

- [ ] **Valid HTML:** Proper semantic markup (headings in order, lists for lists, buttons for actions, links for navigation).
- [ ] **ARIA usage:** ARIA is used correctly and only when native HTML isn't sufficient. `role`, `aria-label`, `aria-describedby`, `aria-live` for dynamic content.
- [ ] **Screen reader testing:** Content makes sense when read linearly. Dynamic updates are announced.
- [ ] **Browser/AT compatibility:** Tested with at least one screen reader (VoiceOver, NVDA, or JAWS).

### Accessibility Issue Severity

| Severity | Definition | Example |
|----------|-----------|---------|
| **Critical** | Blocks users from completing a task entirely | Form submit button not keyboard accessible, modal traps focus permanently |
| **High** | Significantly impairs usability for assistive tech users | Missing form labels, no focus indicators, images without alt text |
| **Medium** | Causes difficulty but workarounds exist | Poor color contrast on secondary text, heading level skipped |
| **Low** | Minor issue, doesn't block functionality | Decorative image with unnecessary alt text, redundant ARIA role |

---

## Design System Consistency

When reviewing design system adherence:

### Design Token Audit

Check that the implementation matches the design system tokens:

1. **Colors:** Are all colors from the design system palette? Flag any hex/rgb values that don't match a token.
2. **Typography:** Are font sizes, weights, and line heights using design tokens? Flag any arbitrary values.
3. **Spacing:** Is spacing consistent and using the scale (4px, 8px, 12px, 16px, 24px, 32px, 48px, 64px)? Flag arbitrary padding/margin values.
4. **Border radius:** Are border radii consistent and from the token set?
5. **Shadows:** Are box shadows from the design system? Flag custom shadow values.
6. **Breakpoints:** Are responsive breakpoints consistent across components?

### Component Inventory

When the customer wants to understand their component landscape:

```
## Component Inventory: [Date]

### Component Count
- Total unique components: [N]
- Shared/reusable components: [N]
- Page-specific components: [N]
- Duplicate or near-duplicate components: [N] (candidates for consolidation)

### Consistency Issues
1. [Component A and Component B do the same thing differently]
2. [Component C uses hardcoded values instead of design tokens]

### Recommendations
- Consolidate: [list of components that should be merged]
- Extract: [list of patterns that should become shared components]
- Deprecate: [list of components that should be replaced]
```

---

## Component Architecture Review

When reviewing frontend component structure:

### Component Quality Checklist

- [ ] **Single responsibility:** Does each component do one thing well? Components over 200 lines likely need splitting.
- [ ] **Props interface:** Are props well-typed? Are required vs optional props clear? Are there too many props (> 8 suggests the component needs decomposition)?
- [ ] **State management:** Is state lifted to the right level? Is there unnecessary prop drilling? Would context or a state management library help?
- [ ] **Composition:** Are components composable via children/slots rather than configured via massive prop objects?
- [ ] **Error boundaries:** Do components handle errors gracefully? (loading states, error states, empty states)
- [ ] **Reusability:** Could this component be used in another context? If not, is that intentional?
- [ ] **Performance:** Are expensive renders memoized where appropriate? Are large lists virtualized?

### Component Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| God component (500+ lines) | Hard to maintain, test, and reason about | Split into smaller, focused components |
| Prop drilling (5+ levels) | Fragile, verbose, hard to refactor | Use React Context, Zustand, or composition |
| Inline styles everywhere | No consistency, no design system, hard to theme | Use design tokens via CSS variables or utility classes |
| Business logic in components | Couples logic to presentation, hard to test | Extract to hooks, services, or utility functions |
| Conditional rendering soup | Nested ternaries, unreadable render logic | Extract conditions to named variables or sub-components |
| Fetching data in every component | Waterfall requests, inconsistent loading states | Centralize data fetching, use React Query or SWR |

---

## Performance Optimization (Core Web Vitals)

When optimizing frontend performance:

### Core Web Vitals Targets

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| **LCP** (Largest Contentful Paint) | < 2.5s | 2.5s - 4.0s | > 4.0s |
| **INP** (Interaction to Next Paint) | < 200ms | 200ms - 500ms | > 500ms |
| **CLS** (Cumulative Layout Shift) | < 0.1 | 0.1 - 0.25 | > 0.25 |

### Performance Optimization Checklist

#### LCP (Make it load fast)
- [ ] Images: Use appropriate format (WebP/AVIF), set explicit width/height, lazy-load below-fold images, preload hero image
- [ ] Fonts: Use `font-display: swap`, preload critical fonts, subset if possible
- [ ] JavaScript: Code-split by route, defer non-critical JS, remove unused dependencies
- [ ] CSS: Inline critical CSS, defer non-critical stylesheets, remove unused CSS
- [ ] Server: Use CDN, enable compression (Brotli > gzip), cache static assets aggressively

#### INP (Make it feel responsive)
- [ ] Event handlers: No heavy computation in click/input handlers — defer to requestIdleCallback or web workers
- [ ] Rendering: Virtualize long lists (react-window, @tanstack/virtual), avoid rendering off-screen content
- [ ] State updates: Batch state updates, use `startTransition` for non-urgent updates (React 18+)
- [ ] Third-party scripts: Defer analytics, chat widgets, and tracking scripts — they compete for main thread

#### CLS (Make it stable)
- [ ] Images and ads: Always set explicit width and height (or aspect-ratio)
- [ ] Fonts: Reserve space with `font-display: optional` or `size-adjust`
- [ ] Dynamic content: Never insert content above existing content after page load
- [ ] Animations: Use `transform` and `opacity` only — avoid animating `width`, `height`, `top`, `left`

---

## Mobile Responsiveness Assessment

When reviewing mobile experience:

### Mobile Checklist

- [ ] **Touch targets:** All interactive elements are at least 44x44px with 8px spacing between targets
- [ ] **Viewport:** `<meta name="viewport" content="width=device-width, initial-scale=1">` is set
- [ ] **Horizontal scroll:** No horizontal scrolling at any viewport width from 320px to 1440px
- [ ] **Text readability:** Body text is at least 16px on mobile (prevents iOS zoom on input focus)
- [ ] **Navigation:** Primary navigation is accessible on mobile (hamburger menu, bottom nav, or similar)
- [ ] **Forms:** Input types are correct (`type="email"`, `type="tel"`, `type="number"`) to show appropriate mobile keyboard
- [ ] **Gestures:** Swipe, pinch-to-zoom, and other gestures don't conflict with browser defaults
- [ ] **Orientation:** Layout works in both portrait and landscape

### Design Review Report Template

```
## Design Review: [Page/Feature Name]
**Reviewer:** [Name] (AI CTO - Design Engineer)
**Date:** [current date]

### Scores
- Accessibility: [Pass/Fail with count of issues by severity]
- Design Consistency: [High/Medium/Low]
- Mobile Readiness: [High/Medium/Low]
- Performance: [LCP/INP/CLS scores or estimates]

### Critical Issues (must fix)
1. [Issue with specific location and recommended fix]

### Improvements (should fix)
1. [Issue with specific location and recommended fix]

### Nice-to-haves
1. [Suggestion with rationale]

### Overall Assessment
[2-3 sentence summary of the design quality and top priorities]
```


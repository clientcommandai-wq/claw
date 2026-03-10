# UI Review Skill

**Purpose:** Conduct thorough visual design reviews. Covers spacing, alignment, typography, color usage, layout across breakpoints, interaction design, dark mode consistency, and visual performance.

---

## When This Skill Activates

The `design-engineer` orchestrator routes here when:
- A page or component needs visual QA
- A design implementation needs to be compared against a Figma file
- Responsive behavior needs testing across viewports
- A visual regression is reported
- General "does this look right?" review

---

## Review Process

### Phase 1: First Impression (5-Second Test)

Before analyzing details, look at the page/component as a whole:

1. **Where does your eye go first?** Is it the right thing? (Should be the primary action or key content)
2. **Can you tell what this page does** without reading any text? (Visual hierarchy should communicate purpose)
3. **Does anything feel "off"?** Trust your instinct — if something looks wrong, it probably is
4. **Is it clear what to do next?** (Primary action should be obvious)

Document your first impressions before diving into the checklist. First impressions mirror what real users experience.

---

### Phase 2: Visual Consistency Audit

#### Spacing

Check that spacing follows the design system's scale consistently:

| What to Check | Common Issues |
|---------------|---------------|
| **Margins between sections** | Inconsistent gaps between content blocks |
| **Padding within containers** | Cards or panels with uneven internal padding |
| **Gap between form elements** | Labels too close or too far from inputs |
| **Spacing between list items** | Uneven rhythm in repeated elements |
| **Icon-to-text spacing** | Icons touching text or floating too far away |
| **Button internal padding** | Text too close to button edges |

**How to verify:** Measure actual rendered spacing against the design system tokens. If the system uses 4px/8px/12px/16px/24px/32px/48px steps, there should be no 13px or 22px values.

#### Alignment

| What to Check | Common Issues |
|---------------|---------------|
| **Baseline alignment** | Text at different vertical positions in the same row |
| **Left edge alignment** | Content not aligned to the same left edge within a section |
| **Center alignment** | Visually off-center (optical vs. mathematical center) |
| **Grid alignment** | Elements not snapping to the column grid |
| **Icon alignment** | Icons not vertically centered with adjacent text |

**How to verify:** Draw imaginary vertical and horizontal lines. Elements that should align should touch the same line.

#### Typography

| What to Check | Expected |
|---------------|----------|
| **Heading hierarchy** | h1 > h2 > h3 — size AND weight should decrease consistently |
| **Body text size** | Minimum 16px for body text on desktop, 14px absolute minimum for secondary text |
| **Line height** | 1.4-1.6 for body text, 1.1-1.3 for headings |
| **Letter spacing** | Tighter for headings, default or slightly loose for body |
| **Font weight usage** | Limited to 2-3 weights (regular, medium, bold). No random 300/600/800 mixing |
| **Consistent font family** | Same family throughout unless the design system defines multiple |
| **Truncation** | Long text truncates with ellipsis, not by clipping or wrapping awkwardly |
| **Max line length** | 60-80 characters for body text (readability) |

#### Color

| What to Check | Common Issues |
|---------------|---------------|
| **Brand color usage** | Wrong shade of brand color (design system defines the exact values) |
| **Semantic colors** | Red for errors, green for success, yellow/amber for warnings — consistent everywhere |
| **Gray palette** | Too many different grays. Pick from the design system's palette, not eyedropped values |
| **Text on backgrounds** | Insufficient contrast (see accessibility audit for exact ratios) |
| **State colors** | Hover, active, focus, disabled — all defined and consistent |
| **Link colors** | Distinguishable from body text, consistent everywhere |

---

### Phase 3: Layout Review Across Breakpoints

Test at these viewports at minimum:

| Viewport | Width | Key Concerns |
|----------|-------|--------------|
| **Small mobile** | 375px | Touch targets, single column, no horizontal scroll |
| **Large mobile** | 428px | Same as small mobile, verify nothing breaks at wider phone |
| **Tablet portrait** | 768px | Column layout transitions, sidebar behavior |
| **Tablet landscape** | 1024px | Content width, image scaling |
| **Desktop** | 1280px | Full layout, multi-column, proper use of space |
| **Large desktop** | 1920px | Content not stretching too wide, proper max-width constraints |

#### What to Check at Each Breakpoint

1. **Content reflow** — Does the layout adapt logically? (3 columns to 2 to 1, not random reshuffling)
2. **No horizontal scrollbar** — Content stays within the viewport width
3. **Touch targets** — On mobile, interactive elements are at least 44x44px
4. **Text readability** — Font sizes adjust appropriately (not tiny on mobile, not massive on desktop)
5. **Image scaling** — Images resize proportionally, no stretching or cropping critical content
6. **Navigation** — Desktop nav collapses to mobile-appropriate pattern (hamburger, bottom nav, etc.)
7. **Forms** — Input fields are full-width on mobile, labels positioned appropriately
8. **Tables** — Responsive handling (scroll, reflow, or card view on mobile)
9. **Modals** — Full-screen on mobile, centered overlay on desktop
10. **White space** — Appropriate for the viewport (less padding on mobile, more on desktop)

---

### Phase 4: Interaction Design Review

#### States

Every interactive element should have these states defined:

| State | Visual Treatment | Required For |
|-------|-----------------|-------------|
| **Default** | Resting state | All interactive elements |
| **Hover** | Visual change on mouse hover | Buttons, links, cards, rows |
| **Focus** | Visible focus ring/outline | ALL interactive elements (keyboard navigation) |
| **Active/Pressed** | Brief visual feedback on click/tap | Buttons, toggles |
| **Disabled** | Visually muted, cursor: not-allowed | Form inputs, buttons |
| **Loading** | Spinner, skeleton, or progress indicator | Buttons that trigger async actions |
| **Error** | Red border/text/icon | Form inputs with validation |
| **Success** | Green confirmation | Form submissions, actions |

#### Transitions and Animations

| What to Check | Standard |
|---------------|----------|
| **Duration** | 150-300ms for micro-interactions, 300-500ms for page transitions |
| **Easing** | ease-out for entrances, ease-in for exits, ease-in-out for state changes |
| **Properties** | Animate transform and opacity (GPU-accelerated). Avoid animating width, height, top, left (triggers layout) |
| **Reduced motion** | All animations must be disabled or simplified when `prefers-reduced-motion: reduce` is active |
| **Purpose** | Every animation should guide attention or provide feedback. Decorative animation should be removable |

#### Loading States

| Pattern | When to Use |
|---------|------------|
| **Skeleton screen** | Content loading. Matches the shape of the expected content. |
| **Spinner** | Short actions (< 3 seconds). Centered in the context of the action. |
| **Progress bar** | Long actions with measurable progress (file upload, data processing). |
| **Optimistic UI** | Instant feedback with background sync (likes, toggles). Must handle failure gracefully. |
| **Inline loading** | Button loading states. Replace the label with a spinner, keep the button disabled. |

---

### Phase 5: Dark Mode / Theme Consistency

If the product supports dark mode or multiple themes:

| What to Check | Common Issues |
|---------------|---------------|
| **Background colors** | Not pure black (#000). Use dark grays (#111, #1a1a1a) for eye comfort |
| **Text contrast** | White text on dark backgrounds should still meet 4.5:1 ratio |
| **Shadows** | Box shadows that work on light mode are invisible on dark mode — use subtle lighter borders instead |
| **Images** | Some images need dark mode variants (diagrams, illustrations with white backgrounds) |
| **Form inputs** | Input backgrounds should be distinguishable from the page background |
| **Borders** | Light-mode borders may be invisible in dark mode. Use theme-aware border colors |
| **Status colors** | Red/green/yellow may need adjustment for dark backgrounds (slightly brighter/more saturated) |

---

### Phase 6: Visual Performance

Visual choices affect performance. Check:

| Element | Concern | Standard |
|---------|---------|----------|
| **Images** | File size | < 200KB per image. Use WebP/AVIF where supported. Use srcset for responsive sizes. |
| **Icons** | Delivery method | SVG inline or SVG sprite sheet. No icon fonts (poor accessibility). |
| **Fonts** | Loading strategy | font-display: swap. Preload critical fonts. Limit to 2-3 font files. |
| **Animations** | Performance | CSS transforms/opacity only. No JS for what CSS can do. Test on low-end devices. |
| **DOM depth** | Render performance | Avoid deeply nested DOM trees (>15 levels). Simplify markup. |
| **CSS** | Bundle size | Check for unused CSS. Purge in production builds. |

---

## UI Review Checklist

### Visual Consistency
- [ ] Spacing follows the design system scale (no arbitrary pixel values)
- [ ] Alignment is consistent (elements that should align do align)
- [ ] Typography hierarchy is clear and consistent
- [ ] Colors match the design system palette
- [ ] Interactive states are defined for all clickable elements
- [ ] Icons are consistent in size, weight, and style

### Responsive Behavior
- [ ] Tested at 375px, 768px, 1280px minimum
- [ ] No horizontal scroll at any viewport
- [ ] Touch targets are 44x44px minimum on mobile
- [ ] Layout transitions are logical (not abrupt or broken)
- [ ] Text is readable at all viewports

### Interaction Design
- [ ] All interactive elements have hover, focus, active, and disabled states
- [ ] Loading states exist for all async operations
- [ ] Error states are clear and actionable
- [ ] Empty states are designed (not just blank pages)
- [ ] Transitions are smooth (150-300ms, ease-out entry, ease-in exit)

### Visual Performance
- [ ] Images are optimized (< 200KB, correct format)
- [ ] Fonts are loaded with font-display: swap
- [ ] Animations use CSS transforms/opacity only
- [ ] No layout shift on page load (CLS < 0.1)

### Theme Support (if applicable)
- [ ] Dark mode renders correctly
- [ ] No contrast violations in either theme
- [ ] Form inputs are visible in both themes
- [ ] Shadows and borders work in both themes

---

## Reporting Format

When reporting UI review findings, use this structure:

```
## UI Review: [Page/Component Name]

### Summary
[1-2 sentence overview of overall quality]

### Critical Issues (Must Fix)
1. [Issue] — [Location] — [Suggested Fix]

### Important Issues (Should Fix)
1. [Issue] — [Location] — [Suggested Fix]

### Minor Issues (Nice to Fix)
1. [Issue] — [Location] — [Suggested Fix]

### What Looks Good
- [Positive observation]
- [Positive observation]
```

Always include positive observations. Teams are more receptive to feedback when it's balanced.


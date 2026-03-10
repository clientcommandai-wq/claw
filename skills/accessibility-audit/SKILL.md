# Accessibility Audit Skill

**Purpose:** Conduct comprehensive accessibility audits against WCAG 2.1 Level AA standards. Covers keyboard navigation, screen reader compatibility, color contrast, form accessibility, motion sensitivity, and semantic structure.

---

## When This Skill Activates

The `design-engineer` orchestrator routes here when:
- A full accessibility audit is requested
- An accessibility complaint or issue is reported
- A new component or page needs accessibility verification
- WCAG compliance status needs to be assessed
- An accessibility regression is suspected

---

## WCAG 2.1 Level AA Audit Checklist

Organized by WCAG's four principles: Perceivable, Operable, Understandable, Robust.

### 1. Perceivable

Users must be able to perceive the information being presented.

#### 1.1 Text Alternatives

| Check | WCAG Criterion | How to Verify |
|-------|---------------|---------------|
| **Informative images have descriptive alt text** | 1.1.1 (A) | Every `<img>` with content meaning has `alt` that describes the image's purpose, not just "image" or "photo" |
| **Decorative images are hidden from screen readers** | 1.1.1 (A) | Decorative images use `alt=""` or `role="presentation"` or are CSS backgrounds |
| **Complex images have extended descriptions** | 1.1.1 (A) | Charts, graphs, infographics have alt text summary + detailed text description nearby |
| **Icon buttons have accessible names** | 1.1.1 (A) | Icon-only buttons have `aria-label` or visually hidden text. Verify by checking the accessible name in dev tools |
| **SVG elements have titles** | 1.1.1 (A) | Inline SVGs have `<title>` and `role="img"` and `aria-labelledby` |

#### 1.2 Time-Based Media

| Check | WCAG Criterion | How to Verify |
|-------|---------------|---------------|
| **Videos have captions** | 1.2.2 (A) | Pre-recorded video with audio has synchronized captions |
| **Audio has transcripts** | 1.2.1 (A) | Pre-recorded audio has a text transcript |
| **Auto-playing media can be paused** | 1.4.2 (A) | Any audio that plays for >3 seconds can be paused or volume controlled |

#### 1.3 Adaptable

| Check | WCAG Criterion | How to Verify |
|-------|---------------|---------------|
| **Semantic HTML is used** | 1.3.1 (A) | Headings use `<h1>`-`<h6>`, lists use `<ul>`/`<ol>`, tables use `<table>` with `<th>` — not divs styled to look like these |
| **Heading hierarchy is logical** | 1.3.1 (A) | No skipped heading levels (h1 then h3). Each page has exactly one h1. |
| **Form inputs have associated labels** | 1.3.1 (A) | Every `<input>`, `<select>`, `<textarea>` has a `<label>` with matching `for`/`id`, or `aria-label`, or `aria-labelledby` |
| **Landmark regions are defined** | 1.3.1 (A) | Page has `<main>`, `<nav>`, `<header>`, `<footer>`. Content is within landmarks. |
| **Tables have headers** | 1.3.1 (A) | Data tables use `<th>` with `scope="col"` or `scope="row"` |
| **Content order is meaningful** | 1.3.2 (A) | DOM order matches visual order. CSS layout doesn't rearrange content in a confusing way for screen readers |
| **Orientation is not locked** | 1.3.4 (AA) | Page works in both portrait and landscape unless a specific orientation is essential |

#### 1.4 Distinguishable

| Check | WCAG Criterion | Standard | How to Verify |
|-------|---------------|----------|---------------|
| **Normal text contrast** | 1.4.3 (AA) | 4.5:1 ratio | Test with contrast checker tool. Normal text = under 18pt (24px) or under 14pt (18.66px) bold |
| **Large text contrast** | 1.4.3 (AA) | 3:1 ratio | Large text = 18pt+ (24px+) or 14pt+ (18.66px+) bold |
| **UI component contrast** | 1.4.11 (AA) | 3:1 ratio | Buttons, inputs, icons, focus indicators — their boundaries must contrast with the background |
| **Color not sole indicator** | 1.4.1 (A) | N/A | Red text alone doesn't convey "error" — add icon, bold, or underline. Green doesn't mean "success" alone |
| **Text resize to 200%** | 1.4.4 (AA) | No content loss | Zoom browser to 200%. All content still readable. No overlapping. No horizontal scroll for single-column content |
| **Reflow at 320px** | 1.4.10 (AA) | No horizontal scroll | At 320px CSS width, content reflows to single column. No horizontal scrollbar (except data tables, maps) |
| **Text spacing override** | 1.4.12 (AA) | No content loss | When user overrides letter-spacing (0.12em), word-spacing (0.16em), line-height (1.5), paragraph-spacing (2em) — content still works |

---

### 2. Operable

Users must be able to operate the interface.

#### 2.1 Keyboard Accessible

| Check | WCAG Criterion | How to Verify |
|-------|---------------|---------------|
| **All functionality keyboard accessible** | 2.1.1 (A) | Tab through the entire page. Every button, link, form input, menu, and interactive element is reachable and activatable |
| **No keyboard traps** | 2.1.2 (A) | Pressing Tab never gets stuck in a loop. Modals trap focus but release it when closed (Escape key closes modal) |
| **Tab order is logical** | 2.4.3 (A) | Focus moves through the page in a logical sequence: top to bottom, left to right, matching visual order |
| **Focus indicators visible** | 2.4.7 (AA) | Every focused element has a visible indicator (outline, border, shadow). Never use `outline: none` without a replacement |
| **Skip navigation link** | 2.4.1 (A) | First focusable element on the page is a "Skip to main content" link that jumps past the navigation |
| **Custom keyboard shortcuts** | 2.1.4 (A) | Custom shortcuts can be remapped or disabled. Single-character shortcuts require modifier key or can be turned off |

#### Keyboard Testing Procedure

Test these key interactions on every page:

```
1. Press TAB repeatedly
   - Does focus move through ALL interactive elements?
   - Is the visual focus indicator always visible?
   - Is the order logical (matches visual layout)?
   - Does focus ever disappear or get stuck?

2. Press SHIFT+TAB
   - Does focus move backward correctly?

3. Press ENTER on buttons and links
   - Do buttons activate?
   - Do links navigate?

4. Press SPACE on checkboxes and buttons
   - Do checkboxes toggle?
   - Do buttons activate?

5. Press ESCAPE on modals and popups
   - Does the modal close?
   - Does focus return to the trigger element?

6. Press ARROW KEYS in dropdowns, menus, tabs
   - Can you navigate between options?
   - Does selection follow focus (or is it separate)?

7. Open a modal, then TAB
   - Is focus trapped within the modal?
   - Can you reach the close button?
   - Press ESCAPE — does focus return to the trigger?
```

#### 2.2 Enough Time

| Check | WCAG Criterion | How to Verify |
|-------|---------------|---------------|
| **Session timeouts warned** | 2.2.1 (A) | User is warned before timeout and given option to extend |
| **Auto-updating content pausable** | 2.2.2 (A) | Carousels, feeds, and auto-refreshing content can be paused |
| **No time limits on input** | 2.2.1 (A) | Forms don't expire while user is filling them out |

#### 2.3 Seizures and Physical Reactions

| Check | WCAG Criterion | How to Verify |
|-------|---------------|---------------|
| **No flashing content** | 2.3.1 (A) | Nothing flashes more than 3 times per second |
| **Reduced motion respected** | 2.3.3 (AAA, but best practice) | `prefers-reduced-motion: reduce` disables or reduces all animations |

#### 2.4 Navigable

| Check | WCAG Criterion | How to Verify |
|-------|---------------|---------------|
| **Page has descriptive title** | 2.4.2 (A) | Each page has a unique `<title>` that describes its purpose: "Dashboard - CompanyName" not just "Page" |
| **Links have descriptive text** | 2.4.4 (A) | No "click here" or "read more" links. Link text describes the destination: "View order #1234" |
| **Multiple navigation methods** | 2.4.5 (AA) | Users can find pages via navigation menu AND search (or sitemap) |
| **Headings describe content** | 2.4.6 (AA) | Headings and labels describe the content that follows them |

---

### 3. Understandable

Users must be able to understand the information and interface.

#### 3.1 Readable

| Check | WCAG Criterion | How to Verify |
|-------|---------------|---------------|
| **Page language set** | 3.1.1 (A) | `<html lang="en">` (or appropriate language code) is present |
| **Language changes marked** | 3.1.2 (AA) | Text in a different language has `lang` attribute: `<span lang="fr">Bonjour</span>` |

#### 3.2 Predictable

| Check | WCAG Criterion | How to Verify |
|-------|---------------|---------------|
| **Focus doesn't change context** | 3.2.1 (A) | Tabbing to an element doesn't trigger navigation, popups, or form submission |
| **Input doesn't change context** | 3.2.2 (A) | Typing or selecting doesn't trigger page navigation. Provide a submit button |
| **Consistent navigation** | 3.2.3 (AA) | Navigation appears in the same place on every page |
| **Consistent identification** | 3.2.4 (AA) | Same functionality has same label everywhere (not "Submit" on one form and "Send" on another) |

#### 3.3 Input Assistance

| Check | WCAG Criterion | How to Verify |
|-------|---------------|---------------|
| **Errors identified** | 3.3.1 (A) | When a form error occurs, the specific field is identified and the error is described in text |
| **Input labels or instructions** | 3.3.2 (A) | Fields have labels. Required fields are indicated. Expected format is described (e.g., "MM/DD/YYYY") |
| **Error suggestions** | 3.3.3 (AA) | When an error is detected and a suggestion can be made, the suggestion is provided. "Invalid email" should say "Please enter an email in the format name@domain.com" |
| **Error prevention** | 3.3.4 (AA) | Legal, financial, or data-deletion actions are reversible, or confirmed, or reviewed before submission |

### Form Accessibility Deep Dive

Forms are the most common source of accessibility issues. Check every form for:

```
1. Labels
   - Every input has a visible <label> with matching for/id
   - Placeholder text is NOT used as a replacement for labels
   - Required fields show "(required)" or use aria-required="true"

2. Error Handling
   - Errors are announced immediately (aria-live="polite" or role="alert")
   - Error messages are associated with their field (aria-describedby)
   - The first error field receives focus
   - Error messages persist until the error is fixed (not toast notifications that disappear)

3. Grouping
   - Related fields (e.g., address) are grouped in <fieldset> with <legend>
   - Radio buttons and checkboxes are in <fieldset> with descriptive <legend>

4. Autocomplete
   - Common fields use autocomplete attributes (name, email, tel, address-line1, etc.)
   - This helps users with cognitive disabilities and benefits all users on mobile
```

---

### 4. Robust

Content must be robust enough for assistive technologies.

| Check | WCAG Criterion | How to Verify |
|-------|---------------|---------------|
| **Valid HTML** | 4.1.1 (A) | No duplicate IDs. All tags properly opened and closed. |
| **ARIA used correctly** | 4.1.2 (A) | ARIA roles, states, and properties match the element's actual behavior. Don't use `role="button"` on a `<div>` when you could use `<button>` |
| **Status messages announced** | 4.1.3 (AA) | Toast notifications, status updates, and results counts use `role="status"` or `aria-live` |
| **Dynamic content announced** | 4.1.2 (A) | Content that appears or changes dynamically is announced to screen readers via live regions |

---

## Screen Reader Testing

### Quick Screen Reader Test (VoiceOver on macOS)

```
1. Enable VoiceOver: Cmd + F5
2. Navigate with VO+Right Arrow through the page
   - Does every element announce correctly?
   - Are headings announced as headings?
   - Are buttons announced as buttons?
   - Are links announced as links with descriptive text?
3. Navigate by headings: VO+Cmd+H
   - Can you navigate the page by heading structure?
4. Navigate by landmarks: VO+Cmd+L then arrow keys
   - Are all landmark regions announced?
5. Tab through interactive elements
   - Are all form fields announced with their labels?
   - Are error messages announced?
6. Open a modal
   - Is focus trapped correctly?
   - Is the modal title announced?
```

### ARIA Attribute Verification

| ARIA Pattern | Required Attributes |
|-------------|-------------------|
| **Modal/Dialog** | `role="dialog"`, `aria-modal="true"`, `aria-labelledby` pointing to title |
| **Tab Panel** | `role="tablist"`, `role="tab"`, `role="tabpanel"`, `aria-selected`, `aria-controls` |
| **Accordion** | `aria-expanded`, `aria-controls`, heading element wrapping the trigger |
| **Dropdown Menu** | `aria-haspopup`, `aria-expanded`, `role="menu"`, `role="menuitem"` |
| **Alert/Notification** | `role="alert"` or `aria-live="assertive"` for urgent, `role="status"` or `aria-live="polite"` for non-urgent |
| **Loading State** | `aria-busy="true"` on the region being loaded, `aria-live="polite"` to announce completion |
| **Toggle/Switch** | `role="switch"`, `aria-checked` |

---

## Color Contrast Reference

| Element Type | Minimum Ratio (AA) | How to Measure |
|-------------|-------------------|----------------|
| Normal text (< 18pt / < 14pt bold) | 4.5:1 | Foreground color vs. background color |
| Large text (>= 18pt / >= 14pt bold) | 3:1 | Foreground color vs. background color |
| UI components (borders, icons) | 3:1 | Component color vs. adjacent background |
| Focus indicators | 3:1 | Focus indicator color vs. adjacent colors |
| Disabled elements | No requirement | But should still be perceivable as disabled |
| Placeholder text | 4.5:1 | Often fails — placeholders are typically too light |
| Links within text | 3:1 against surrounding text OR underlined | Must be distinguishable from body text by more than color alone |

---

## Audit Report Format

```
## Accessibility Audit: [Page/Component Name]
Date: [Date]
Standard: WCAG 2.1 Level AA
Auditor:  Design Engineer

### Summary
[Overall compliance status: Pass / Fail with N issues / Partial]
[Count of issues by severity: N critical, N serious, N moderate, N minor]

### Critical (P0) — Blocks Users
Issue | Location | WCAG Criterion | Impact | Recommendation
------|----------|---------------|--------|---------------
[Description] | [CSS selector or component name] | [e.g., 2.1.2] | [Who is blocked] | [Specific fix]

### Serious (P1) — Major Barriers
[Same table format]

### Moderate (P2) — Significant Barriers
[Same table format]

### Minor (P3) — Best Practice
[Same table format]

### Passing Checks
- [List of checks that passed — gives credit for what's working]

### Recommended Priority
1. Fix all P0 issues immediately
2. Fix P1 issues before next release
3. Schedule P2 issues in the next sprint
4. Address P3 issues as capacity allows
```

---

## Accessibility Quick Wins

When time is limited, fix these first — they cover the most common accessibility failures:

1. **Add alt text to images** — Most missed accessibility requirement globally
2. **Associate labels with form inputs** — Every input needs a `<label>`
3. **Set page language** — `<html lang="en">`
4. **Fix heading hierarchy** — One h1 per page, no skipped levels
5. **Add skip navigation** — First element on the page, links to `<main>`
6. **Ensure color contrast** — Test all text against its background
7. **Add visible focus indicators** — If custom styling removed the default, add a better one
8. **Test keyboard navigation** — Tab through the page, fix traps and unreachable elements


# Component Patterns Skill

**Purpose:** Design, build, document, and maintain reusable UI components and design systems. Covers component inventory, API design, composition patterns, naming conventions, documentation standards, and migration strategies.

---

## When This Skill Activates

The `design-engineer` orchestrator routes here when:
- A new reusable component needs to be built
- A component's API (props/slots/events) needs design or review
- The design system needs auditing, extending, or documenting
- Component inconsistencies need to be resolved
- Legacy components need migration to a new pattern
- Component documentation needs to be written or updated

---

## Component Inventory and Audit

Before building anything new, audit what already exists. Component duplication is the most common source of design inconsistency.

### Inventory Process

1. **Catalog existing components** — List every reusable component in the codebase. Include:
   - Name
   - Location (file path)
   - Purpose (what it renders)
   - Usage count (how many places it's used)
   - Variants (sizes, colors, states)
   - Last modified date

2. **Identify duplicates** — Components that do the same thing but exist in different places with different names. Common examples:
   - `Button` and `Btn` and `ActionButton` — these should be one component
   - `Card` and `Panel` and `Container` — often the same thing with different padding
   - `Modal` and `Dialog` and `Popup` — usually the same pattern with slight variations

3. **Identify gaps** — Patterns used across the product that don't have a reusable component yet. Signs of a missing component:
   - Same CSS copied into multiple files
   - Same JSX/HTML structure repeated across pages
   - Developers asking "how do I build X?" repeatedly

4. **Assess quality** — For each component:
   - Does it have props documentation?
   - Does it handle all states (loading, error, empty, disabled)?
   - Is it accessible (keyboard, screen reader, contrast)?
   - Is it responsive?
   - Does it use design tokens (not hardcoded values)?

---

## Naming Conventions

Consistent naming makes components discoverable and predictable.

### Component Names
- **PascalCase** for component files and exports: `UserCard`, `SearchInput`, `NavigationMenu`
- **Descriptive** — The name should tell you what the component renders: `PricingTable` not `Table2`
- **Avoid abbreviations** — `Button` not `Btn`, `Navigation` not `Nav` (unless it's an industry standard abbreviation)
- **Prefix with context when needed** — `DashboardSidebar` vs. `SettingsSidebar` (not just `Sidebar` for both)

### File Organization

Group components by domain or type — choose one and be consistent:

**By type (flat):**
```
components/
  Button/
    Button.tsx
    Button.test.tsx
    Button.stories.tsx
    Button.module.css
  Card/
    Card.tsx
    ...
  Input/
    Input.tsx
    ...
```

**By domain (grouped):**
```
components/
  common/
    Button/
    Card/
    Input/
  dashboard/
    StatsCard/
    ActivityFeed/
  settings/
    ProfileForm/
    NotificationToggle/
```

### Token/Variable Names
- Design tokens use a structured naming convention: `{category}-{property}-{variant}-{state}`
- Examples: `color-text-primary`, `color-bg-error`, `spacing-md`, `radius-lg`, `font-size-body`
- Avoid generic names: `blue-500` tells you the color but not the purpose. `color-primary` tells you the purpose.

---

## Component API Design

The API (props, slots, events) is the most important part of a component. A bad API creates confusion and workarounds that are worse than no component at all.

### Props Design Principles

**1. Make the common case easy, the uncommon case possible**
```
// GOOD — common case requires minimal props
<Button>Save</Button>                    // Default style, default size
<Button variant="danger">Delete</Button> // Uncommon variant is explicit
<Button size="sm" loading>Saving...</Button>

// BAD — every usage requires many props
<Button color="blue" size="md" weight="bold" padding="12" radius="4">Save</Button>
```

**2. Use semantic prop names, not visual ones**
```
// GOOD — describes purpose
<Alert variant="warning">Low stock</Alert>
<Badge status="active">Online</Badge>

// BAD — describes appearance
<Alert color="yellow">Low stock</Alert>
<Badge bgColor="green">Online</Badge>
```

**3. Boolean props should default to false**
```
// GOOD — opt-in to non-default behavior
<Input disabled />
<Modal closeable />
<Button loading />

// BAD — double negatives
<Input notDisabled={false} />  // What?
```

**4. Use enums for constrained choices, not open strings**
```
// GOOD — type-safe, discoverable
type ButtonVariant = "primary" | "secondary" | "danger" | "ghost";
<Button variant="primary" />

// BAD — any string, typos won't error
<Button style="primery" />  // Typo goes unnoticed
```

**5. Accept children/slots for composition**
```
// GOOD — composable
<Card>
  <CardHeader>Title</CardHeader>
  <CardBody>Content</CardBody>
  <CardFooter>Actions</CardFooter>
</Card>

// BAD — rigid
<Card title="Title" body="Content" footer="Actions" />
// What if the footer needs a button? A link? Multiple elements?
```

### Prop Table Documentation

Every component needs a props table:

```
| Prop | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| variant | "primary" \| "secondary" \| "danger" \| "ghost" | "primary" | No | Visual style of the button |
| size | "sm" \| "md" \| "lg" | "md" | No | Size of the button |
| disabled | boolean | false | No | Whether the button is disabled |
| loading | boolean | false | No | Shows loading spinner and disables interaction |
| type | "button" \| "submit" \| "reset" | "button" | No | HTML button type attribute |
| onClick | () => void | — | No | Click handler |
| children | ReactNode | — | Yes | Button content |
```

---

## Composition Patterns

### Compound Components

Use compound components when a parent component needs to coordinate multiple child components:

```
// Compound component — parent provides context, children consume it
<Tabs defaultTab="settings">
  <TabList>
    <Tab id="profile">Profile</Tab>
    <Tab id="settings">Settings</Tab>
    <Tab id="billing">Billing</Tab>
  </TabList>
  <TabPanels>
    <TabPanel id="profile">Profile content</TabPanel>
    <TabPanel id="settings">Settings content</TabPanel>
    <TabPanel id="billing">Billing content</TabPanel>
  </TabPanels>
</Tabs>
```

**When to use:** Tabs, Accordions, Select/Option, Table/Row/Cell, Menu/MenuItem

### Render Props / Slots

Use when consumers need control over what's rendered inside the component:

```
// Render prop — consumer controls rendering
<DataTable
  data={users}
  columns={[
    { key: "name", header: "Name", render: (user) => <UserAvatar name={user.name} /> },
    { key: "email", header: "Email" },
    { key: "role", header: "Role", render: (user) => <RoleBadge role={user.role} /> },
  ]}
/>
```

**When to use:** Data tables, lists with custom items, form fields with custom rendering

### Headless Components

Provide behavior without rendering — the consumer provides all the UI:

```
// Headless — handles state and accessibility, consumer provides UI
const { isOpen, toggle, triggerProps, contentProps } = useDisclosure();

<button {...triggerProps}>Toggle Menu</button>
{isOpen && <div {...contentProps}>Menu content here</div>}
```

**When to use:** When different visual treatments are needed for the same behavior pattern across the product

---

## State Management Within Components

### Internal State Rules

1. **Keep state as local as possible** — If only this component needs the state, it belongs in the component
2. **Lift state when siblings need it** — If two sibling components share state, lift it to their parent
3. **Controlled vs. uncontrolled** — Components that accept a `value` prop are controlled. Components that manage their own value are uncontrolled. Support both when possible.

```
// Controlled — parent owns the state
<Input value={email} onChange={setEmail} />

// Uncontrolled — component owns the state, parent gets notified
<Input defaultValue="hello@example.com" onBlur={(value) => validate(value)} />
```

### Derived State

Never store state that can be calculated from existing state or props:

```
// BAD — storing derived state
const [items, setItems] = useState(allItems);
const [filteredItems, setFilteredItems] = useState(allItems); // This is derived!

// GOOD — computing on render
const [items, setItems] = useState(allItems);
const [filter, setFilter] = useState("");
const filteredItems = items.filter(item => item.name.includes(filter));
```

---

## Documentation Standards

### Component Documentation Template

Every component in the design system should have this documentation:

```markdown
# ComponentName

Brief description of what this component does and when to use it.

## Usage

[Code example of the most common usage]

## Variants

[Visual examples of each variant with code]

## Props

[Props table — see format above]

## Accessibility

- Keyboard: [How to interact with keyboard]
- Screen reader: [What gets announced]
- ARIA: [Which ARIA attributes are used and why]

## States

- Default
- Hover
- Focus
- Active/Pressed
- Disabled
- Loading
- Error

## Responsive Behavior

[How the component adapts across breakpoints]

## Do's and Don'ts

DO: [Correct usage examples]
DON'T: [Incorrect usage examples with explanation]

## Related Components

- [Similar component and when to use it instead]
```

### Storybook Stories (If Used)

Every component should have stories for:
1. **Default** — Most common usage
2. **All variants** — One story per variant
3. **All sizes** — One story per size
4. **States** — Loading, disabled, error
5. **Edge cases** — Long text, empty content, extreme values
6. **Composition** — Used together with other components

---

## Migration Strategy for Legacy Components

When replacing an old component with a new one:

### Phase 1: Build the New Component
- Build alongside the old one, don't replace yet
- Ensure feature parity (the new component can do everything the old one does)
- Document the differences between old and new APIs

### Phase 2: Create a Migration Guide
```markdown
# Migrating from OldButton to Button

## What Changed
- `color` prop renamed to `variant`
- `small`/`large` boolean props replaced with `size` enum
- `onClick` handler now receives the event as first argument

## Migration Steps
1. Replace `<OldButton>` with `<Button>`
2. Replace `color="primary"` with `variant="primary"`
3. Replace `small` with `size="sm"` and `large` with `size="lg"`
4. Update onClick handlers to accept (event) parameter

## Before/After Examples
[Side-by-side code examples]
```

### Phase 3: Incremental Migration
- Migrate one file/page at a time
- Each migration is its own PR (easy to review, easy to revert)
- Run visual regression tests after each migration
- Track migration progress: "12/34 usages migrated"

### Phase 4: Deprecate and Remove
- Add deprecation warnings to the old component
- Set a deadline for completing migration
- Remove the old component only after all usages are migrated
- Store the migration learnings in team-memory for next time

---

## Component Design Checklist

Before shipping any new component:

### API
- [ ] Props have semantic names (not visual)
- [ ] Common case requires minimal props
- [ ] Boolean props default to false
- [ ] Constrained choices use enums, not open strings
- [ ] Component accepts children/slots for flexible content
- [ ] Controlled and uncontrolled usage both supported (where applicable)

### Accessibility
- [ ] Uses semantic HTML elements
- [ ] Keyboard navigable (Tab, Enter, Space, Escape, Arrow keys as appropriate)
- [ ] Focus indicator is visible
- [ ] Screen reader announces correctly (test with VoiceOver or NVDA)
- [ ] ARIA attributes are correct and complete
- [ ] Color contrast meets WCAG 2.1 AA

### Visual
- [ ] Uses design tokens, not hardcoded values
- [ ] All states are styled (default, hover, focus, active, disabled, loading, error)
- [ ] Responsive behavior defined for all breakpoints
- [ ] Dark mode compatible (if themes are supported)
- [ ] Animation respects prefers-reduced-motion

### Code Quality
- [ ] Props are typed (TypeScript interfaces or PropTypes)
- [ ] Default props are sensible
- [ ] Error states handled gracefully
- [ ] No side effects on render
- [ ] Performance: no unnecessary re-renders

### Documentation
- [ ] Props table complete and accurate
- [ ] Usage examples cover common cases
- [ ] Do's and Don'ts documented
- [ ] Accessibility notes included
- [ ] Storybook stories written (if using Storybook)


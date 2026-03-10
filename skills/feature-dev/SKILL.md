# Feature Development Skill

**Purpose:** Implement features end-to-end — from understanding the requirement to shipping tested, documented code that follows existing codebase patterns.

---

## When This Skill Activates

The `product-engineer` orchestrator routes here when:
- A new feature needs to be built
- A bug needs to be fixed
- An existing feature needs enhancement
- A refactoring task is scoped and approved

---

## Phase 1: Requirement Analysis

Before writing any code, make sure you understand what you're building and why.

### Questions to Answer

1. **Who is this for?** Which user or system will use this feature?
2. **What problem does it solve?** What's painful or missing today?
3. **How will we know it works?** What does success look like? How will it be measured?
4. **What are the boundaries?** What is explicitly NOT in scope?
5. **Are there dependencies?** Does this depend on other features, services, or decisions?

### Clarification Protocol

If ANY of these questions can't be answered from the task description, team-memory, or USER.md:
- Ask the requester directly — don't assume
- Phrase questions concretely: "When you say 'users should be able to export data,' do you mean CSV, JSON, or both? And should it include all fields or a subset?"
- Batch your questions — don't drip them one at a time

If the requester is unavailable and the task is urgent:
- State your assumptions explicitly: "I'm assuming CSV export of all visible columns. I'll adjust if that's wrong."
- Proceed with the most reasonable interpretation
- Flag assumptions in the PR description

---

## Phase 2: Implementation Planning

Break the work into concrete tasks. Each task should be independently testable.

### Planning Template

```
Feature: [Name]
Requester: [Who asked for this]
User Story: As a [user], I want [capability] so that [benefit]

Tasks:
1. [Task] — Estimated: [time] — Files: [which files]
2. [Task] — Estimated: [time] — Files: [which files]
3. [Task] — Estimated: [time] — Files: [which files]

Dependencies: [What needs to exist before this can start]
Risks: [What could go wrong]
Edge Cases: [Non-obvious scenarios to handle]
```

### Size Guideline

- **1-3 tasks:** Implement in a single PR
- **4-8 tasks:** Consider splitting into 2-3 PRs with logical boundaries
- **9+ tasks:** Definitely split. Each PR should be reviewable in under 30 minutes

---

## Phase 3: Code Implementation

### Before You Write

1. **Search for existing patterns** — How does the codebase handle similar features? Follow those patterns.
2. **Check for utilities** — Does a helper function already exist? Don't reinvent.
3. **Read recent commits** — What's the team's current style and velocity?
4. **Identify the right location** — Where does this code belong? Follow the project structure.

### While You Write

Follow these principles in order of priority:

#### 1. Correctness
- Does it do what the requirement asks?
- Does it handle all specified edge cases?
- Are business rules implemented accurately?

#### 2. Readability
- Can another developer understand this code without your explanation?
- Are names descriptive? (`getUserSubscriptionStatus` not `getStatus`)
- Are functions small and focused? (One function = one job)
- Are comments explaining "why," not "what"?

#### 3. Error Handling
Every external operation must have explicit error handling:

```
// BAD — fails silently
const data = await fetchUser(id);

// GOOD — handles the failure
let data;
try {
  data = await fetchUser(id);
} catch (error) {
  logger.error("Failed to fetch user", { userId: id, error: error.message });
  throw new UserNotFoundError(id);
}
```

Common failure points that MUST have error handling:
- Database queries (connection lost, constraint violations, timeouts)
- HTTP requests (network errors, non-2xx responses, timeouts)
- File operations (permission denied, not found, disk full)
- JSON parsing (invalid format, unexpected structure)
- User input (missing fields, invalid types, out-of-range values)

#### 4. Logging
Log with enough context to debug issues in production:

```
// BAD
logger.error("Payment failed");

// GOOD
logger.error("Payment processing failed", {
  userId: user.id,
  amount: payment.amount,
  currency: payment.currency,
  provider: "stripe",
  error: error.message,
  errorCode: error.code
});
```

Log levels:
- `error` — Something broke that shouldn't have. Needs attention.
- `warn` — Something unexpected happened but was handled. Worth investigating.
- `info` — Normal operations worth tracking (user signed up, payment processed, export completed).
- `debug` — Detailed flow for development. Stripped in production.

#### 5. Performance
- Don't optimize prematurely, but don't be deliberately wasteful
- Watch for N+1 queries — if you're querying in a loop, you probably need a JOIN or batch query
- Watch for unnecessary re-renders in frontend code — memoize expensive computations
- Set timeouts on all external calls — never let a hanging request block indefinitely

---

## Phase 4: Edge Cases

Think through these BEFORE submitting the PR:

### Data Edge Cases
- Empty state: What happens when there's no data?
- Single item: Does the UI handle singular vs. plural correctly?
- Large dataset: What happens with 10,000 items? Is pagination needed?
- Special characters: Unicode, HTML entities, SQL injection attempts
- Null/undefined: What happens when optional fields are missing?

### User Behavior Edge Cases
- Double-click: What happens if they submit the form twice?
- Back button: Does navigation state survive browser back?
- Concurrent editing: What if two users edit the same resource?
- Offline/slow network: What happens when the API is slow or unreachable?
- Permissions: What happens when a user tries to access something they shouldn't?

### System Edge Cases
- Timeout: What if an external service takes too long?
- Rate limiting: What if we hit API limits?
- Disk/memory: What happens if storage is full?
- Partial failure: What if step 2 of a 3-step process fails? Is step 1 rolled back?

---

## Phase 5: Documentation

Every feature needs minimal documentation:

### In-Code
- Non-obvious logic gets a comment explaining WHY
- Public functions get a brief description of what they do, what they accept, and what they return
- Complex algorithms get a high-level explanation before the implementation

### In the PR
- What user problem does this solve?
- What approach did you take and why?
- What alternatives did you consider?
- How should reviewers test this?
- Are there follow-up tasks?

### In Team Memory
After completing the feature, store in team-memory:
- Key decisions made during implementation
- Gotchas or workarounds future developers should know
- Patterns established that should be followed for similar features

---

## Feature Implementation Checklist

Before marking a feature as complete, verify every item:

### Requirements
- [ ] All acceptance criteria met
- [ ] Edge cases identified and handled
- [ ] Error states have user-friendly messages

### Code Quality
- [ ] Follows existing codebase patterns
- [ ] No hardcoded values that should be configurable
- [ ] No secrets or credentials in code
- [ ] No commented-out code
- [ ] Linter passes with no new warnings

### Testing
- [ ] Unit tests for new functions
- [ ] Integration tests for new endpoints or services
- [ ] Edge case tests for non-obvious scenarios
- [ ] All existing tests still pass

### Error Handling
- [ ] All async operations wrapped in try/catch
- [ ] All external calls have timeouts
- [ ] Error messages are user-friendly (no stack traces in UI)
- [ ] Errors are logged with sufficient context

### Documentation
- [ ] PR description explains the "why"
- [ ] Non-obvious code has inline comments
- [ ] README or docs updated if needed
- [ ] Team-memory updated with key decisions


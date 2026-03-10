# Product Engineer — Orchestrator Skill

**Purpose:** Route incoming product engineering tasks to the appropriate sub-skill. Every request goes through this orchestrator first. You classify, assess scope, route, and follow up.

---

## Trigger

Any task related to building software: feature requests, bug reports, API design, refactoring, testing, code review, technical questions, or implementation planning.

---

## Step 1: Classify the Task

Read the incoming request and classify it into one of these categories:

| Category | Signals | Route To |
|----------|---------|----------|
| **Feature Development** | "Build X", "Add Y", "Implement Z", user story, feature request, enhancement | `feature-dev` skill |
| **API Design** | "Design an API for", "Add endpoint", "REST/GraphQL", request/response, "webhook" | `api-design` skill |
| **Testing** | "Write tests", "Test coverage", "Bug that needs regression test", "QA", "E2E" | `testing` skill |
| **Bug Fix** | "X is broken", "Error when", "Doesn't work", stack trace, regression | Diagnose first (see below), then route |
| **Code Review** | "Review this PR", "Check this code", link to pull request or diff | Direct review (see below) |
| **Refactoring** | "Clean up", "Simplify", "Tech debt", "Performance", "Optimize" | Scope assessment, then `feature-dev` |
| **Technical Question** | "How does X work?", "Why is Y done this way?", "What's the best approach for Z?" | Research and answer directly |

### Bug Fix Triage

Bugs don't always fit neatly into one sub-skill. Triage first:

1. **Reproduce** — Can you identify the conditions under which the bug occurs?
2. **Locate** — Search the codebase for the relevant code path
3. **Classify severity:**
   - **P0 (Critical):** Production is down, data loss, security vulnerability. Escalate immediately to 
   - **P1 (High):** Major feature broken, many users affected. Fix now, route to `feature-dev`
   - **P2 (Medium):** Feature partially broken, workaround exists. Schedule fix, route to `feature-dev`
   - **P3 (Low):** Minor issue, cosmetic, edge case. Add to backlog
4. **Fix** — Implement the fix via `feature-dev` skill
5. **Prevent** — Write a regression test via `testing` skill

---

## Step 2: Assess Scope

Before routing, determine the scope of work:

### Small (Hours)
- Single file change
- Bug fix with known cause
- Adding a test for existing code
- Updating documentation
- **Process:** Implement directly. No planning document needed.

### Medium (1-3 Days)
- Multiple file changes
- New feature within existing patterns
- New API endpoint following established conventions
- Moderate refactoring
- **Process:** Write a brief plan (what changes, which files, what tests). Get confirmation before starting.

### Large (1+ Week)
- New subsystem or module
- Database schema changes
- New architectural pattern
- Major refactoring or migration
- **Process:** Write a detailed implementation plan with phases. Present to the team. Get explicit approval. Break into multiple PRs.

---

## Step 3: Route to Sub-Skill

### Decision Tree

```
Is this a feature, enhancement, or bug fix?
├── YES → Is there an API component?
│   ├── YES → Start with `api-design`, then `feature-dev` for implementation
│   └── NO  → Route to `feature-dev`
└── NO
    ├── Is this a testing task?
    │   ├── YES → Route to `testing`
    │   └── NO  → Continue
    ├── Is this API-only (no UI, no business logic changes)?
    │   ├── YES → Route to `api-design`
    │   └── NO  → Continue
    ├── Is this a code review?
    │   ├── YES → Review directly (see Code Review below)
    │   └── NO  → Continue
    └── Is this a technical question?
        ├── YES → Research and answer (check team-memory first)
        └── NO  → Ask for clarification
```

### Multi-Skill Tasks

Many tasks span multiple sub-skills. Execute them in order:

1. **Feature with API:** `api-design` (design the contract) then `feature-dev` (implement) then `testing` (verify)
2. **Bug with regression:** Diagnose and fix via `feature-dev`, then `testing` for the regression test
3. **Refactor with test updates:** `feature-dev` for the refactor, then `testing` to update/add tests
4. **New feature end-to-end:** `api-design` if there's an API, `feature-dev` for implementation, `testing` for coverage

---

## Step 4: Post-Completion

After the sub-skill completes its work:

### Testing Plan
Always suggest a testing plan, even if the task didn't go through the `testing` skill:
- What unit tests should cover this change?
- Are there integration test implications?
- Should an E2E test be added or updated?
- What manual testing should happen before merge?

### Documentation
- Did this change require a README or doc update?
- Are there new environment variables or configuration?
- Should the changelog be updated?
- Does team-memory need a new entry?

### Review Checklist
Before considering any task complete, verify:
- [ ] Code follows existing codebase patterns
- [ ] All new functions have tests
- [ ] Error handling covers failure modes
- [ ] No secrets, credentials, or PII in the code
- [ ] Linter and formatter pass
- [ ] PR description explains the "why," not just the "what"
- [ ] Migration plan exists if schema changes are involved

---

## Code Review Protocol

When reviewing code directly (not routing to a sub-skill):

1. **Read the PR description** — Understand the intent before reading the code
2. **Check the diff** — Look for:
   - Logic errors and edge cases
   - Missing error handling
   - Inconsistency with existing patterns
   - Test coverage for new code
   - Security concerns (input validation, auth checks, SQL injection)
   - Performance implications (N+1 queries, unnecessary re-renders, missing indexes)
3. **Leave actionable feedback** — Every comment should suggest a specific fix or ask a specific question. "This could be better" is not helpful. "This N+1 query will be slow with >100 records — consider eager loading with `.include()`" is helpful.
4. **Categorize feedback:**
   - **Must fix:** Bugs, security issues, missing error handling
   - **Should fix:** Pattern violations, missing tests, unclear naming
   - **Nit:** Style preferences, minor improvements, optional suggestions
5. **Approve or request changes** — Don't leave a review in limbo

---

## Context Loading

Before starting any task:

1. Check `USER.md` for tech stack, conventions, and repo information
2. Search `team-memory` for prior decisions about the relevant area of the codebase
3. Check if there are related open tickets or PRs
4. Review recent commits in the affected area to understand current momentum

---

## Escalation Triggers

Escalate to  when:
- Production incident (P0/P1 bugs)
- Security vulnerability discovered
- Data integrity concern
- Conflicting requirements from different stakeholders
- Architectural decision that will be very difficult to reverse
- You've been stuck for more than 30 minutes without progress


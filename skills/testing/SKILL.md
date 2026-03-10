# Testing Skill

**Purpose:** Design and implement comprehensive test strategies. Covers unit tests, integration tests, end-to-end tests, test coverage analysis, and regression planning.

---

## When This Skill Activates

The `product-engineer` orchestrator routes here when:
- Tests need to be written for new or existing code
- Test coverage needs analysis or improvement
- A testing strategy needs to be designed for a feature
- Flaky or failing tests need investigation
- Regression test planning is needed after a bug fix

---

## The Test Pyramid

Structure your tests following the pyramid — many fast tests at the base, fewer slow tests at the top.

```
          /\
         /  \        E2E Tests (few)
        / e2e\       - Full user flows
       /------\      - Critical paths only
      /        \
     / integr.  \    Integration Tests (some)
    /            \   - API endpoints
   /--------------\  - Service interactions
  /                \ - Database queries
 /    unit tests    \
/____________________\  Unit Tests (many)
                        - Pure functions
                        - Business logic
                        - Data transformations
```

### Distribution Target
- **Unit:** 70-80% of total tests
- **Integration:** 15-25% of total tests
- **E2E:** 5-10% of total tests

---

## Unit Testing

### When to Write Unit Tests
- Every pure function (no side effects, no external dependencies)
- Business logic and data transformations
- Input validation and error handling
- Utility functions and helpers
- State management logic (reducers, selectors)

### Arrange-Act-Assert Pattern

Every unit test follows this structure:

```
// Test: calculateDiscount applies 20% off for orders over $100

// ARRANGE — Set up the test data and preconditions
const order = { items: [{ price: 50, quantity: 3 }], total: 150 };
const discountRules = { threshold: 100, percentage: 0.2 };

// ACT — Execute the function being tested
const result = calculateDiscount(order, discountRules);

// ASSERT — Verify the result matches expectations
expect(result.discount).toBe(30);
expect(result.finalTotal).toBe(120);
```

### Test Naming Convention

Test names should read like sentences. Someone who's never seen the code should understand what's being tested.

```
// BAD
test("discount", () => { ... });
test("test 1", () => { ... });

// GOOD
test("calculates 20% discount when order total exceeds $100", () => { ... });
test("returns zero discount when order total is below threshold", () => { ... });
test("throws ValidationError when order has no items", () => { ... });
```

### Mocking Strategy

Mock external dependencies, not internal logic:

```
// GOOD: Mock the HTTP client (external dependency)
jest.mock("./httpClient");
httpClient.get.mockResolvedValue({ data: mockUser });

// BAD: Mock a utility function to force a code path
// This makes the test brittle and tied to implementation details
```

**When to Mock:**
- External APIs and HTTP calls
- Database queries (in unit tests — use real DB in integration tests)
- File system operations
- Time-dependent functions (Date.now, setTimeout)
- Third-party libraries with side effects

**When NOT to Mock:**
- Pure functions within your own codebase
- Simple utilities and helpers
- Data structures and transformations

### Fixtures and Factories

Use factories for test data, not copy-pasted objects:

```
// Factory function — reusable across tests
function createUser(overrides = {}) {
  return {
    id: "usr_test_123",
    name: "Test User",
    email: "test@example.com",
    role: "member",
    createdAt: new Date("2025-01-01"),
    ...overrides
  };
}

// Usage
const admin = createUser({ role: "admin" });
const deletedUser = createUser({ deletedAt: new Date() });
```

---

## Integration Testing

### When to Write Integration Tests
- API endpoint handlers (the full request-response cycle)
- Database queries and transactions
- Service-to-service communication
- Authentication and authorization flows
- Queue/job processing

### API Endpoint Tests

Test the full HTTP cycle — request in, response out, database state verified:

```
// Test: POST /api/users creates a user and returns 201

// ARRANGE
const newUser = { name: "Alice", email: "alice@example.com" };

// ACT
const response = await request(app)
  .post("/api/users")
  .send(newUser)
  .set("Authorization", "Bearer valid-token");

// ASSERT — Response
expect(response.status).toBe(201);
expect(response.body.data.name).toBe("Alice");
expect(response.body.data.id).toBeDefined();

// ASSERT — Side effects
const dbUser = await db.user.findUnique({ where: { email: "alice@example.com" } });
expect(dbUser).toBeDefined();
expect(dbUser.name).toBe("Alice");
```

### Database Tests

- Use a test database (separate from development)
- Run migrations before the test suite
- Clean up data between tests (truncate tables or use transactions that roll back)
- Test both the happy path AND constraint violations (unique, foreign key, not null)

```
// Test: creating a user with duplicate email fails with conflict

const existingUser = await createTestUser({ email: "alice@example.com" });

await expect(
  userService.create({ name: "Alice 2", email: "alice@example.com" })
).rejects.toThrow(ConflictError);
```

### Authentication Tests

Every protected endpoint needs at minimum:
1. **No token** returns 401
2. **Invalid token** returns 401
3. **Expired token** returns 401
4. **Valid token, insufficient permissions** returns 403
5. **Valid token, correct permissions** returns 200 (or appropriate success code)

---

## End-to-End Testing

### When to Write E2E Tests
- Critical user flows that generate revenue (signup, purchase, checkout)
- Authentication flows (login, logout, password reset)
- Flows that span multiple services or pages
- Flows where a failure would cause significant user harm

### What NOT to E2E Test
- Individual components (that's what unit tests are for)
- Every possible combination of inputs (combinatorial explosion)
- Edge cases that can be caught at the unit level
- Third-party service behavior (mock at the API boundary)

### E2E Test Structure

```
// Test: User can sign up, verify email, and access dashboard

test("complete signup flow", async () => {
  // Navigate to signup page
  await page.goto("/signup");

  // Fill out the form
  await page.fill("[name=email]", "newuser@example.com");
  await page.fill("[name=password]", "SecureP@ss123!");
  await page.click("button[type=submit]");

  // Verify redirect to email verification page
  await expect(page).toHaveURL("/verify-email");
  await expect(page.locator("h1")).toContainText("Check your email");

  // Simulate email verification (click the verification link)
  const verificationUrl = await getLatestVerificationUrl("newuser@example.com");
  await page.goto(verificationUrl);

  // Verify redirect to dashboard
  await expect(page).toHaveURL("/dashboard");
  await expect(page.locator("[data-testid=welcome-message]")).toContainText("Welcome");
});
```

### E2E Best Practices
- Use `data-testid` attributes for selectors, not CSS classes or text content (classes change, text gets localized)
- Set reasonable timeouts — E2E tests are slow by nature, but 30+ second waits usually mean something is wrong
- Take screenshots on failure for debugging
- Run E2E tests in CI, not just locally
- Keep E2E tests independent — each test should set up its own state, not depend on other tests running first

---

## Test Coverage Analysis

### Coverage Metrics

| Metric | Target | Priority |
|--------|--------|----------|
| **Line coverage** | 80%+ | Medium — easy to game, useful as a baseline |
| **Branch coverage** | 75%+ | High — catches untested conditional paths |
| **Function coverage** | 90%+ | High — ensures no dead code |
| **Critical path coverage** | 100% | Critical — payment, auth, data mutations |

### Coverage Gap Identification

When analyzing coverage gaps, focus on:

1. **Uncovered error paths** — Most coverage gaps are in error handling. If your catch blocks aren't tested, you don't know if they work.
2. **Uncovered conditional branches** — `if/else`, ternary operators, `switch` cases. If only the happy path is covered, the sad path is untested.
3. **Untested edge cases** — null inputs, empty arrays, boundary values, overflow conditions.
4. **Dead code** — Functions that show 0% coverage might be unused. Investigate before adding tests — maybe remove the code instead.

### Coverage Anti-Patterns

- **Testing getters/setters** — Don't write a test for `getName()` that returns `this.name`. Test behavior, not accessors.
- **100% coverage as a goal** — Diminishing returns after ~85%. Focus effort on testing risky code, not boilerplate.
- **Coverage-driven testing** — Don't write tests to hit a number. Write tests to verify behavior. Good tests naturally produce good coverage.

---

## Regression Test Planning

After every bug fix, answer these questions:

1. **Why did existing tests miss this?** Was there a gap in coverage, or did the tests cover the wrong thing?
2. **What test would have caught this?** Write it. This is the regression test.
3. **Are there similar bugs hiding elsewhere?** If the bug was "we don't validate email format on the profile update endpoint," check if other endpoints also skip email validation.
4. **Should this be a unit test or integration test?** Unit if it's a logic error. Integration if it's a wiring error. E2E if it's a user flow error.

### Regression Test Template

```
// Regression: [TICKET-ID] — [Brief description of the bug]
// Bug: [What went wrong]
// Root cause: [Why it went wrong]
// Fix: [What was changed]
// This test ensures the bug doesn't recur.

test("TICKET-123: email validation rejects addresses without @ symbol", () => {
  expect(validateEmail("notanemail")).toBe(false);
  expect(validateEmail("also.not.email")).toBe(false);
  expect(validateEmail("valid@example.com")).toBe(true);
});
```

---

## Flaky Test Investigation

When a test fails intermittently:

1. **Identify the pattern** — Does it fail on CI but not locally? At certain times? Under load?
2. **Common causes:**
   - **Timing issues:** Test depends on setTimeout, network calls, or race conditions. Fix with explicit waits, not sleep().
   - **Shared state:** Tests modify global state and affect each other. Fix with proper setup/teardown.
   - **Non-deterministic data:** Tests depend on random data, current time, or auto-increment IDs. Fix with deterministic fixtures.
   - **External dependencies:** Tests hit real services that are occasionally slow or down. Fix with mocks or retries.
3. **Never** — Skip or disable a flaky test without a tracking issue. Flaky tests erode trust in the entire suite.

---

## Testing Checklist

Before any PR with code changes:

### Unit Tests
- [ ] All new functions have at least one test
- [ ] Happy path tested for every new feature
- [ ] Error paths tested (what happens when things fail)
- [ ] Edge cases tested (empty input, null, boundary values)
- [ ] Mocks are used for external dependencies only

### Integration Tests
- [ ] New API endpoints have request/response tests
- [ ] Authentication and authorization tested
- [ ] Database interactions tested (create, read, update, delete)
- [ ] Error responses match the API contract

### Regression Tests
- [ ] Every bug fix includes a test that would have caught the bug
- [ ] Similar code paths checked for the same bug pattern

### Quality
- [ ] Test names describe the behavior being tested
- [ ] Tests are independent (no ordering dependencies)
- [ ] Tests clean up after themselves
- [ ] No hardcoded timeouts or sleep() calls
- [ ] Tests run in under 30 seconds locally (for the changed files)
- [ ] All existing tests still pass


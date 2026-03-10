# API Design Skill

**Purpose:** Design and implement clean, consistent, well-documented APIs. Covers RESTful design, schema definitions, authentication patterns, pagination, versioning, and documentation.

---

## When This Skill Activates

The `product-engineer` orchestrator routes here when:
- A new API endpoint needs to be designed
- An existing API needs modification or extension
- A webhook integration needs to be built
- API documentation needs to be written or updated
- An API design review is requested

---

## RESTful Design Principles

### Resource Naming

Resources are nouns, not verbs. The HTTP method provides the verb.

```
GOOD:
  GET    /api/users          — List users
  GET    /api/users/:id      — Get a specific user
  POST   /api/users          — Create a user
  PATCH  /api/users/:id      — Update a user (partial)
  PUT    /api/users/:id      — Replace a user (full)
  DELETE /api/users/:id      — Delete a user

BAD:
  GET    /api/getUsers
  POST   /api/createUser
  POST   /api/deleteUser/:id
```

### Naming Conventions
- Use plural nouns for collections: `/users` not `/user`
- Use kebab-case for multi-word resources: `/user-preferences` not `/userPreferences`
- Nest resources to show relationships: `/users/:id/orders` not `/user-orders?userId=:id`
- Limit nesting to 2 levels: `/users/:id/orders/:orderId` is fine. `/users/:id/orders/:orderId/items/:itemId/reviews` is too deep — flatten it to `/order-items/:itemId/reviews`

### HTTP Methods

| Method | Use For | Idempotent | Safe | Body |
|--------|---------|-----------|------|------|
| `GET` | Read resources | Yes | Yes | No |
| `POST` | Create resources, trigger actions | No | No | Yes |
| `PUT` | Replace entire resource | Yes | No | Yes |
| `PATCH` | Partial update | No* | No | Yes |
| `DELETE` | Remove resource | Yes | No | No |

*PATCH is idempotent if you send the same patch repeatedly. It's not idempotent if the patch depends on current state.

### Status Codes

Use the right code. Don't return 200 for everything.

| Code | Meaning | When to Use |
|------|---------|------------|
| `200` | OK | Successful GET, PATCH, PUT, DELETE |
| `201` | Created | Successful POST that created a resource |
| `204` | No Content | Successful DELETE with no response body |
| `400` | Bad Request | Validation failure, malformed request body |
| `401` | Unauthorized | Missing or invalid authentication |
| `403` | Forbidden | Authenticated but not authorized for this resource |
| `404` | Not Found | Resource doesn't exist |
| `409` | Conflict | Resource already exists, version conflict |
| `422` | Unprocessable Entity | Valid JSON but business rule violation |
| `429` | Too Many Requests | Rate limit exceeded |
| `500` | Internal Server Error | Unhandled server error (never return intentionally) |

---

## Request/Response Schema Design

### Consistent Response Envelope

Use a consistent structure for all responses:

```json
// Success (single resource)
{
  "data": { "id": "usr_123", "name": "Alice", "email": "alice@example.com" },
  "meta": { "requestId": "req_abc" }
}

// Success (collection)
{
  "data": [
    { "id": "usr_123", "name": "Alice" },
    { "id": "usr_456", "name": "Bob" }
  ],
  "meta": {
    "total": 42,
    "page": 1,
    "pageSize": 20,
    "requestId": "req_abc"
  }
}

// Error
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email address is required",
    "details": [
      { "field": "email", "message": "This field is required", "code": "required" }
    ]
  },
  "meta": { "requestId": "req_abc" }
}
```

### Field Naming
- Use camelCase for JSON fields: `firstName`, not `first_name` or `FirstName`
- Use ISO 8601 for dates: `"2025-03-15T14:30:00Z"` not `"March 15, 2025"` or `1710510600`
- Use strings for IDs, not numbers: `"id": "usr_123"` not `"id": 123` (avoids JavaScript integer precision issues)
- Use prefixed IDs when multiple resource types exist: `usr_`, `ord_`, `inv_` (makes debugging easier)

### Null Handling
- Omit fields that are null/undefined rather than sending `"field": null` (saves bandwidth, clearer intent)
- Exception: If a field being null is semantically different from being absent, include it
- Document which fields are always present vs. optional

---

## Authentication and Authorization

### Authentication Patterns

Support these patterns in priority order (check USER.md for what the team uses):

1. **Bearer Token** (most common): `Authorization: Bearer <token>`
2. **API Key** (for machine-to-machine): `X-API-Key: <key>` header or `?api_key=<key>` query param
3. **Session Cookie** (for browser clients): `Cookie: session=<value>`

### Authorization Rules

- Check authentication FIRST, then authorization
- Return 401 for "who are you?" (missing/invalid token)
- Return 403 for "you can't do that" (valid token, insufficient permissions)
- Never reveal whether a resource EXISTS to unauthorized users — return 404, not 403, if the user shouldn't know about it
- Implement at the middleware level, not in every handler

### Rate Limiting

Every public API endpoint needs rate limiting:

```
Rate-Limit Headers (include in every response):
  X-RateLimit-Limit: 100         — Max requests per window
  X-RateLimit-Remaining: 87      — Requests remaining
  X-RateLimit-Reset: 1678901234  — Unix timestamp when window resets

When exceeded, return:
  429 Too Many Requests
  Retry-After: 30                — Seconds to wait
```

---

## Pagination

### Offset-Based (Simple, Good for Most Cases)

```
GET /api/users?page=2&pageSize=20

Response:
{
  "data": [...],
  "meta": {
    "total": 142,
    "page": 2,
    "pageSize": 20,
    "totalPages": 8
  }
}
```

### Cursor-Based (Better for Large/Real-Time Datasets)

```
GET /api/users?cursor=eyJpZCI6MTIzfQ&limit=20

Response:
{
  "data": [...],
  "meta": {
    "nextCursor": "eyJpZCI6MTQzfQ",
    "hasMore": true
  }
}
```

### Rules
- Default page size: 20 items
- Maximum page size: 100 items (prevent clients from requesting everything)
- Always include total count for offset pagination (helps UI show "page X of Y")
- Always include `hasMore` for cursor pagination

---

## Filtering, Sorting, and Search

### Filtering
```
GET /api/users?status=active&role=admin
GET /api/orders?createdAfter=2025-01-01&createdBefore=2025-03-01
GET /api/products?priceMin=10&priceMax=50
```

### Sorting
```
GET /api/users?sort=createdAt         — Ascending (default)
GET /api/users?sort=-createdAt        — Descending (prefix with -)
GET /api/users?sort=-createdAt,name   — Multiple sort fields
```

### Full-Text Search
```
GET /api/users?q=alice                — General search across searchable fields
```

---

## Versioning Strategy

### URL Path Versioning (Recommended)
```
/api/v1/users
/api/v2/users
```

### Rules
- Start at v1. Don't version until you need to.
- A new version is needed when you remove fields, rename fields, change field types, or change behavior
- Adding new optional fields does NOT require a new version
- Support the previous version for at least 6 months after deprecation
- Include deprecation warnings in response headers: `Deprecation: true`, `Sunset: Sat, 01 Mar 2026 00:00:00 GMT`

---

## Webhook Design

When building webhooks for external consumers:

### Payload Structure
```json
{
  "id": "evt_abc123",
  "type": "order.completed",
  "created": "2025-03-15T14:30:00Z",
  "data": {
    "orderId": "ord_456",
    "amount": 9900,
    "currency": "usd"
  }
}
```

### Security
- Sign payloads with HMAC-SHA256: `X-Webhook-Signature: sha256=<hex_digest>`
- Include a timestamp to prevent replay attacks: `X-Webhook-Timestamp: 1710510600`
- Reject payloads older than 5 minutes
- Use HTTPS only — never send webhooks over HTTP

### Delivery
- Retry on failure: 3 attempts with exponential backoff (1s, 10s, 60s)
- Return success on 2xx status codes, retry on 4xx/5xx
- Provide a webhook testing endpoint for consumers to verify their integration
- Log all delivery attempts for debugging

---

## API Documentation

### OpenAPI/Swagger

Every API should have an OpenAPI spec. At minimum:

```yaml
paths:
  /api/users:
    get:
      summary: List users
      description: Returns a paginated list of users
      parameters:
        - name: page
          in: query
          schema: { type: integer, default: 1 }
        - name: pageSize
          in: query
          schema: { type: integer, default: 20, maximum: 100 }
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema: { $ref: '#/components/schemas/UserListResponse' }
        '401':
          description: Authentication required
```

### Documentation Rules
- Every endpoint gets a summary (one line) and description (paragraph explaining use case)
- Every parameter is documented with type, default, and constraints
- Every response code is documented with an example
- Error responses include all possible error codes and their meanings
- Include curl examples for every endpoint

---

## API Design Checklist

Before finalizing any API design:

### Naming and Structure
- [ ] Resources are plural nouns
- [ ] Nesting depth is 2 levels or less
- [ ] Naming is consistent with existing endpoints
- [ ] URL structure follows RESTful conventions

### Request/Response
- [ ] Response envelope is consistent with other endpoints
- [ ] Field names use camelCase
- [ ] Dates use ISO 8601
- [ ] IDs are strings, not numbers
- [ ] Pagination is implemented for list endpoints
- [ ] Filtering and sorting are available where appropriate

### Security
- [ ] Authentication is required (or explicitly documented as public)
- [ ] Authorization checks are in place
- [ ] Rate limiting is configured
- [ ] Input is validated and sanitized
- [ ] Error responses don't leak internal details

### Documentation
- [ ] OpenAPI spec is written or updated
- [ ] All parameters documented
- [ ] All response codes documented
- [ ] Examples included for success and error cases
- [ ] Breaking changes are versioned

### Operational
- [ ] Requests are logged with correlation IDs
- [ ] Response times are monitored
- [ ] Error rates are tracked
- [ ] The endpoint is included in health checks if critical


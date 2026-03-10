# Credential Proxy Skill

**Purpose:** Use stored API keys and credentials securely via ClawTrust's credential proxy. You NEVER see the actual credential values — the proxy decrypts and executes requests server-side.

---

## How It Works

1. Your owner stores credentials in the ClawTrust dashboard (e.g., GMAIL_APP_PASSWORD, HUBSPOT_API_KEY)
2. You call the proxy with the credential key name + your request
3. The proxy decrypts the credential server-side, executes the request, returns the result
4. You NEVER have access to the credential value itself

---

## MUST

- Always use the credential proxy for external service calls that require authentication
- Reference credentials by their UPPER_SNAKE_CASE key name
- Handle proxy errors gracefully — if the proxy is down, inform the user you can't access the service right now
- Log which credential you're using and why (for audit trail)

## MUST NOT

- NEVER try to extract, guess, or reconstruct credential values
- NEVER ask the user to paste credentials into chat
- NEVER store credential values in files, memory, or workspace
- NEVER attempt to bypass the proxy by calling services directly without auth

---

## Usage: HTTP Bearer Token

```bash
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/contacts",
      "method": "GET"
    }
  }'
```

**Response:**
```json
{
  "success": true,
  "data": { "results": [...] },
  "status": 200
}
```

## Usage: HTTP API Key

```bash
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "SENDGRID_API_KEY",
    "service": "http-api-key",
    "request": {
      "url": "https://api.sendgrid.com/v3/mail/send",
      "method": "POST",
      "body": {
        "personalizations": [{"to": [{"email": "user@example.com"}]}],
        "from": {"email": "noreply@company.com"},
        "subject": "Hello",
        "content": [{"type": "text/plain", "value": "Hi there"}]
      }
    }
  }'
```

## Usage: SMTP (Send Email)

```bash
curl --max-time 15 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "GMAIL_APP_PASSWORD",
    "service": "smtp",
    "request": {
      "from": "alex@company.com",
      "to": "client@example.com",
      "subject": "Follow-up from our call",
      "body": "Hi, just following up on our conversation..."
    }
  }'
```

## Usage: HTTP Basic Auth

```bash
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "JIRA_CREDENTIALS",
    "service": "http-basic",
    "request": {
      "url": "https://company.atlassian.net/rest/api/3/search",
      "method": "GET"
    }
  }'
```

---

## Error Handling

The proxy may return errors. Always handle them:

```bash
# With timeout fallback (REQUIRED — never block on proxy)
RESULT=$(curl --max-time 3 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"credentialKey":"HUBSPOT_API_KEY","service":"http-bearer","request":{"url":"https://api.hubapi.com/crm/v3/contacts","method":"GET"}}' \
  || echo '{"success":false,"error":"Proxy unreachable"}')

# Check result
if echo "$RESULT" | jq -e '.success' > /dev/null 2>&1; then
  echo "Got data: $(echo $RESULT | jq '.data')"
else
  echo "Proxy call failed: $(echo $RESULT | jq -r '.error // .message')"
fi
```

## Common Error Codes

| Error | Meaning | What to Do |
|-------|---------|-----------|
| `credential_not_found` | No credential with that key | Ask owner to add it in dashboard |
| `service_mismatch` | Wrong service type for this key | Check if key is smtp vs http-bearer |
| `domain_not_allowed` | URL not in credential's allowlist | Ask owner to update allowed domains |
| `rate_limited` | Too many requests (60/min per key) | Wait and retry |
| `proxy_error` | Internal proxy failure | Retry once, then report to owner |

---

## Available Credentials

To check what credentials are available (metadata only, never values):

```bash
curl --max-time 3 -s \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/credentials" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  | jq '.items[] | {key, serviceType, allowedDomains, description}'
```

---

## Security Notes

- Credentials are encrypted with AES-256-GCM at rest
- Decryption only happens server-side on the ClawTrust control plane
- Every proxy call is audit-logged (credential key, target URL, success/fail, latency)
- Each credential has a domain allowlist — the proxy rejects requests to unlisted domains
- Rate limited to 60 requests per minute per credential


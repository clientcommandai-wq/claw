# CRM Skill (HubSpot)

> Manage contacts, deals, activities, and pipeline in HubSpot via the credential-proxy. You are the CRM brain — every interaction gets logged, every deal gets tracked, every contact record stays clean.

---

## When to Activate

This skill is called by the sales-lead orchestrator when:
- A new contact needs to be created or updated
- A deal needs to be created, moved, or closed
- Activities (emails, calls, meetings) need to be logged
- Pipeline reports or summaries are requested
- Contact history is needed before outreach

---

## HubSpot API Access

All HubSpot operations go through the credential-proxy. Never call the HubSpot API directly.

### Base Pattern

```bash
RESULT=$(curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/...",
      "method": "GET"
    }
  }' \
  || echo '{"success":false,"error":"HubSpot unreachable"}')
```

**Always** use the `--max-time 10` flag and the `|| echo` fallback. Never block on HubSpot calls.

---

## Contact Operations

### Search for a Contact

Before creating a contact, always search first to avoid duplicates.

```bash
# Search by email
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/objects/contacts/search",
      "method": "POST",
      "body": {
        "filterGroups": [{
          "filters": [{
            "propertyName": "email",
            "operator": "EQ",
            "value": "prospect@example.com"
          }]
        }],
        "properties": ["email", "firstname", "lastname", "company", "jobtitle", "phone", "lifecyclestage"]
      }
    }
  }'
```

### Create a Contact

Only create after confirming no duplicate exists.

```bash
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/objects/contacts",
      "method": "POST",
      "body": {
        "properties": {
          "email": "prospect@example.com",
          "firstname": "Jane",
          "lastname": "Smith",
          "company": "Acme Corp",
          "jobtitle": "VP of Operations",
          "phone": "",
          "lifecyclestage": "lead",
          "lead_source": "cold_outreach"
        }
      }
    }
  }'
```

### Update a Contact

Use PATCH to update without overwriting existing fields.

```bash
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/objects/contacts/CONTACT_ID",
      "method": "PATCH",
      "body": {
        "properties": {
          "jobtitle": "CTO",
          "notes": "Promoted from VP Engineering as of Feb 2026"
        }
      }
    }
  }'
```

### Required Fields for New Contacts

| Field | Required | Source |
|-------|----------|--------|
| `email` | Yes | From prospect or research |
| `firstname` | Yes | From prospect or research |
| `lastname` | Yes | From prospect or research |
| `company` | Yes | From prospect or research |
| `jobtitle` | Recommended | Research |
| `lifecyclestage` | Yes | Set to "lead" for new contacts |
| `lead_source` | Recommended | How they were found (cold_outreach, inbound, referral, event) |

---

## Deal Operations

### Create a Deal

Create a deal when a lead is qualified and worth pursuing.

```bash
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/objects/deals",
      "method": "POST",
      "body": {
        "properties": {
          "dealname": "Acme Corp - Widget Pro",
          "pipeline": "default",
          "dealstage": "qualifiedtobuy",
          "amount": "5000",
          "closedate": "2026-03-15",
          "description": "VP Ops interested in Widget Pro for 50-person team. Budget approved Q1."
        }
      }
    }
  }'
```

After creating the deal, associate it with the contact:

```bash
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/objects/deals/DEAL_ID/associations/contacts/CONTACT_ID/deal_to_contact",
      "method": "PUT"
    }
  }'
```

### Move a Deal to Next Stage

```bash
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/objects/deals/DEAL_ID",
      "method": "PATCH",
      "body": {
        "properties": {
          "dealstage": "presentationscheduled",
          "notes_last_updated": "Demo scheduled for Feb 15. Contact confirmed attendance."
        }
      }
    }
  }'
```

### Pipeline Stage Mapping

Map the owner's sales process (from USER.md `SALES_PROCESS_STAGES`) to HubSpot default stages:

| Owner's Stage | HubSpot Stage ID | When to Move |
|--------------|-----------------|--------------|
| Lead | `appointmentscheduled` or custom | New, unqualified contact |
| Contacted | `qualifiedtobuy` | First outreach sent, awaiting response |
| Qualified | `qualifiedtobuy` | BANT criteria met (score >= 6) |
| Demo Scheduled | `presentationscheduled` | Demo or call booked and confirmed |
| Proposal Sent | `decisionmakerboughtin` | Pricing or proposal delivered |
| Negotiation | `contractsent` | Discussing terms, close is near |
| Closed Won | `closedwon` | Deal signed, payment received |
| Closed Lost | `closedlost` | Prospect declined or went with competitor |

> **Note:** HubSpot stage IDs vary by account configuration. On first use, query the pipeline definition to get actual stage IDs:
> `GET https://api.hubapi.com/crm/v3/pipelines/deals`

---

## Activity Logging

### Log an Email

Every outreach email, follow-up, and reply must be logged.

```bash
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/objects/emails",
      "method": "POST",
      "body": {
        "properties": {
          "hs_timestamp": "2026-02-10T10:00:00.000Z",
          "hs_email_direction": "EMAIL",
          "hs_email_subject": "Quick question about your operations workflow",
          "hs_email_text": "Hi Jane, I noticed...",
          "hs_email_status": "SENT"
        }
      }
    }
  }'
```

Then associate the email with the contact:
```bash
# Associate email engagement with contact
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/objects/emails/EMAIL_ID/associations/contacts/CONTACT_ID/email_to_contact",
      "method": "PUT"
    }
  }'
```

### Log a Note

For qualification notes, meeting summaries, or general observations.

```bash
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/objects/notes",
      "method": "POST",
      "body": {
        "properties": {
          "hs_timestamp": "2026-02-10T10:00:00.000Z",
          "hs_note_body": "Qualification complete. Score: 8/10. Budget: $50K approved for Q1. Authority: VP Ops has signing power up to $100K. Need: Manual processes costing 20 hrs/week. Timeline: Want to implement by April."
        }
      }
    }
  }'
```

---

## Pipeline Reports

### Pull Pipeline Summary

```bash
# Get all deals in pipeline
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/objects/deals/search",
      "method": "POST",
      "body": {
        "filterGroups": [{
          "filters": [{
            "propertyName": "dealstage",
            "operator": "NEQ",
            "value": "closedlost"
          }]
        }],
        "properties": ["dealname", "dealstage", "amount", "closedate", "pipeline"],
        "sorts": [{"propertyName": "closedate", "direction": "ASCENDING"}],
        "limit": 100
      }
    }
  }'
```

### Report Format

Present pipeline data in this format:

```
PIPELINE REPORT — [Date]

Total Active Deals: [count]
Total Pipeline Value: $[sum of amounts]
Weighted Pipeline: $[weighted by stage probability]

BY STAGE:
  Lead:           [N] deals | $[value]
  Qualified:      [N] deals | $[value]
  Demo:           [N] deals | $[value]
  Proposal:       [N] deals | $[value]
  Negotiation:    [N] deals | $[value]

CLOSING THIS MONTH:
  [Deal 1] — $[amount] — [stage] — [% probability]
  [Deal 2] — $[amount] — [stage] — [% probability]

STALE DEALS (no activity in 14+ days):
  [Deal 3] — last activity [date] — recommend: [action]
```

---

## Data Hygiene Rules

1. **No duplicate contacts** — Always search before creating
2. **No orphan deals** — Every deal must be associated with at least one contact
3. **No empty stages** — Deals at a stage for 30+ days without activity should be flagged
4. **Consistent naming** — Deal names follow pattern: "[Company] - [Product/Service]"
5. **Activity timestamps** — Use ISO 8601 format, always include timezone
6. **Notes are structured** — Start notes with the purpose: "Qualification:", "Follow-up:", "Meeting notes:", etc.
7. **Never delete records** — Mark as closed-lost or archive. Deletion destroys history.

---

## Error Handling

| Error | Cause | Action |
|-------|-------|--------|
| 401 Unauthorized | API key expired or invalid | Alert owner: "Your HubSpot API key may need updating in the ClawTrust dashboard." |
| 409 Conflict | Duplicate contact | Search for existing, merge data instead |
| 429 Rate Limited | Too many requests | Wait 10 seconds, retry once. If still limited, batch remaining operations. |
| 404 Not Found | Invalid contact/deal ID | Verify the ID is correct. May have been deleted in HubSpot directly. |
| 500 Server Error | HubSpot is down | Retry once after 30 seconds. If still failing, log the intended action and retry later. |

### Graceful Degradation

If HubSpot is unreachable:
1. Log the intended action locally (in a structured note)
2. Inform the owner: "HubSpot isn't responding right now. I've logged the activity and will sync when it's back."
3. Retry on next task cycle
4. Never block sales activity because the CRM is down — adapt and log manually


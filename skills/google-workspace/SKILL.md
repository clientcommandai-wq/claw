# Skill — Google Workspace Management

**Purpose:** Create, organize, search, and share documents, spreadsheets, and files across Google Workspace (Drive, Docs, Sheets, Slides, Calendar) via the credential-proxy.

---

## Prerequisites

This skill requires the following credentials stored in the ClawTrust dashboard:

| Credential Key | Service | Purpose |
|---------------|---------|---------|
| `GOOGLE_WORKSPACE_OAUTH` | OAuth2 | Full Google Workspace access (Drive, Docs, Sheets, Calendar) |

If the credential is missing, inform the customer:
> "I need Google Workspace access to do this. Please add the GOOGLE_WORKSPACE_OAUTH credential in your ClawTrust dashboard. I'll walk you through it if needed."

---

## Capabilities

### Document Creation

Create documents from scratch or from templates:

```bash
# Create a new Google Doc
RESULT=$(curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "GOOGLE_WORKSPACE_OAUTH",
    "service": "google-docs",
    "request": {
      "action": "create",
      "title": "Q4 2026 Operations Report",
      "content": "...",
      "folderId": "FOLDER_ID_HERE"
    }
  }' \
  || echo '{"success":false,"error":"Proxy unreachable"}')
```

**Document types supported:**
- Google Docs (reports, memos, process documents, meeting notes)
- Google Sheets (trackers, financial summaries, data tables)
- Google Slides (presentation decks, pitch materials)

### File Organization

Maintain a clean, navigable folder structure:

**Default folder hierarchy** (customize in USER.md):
```
/Shared Drive Root/
├── Clients/
│   └── {ClientName}/
│       ├── Contracts/
│       ├── Invoices/
│       │   └── {Year}/
│       ├── Proposals/
│       └── Correspondence/
├── Internal/
│   ├── Finance/
│   │   ├── Invoices Sent/
│   │   ├── Invoices Received/
│   │   └── Reports/
│   ├── HR/
│   ├── Operations/
│   │   ├── Processes/
│   │   ├── Checklists/
│   │   └── Templates/
│   └── Meeting Notes/
│       └── {Year}/
│           └── {Month}/
└── Templates/
    ├── Invoice Template
    ├── Meeting Agenda Template
    └── Process Document Template
```

**File naming convention** (default, configurable in USER.md):
```
{YYYY-MM-DD}_{ClientOrTopic}_{DocumentType}.{ext}
```
Examples:
- `2026-02-10_AcmeCorp_Invoice-1042.pdf`
- `2026-02-10_Engineering_Standup-Notes.gdoc`
- `2026-Q4_Operations_Report.gsheet`

### File Search

Search across Drive to find documents:

```bash
# Search Drive for files matching a query
RESULT=$(curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "GOOGLE_WORKSPACE_OAUTH",
    "service": "google-drive",
    "request": {
      "action": "search",
      "query": "name contains '\''Q4 report'\'' and mimeType = '\''application/vnd.google-apps.spreadsheet'\''",
      "limit": 10
    }
  }' \
  || echo '{"success":false,"error":"Proxy unreachable"}')
```

**Search strategies:**
- By name: `name contains 'invoice'`
- By type: `mimeType = 'application/vnd.google-apps.spreadsheet'`
- By date: `modifiedTime > '2026-01-01T00:00:00'`
- By folder: `'FOLDER_ID' in parents`
- Combined: `name contains 'Acme' and mimeType = 'application/pdf' and modifiedTime > '2026-01-01'`

If a search returns no results, try:
1. Broaden the search terms (remove date filters, use partial names)
2. Search in a different folder (maybe it was filed elsewhere)
3. Check "Trash" — it may have been accidentally deleted
4. Ask the customer: "I couldn't find a file matching '[query]'. Do you remember the exact name or where it was saved?"

### Sharing and Permissions

**Share files with appropriate access levels:**

| Permission | Use Case | Approval Required? |
|-----------|----------|-------------------|
| Viewer | Internal team read-only access | No |
| Commenter | Internal review/feedback | No |
| Editor | Internal collaboration | No |
| Viewer (external) | Client document review | YES |
| Editor (external) | Client collaboration | YES |

```bash
# Share a file (ALWAYS check AGENTS.md for approval requirements)
RESULT=$(curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "GOOGLE_WORKSPACE_OAUTH",
    "service": "google-drive",
    "request": {
      "action": "share",
      "fileId": "FILE_ID",
      "email": "collaborator@company.com",
      "role": "writer",
      "sendNotification": true,
      "emailMessage": "Shared the Q4 report for your review."
    }
  }' \
  || echo '{"success":false,"error":"Proxy unreachable"}')
```

**Before sharing externally**, always:
1. Confirm with the customer: "I'm about to share [document] with [person] as [permission level]. OK?"
2. Verify the recipient email is correct (typos in email = data leak)
3. Set an expiration if the access is temporary

### Spreadsheet Operations

Create and manage structured data:

```bash
# Create a spreadsheet with formatted data
RESULT=$(curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "GOOGLE_WORKSPACE_OAUTH",
    "service": "google-sheets",
    "request": {
      "action": "create",
      "title": "Accounts Receivable Tracker - February 2026",
      "sheets": [
        {
          "name": "Outstanding",
          "headers": ["Invoice #", "Client", "Amount", "Date Sent", "Due Date", "Status", "Days Overdue"],
          "data": []
        },
        {
          "name": "Paid",
          "headers": ["Invoice #", "Client", "Amount", "Date Sent", "Date Paid", "Payment Method"],
          "data": []
        }
      ],
      "folderId": "FINANCE_FOLDER_ID"
    }
  }' \
  || echo '{"success":false,"error":"Proxy unreachable"}')
```

**Common spreadsheet operations:**
- Append rows (new invoice entries, task updates)
- Update cells (status changes, payment records)
- Format cells (currency, dates, conditional formatting for overdue items)
- Create formulas (SUM for totals, DATEDIF for overdue days, COUNTIF for status counts)
- Sort and filter data
- Export as CSV or PDF

---

## Templates

### Meeting Notes Template
```
# Meeting Notes — {Meeting Name}
**Date:** {YYYY-MM-DD}
**Time:** {HH:MM} {Timezone}
**Attendees:** {names}
**Facilitator:** {name}

## Agenda
1. ...

## Discussion Notes
- ...

## Action Items
| Item | Owner | Due Date | Status |
|------|-------|----------|--------|

## Next Meeting
**Date:** {date} | **Time:** {time}
```

### Process Document Template
```
# Process: {Process Name}
**Owner:** {name/role}
**Last Updated:** {date}
**Frequency:** {daily/weekly/monthly/as-needed}

## Purpose
{Why this process exists}

## Steps
1. ...
2. ...
3. ...

## Exceptions
- If {condition}, then {alternative step}

## Related Documents
- {links}
```

---

## Error Handling

| Error | Meaning | Action |
|-------|---------|--------|
| `credential_not_found` | GOOGLE_WORKSPACE_OAUTH not set up | Ask customer to add it in dashboard |
| `403 Forbidden` | No access to the requested file/folder | Ask customer to share it with the workspace service account |
| `404 Not Found` | File/folder doesn't exist or was deleted | Search for it, check trash, ask customer |
| `429 Rate Limited` | Too many API calls | Wait 60s, retry, batch subsequent operations |
| `507 Storage Full` | Drive storage limit reached | Inform customer, suggest cleanup |

---

## Security Rules

- Never download files to the local filesystem — work through the API only
- Never share files with "Anyone with the link" permission — always use specific email addresses
- Never move files out of their designated folder structure without customer approval
- Verify recipient email addresses match known contacts before sharing
- Log all sharing actions in team-memory for audit trail


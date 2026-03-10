# Skill — Invoicing

**Purpose:** Generate, send, track, and follow up on invoices. Manage accounts receivable and payment reminders. Integrate with accounting software via credential-proxy.

---

## Prerequisites

| Credential Key | Service | Required? |
|---------------|---------|-----------|
| `GOOGLE_WORKSPACE_OAUTH` | Google Sheets/Docs | Yes (for invoice generation and A/R tracking) |
| `SMTP_CREDENTIALS` or `GMAIL_APP_PASSWORD` | Email delivery | Yes (for sending invoices) |
| `QUICKBOOKS_OAUTH` or `XERO_OAUTH` or `FRESHBOOKS_API_KEY` | Accounting sync | Optional (per USER.md) |

---

## Invoice Data Fields

Every invoice must contain these fields before it can be sent:

### Required Fields
| Field | Source | Example |
|-------|--------|---------|
| Invoice Number | Auto-generated from USER.md prefix + sequence | INV-1042 |
| Issue Date | Today's date | 2026-02-10 |
| Due Date | Issue date + payment terms from USER.md | 2026-03-12 (net-30) |
| Bill To (name) | Customer provides or from team-memory | Acme Corporation |
| Bill To (email) | Customer provides or from team-memory | billing@acmecorp.com |
| Line Items | Customer provides | 1x Q4 Consulting @ $4,500 |
| Subtotal | Calculated | $4,500.00 |
| Tax | Calculated from USER.md tax rate | $0.00 |
| Total | Calculated | $4,500.00 |
| Currency | From USER.md | USD |

### Optional Fields
| Field | Source | Example |
|-------|--------|---------|
| PO Number | Customer provides | PO-2026-0089 |
| Project Name | Customer provides | Q4 Platform Redesign |
| Payment Instructions | From USER.md | Wire to Chase acct ending 4421 |
| Notes | Customer provides | "Thank you for your business" |
| Late Fee Terms | From USER.md | 1.5% monthly after 30 days |

---

## Invoice Lifecycle

```
DRAFT → APPROVED → SENT → VIEWED → PAID
                              │
                              └→ OVERDUE → REMINDER_1 → REMINDER_2 → ESCALATED
```

### 1. DRAFT — Invoice Created
- Assemble all required fields
- Generate invoice number (next in sequence from A/R tracker)
- Calculate totals (subtotal + tax = total)
- Present to customer for review:

> "Here's the draft invoice:
> - Invoice #INV-1042
> - To: Acme Corporation (billing@acmecorp.com)
> - Amount: $4,500.00
> - Due: March 12, 2026 (net-30)
> - Line items: 1x Q4 Consulting — $4,500.00
>
> Should I send this?"

### 2. APPROVED — Customer Says "Send It"
- Only proceed after explicit approval ("yes", "send it", "approved", "looks good")
- "Maybe" or "let me check" = NOT approved, wait

### 3. SENT — Invoice Delivered
- Send via email (using credential-proxy SMTP)
- Attach invoice as PDF
- Email body includes: invoice summary, amount, due date, payment instructions
- Log in A/R tracker: invoice number, client, amount, date sent, due date, status = "Sent"
- Confirm to customer: "Invoice #INV-1042 sent to billing@acmecorp.com"

### 4. VIEWED — Recipient Opened (if tracking available)
- Update status in tracker

### 5. PAID — Payment Received
- Customer informs you payment was received
- Update A/R tracker: status = "Paid", payment date, payment method
- If accounting software is connected, sync the payment record
- Confirm: "Recorded — Invoice #INV-1042 marked as paid ($4,500 via wire transfer on Feb 15)"

### 6. OVERDUE — Past Due Date
- Triggered when today > due date and status is not "Paid"
- Follow the reminder schedule below

---

## Payment Reminder Schedule

Default schedule (configurable by customer during onboarding):

| Trigger | Action | Template |
|---------|--------|----------|
| Due date - 3 days | Friendly heads-up | REMINDER_UPCOMING |
| Due date + 1 day | First overdue notice | REMINDER_1 |
| Due date + 7 days | Second notice, firmer | REMINDER_2 |
| Due date + 14 days | Final notice before escalation | REMINDER_3 |
| Due date + 21 days | Escalate to customer | ESCALATE |

### Reminder Templates

**REMINDER_UPCOMING** (3 days before due):
```
Subject: Upcoming payment — Invoice #{number} due {due_date}

Hi {client_name},

Just a friendly reminder that Invoice #{number} for {amount} is due on {due_date}.

Payment details are included in the original invoice. Let us know if you have any questions.

Best,
{company_name}
```

**REMINDER_1** (1 day overdue):
```
Subject: Payment due — Invoice #{number}

Hi {client_name},

Invoice #{number} for {amount} was due on {due_date}. If you've already sent payment, please disregard this message.

If you need a copy of the invoice, I'm happy to resend it.

Best,
{company_name}
```

**REMINDER_2** (7 days overdue):
```
Subject: Payment overdue — Invoice #{number} ({days_overdue} days)

Hi {client_name},

This is a follow-up regarding Invoice #{number} for {amount}, which was due on {due_date} ({days_overdue} days ago).

Could you provide an update on the expected payment date?

Best,
{company_name}
```

**REMINDER_3** (14 days overdue):
```
Subject: Final notice — Invoice #{number} ({days_overdue} days overdue)

Hi {client_name},

Invoice #{number} for {amount} is now {days_overdue} days past due.

Please arrange payment at your earliest convenience or contact us to discuss any issues.

{late_fee_notice}

Best,
{company_name}
```

> All reminders require initial customer approval of the reminder schedule. Once approved, they send automatically. Each reminder is logged in the A/R tracker.

---

## Accounts Receivable Reporting

### A/R Summary (generate on request or as part of monthly report)

```
ACCOUNTS RECEIVABLE SUMMARY — {date}
========================================

OUTSTANDING INVOICES:
  Total: {count} invoices, {total_amount}

  Current (0-30 days):   {count}  {amount}
  Overdue (31-60 days):  {count}  {amount}
  Overdue (61-90 days):  {count}  {amount}
  Overdue (90+ days):    {count}  {amount}

TOP OUTSTANDING:
  1. {client} — {invoice_number} — {amount} — {days_overdue} days overdue
  2. ...

PAID THIS PERIOD:
  Total: {count} invoices, {total_amount}
  Average days to payment: {avg_days}

COLLECTION RATE: {paid_total / (paid_total + outstanding_total) * 100}%
```

---

## Accounting Software Integration

If the customer uses accounting software (specified in USER.md), sync invoice data:

### QuickBooks Online
```bash
# Create invoice in QuickBooks via credential-proxy
RESULT=$(curl --max-time 15 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "QUICKBOOKS_OAUTH",
    "service": "http-bearer",
    "request": {
      "url": "https://quickbooks.api.intuit.com/v3/company/COMPANY_ID/invoice",
      "method": "POST",
      "body": {
        "Line": [
          {
            "Amount": 4500.00,
            "DetailType": "SalesItemLineDetail",
            "Description": "Q4 Consulting Services"
          }
        ],
        "CustomerRef": {"value": "CUSTOMER_ID"}
      }
    }
  }' \
  || echo '{"success":false,"error":"Proxy unreachable"}')
```

### Xero
```bash
RESULT=$(curl --max-time 15 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "XERO_OAUTH",
    "service": "http-bearer",
    "request": {
      "url": "https://api.xero.com/api.xro/2.0/Invoices",
      "method": "POST",
      "body": {
        "Type": "ACCREC",
        "Contact": {"Name": "Acme Corporation"},
        "LineItems": [
          {"Description": "Q4 Consulting Services", "UnitAmount": 4500.00, "Quantity": 1}
        ],
        "DueDate": "2026-03-12"
      }
    }
  }' \
  || echo '{"success":false,"error":"Proxy unreachable"}')
```

If no accounting software is configured, invoice records live in the Google Sheets A/R tracker only. Recommend to the customer: "Connecting QuickBooks or Xero would let me keep your books in sync automatically."

---

## Invoice Number Generation

1. Read the A/R tracker spreadsheet to find the last invoice number
2. Increment by 1 (sequential) or generate date-based (per USER.md preference)
3. Verify no duplicates exist (search tracker for the generated number)
4. If collision found, increment again

**Sequential:** INV-1042 → INV-1043 → INV-1044
**Date-based:** INV-2026-02-001 → INV-2026-02-002 → INV-2026-03-001

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Missing client email | Ask: "What email should I send this invoice to?" |
| Missing line items | Ask: "What services/products should I include on this invoice?" |
| Duplicate invoice number detected | Auto-increment and log the anomaly |
| Email delivery failed | Retry once, then inform customer with the specific error |
| Accounting sync failed | Send invoice via email anyway, flag sync issue for customer |
| Client disputes amount | Flag to customer immediately — never adjust amounts autonomously |
| Tax rate unclear | Ask customer — never guess tax rates |

---

## Security Rules

- Never store financial data outside approved systems (Sheets tracker, accounting software)
- Never share A/R reports externally without explicit approval
- Never adjust invoice amounts after sending without customer approval and a new invoice
- Log every invoice action (created, sent, reminder sent, payment recorded) for audit trail
- Never include bank account details in any communication except the invoice itself


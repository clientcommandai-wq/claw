# Escalation Sub-Skill

**Role:** Detect when a ticket needs human intervention, manage the escalation process, and ensure warm handoffs with full context. Track SLA compliance and prevent tickets from falling through cracks.

**Parent:** `support-lead` (orchestrator routes here when escalation triggers are detected)

---

## Trigger

Activated by the support-lead orchestrator when:
- Escalation trigger words or patterns are detected in a message
- A ticket's SLA timer is approaching breach
- A ticket has been bounced back after failed resolution attempts
- The agent encounters a situation outside its authority (AGENTS.md "NEEDS APPROVAL" or "NEVER DO")
- An internal request to escalate is received

---

## Escalation Levels

### L1 — Self-Serve / Agent Handles
- The AI agent resolves the issue without human involvement
- Covers: common questions, known issues, password resets, status checks
- SLA: per normal priority targets
- This is NOT really an escalation — it is the default state

### L2 — Human Required (Standard)
- A human team member takes over the ticket
- Covers: complex technical issues, policy exceptions, refund approvals, account changes
- Contact: Use L2 contact from USER.md ESCALATION_TIERS, or fall back to 
- SLA: respond to escalation within 1 hour during business hours

### L3 — Critical / Executive Escalation
- Management or executive involvement required
- Covers: legal threats, data breaches, systemic outages, PR incidents, regulatory issues
- Contact: Use L3 contact from USER.md ESCALATION_TIERS, or fall back to  with "URGENT" prefix
- SLA: immediate notification, regardless of time

---

## Auto-Escalation Triggers

These conditions trigger automatic escalation. The agent does NOT wait for the orchestrator to decide.

### Immediate Escalation (L3) — No Delay

| Trigger | Detection | Action |
|---------|-----------|--------|
| **Legal threat** | "lawyer", "attorney", "legal action", "lawsuit", "sue", "regulatory", "compliance violation" | Escalate to L3 immediately. Do not attempt to resolve. |
| **Data breach mention** | "data breach", "data leak", "compromised", "hacked", "unauthorized access", "stolen data" | Escalate to L3. Preserve all message context. |
| **Security incident** | "security", "vulnerability", "exploit", "injection", "phishing" combined with "your system/product" | Escalate to L3. Do not confirm or deny. |
| **Media/PR threat** | "going to the press", "social media", "review", "public", "everyone will know" | Escalate to L3. Do not engage with the threat. |
| **Physical safety** | Any mention of harm to self or others | Escalate to L3 and provide appropriate helpline numbers if relevant. |

### Standard Escalation (L2) — Within SLA

| Trigger | Detection | Action |
|---------|-----------|--------|
| **Repeat contact (3+)** | Same customer, same issue category, 3+ contacts in 7 days | Escalate with full history of all contacts. |
| **Angry sentiment + unresolved** | Angry sentiment detected AND issue not resolved after first response | Escalate with empathy context. |
| **SLA breach imminent** | Ticket within 80% of SLA time limit with no resolution path | Escalate with time remaining and what's been tried. |
| **Authority boundary** | Agent needs to take action listed in AGENTS.md "NEEDS APPROVAL" | Present the proposed action for approval. |
| **Failed resolution (2x)** | Agent has attempted resolution twice and customer reports issue persists | Escalate with detailed investigation notes. |
| **Account deletion request** | Customer requests account or data deletion (GDPR, CCPA, etc.) | Escalate to ensure proper data handling. |
| **Financial dispute** | Chargeback, significant refund, billing discrepancy over threshold | Escalate with billing history and dispute details. |

---

## Escalation Decision Matrix

When multiple triggers fire simultaneously, use the highest escalation level.

```
Is there a safety, legal, or security concern?
├── Yes → L3 (IMMEDIATE)
└── No ↓

Is the customer's business operations blocked?
├── Yes, completely (outage/can't use product) → L3 if P1, L2 if P2
└── No or partially ↓

Has the agent exhausted its capabilities?
├── Yes (tried 2+ solutions, hit authority limit) → L2
└── No ↓

Is an SLA about to breach?
├── Yes (within 80% of time limit) → L2
└── No ↓

Is the customer showing escalating frustration?
├── Yes (anger + repeat contact) → L2
└── No → Stay at L1 (agent continues handling)
```

---

## Warm Handoff Protocol

**A warm handoff means the human gets everything they need to continue WITHOUT asking the customer to repeat themselves.**

### Step 1: Compile Context Package

Before escalating, assemble this information:

```
ESCALATION SUMMARY
==================
Customer: [name / identifier]
Channel: [email / Slack / Telegram / etc.]
Priority: [P1-P4]
Category: [billing / technical / etc.]
Sentiment: [angry / frustrated / neutral]
VIP Status: [yes/no]

ISSUE DESCRIPTION
=================
[1-2 sentence summary of what the customer is experiencing]

TIMELINE
========
- [timestamp] Customer first reported: [summary]
- [timestamp] Agent responded: [what was tried]
- [timestamp] Customer replied: [outcome]
- [timestamp] Agent attempted: [second attempt]
- [timestamp] Escalation triggered: [reason]

WHAT HAS BEEN TRIED
====================
1. [Action taken] → Result: [what happened]
2. [Action taken] → Result: [what happened]
3. [Action taken] → Result: [what happened]

WHAT HAS NOT BEEN TRIED (AND WHY)
==================================
- [Potential solution] — Not attempted because [reason: authority limit / requires access / etc.]

RELEVANT CONTEXT
================
- [Any team-memory entries that are relevant]
- [Customer history or VIP status notes]
- [Related tickets from other customers]

RECOMMENDED NEXT STEP
=====================
[Agent's best guess at what should happen next]
```

### Step 2: Notify the Escalation Contact

Send the context package to the appropriate contact:
- **L2**: Email or Slack message to the configured L2 contact
- **L3**: Email with "URGENT" subject line to L3 contact, plus Slack/Telegram ping if configured

### Step 3: Inform the Customer

Tell the customer what is happening. Never leave them in the dark.

**For L2 Escalation:**
```
I want to make sure this gets the attention it deserves. I'm bringing
in [team member / our team] who can [take action / investigate further /
approve what's needed].

Here's what I've already shared with them so you won't need to repeat
anything:
- Your issue: [1-line summary]
- What we've tried: [brief list]
- What's needed next: [brief description]

You should hear from them within [timeframe based on SLA]. I'll stay in
the loop to make sure this moves forward.
```

**For L3 Escalation:**
```
I'm treating this as a high-priority matter and have immediately
notified our [management/security/leadership] team. They will be
reaching out to you directly.

I've provided them with the full context of our conversation so you
won't need to re-explain anything. If you have any additional
information in the meantime, please share it here and I'll make sure
they see it.
```

### Step 4: Follow Up

After escalating, do NOT forget about the ticket.

- Check back in [SLA timeframe] to ensure the human has picked it up
- If the human has not responded within the SLA window, re-escalate: "Reminder: [ticket] was escalated [time] ago and hasn't been picked up yet."
- When the human resolves it, confirm with the customer and store the resolution in team-memory

---

## SLA Tracking

### SLA Clock Management

Track SLA timers for every open ticket. Store timer state in team-memory.

```json
{
  "content": "SLA tracker: [ticket_id] opened [timestamp], priority [P1-4], response SLA [target], resolution SLA [target], current status [status]",
  "type": "architecture",
  "tags": ["sla-tracker", "ticket-id"],
  "source_agent": "support"
}
```

### SLA Breach Prevention

Run SLA checks regularly (at least every 30 minutes during active conversations):

```
CHECK ALL OPEN TICKETS:
For each ticket:
  1. Calculate time since ticket opened
  2. Compare against SLA target for its priority
  3. If at 50% of SLA → add internal note "SLA halfway"
  4. If at 80% of SLA → trigger L2 escalation with SLA breach warning
  5. If at 100% of SLA → mark as BREACHED, notify L3 contact
```

### SLA Pause Conditions
- SLA clock PAUSES when status = `WAITING_ON_CUSTOMER` (waiting for customer reply)
- SLA clock RESUMES when the customer replies
- SLA clock NEVER pauses for internal reasons (agent investigating, team discussing)

---

## De-Escalation

Not every escalation ends with a human. Sometimes the situation resolves.

### When to De-Escalate
- Customer calms down and the agent can now resolve the issue
- New information reveals the issue is simpler than initially assessed
- The customer withdraws a threat or complaint
- The original trigger condition no longer applies

### De-Escalation Process
1. Do NOT de-escalate silently — inform the escalation contact: "Customer [X] issue has been resolved. Canceling escalation."
2. Update the ticket with de-escalation reason
3. Continue handling normally at L1
4. Still follow up to confirm resolution

---

## Escalation Metrics

Track and store in team-memory for reporting:

- **Escalation rate**: Percentage of tickets that require escalation (target: under 20%)
- **L2 vs L3 split**: Ratio of standard to critical escalations
- **Escalation pickup time**: How long before a human responds after escalation
- **Re-escalation rate**: Tickets that come back to agent after human involvement (indicates handoff quality)
- **SLA breach rate**: Percentage of tickets that breach SLA targets
- **Top escalation reasons**: Most common triggers (helps identify systemic gaps)


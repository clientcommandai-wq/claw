# Support Lead Orchestrator

**Role:** Primary orchestrator for all support operations. Every incoming support request flows through this skill first.

**Purpose:** Classify, prioritize, and route support requests to the correct sub-skill. After resolution, capture learnings and identify knowledge base improvements.

---

## Trigger

This skill activates when:
- A new support request arrives on any channel (email, Slack, Telegram, Discord, WhatsApp)
- An internal team member asks a support-related question
- A follow-up arrives on an existing ticket
- An SLA timer approaches breach threshold

---

## Orchestration Flow

```
INCOMING REQUEST
      |
      v
[1. CONTEXT LOAD]
      |  - Search team-memory for customer history
      |  - Check if follow-up to existing ticket
      |  - Load customer profile from USER.md
      |
      v
[2. CLASSIFY REQUEST TYPE]
      |  - ticket-triage (new issue)
      |  - knowledge-base (question/how-to)
      |  - escalation (urgent/angry/legal)
      |  - follow-up (existing ticket)
      |
      v
[3. ASSESS SEVERITY]
      |  - P1: Service outage, data loss, security incident
      |  - P2: Major feature broken, degraded service
      |  - P3: Minor bug, workaround exists
      |  - P4: Question, feature request, general inquiry
      |
      v
[4. ROUTE TO SUB-SKILL]
      |  - ticket-triage → classify, prioritize, assign
      |  - knowledge-base → search docs, draft answer
      |  - escalation → detect triggers, warm handoff
      |
      v
[5. POST-RESOLUTION]
      |  - Confirm resolution with customer
      |  - Store learnings in team-memory
      |  - Flag knowledge base gaps
      |  - Update SLA tracking
      |
      v
    DONE
```

---

## Step 1: Context Load

Before classifying anything, gather context. This prevents asking the customer questions you should already know the answer to.

```
CONTEXT LOAD CHECKLIST:
[ ] Search team-memory: "customer name/identifier + recent issues"
[ ] Check: Is this a reply to an existing conversation? (look for ticket refs, thread context)
[ ] Check: Is this customer flagged as VIP in USER.md?
[ ] Check: Has this customer contacted us in the last 7 days? (potential repeat issue)
[ ] Load: Any relevant knowledge base articles for keywords in their message
```

If this is a follow-up to an existing issue, skip classification and resume the existing ticket flow. Acknowledge the follow-up: "Thanks for the update on [issue]. Let me pick up where we left off."

---

## Step 2: Classification Decision Tree

Read the entire message before classifying. Customers often bury the real issue.

```
Is the customer reporting a problem or asking a question?
├── PROBLEM (something is broken/wrong)
│   ├── Is it a billing/payment issue?
│   │   ├── Yes → ticket-triage (category: billing)
│   │   └── No ↓
│   ├── Is it a technical/product issue?
│   │   ├── Yes → ticket-triage (category: technical)
│   │   └── No ↓
│   ├── Is it an account access issue?
│   │   ├── Yes → ticket-triage (category: account-access)
│   │   └── No → ticket-triage (category: general)
│   │
│   └── [OVERRIDE] Does the message contain escalation triggers?
│       ├── Yes → escalation (skip ticket-triage)
│       └── No → continue with ticket-triage
│
├── QUESTION (how do I...? / what is...? / can I...?)
│   ├── Is the answer likely in documentation?
│   │   ├── Yes → knowledge-base
│   │   └── No ↓
│   ├── Is this a feature request disguised as a question?
│   │   ├── Yes → ticket-triage (category: feature-request)
│   │   └── No → knowledge-base
│
├── FEEDBACK (praise, complaint, suggestion)
│   ├── Positive → Acknowledge, store in team-memory, no ticket needed
│   ├── Complaint → ticket-triage (category: complaint)
│   └── Suggestion → ticket-triage (category: feature-request)
│
└── UNCLEAR
    └── Ask ONE clarifying question, then re-classify
```

---

## Step 3: Severity Assessment

Assign priority BEFORE routing. This ensures SLA timers start immediately.

### Priority Matrix

| Priority | Criteria | Examples | SLA (default) |
|----------|----------|----------|---------------|
| **P1 - Critical** | Service completely down, data loss, security breach, revenue-blocking | "Our entire team can't log in", "We think our data was compromised", "Checkout is broken for all customers" | Respond: 1hr, Resolve: 4hr |
| **P2 - High** | Major feature broken, significant degradation, no workaround | "Exports are failing", "Integrations stopped syncing", "Performance is extremely slow" | Respond: 4hr, Resolve: 24hr |
| **P3 - Medium** | Minor bug, workaround exists, cosmetic issue | "This button doesn't work on mobile", "Report shows wrong date format", "Notifications are delayed" | Respond: 24hr, Resolve: 72hr |
| **P4 - Low** | Question, feature request, how-to, general inquiry | "How do I set up X?", "Can you add Y feature?", "What's the difference between A and B?" | Respond: 48hr, Resolve: 1 week |

### Priority Escalation Triggers (upgrade by 1 level)
- Customer explicitly says "urgent" or "emergency"
- Customer is flagged as VIP
- Same issue reported by 3+ customers in 24 hours (systemic)
- Customer mentions legal action, regulatory compliance, or data breach
- Revenue impact mentioned ("we're losing money", "customers can't buy")

### Automatic P1 Keywords
If the message contains any of these, classify as P1 immediately:
- "outage", "down", "data breach", "security incident", "can't access anything"
- "all users affected", "production is broken", "losing revenue"
- "URGENT" (all caps)

---

## Step 4: Routing

### Route to `ticket-triage`
- All new problems, bugs, complaints, and feature requests
- The sub-skill handles classification, auto-response, and tracking

### Route to `knowledge-base`
- Questions, how-to requests, documentation lookups
- If the knowledge base search finds nothing, the sub-skill will escalate back to you

### Route to `escalation`
- Detected anger, legal threats, or repeated contact
- P1 issues that may need human intervention
- Any request where AGENTS.md says "NEEDS APPROVAL"

### Follow-up Handling (no routing needed)
- If this is a reply to an existing conversation, continue directly
- Acknowledge the update, check if the issue is now resolved
- If the customer says "that didn't work," re-investigate with the new information

---

## Step 5: Post-Resolution Protocol

After EVERY resolved ticket, run this checklist:

```
POST-RESOLUTION CHECKLIST:
[ ] Customer confirmed the issue is resolved (or 48hr auto-close warning sent)
[ ] Root cause identified and documented in the ticket
[ ] Resolution stored in team-memory (if novel or useful for future)
[ ] Check: Should this become a knowledge base article?
    - Was the answer NOT already in the KB? → Suggest new article
    - Was the KB article wrong or outdated? → Flag for update
[ ] Check: Is this a systemic issue?
    - Same issue from multiple customers → Flag for engineering escalation
[ ] SLA compliance recorded (did we hit targets?)
[ ] Customer satisfaction: if the interaction was long/complex, ask for feedback
```

### Knowledge Base Gap Detection

After resolving a ticket, ask yourself:
1. Did I find the answer in the knowledge base? If no, this is a gap.
2. Was the KB article accurate? If no, flag for update.
3. Did the customer find the answer themselves before contacting us? If no, the KB may need better navigation.
4. Would a proactive notification have prevented this ticket? If yes, flag for product team.

Store recommendations in team-memory with tag `kb-gap` so they accumulate for review.

---

## Multi-Issue Handling

Sometimes a customer message contains multiple issues. Handle them:

1. Acknowledge ALL issues in your response: "I see three things here — let me address each one."
2. Prioritize by severity (handle the P1 first)
3. Classify each issue independently
4. If different sub-skills are needed, route them separately but keep the customer updated as a unit
5. Do NOT ask the customer to submit separate tickets — that is your job

---

## Channel-Specific Behavior

| Channel | Behavior |
|---------|----------|
| **Email** | Full investigation before responding. Include ticket reference. Formal tone. |
| **Slack** | Quick acknowledgment within minutes ("On it!"), full response in thread. |
| **Telegram/WhatsApp** | Conversational, shorter messages. Use follow-ups rather than one massive message. |
| **Discord** | Check if question was already answered in the channel. Reference previous answers. |

---

## Metrics to Track

Store these in team-memory periodically for reporting:

- **Tickets opened** (per day/week)
- **Average first response time** (vs SLA target)
- **Average resolution time** (vs SLA target)
- **Tickets resolved without escalation** (self-serve rate)
- **Knowledge base hit rate** (issues resolved from KB)
- **Repeat contact rate** (same customer, same issue)
- **SLA breach count** (number of tickets that missed targets)


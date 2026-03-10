# Ticket Triage Sub-Skill

**Role:** Classify, prioritize, and process incoming support tickets. This is the workhorse of the support operation — it handles the majority of incoming requests.

**Parent:** `support-lead` (orchestrator routes here for new issues)

---

## Trigger

Activated by the support-lead orchestrator when:
- A new problem, bug report, complaint, or feature request is received
- A ticket needs reclassification after new information surfaces
- A batch triage is requested (process queue of unclassified tickets)

---

## Classification System

### Categories

Every ticket must be assigned exactly ONE primary category and optionally one secondary tag.

| Category | Description | Auto-Response? | Example |
|----------|-------------|---------------|---------|
| `billing` | Payment issues, invoices, subscription changes, refund requests | Yes | "I was charged twice", "How do I upgrade?" |
| `technical` | Product bugs, errors, crashes, integrations not working | Depends | "I get an error when I click export", "API returns 500" |
| `account-access` | Login issues, password resets, permission problems, locked accounts | Yes | "I forgot my password", "My account is locked" |
| `feature-request` | New feature suggestions, enhancement requests, wishlist items | Yes | "Can you add dark mode?", "It would be great if..." |
| `bug-report` | Specific reproducible bugs with steps | No | "When I do X then Y, Z happens instead of W" |
| `complaint` | Service quality complaints, negative feedback | No | "Your support is too slow", "This feature used to work better" |
| `general` | Anything that does not fit above categories | No | "I have a question about your product" |

### Classification Rules

1. **Read the ENTIRE message** before classifying. The category might not match the first sentence.
2. **Billing keywords**: charge, invoice, payment, refund, subscription, cancel, upgrade, downgrade, receipt, billing, price, cost
3. **Technical keywords**: error, bug, crash, broken, not working, failing, timeout, 500, 404, integration, API, sync
4. **Account keywords**: login, password, access, locked, permission, reset, sign in, authentication, 2FA, MFA
5. **Feature keywords**: wish, would be nice, can you add, suggestion, feature, enhancement, idea, roadmap
6. If ambiguous, classify based on what the customer NEEDS, not what they SAY. ("I can't log in to see my invoice" = `account-access`, not `billing`)

---

## Priority Assignment

### Priority Decision Flow

```
Is the service completely unavailable for the customer?
├── Yes → P1
└── No ↓

Is a major feature broken with no workaround?
├── Yes → P2
└── No ↓

Is there a bug or issue, but the customer can work around it?
├── Yes → P3
└── No ↓

Is this a question, feature request, or minor cosmetic issue?
└── Yes → P4
```

### SLA Timer Defaults

These are defaults. Override with values from USER.md if configured.

| Priority | First Response | Resolution Target | Breach Warning |
|----------|---------------|-------------------|----------------|
| P1 | 1 hour | 4 hours | At 45 min / 3 hr |
| P2 | 4 hours | 24 hours | At 3 hr / 20 hr |
| P3 | 24 hours | 72 hours | At 20 hr / 60 hr |
| P4 | 48 hours | 1 week | At 36 hr / 5 days |

When an SLA breach warning threshold is hit:
1. Immediately notify the escalation contact
2. Add internal note: "SLA breach approaching — [time remaining]"
3. If no progress on the ticket, escalate to the next level

---

## Sentiment Detection

Analyze the customer's emotional state to adjust response tone and priority.

### Sentiment Categories

| Sentiment | Indicators | Response Adjustment |
|-----------|-----------|-------------------|
| **Angry** | ALL CAPS, exclamation marks, profanity, threats, "worst service", "never again" | Lead with empathy. Acknowledge frustration explicitly. Escalate if 3+ anger signals. |
| **Frustrated** | "I've tried everything", "this keeps happening", "again?!", repeated contact | Acknowledge their effort. Skip basic troubleshooting they've already done. |
| **Confused** | Question marks, "I don't understand", vague descriptions, contradictory info | Slow down. Ask one clarifying question at a time. Use simple language. |
| **Neutral** | Straightforward description, factual tone, no emotional language | Standard professional response. Focus on efficiency. |
| **Positive** | Praise, gratitude, constructive suggestions, "love your product" | Thank them. Make them feel heard. Still resolve the issue thoroughly. |

### Sentiment-Based Priority Adjustments

- **Angry + repeat contact** (3+ times same issue) → Upgrade priority by 1 level AND trigger escalation review
- **Frustrated + long message** (customer clearly spent time explaining) → Respond with proportional thoroughness
- **Multiple exclamation marks or ALL CAPS** → Add empathy opener, do NOT match their energy

---

## Auto-Response Templates

For common, well-understood issues, send an immediate helpful response. Always customize with specifics from the customer's message.

### Account Access — Password Reset

```
Subject: Password Reset for Your Account

Hi [Name],

I can help you get back into your account. Here's how to reset your password:

1. Go to [LOGIN_URL]
2. Click "Forgot Password"
3. Enter the email address associated with your account
4. Check your inbox (and spam folder) for the reset link
5. The link expires in 1 hour

If you don't receive the email within 5 minutes, let me know and I'll
investigate further. Sometimes the email goes to spam, so please check
there first.

If your account is locked due to too many failed attempts, I'll need to
verify your identity before unlocking it — I'll ask a couple of quick
questions.
```

### Billing — Duplicate Charge

```
Subject: Re: Duplicate Charge on Your Account

Hi [Name],

I see you're concerned about a duplicate charge. I'm looking into this
right now.

Before I investigate, a quick note: sometimes charges appear as
"pending" and then disappear within 3-5 business days. If the charge is
still showing after that period, it may be a genuine duplicate.

I'm checking your billing history now and will follow up with what I
find. If this is confirmed as a duplicate, I'll flag it for a refund
(which will need approval from our team).

I'll have an update for you within [SLA_TIME].
```

### Feature Request — Acknowledgment

```
Subject: Thanks for Your Feature Suggestion

Hi [Name],

Thanks for suggesting [FEATURE]. I've logged this as a feature request.

Here's what happens next:
- Your suggestion has been recorded and tagged for our product team
- Feature requests are reviewed [frequency if known, otherwise "periodically"]
- I can't promise a timeline, but your input genuinely helps shape the product

If you have any additional context on how this feature would help your
workflow, I'd love to hear it — the more detail we have, the better we
can evaluate it.
```

### General — Need More Information

```
Hi [Name],

Thanks for reaching out. I want to make sure I get this right for you.

Could you help me with a couple of details?
1. [Specific question about the issue]
2. [Specific question about their environment/setup]
3. When did this start happening?

This will help me investigate much faster. In the meantime, I'm
searching our knowledge base for similar issues.
```

---

## VIP Detection

Check the customer's identity against VIP list in USER.md before processing.

### VIP Signals
- Customer name/email/domain matches USER.md VIP_CUSTOMERS list
- Customer mentions enterprise contract, dedicated account manager, or SLA agreement
- Internal team member flags the customer as VIP

### VIP Treatment
- Automatically upgrade priority by 1 level (P3 becomes P2, P2 becomes P1)
- Include VIP tag in all internal notes
- Faster SLA targets (halve the default response time)
- Proactive follow-up within 24 hours of resolution
- Never use auto-responses for VIP tickets — always personalize

---

## Ticket Lifecycle

```
NEW → ACKNOWLEDGED → INVESTIGATING → WAITING_ON_CUSTOMER → RESOLVED → CLOSED
                                         ↑                      |
                                         |                      v
                                         +---- REOPENED ←── (customer replies)
```

### State Transitions
- **NEW → ACKNOWLEDGED**: Send first response (auto or custom)
- **ACKNOWLEDGED → INVESTIGATING**: Start active work on the issue
- **INVESTIGATING → WAITING_ON_CUSTOMER**: Asked customer for information, waiting
- **WAITING_ON_CUSTOMER → INVESTIGATING**: Customer replied with info
- **INVESTIGATING → RESOLVED**: Solution provided, awaiting confirmation
- **RESOLVED → CLOSED**: Customer confirmed fix OR 48-hour auto-close (with warning)
- **CLOSED → REOPENED**: Customer replies to a closed ticket

### Auto-Close Rules
- After resolution response: wait 48 hours for confirmation
- At 24 hours: send reminder — "Just checking — did that resolve the issue?"
- At 48 hours: "I'm closing this ticket as resolved. If the issue comes back, just reply and I'll reopen it."
- NEVER auto-close P1 or P2 tickets — always require explicit confirmation

---

## Duplicate Detection

Before creating a new ticket, check:
1. Has this customer reported the same issue in the last 7 days?
2. Is the same issue being reported by multiple customers right now?

If duplicate detected:
- Merge with existing ticket (add new context as a note)
- Tell the customer: "I see you mentioned this earlier — I'm adding this new information to your existing case."
- If multiple customers: flag as potential systemic issue and upgrade to P2 minimum

---

## Batch Triage Mode

When processing a queue of unclassified tickets:
1. Sort by timestamp (oldest first, unless SLA timers suggest otherwise)
2. Classify each ticket: category + priority + sentiment
3. Send acknowledgments for anything that hasn't been acknowledged
4. Flag P1/P2 for immediate attention
5. Group similar issues (potential systemic problem)
6. Report summary to team channel: "Triaged X tickets: Y P1, Z P2, ..."


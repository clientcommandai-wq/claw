# Sales Lead Orchestrator Skill

> The master router for all sales activity. Every sales task hits this skill first. You classify it, check context, route to the right sub-skill, and log everything to the CRM afterward.

---

## When to Activate

This skill activates on every sales-related task, including:
- Inbound lead from the Receptionist AI ("new sales inquiry from...")
- Owner requests ("reach out to Company X", "update the pipeline", "what's our pipeline look like?")
- Scheduled follow-ups (it's time to send the Day 3 follow-up to Prospect Y)
- CRM-triggered events (deal stage changed, new contact added)
- Self-initiated tasks (daily pipeline review, weekly outreach planning)

---

## Step 1: Classify the Task

Read the full request and determine its type:

| Classification | Signals | Route To |
|---------------|---------|----------|
| **CRM work** | "update the pipeline", "log this call", "add a contact", "what's our pipeline?", "deal report" | `crm` skill |
| **Outreach** | "reach out to", "send a follow-up", "draft an email to", "cold outreach", "sequence" | `email-outreach` skill |
| **Lead qualification** | "is this a good lead?", "qualify", "research this company", "score this prospect", new inbound lead | `lead-qualification` skill |
| **Pipeline review** | "how are we doing?", "weekly update", "what deals are closing?", "forecast" | Handle directly (Step 4) |
| **Strategy** | "should we target [industry]?", "what's working?", "competitive intel" | Handle directly (Step 4) |
| **Meeting prep** | "prep me for the call with [company]", "what do I need to know about [prospect]?" | Handle directly (Step 4) |

### Classification Decision Tree

```
INCOMING SALES TASK
  |
  +--> Is this about CRM data? (create, update, query, report)
  |      YES --> Route to crm skill
  |      NO  --> Continue
  |
  +--> Is this about sending emails or messages to prospects?
  |      YES --> Route to email-outreach skill
  |      NO  --> Continue
  |
  +--> Is this about evaluating, scoring, or researching a prospect?
  |      YES --> Route to lead-qualification skill
  |      NO  --> Continue
  |
  +--> Is this a pipeline review, strategy question, or meeting prep?
  |      YES --> Handle directly (Step 4)
  |      NO  --> Continue
  |
  +--> Is this a sales task at all?
  |      NO  --> Acknowledge and suggest routing to the right AI employee
  |      YES --> Acknowledge and handle best you can
```

---

## Step 2: Check Context

Before routing, gather relevant context to pass along:

### For Every Task

1. **Check team-memory** for prior interactions with this prospect/company

```bash
CONTEXT=$(curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/search" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"query": "[prospect/company name]", "limit": 5}' \
  || echo '{"memories":[]}')
```

2. **Check CRM** for existing contact/deal records via `crm` skill
3. **Check if this is a new prospect or existing lead** — this changes the approach entirely:
   - **New prospect:** Qualify first, then outreach
   - **Existing lead, active pipeline:** Continue the sequence, update the deal
   - **Existing lead, went cold:** Reactivation outreach (different tone and approach)
   - **Former customer:** Re-engagement (reference past relationship)

### Context Checklist

Before routing to any sub-skill, make sure you have:

| Context | Source | Pass Along? |
|---------|--------|-------------|
| Company name | Task request | Always |
| Contact name and role | CRM or task request | If available |
| Prior interactions | team-memory + CRM | Always |
| Deal stage (if exists) | CRM | If they're in pipeline |
| Last contact date | CRM | If they're in pipeline |
| Qualification score | team-memory or CRM | If previously scored |
| Owner notes/instructions | Task request | Always |

---

## Step 3: Route to Sub-Skill

When routing, always pass:

```
- Original task/request
- Classification
- Context gathered in Step 2 (prior interactions, deal status, etc.)
- Any specific instructions from the owner
- Priority level (see below)
```

### Priority Levels for Sales Tasks

| Priority | Criteria | Handling |
|----------|----------|---------|
| **Immediate** | Inbound lead (warm — they contacted us), deal at risk, owner request with "ASAP" | Process within 30 minutes |
| **Today** | Scheduled follow-ups due today, new leads to qualify, pipeline updates | Process within same business day |
| **This Week** | Cold outreach batches, pipeline reviews, strategy tasks | Process within the week |
| **Ongoing** | Nurture campaigns, long-term prospect research, process improvement | Batch and process when bandwidth allows |

### Routing Matrix

**To crm skill:**
- Any task involving HubSpot data: creating, reading, updating, or reporting on contacts, deals, or activities
- Pipeline stage changes, deal updates, contact enrichment
- "What's our pipeline look like?" or "pull the numbers for this week"

**To email-outreach skill:**
- Cold outreach to new prospects (after qualification is done)
- Follow-up emails in an active sequence
- Responses to prospect replies (positive, objection, or unsubscribe)
- Re-engagement emails for cold leads

**To lead-qualification skill:**
- New inbound leads that need scoring
- Prospects the owner wants evaluated ("is this company a good fit?")
- Research requests ("find out more about Company X")
- Batch qualification of a list of prospects

---

## Step 4: Handle Directly

Some tasks don't need a sub-skill. Handle them here.

### Pipeline Review

When the owner asks "How are we doing?" or "What's our pipeline look like?":

1. Pull pipeline data via `crm` skill
2. Summarize by stage:

```
PIPELINE SUMMARY — [Date]

Active Deals: [count] | Total Value: $[amount]

By Stage:
- Lead: [count] deals ($[value])
- Qualified: [count] deals ($[value])
- Demo Scheduled: [count] deals ($[value])
- Proposal Sent: [count] deals ($[value])
- Negotiation: [count] deals ($[value])

Hot This Week:
- [Company A] — [stage] — next step: [what] by [when]
- [Company B] — [stage] — next step: [what] by [when]

At Risk:
- [Company C] — no response in [N] days. Recommend: [action]

Closed This Month: [count] won ($[value]) | [count] lost
```

### Meeting Prep

When the owner says "prep me for the call with [Company]":

1. Pull all CRM data for the company and contacts
2. Search team-memory for any stored intelligence
3. Research recent news about the company
4. Compile a briefing:

```
MEETING BRIEFING — [Company Name]

Company: [Name] | Industry: [X] | Size: [Y employees] | Revenue: [if known]
Contact: [Name], [Title]
Website: [URL]

DEAL HISTORY:
- First contact: [date] via [channel]
- Current stage: [pipeline stage]
- Key interactions: [summary of past touchpoints]

WHAT THEY CARE ABOUT:
- [Pain point 1 from prior conversations]
- [Pain point 2]

RECENT NEWS:
- [Relevant company news, funding, product launches]

SUGGESTED TALKING POINTS:
1. [Based on their needs and your product]
2. [Based on their industry]
3. [Based on prior conversation threads]

POTENTIAL OBJECTIONS:
- [Anticipated objection 1] → [Suggested response]
- [Anticipated objection 2] → [Suggested response]
```

### Strategy Questions

When the owner asks about what's working or what to try:

1. Analyze pipeline data: win rates, conversion by source, average deal cycle
2. Review team-memory for outreach insights (which emails get replies, which don't)
3. Present findings with recommendations, not just data

---

## Step 5: Post-Task — Log Everything

After every task completes (whether handled directly or by a sub-skill), ensure:

1. **CRM is updated** — Route to `crm` skill to log the activity if it wasn't already
2. **team-memory is updated** — Store any new intelligence learned about prospects, competitors, or process improvements
3. **Follow-up is scheduled** — If a next step was promised, set a reminder

### What to Log in CRM

| Event | Log As | Required Fields |
|-------|--------|----------------|
| Outreach sent | Email activity | Contact, subject, body summary, date |
| Call completed | Call activity | Contact, duration, outcome, next steps |
| Meeting held | Meeting activity | Contact, attendees, notes, next steps |
| Deal stage changed | Deal update | New stage, reason for change, next step |
| Lead qualified | Note on contact | Qualification score, BANT details, recommendation |
| Lead disqualified | Deal closed-lost | Reason for disqualification |

### What to Store in team-memory

| Insight | Type | Tags |
|---------|------|------|
| Prospect's pain points | `pattern` | `[company-name]`, `pain-points` |
| Competitive intelligence | `decision` | `competitive`, `[competitor-name]` |
| What outreach worked | `pattern` | `outreach`, `what-works` |
| Why a deal was lost | `gotcha` | `lost-deal`, `[company-name]` |
| Process improvement idea | `architecture` | `sales-process` |

---

## Daily Rhythm

If no specific task is assigned, follow this daily routine:

1. **Morning:** Check for inbound leads (from Receptionist AI or CRM). Qualify and prioritize.
2. **Mid-morning:** Send scheduled follow-ups. Process outreach sequences.
3. **Noon:** Update pipeline. Log any activities from the morning.
4. **Afternoon:** Research new prospects. Prepare outreach for the next day.
5. **End of day:** Send a brief summary to the owner (via Slack or Telegram):

```
TODAY'S SALES ACTIVITY:
- Outreach sent: [N] emails
- Replies received: [N] (positive: [N], objection: [N], unsubscribe: [N])
- Leads qualified: [N] (hot: [N], warm: [N], not a fit: [N])
- Deals progressed: [list any stage changes]
- Follow-ups due tomorrow: [N]
```

---

## Edge Cases

### Task involves multiple sub-skills
Break it into sequential steps. Example: "Research Acme Corp and send them an email" = qualify first (lead-qualification), then outreach (email-outreach).

### Conflicting priorities
If the owner assigns something while you have scheduled follow-ups due, prioritize the owner's request. Delay follow-ups by 1 day max.

### Inbound lead from Receptionist AI
Treat as Immediate priority. Qualify within 30 minutes. If qualified, send first outreach within 2 hours. Speed matters with warm leads.

### Owner says "just send it" without review
If you have approval for that type of outreach (first batch already approved), proceed. If not, confirm once: "Just to confirm — this is a [cold outreach / pricing quote / discount offer]. Want me to go ahead?" One confirmation, not a lecture.


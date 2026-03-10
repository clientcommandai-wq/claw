# Email Outreach Skill

> Draft and send personalized sales emails. Run follow-up sequences. Handle replies. Track what works. You are not a spam cannon — every email you send should feel like it was written by a thoughtful human who did their homework.

---

## When to Activate

This skill is called by the sales-lead orchestrator when:
- Cold outreach needs to be drafted or sent
- A follow-up is due in an active sequence
- A prospect replied and needs a response
- The owner requests "email [company/person] about [topic]"
- Re-engagement outreach for cold leads

---

## Golden Rules of Sales Email

These rules are non-negotiable. Every email must follow them.

1. **Personalize or don't send.** Reference something specific about the recipient: their company, role, a recent announcement, a shared connection. "Hi [First Name]," followed by generic content is not personalization.

2. **Lead with their problem, not your product.** The first sentence should be about THEM, not you. What pain point do they have? What challenge are they facing?

3. **Keep it short.** Cold outreach: under 150 words. Follow-ups: under 100 words. If you can't say it in 150 words, you don't understand it well enough.

4. **One clear CTA.** Every email ends with exactly one ask. Not "let me know if you want to chat or see a demo or read our case study." Pick one.

5. **No buzzwords.** Ban list: "synergy", "leverage", "circle back", "touch base", "innovative", "cutting-edge", "game-changer", "disruptive", "paradigm shift", "best-in-class", "thought leader", "move the needle."

6. **Subject lines matter.** Short (under 8 words), specific, lowercase feels natural. Good: "quick question about your ops workflow". Bad: "Exciting Partnership Opportunity!!!"

7. **Send at the right time.** During the prospect's business hours (9 AM - 5 PM in their timezone). Tuesday-Thursday tend to get better response rates. Never on weekends or holidays.

---

## Cold Outreach — First Touch

### Before Writing

Gather this information (from lead-qualification or CRM):
- Prospect's name, title, company
- What their company does
- A recent trigger: new funding, product launch, job posting, news mention, company growth
- Their likely pain point based on their role and industry
- How your product/service addresses that specific pain point

### Email Structure

```
SUBJECT: [Short, specific, lowercase — reference their world, not yours]

Hi [First Name],

[Opening: 1 sentence about THEM. Reference something specific.]

[Problem: 1-2 sentences about the challenge they likely face.]

[Bridge: 1 sentence connecting their problem to your solution. No feature dumps.]

[Proof: 1 sentence of social proof — a result, a metric, a relevant customer. Optional but powerful.]

[CTA: 1 clear ask. Usually a meeting or reply.]

[Sign-off]
[Signature]
```

### Example Cold Email

```
Subject: reducing manual ops at acme

Hi Jane,

I saw Acme Corp just closed a Series B — congrats. Scaling from 50 to 200 people usually means the manual workflows that got you here start breaking.

We help ops teams at companies your size automate the repetitive work that eats 15-20 hours a week — scheduling, reporting, data entry. One of our clients in fintech cut their ops overhead by 60% in the first quarter.

Would a 15-minute call this week make sense to see if there's a fit?

Best,
[Name]

```

### What Makes This Work
- Opens with THEIR news (Series B), not our product
- Identifies a specific pain point (manual workflows break at scale)
- Quantifies the problem (15-20 hours/week)
- One proof point (60% reduction)
- Clear, low-commitment CTA (15-minute call)
- Under 100 words

---

## Follow-Up Sequences

After the first touch, follow up at these intervals. Each follow-up adds value — never just "checking in."

### Sequence Timing

| Touch | Day | Purpose | Approach |
|-------|-----|---------|----------|
| 1 | Day 0 | First contact | Problem-focused cold email (above) |
| 2 | Day 3 | Value add | Share a relevant insight, case study, or data point |
| 3 | Day 7 | Different angle | Approach the problem from a new perspective |
| 4 | Day 14 | Breakup | Final touch, low-pressure, door open |

**After Touch 4 with no response: STOP.** Move to nurture track. Revisit in 60-90 days with fresh context.

### Touch 2 — Value Add (Day 3)

```
Subject: Re: reducing manual ops at acme

Hi Jane,

Following up on my note from earlier this week. Wanted to share this — we published a breakdown of how [similar company] restructured their ops workflow after their Series B.

[Link or brief summary of the insight]

Thought it might be relevant given where Acme is right now. Happy to chat if you want to dig in.

[Name]
```

### Touch 3 — Different Angle (Day 7)

```
Subject: one more thought on acme ops

Hi Jane,

Quick thought — I've been talking to a few ops leaders at post-Series B companies, and the #1 thing they wish they'd done sooner is automate before hiring. Cheaper and faster to scale.

If Acme is thinking about adding ops headcount, it might be worth a 10-minute chat to see if automation could cover some of that instead.

Either way, no pressure. Just wanted to flag it.

[Name]
```

### Touch 4 — Breakup (Day 14)

```
Subject: closing the loop

Hi Jane,

I'll keep this short — I've reached out a few times and I know you're busy. I don't want to be that person who clogs your inbox.

If the timing isn't right, totally understand. I'll check back in a couple months. But if you'd like to chat before then, I'm easy to find.

All the best,
[Name]
```

---

## Handling Replies

### Positive Reply ("Sure, let's chat")

1. Respond within 2 hours (speed matters with warm interest)
2. Propose 2-3 times (coordinate with Receptionist AI or calendar skill)
3. Confirm the meeting with calendar details
4. Log in CRM: move deal to "Demo Scheduled"
5. Prepare meeting briefing (via sales-lead orchestrator)

**Response template:**
```
Great to hear from you, [Name]! I'd love to find a time.

How do any of these work?
- [Day 1] at [Time] [TZ]
- [Day 2] at [Time] [TZ]
- [Day 3] at [Time] [TZ]

Happy to adjust if none of those fit.
```

### Objection Reply

Common objections and how to handle them:

| Objection | Response Approach |
|-----------|-------------------|
| "We're not interested" | Acknowledge, ask what they're using now (for intel), close gracefully |
| "Too expensive" | Ask about their budget range, highlight ROI, offer to show value first |
| "We already have a solution" | Ask what they like/dislike about it, position as complement not replacement |
| "Not the right time" | Ask when would be better, set a follow-up for that date |
| "Send me more info" | Send a 1-pager (not a 50-page deck), suggest a brief call instead |
| "I need to talk to my team" | Offer to join a team call, ask who else is involved (identify the decision-maker) |

**Objection response structure:**
1. Acknowledge: "That makes sense." (Never argue)
2. Clarify: "Can I ask — is it the [specific aspect] that's the concern?"
3. Address: One concise point that directly addresses the concern
4. Redirect: Back to a CTA (meeting, follow-up, more info)

### Unsubscribe / "Stop Emailing Me"

1. Respond immediately (within 1 hour)
2. Apologize briefly: "Understood — sorry for the interruption. I've removed you from my outreach."
3. Remove from ALL active sequences immediately
4. Update CRM: mark as "opted out" with today's date
5. **Never re-add them to outreach.** If they re-engage voluntarily in the future, that's different.
6. Store in team-memory: "[Contact] at [Company] opted out on [date]" so no one else contacts them

---

## A/B Testing

Track what works by testing variations. Only test one variable at a time.

### What to Test

| Variable | Example A | Example B | How to Measure |
|----------|-----------|-----------|---------------|
| Subject line | "quick question about ops" | "scaling past 50 people" | Open rate (if tracked) |
| Opening line | Company news reference | Pain point question | Reply rate |
| CTA | "15-min call?" | "worth exploring?" | Reply rate |
| Email length | 80 words | 140 words | Reply rate |
| Send time | 9 AM prospect time | 2 PM prospect time | Open rate |

### Tracking Results

After every outreach batch, store results in team-memory:

```bash
curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/memories" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Outreach batch Feb 10: Subject line A (question format) got 3/10 replies, Subject line B (statement format) got 1/10 replies. Question-style subjects performing 3x better for SaaS prospects.",
    "type": "pattern",
    "source_agent": "sales-lead",
    "tags": ["outreach", "ab-test", "subject-lines"]
  }' || true
```

Over time, this builds a knowledge base of what works for this specific customer's market.

---

## Re-Engagement Outreach

For prospects who went cold (no response after full sequence, 60-90 days ago):

### Rules
- Must have new context (new trigger event, product update, new case study)
- Cannot repeat the same messaging from the original sequence
- Acknowledge the gap: "It's been a while since we were in touch"
- Keep it even shorter than cold outreach — they've heard from you before

### Template

```
Subject: [new trigger] at [company]

Hi [Name],

Haven't been in touch since [month] — hope things are going well at [Company].

I noticed [new trigger: product launch, hiring, funding, news]. Since we last spoke, we've [new development: new feature, new case study, new client in their industry].

Thought it might be worth a quick revisit. Open to a 10-minute call?

[Name]
```

---

## Email Deliverability

Avoid these to keep emails out of spam:

- No ALL CAPS in subject lines
- No excessive exclamation marks or question marks
- No image-heavy emails (keep it text)
- No link shorteners (bit.ly, etc.) — use full URLs
- No attachments in cold outreach (link to hosted documents instead)
- Don't send more than 30 cold emails per day from one email address
- Space out sends — don't blast 30 emails in 5 minutes. Spread over the day.
- Include a plain-text version (no HTML-only emails)


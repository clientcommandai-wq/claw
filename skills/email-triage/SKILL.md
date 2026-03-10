# Email Triage Skill

> Process inbound emails: classify by type, assign priority, draft responses or route to the right person. You are the inbox zero engine.

---

## When to Activate

This skill is called by the receptionist orchestrator when:
- A new inbound email arrives
- The owner asks you to "check email" or "process the inbox"
- An email-related task comes in ("reply to John", "what emails came in today")

---

## Step 1: Classify the Email

Read the full email (subject, body, sender, any attachments mentioned) and classify:

| Type | Signals | Default Priority | Default Action |
|------|---------|-----------------|----------------|
| **Sales Lead** | "interested in", "pricing", "demo", "how much", "quote", sender from company domain, LinkedIn mention | P2 | Flag for sales team. Draft acknowledgment. |
| **Customer Inquiry** | Existing customer, references order/account/project, asks about status/features | P2 | Search team-memory for context. Draft response or route. |
| **Support Request** | "help", "issue", "problem", "not working", "error", "broken", complaint language | P2 (P1 if system down) | Route to support. Draft acknowledgment. |
| **Partnership / Business** | "partnership", "collaboration", "proposal", "opportunity", from another business | P3 | Summarize and route to owner. |
| **Job Application** | Resume attached, "applying for", "position", "role", "hiring" | P3 | Acknowledge receipt. Route to HR contact if configured. |
| **Invoice / Billing** | "invoice", "payment", "receipt", PDF attachment with dollar amounts | P3 | Route to billing contact. |
| **Internal / Team** | From team members, internal domain, about internal matters | P3 | Route to appropriate team member. |
| **Newsletter / Marketing** | Bulk sender, unsubscribe link, "weekly digest", marketing language | P4 | Archive. No response needed. |
| **Spam** | Unsolicited, no prior relationship, mass mailing, suspicious links, phishing indicators | -- | Archive silently. Never respond. |
| **Automated / System** | Password resets, shipping notifications, system alerts, noreply@ sender | P4 | Archive or route if action needed. |

### Spam Detection Signals

Flag as spam if 3 or more of these are present:
- Sender has no prior interaction history
- Subject contains ALL CAPS words or excessive punctuation (!!!, ???)
- Body contains suspicious URLs or link shorteners
- "Dear Sir/Madam" or other generic openings with no personalization
- Promises of money, prizes, or unrealistic offers
- Urgent language combined with a request for personal information
- Sender domain doesn't match the claimed company
- Attachment with executable extension (.exe, .scr, .bat, .js)

**When uncertain:** Classify as P4 and let the owner decide. Never auto-archive something that might be legitimate.

---

## Step 2: Assign Priority

Start with the default priority from the classification table, then adjust:

### Priority Bumps (increase by one level)

- Sender is in VIP_CONTACTS (USER.md)
- Email mentions a deadline within 48 hours
- Email is a reply to an existing conversation
- Subject contains "urgent", "ASAP", or "time-sensitive"
- Sender has emailed before about the same unresolved issue (escalation signal)
- Email is CC'd to executives or multiple stakeholders

### Priority Drops (decrease by one level)

- Email is clearly informational with no action needed ("FYI", "for your records")
- Sender is a known low-priority contact
- Email is a forward of a forward with no specific ask

### Final Priority Definitions

| Priority | Meaning | Response SLA |
|----------|---------|-------------|
| **P1** | Drop everything. System down, VIP emergency, time-critical with money on the line. | Acknowledge in < 5 minutes. Escalate immediately. |
| **P2** | Important and time-sensitive. Sales leads, customer issues, meetings this week. | Acknowledge in < 30 minutes. Resolve or route within 2 hours. |
| **P3** | Normal business. Partnership requests, general inquiries, internal coordination. | Respond within 4 business hours. |
| **P4** | Low priority. Newsletters, FYI emails, non-urgent updates. | Process within 24 hours. No acknowledgment needed. |

---

## Step 3: Take Action

Based on classification and priority, take the appropriate action:

### Draft a Response

For emails you can respond to directly (FAQs, acknowledgments, simple questions):

**Rules for drafting responses:**
1. Match the sender's formality level — if they write "Hey," you don't reply "Dear Esteemed Colleague"
2. Reference something specific from their email so they know you read it
3. Keep it concise — get to the answer within the first 2 sentences
4. If you're providing information, cite your source (team-memory, USER.md, etc.)
5. End with a clear next step: what you're doing, what they should do, or when they'll hear back
6. Include the email signature from IDENTITY.md

**Response templates by type:**

**Sales Lead Acknowledgment:**
> Hi [Name],
>
> Thanks for reaching out about [specific thing they mentioned]. I'd love to connect you with our team to discuss [their need].
>
> Are you available for a quick call this week? I can propose a few times that work on our end.
>
> [Signature]

**Support Request Acknowledgment:**
> Hi [Name],
>
> I've received your message about [specific issue]. I'm routing this to our [support/technical] team right now and you should hear back within [timeframe].
>
> In the meantime, [any immediate guidance you can offer].
>
> [Signature]

**General Inquiry Response:**
> Hi [Name],
>
> Great question! [Direct answer using information from team-memory or USER.md].
>
> Let me know if you need anything else.
>
> [Signature]

### Route to Team Member

For emails that need human attention:

1. Identify the right recipient (check USER.md routing rules, then team-memory)
2. Forward the email via slack-routing skill with a summary:
   - **From:** [sender name and email]
   - **Subject:** [original subject]
   - **Type:** [your classification]
   - **Priority:** [P1-P4]
   - **Summary:** [1-2 sentence summary of what they need]
   - **Suggested action:** [what you think should happen]
3. Send an acknowledgment to the original sender (if P1-P3)
4. Set a follow-up timer based on priority

### Archive

For newsletters, spam, and automated emails that need no action:
- Archive the email (never delete)
- No response needed
- Log the classification for audit trail

---

## Step 4: Batch Processing

When asked to "check the inbox" or "process emails," handle multiple emails efficiently:

1. Scan all unprocessed emails
2. Sort by priority (P1 first, then P2, etc.)
3. Process P1 emails immediately
4. Batch P2 emails and process in order
5. Summarize P3/P4 emails in a digest

### Inbox Summary Format

> **Email Summary — [Date]**
>
> **Needs Action (P1-P2):**
> - [Sender] — [Subject] — [Classification] — [Your recommended action]
> - [Sender] — [Subject] — [Classification] — [Your recommended action]
>
> **For Review (P3):**
> - [Sender] — [Subject] — [1-sentence summary]
>
> **Archived (P4/Spam):** [Count] emails archived
>
> Want me to handle any of these?

---

## Step 5: Learn and Improve

After processing emails:

1. **Update routing rules:** If you routed an email and the recipient says "this isn't mine, send it to [person]," update your routing table in team-memory
2. **Store sender patterns:** "John from Acme always emails about billing" — store in team-memory
3. **Track response effectiveness:** If a drafted response got a positive reply, note what worked
4. **Refine spam detection:** If something you classified as spam turns out to be legitimate (or vice versa), adjust your signals

---

## Edge Cases

### Email thread (reply chain)
Read the entire thread, not just the latest reply. Summarize the thread status when routing.

### Multiple recipients (CC'd on email)
If you're CC'd (not the primary recipient), monitor but don't respond unless directly asked. If the primary recipient doesn't respond within the SLA, flag it.

### Attachments
Note any attachments in your classification. Don't attempt to open or parse attachments — just note their presence and file type.

### Out-of-office auto-replies
If you receive an OOO reply to an email you sent on behalf of the team, note the return date and set a follow-up reminder for when they're back.

### Encrypted or confidential emails
If an email is marked confidential or contains encryption indicators, route to the owner immediately without summarizing the content in any shared channel.


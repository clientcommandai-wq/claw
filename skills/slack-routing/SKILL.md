# Message Routing Skill

> Route messages to the right person on the right channel. Add context before forwarding. Track what went where. Never forward without a summary.

---

## When to Activate

This skill is called by the receptionist orchestrator when:
- A message needs to be forwarded to a specific person or team
- Someone asks "Who handles X?" and needs to be connected
- Cross-channel routing is needed (email content posted to Slack, Slack message sent via email, etc.)
- Internal routing between AI employees (e.g., directing a sales inquiry to the Sales Lead AI)

---

## The Routing Table

The routing table defines who handles what. It starts with seed data from USER.md (`ROUTING_RULES` section) and grows over time as you learn from corrections and feedback.

### Default Routing Table Structure

```
| Topic / Signal                | Route To           | Channel      | Notes                    |
|-------------------------------|--------------------|--------------|--------------------------|
| Billing, invoices, payments   | [billing contact]  | Email/Slack  | From USER.md             |
| Technical support, bugs       | [support contact]  | Slack #support| From USER.md            |
| Sales inquiries, pricing      | Sales Lead AI      | Same channel | Route to AI teammate     |
| Partnership, biz dev          | [owner]            | Email        | Owner handles directly   |
| Press, media, interviews      | [owner/marketing]  | Email        | Always escalate          |
| HR, hiring, applications      | [HR contact]       | Email        | Sensitive - email only   |
| General questions, FAQ        | Self (Receptionist)| Same channel | Handle directly          |
| Unknown / can't classify      | [owner]            | Fastest chan | Escalate with summary    |
```

### Building the Routing Table

On day one, the table is sparse. Here's how to build it:

1. **Seed from USER.md:** Load any routing rules the owner configured during onboarding
2. **Search team-memory:** Check for previously stored routing patterns
3. **Learn from corrections:** When you route to person A and they say "this should go to person B," update the table
4. **Ask when unsure:** "I'm not sure who handles [topic]. Who should I route these to in the future?"
5. **Store every update:** Save routing rule changes to team-memory so all AI employees benefit

```bash
# Store a routing rule update in team-memory
curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/memories" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Technical support tickets should be routed to Jamie in #engineering, not #support. Confirmed by owner on 2026-02-10.",
    "type": "architecture",
    "source_agent": "receptionist",
    "tags": ["routing", "support", "engineering"]
  }' || true
```

---

## Step 1: Identify the Recipient

Determine who should receive this message:

### Decision Flow

```
MESSAGE NEEDS ROUTING
  |
  +--> Does the sender specify a recipient?
  |      "Tell Sarah about this" → Route to Sarah
  |      "Forward to the team"   → Route to configured team channel
  |
  +--> Check routing table for topic match
  |      Billing topic → billing contact
  |      Support topic → support channel
  |
  +--> Check team-memory for routing history
  |      "Last time someone asked about X, it went to Y"
  |
  +--> Is there another AI employee who handles this?
  |      Sales question → Sales Lead AI
  |      Support ticket → Support AI (if available)
  |
  +--> No match found
         → Escalate to owner with summary
         → Ask owner: "Who should I send [topic] questions to?"
         → Store the answer for next time
```

### Recipient Resolution

When the sender mentions a name:
- Check team-memory for that person's contact details and preferred channel
- If multiple people share the name, ask for clarification
- If you can't find them, ask: "I want to make sure I reach the right person — can you give me a bit more context about who [name] is?"

---

## Step 2: Prepare the Summary

**NEVER forward a raw message without context.** The recipient should understand the situation in 10 seconds.

### Summary Format

When forwarding a message, prepend this context block:

```
---
ROUTED BY: [Your name] (AI Receptionist)
FROM: [Sender name] via [channel]
PRIORITY: [P1-P4]
TOPIC: [Classification]
SUMMARY: [1-2 sentence summary of what the sender needs]
ACTION NEEDED: [What the recipient should do]
ORIGINAL MESSAGE: [below]
---

[Original message, unmodified]
```

### Summary Rules

1. **Be concise:** 1-2 sentences for the summary. Not a paragraph.
2. **Preserve intent:** Capture what the sender WANTS, not just what they said.
3. **Include urgency signals:** If the sender mentioned a deadline, include it.
4. **Note history:** If this is a follow-up to a previous conversation, mention that. "This is their 3rd email about the billing issue from January."
5. **Suggest an action:** Help the recipient know what to do. "They need a callback today" or "Just FYI, no response needed."
6. **Never editorialized:** Don't add opinions about the sender or their request.

### Example Summaries

**Good:**
> SUMMARY: Client from Acme Corp asking about bulk pricing for the Enterprise plan. They're evaluating us against two competitors and need a quote by Friday.
> ACTION NEEDED: Send pricing sheet and offer a demo call.

**Bad:**
> SUMMARY: Got an email. (No context, no action.)

**Bad:**
> SUMMARY: This person is asking about pricing and they seem kind of annoying because they already asked twice and I don't think they're a real buyer. (Editorializing, unhelpful.)

---

## Step 3: Route to the Right Channel

Choose the delivery channel based on urgency, recipient preference, and content type:

### Channel Selection Matrix

| Factor | Email | Slack/Discord | Telegram/WhatsApp |
|--------|-------|--------------|-------------------|
| **Formal / Long content** | Preferred | OK with thread | Avoid |
| **Urgent / Time-sensitive** | Avoid (slow) | Preferred | Good for mobile |
| **Contains attachments** | Preferred | OK | Limited |
| **Needs discussion / back-and-forth** | Avoid | Preferred (threads) | OK |
| **Confidential / Sensitive** | Preferred | DM only | DM only |
| **FYI / No response needed** | OK | Preferred (low noise) | Avoid |

### Cross-Channel Routing

When the original message came on one channel but needs to go to someone on a different channel:

**Email to Slack:**
- Post a summary in the appropriate Slack channel or DM
- Include key details inline (don't just say "check your email")
- If the full email is needed, note: "Full email thread available — let me know if you need the details"

**Slack to Email:**
- Compose a proper email with subject line, greeting, and the Slack message content
- Add context: "This came up in Slack #[channel] and I wanted to make sure you saw it."
- Include any relevant thread context

**Any channel to another AI employee:**
- Route through the system's internal messaging
- Pass all context: sender, channel, priority, classification, original message

### Routing to AI Teammates

When routing to another AI employee (Sales Lead, Support, etc.):

1. Use the same summary format
2. Include which skill should handle it (helps the receiving AI route internally)
3. Note what you've already told the sender (so the AI teammate doesn't repeat information)
4. Set a follow-up to check if the AI teammate handled it

---

## Step 4: Notify the Sender

After routing, always close the loop with the original sender:

### Notification Templates

**Routed to a specific person:**
> "I've passed your message along to [name/role] on our team. They should get back to you within [timeframe]. Is there anything else I can help with in the meantime?"

**Routed to a team/channel:**
> "I've flagged this with our [team name] team. Someone will follow up with you shortly."

**Routed to AI teammate:**
> "I've connected you with our [role] who can help with this directly. They'll take it from here!"

**Can't determine routing:**
> "I want to make sure this gets to the right person. I've escalated it to [owner/manager] and they'll follow up within [timeframe]."

### Notification Rules

- Always tell the sender WHERE their message went (person/team, not specific channel)
- Always give an expected response time
- Don't reveal internal team structure unless the owner has approved it
- If you're unsure about the timeframe, use "within one business day" as a safe default
- Offer to help with anything else — the sender might have a second question you can handle directly

---

## Step 5: Track and Follow Up

### Tracking

For every routed message, log:
- What was routed
- Who it was routed to
- What channel
- When
- Expected response time
- Status (pending/resolved)

### Follow-Up Protocol

| Situation | When to Follow Up | What to Do |
|-----------|-------------------|------------|
| Routed to team member, no response | After the promised SLA | Ping the team member: "Just checking — did you get the message from [sender] about [topic]?" |
| Routed to team member, they responded | After their response | Check if the sender's issue is resolved. If yes, close the thread. If not, re-engage. |
| Routed to AI teammate, no response | After 2 hours | Check if the AI teammate processed it. If not, re-route or escalate. |
| Sender follows up asking for status | Immediately | Check the status of their routed message and update them. |

### Learning from Routing

After every routing cycle, ask yourself:
1. Did the message reach the right person? If not, update the routing table.
2. Was the summary helpful? If the recipient asked follow-up questions I could have anticipated, improve future summaries.
3. Was the channel appropriate? If someone asked me to route differently, note their preference.
4. Did the follow-up timing work? Adjust SLAs based on actual response patterns.

Store all routing improvements in team-memory.

---

## Edge Cases

### Sender asks for someone who doesn't exist or isn't available
"I don't have a contact for [name] in our system. Could you tell me a bit more about what you need? I might be able to connect you with the right person."

### Confidential message ("For [person]'s eyes only")
Route via the most private channel (email DM or Slack DM). Do NOT post in shared channels. Minimize the summary to just the sender's name and "marked as confidential." Don't summarize the content.

### Mass notification (owner wants to notify the whole team)
Confirm the message and recipient list before sending. Post in the appropriate shared channel. Never send individual DMs to the whole team unless specifically asked.

### Circular routing (message gets routed back to you)
If a message you routed gets sent back to you, don't re-route it to the same place. Escalate to the owner: "[Person] sent this back — it may need someone else. Who should handle [topic]?"

### Multiple valid recipients
If the routing table suggests 2+ people, route to the most senior/primary one and CC/tag the others. Don't split the message.


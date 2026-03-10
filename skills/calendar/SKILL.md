# Calendar Management Skill

> Handle all scheduling: check availability, propose times, book meetings, manage rescheduling and cancellations. You are the scheduling brain.

---

## When to Activate

This skill is called by the receptionist orchestrator when:
- Someone requests a meeting, call, or appointment
- Someone asks about availability ("Are you free Thursday?")
- A meeting needs to be rescheduled or cancelled
- Meeting reminders need to be sent
- The owner asks about their schedule ("What's on my calendar today?")

---

## Calendar Access

Access the owner's calendar through the credential-proxy. The specific calendar tool (Google Calendar, Outlook, Calendly) is configured in USER.md under `CALENDAR_TOOL`.

### Checking Availability

```bash
# Check calendar availability via credential-proxy
RESULT=$(curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "GOOGLE_CALENDAR_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://www.googleapis.com/calendar/v3/freeBusy",
      "method": "POST",
      "body": {
        "timeMin": "2026-02-10T09:00:00Z",
        "timeMax": "2026-02-14T18:00:00Z",
        "items": [{"id": "primary"}]
      }
    }
  }' \
  || echo '{"success":false,"error":"Calendar unreachable"}')
```

If the calendar API is unavailable, tell the sender: "I'm having trouble accessing the calendar right now. Let me check manually and get back to you shortly." Then escalate.

---

## Step 1: Understand the Request

Parse the scheduling request for:

| Field | How to Detect | Default if Missing |
|-------|--------------|-------------------|
| **Meeting type** | "call", "meeting", "coffee", "demo", "interview", "sync" | "meeting" |
| **Duration** | "30 minutes", "an hour", "quick call" | Use `DEFAULT_MEETING_DURATION` from USER.md, or 30 minutes |
| **Urgency** | "this week", "ASAP", "sometime next month" | Within the next 5 business days |
| **Participants** | Names, email addresses, "the team", "your CEO" | The sender + the owner |
| **Format** | "in person", "Zoom", "phone call", "video call" | Use `MEETING_LINK_TOOL` from USER.md, or video call |
| **Timezone** | Explicit mention, or infer from sender's known location | Owner's timezone from USER.md |

If critical information is missing (who, roughly when), ask:

> "Happy to set something up! A couple quick questions:
> - How long should we block — 30 minutes or an hour?
> - Any days or times that work best for you this week?"

Don't ask more than 2 questions at once. Get the basics, then fill in gaps from defaults.

---

## Step 2: Check Availability

Before proposing any times:

1. Query the calendar for the requested timeframe
2. Identify open slots that match the requested duration
3. Apply buffer rules: leave `BUFFER_BETWEEN_MEETINGS` (from USER.md, default 15 min) before and after
4. Exclude times outside `BUSINESS_HOURS` (from USER.md, default 9 AM - 6 PM)
5. Avoid proposing times in the first 30 minutes of the business day (the owner may need ramp-up time)
6. If checking multiple participants, find overlapping availability

### Availability Rules

- **Never double-book.** If a slot is taken, it's taken. No exceptions.
- **Respect buffer time.** A meeting at 2:00 PM that ends at 2:30 PM means the next available slot is 2:45 PM (with 15-min buffer).
- **Account for timezones.** Always confirm the timezone. "3 PM" means nothing without a timezone.
- **Avoid back-to-back meetings.** If the owner already has 3+ meetings in a day, flag it: "Your calendar is pretty packed on [day] — want me to try a different day?"

---

## Step 3: Propose Times

Always offer 2-3 options. Never offer just one (too rigid) or more than 4 (decision fatigue).

### Proposal Format

> "I have a few openings this week. How do any of these work?
>
> 1. **Tuesday, Feb 11** at 10:00 AM EST (30 min)
> 2. **Wednesday, Feb 12** at 2:00 PM EST (30 min)
> 3. **Thursday, Feb 13** at 11:00 AM EST (30 min)
>
> Let me know which works best, or if you'd prefer a different time!"

### Proposal Rules

- Spread options across different days when possible
- Offer a mix of morning and afternoon slots
- Include the timezone in every option
- Include the duration in every option
- If the requester is in a different timezone, show times in BOTH timezones:
  > "**Tuesday at 10:00 AM EST / 3:00 PM GMT**"
- If no times are available in the requested window, say so and suggest the next available window:
  > "This week is fully booked, but I have openings next Monday and Tuesday. Would that work?"

---

## Step 4: Confirm and Book

Once both parties agree on a time:

1. **Create the calendar event** via credential-proxy:

```bash
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "GOOGLE_CALENDAR_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://www.googleapis.com/calendar/v3/calendars/primary/events",
      "method": "POST",
      "body": {
        "summary": "Meeting: [Owner] + [Guest]",
        "start": {"dateTime": "2026-02-11T10:00:00-05:00"},
        "end": {"dateTime": "2026-02-11T10:30:00-05:00"},
        "attendees": [{"email": "guest@example.com"}],
        "conferenceData": {"createRequest": {"requestId": "unique-id"}}
      }
    }
  }'
```

2. **Generate a meeting link** if needed (Zoom, Google Meet, etc.)

3. **Send confirmation to both parties:**

> "You're all set! Here are the details:
>
> **Meeting:** [Description]
> **Date:** Tuesday, February 11, 2026
> **Time:** 10:00 AM - 10:30 AM EST
> **Location:** [Zoom link / Google Meet link / Office address]
> **Attendees:** [Owner], [Guest]
>
> I'll send a reminder 24 hours and 1 hour before. Let me know if anything changes!"

4. **Set reminders:** Schedule notifications at:
   - 24 hours before the meeting
   - 1 hour before the meeting

5. **Store in team-memory:** Log the meeting context so other AI employees know about it

---

## Step 5: Handle Changes

### Rescheduling

When someone asks to reschedule:

1. Acknowledge: "No problem, let's find a new time."
2. Ask if they have a preference: "Do you have a specific day or time in mind?"
3. Check availability (same as Step 2)
4. Propose new times (same as Step 3)
5. Update the calendar event (don't delete and recreate — update in place)
6. Notify ALL participants of the change:
   > "Heads up — our meeting has been moved from [old time] to [new time]. Same [location/link]. See you then!"

### Cancellation

When someone cancels:

1. Confirm: "Understood. I'll cancel the meeting on [date] at [time]."
2. Ask if they want to reschedule: "Would you like to find a new time, or shall I leave it for now?"
3. Cancel the calendar event
4. Notify ALL participants:
   > "The meeting scheduled for [date] at [time] has been cancelled. [Reason if provided]. Let me know if you'd like to reschedule."
5. Update team-memory to note the cancellation

### No-Shows

If a meeting time passes and the attendee doesn't join:

1. Wait 5 minutes past the start time
2. Send a gentle check-in to the missing attendee: "Hi [Name] — just checking in, our meeting was scheduled for [time]. Are you still able to join?"
3. If no response after 10 minutes, notify the owner and suggest rescheduling
4. Log the no-show in team-memory (pattern detection — if someone no-shows repeatedly, flag it)

---

## Timezone Handling

Timezone misunderstandings are the #1 cause of missed meetings. Be meticulous.

### Detection

1. **Explicit:** Sender says "EST", "PST", "GMT+5" --> use that
2. **Location-based:** You know the sender is in London from team-memory --> GMT/BST
3. **Domain-based:** Sender's email is .co.uk --> likely GMT/BST
4. **Unknown:** ASK. Don't guess.

> "Just to make sure we're on the same page — what timezone are you in?"

### Display Rules

- Always include the timezone abbreviation with every time you mention
- When participants are in different timezones, show both: "10 AM EST / 4 PM CET"
- Use the sender's timezone as the primary display, owner's timezone in parentheses
- Never use "12 PM" — say "noon" to avoid AM/PM confusion
- For international scheduling, consider using 24-hour format if the sender uses it

---

## Edge Cases

### Meeting request with no specific timeframe
Propose times within the next 3-5 business days. Say: "How does sometime this week or early next week work?"

### Meeting request outside business hours
"I see that time is outside our usual hours ([hours from USER.md]). Let me check if [owner] can accommodate that, or would a time during business hours work?"

### Large group meetings (4+ people)
Warn the owner before attempting: "This involves [N] people — scheduling might take a few rounds. Want me to go ahead?" Then find the best overlap. If perfect overlap is impossible, present the best-fit option with who can and can't make it.

### Recurring meeting request
This needs owner approval (per AGENTS.md). Say: "I can set up a recurring meeting — let me confirm the details with [owner] first. What cadence were you thinking? Weekly, biweekly?"

### Calendar access failure
If the credential-proxy can't reach the calendar API: "I'm having trouble accessing the calendar right now. Can you share 2-3 times that work for you, and I'll confirm manually?"


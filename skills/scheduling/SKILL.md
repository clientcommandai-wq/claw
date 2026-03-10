# Skill — Scheduling and Resource Coordination

**Purpose:** Coordinate team calendars, find optimal meeting times, book rooms and resources, manage recurring meetings, and handle scheduling conflicts across timezones.

---

## Prerequisites

| Credential Key | Service | Required? |
|---------------|---------|-----------|
| `GOOGLE_WORKSPACE_OAUTH` | Google Calendar API | Yes |

---

## Capabilities

### Find Optimal Meeting Times

When asked to schedule a meeting, follow this algorithm:

**Step 1: Gather Requirements**
- Who needs to attend? (required vs. optional attendees)
- How long? (default 30min if not specified)
- Any constraints? (must be mornings, avoid Fridays, etc.)
- Internal or external? (external = NEEDS APPROVAL)
- Recurring or one-off?

**Step 2: Check Availability**

```bash
# Query free/busy for all attendees
RESULT=$(curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "GOOGLE_WORKSPACE_OAUTH",
    "service": "google-calendar",
    "request": {
      "action": "freebusy",
      "timeMin": "2026-02-10T09:00:00-05:00",
      "timeMax": "2026-02-14T17:00:00-05:00",
      "items": [
        {"id": "person1@company.com"},
        {"id": "person2@company.com"},
        {"id": "person3@company.com"}
      ]
    }
  }' \
  || echo '{"success":false,"error":"Proxy unreachable"}')
```

**Step 3: Apply Scoring Algorithm**

Score each available slot on these criteria (highest score wins):

| Criterion | Weight | Scoring |
|-----------|--------|---------|
| All required attendees free | 50 | Binary: all free = 50, any conflict = 0 |
| Optional attendees free | 10 | 10 * (free_optional / total_optional) |
| Within business hours for all timezones | 15 | 15 if all in business hours, 5 if some overlap, 0 if outside |
| Preferred time of day | 10 | 10 for morning (9-12), 7 for early afternoon (12-3), 3 for late afternoon (3-5) |
| Buffer from adjacent meetings | 10 | 10 if 30min+ buffer, 5 if 15min buffer, 0 if back-to-back |
| Day preference | 5 | 5 for Tue-Thu, 3 for Mon, 1 for Fri |

**Step 4: Present Options**

Always present the top 3 options (not just one):

> "Here are the best times for a 30-minute meeting with Alice, Bob, and Carol:
>
> 1. **Tuesday Feb 11, 10:00am EST** (all free, morning slot, 30min buffer)
> 2. **Wednesday Feb 12, 2:00pm EST** (all free, afternoon, back-to-back for Bob)
> 3. **Thursday Feb 13, 11:00am EST** (all free, morning, Carol is optional)
>
> Which works best? Or want me to look at different days?"

**Step 5: Book After Confirmation**

Only book after the customer confirms a time. Never auto-book.

---

### Create Calendar Events

```bash
# Create a calendar event
RESULT=$(curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "GOOGLE_WORKSPACE_OAUTH",
    "service": "google-calendar",
    "request": {
      "action": "create_event",
      "summary": "Engineering Standup",
      "description": "Daily sync — 15 min max. Agenda: blockers, progress, plan for today.",
      "start": "2026-02-11T09:00:00-05:00",
      "end": "2026-02-11T09:30:00-05:00",
      "attendees": [
        {"email": "alice@company.com"},
        {"email": "bob@company.com"},
        {"email": "carol@company.com"}
      ],
      "reminders": {
        "useDefault": false,
        "overrides": [
          {"method": "popup", "minutes": 10},
          {"method": "email", "minutes": 60}
        ]
      },
      "conferenceData": {
        "createRequest": {"requestId": "standup-20260211"}
      }
    }
  }' \
  || echo '{"success":false,"error":"Proxy unreachable"}')
```

**Include with every event:**
- Clear title (not "Meeting" — be specific)
- Description with purpose/agenda
- All attendee emails
- Video conferencing link (Google Meet) if remote
- Appropriate reminders

### Manage Recurring Meetings

Common recurring meeting types and their configurations:

| Meeting Type | Frequency | Duration | Best Practice |
|-------------|-----------|----------|---------------|
| Daily standup | Every weekday | 15 min | Same time daily, video optional, strict timebox |
| Weekly team sync | Weekly | 30-60 min | Tuesday or Wednesday, rotating agenda owner |
| Sprint planning | Bi-weekly | 60-90 min | Monday morning, all engineers required |
| 1:1 | Weekly | 30 min | Consistent day/time, cancel-proof |
| All-hands | Monthly | 60 min | First Monday of month, recorded for absent |
| Quarterly review | Quarterly | 90-120 min | End of quarter, requires prep time |

**Recurring event setup:**
```bash
# Create a recurring event (weekly standup)
RESULT=$(curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "GOOGLE_WORKSPACE_OAUTH",
    "service": "google-calendar",
    "request": {
      "action": "create_event",
      "summary": "Engineering Standup",
      "start": "2026-02-11T09:00:00-05:00",
      "end": "2026-02-11T09:15:00-05:00",
      "recurrence": ["RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"],
      "attendees": [
        {"email": "alice@company.com"},
        {"email": "bob@company.com"}
      ]
    }
  }' \
  || echo '{"success":false,"error":"Proxy unreachable"}')
```

---

### Handle Timezone Coordination

When attendees span multiple timezones:

1. **Always display times in all relevant timezones:**
   > "10:00am EST / 7:00am PST / 3:00pm GMT"

2. **Find the overlap window:**
   - Calculate business hours for each timezone
   - Find the intersection (when all are in business hours)
   - If no overlap exists, say so: "There's no overlap where everyone is in business hours. The closest options are..."

3. **Common timezone overlaps:**
   | Zones | Overlap (local business hours) |
   |-------|-------------------------------|
   | US East + West | 12:00-5:00pm EST (9:00am-2:00pm PST) |
   | US East + UK | 9:00am-12:00pm EST (2:00-5:00pm GMT) |
   | US West + UK | 8:00-9:00am PST (4:00-5:00pm GMT) — very tight |
   | US East + India | 8:00-9:30am EST (6:30-8:00pm IST) — tight |
   | UK + India | 9:00am-12:30pm GMT (2:30-6:00pm IST) |

4. **Never assume timezone.** Always check USER.md for the team's primary timezone and additional timezones.

---

### Handle Conflicts and Rescheduling

When a scheduling conflict is detected:

**Step 1: Identify the conflict**
> "Bob has a conflict at 10am Tuesday — he's in a client call until 10:30."

**Step 2: Assess options**
1. Move the meeting to a different time (present alternatives)
2. Shorten the meeting to fit a gap
3. Make the conflicting attendee optional
4. Split into two shorter meetings

**Step 3: Present to customer**
> "Bob has a conflict. Options:
> 1. Move to 11am (everyone free)
> 2. Keep 10am but make Bob optional (he can catch up async)
> 3. Move to Wednesday same time
>
> What do you prefer?"

**Never** reschedule without asking. **Never** remove attendees without permission.

### Rescheduling protocol:
1. Get approval to reschedule
2. Cancel the old event with a note: "Rescheduled to [new time]"
3. Create the new event
4. Notify all attendees of the change
5. Confirm: "Meeting moved from Tuesday 10am to Wednesday 11am. All attendees notified."

---

### Send Reminders

Proactive reminders for important meetings:

| Timing | Type | When to Send |
|--------|------|-------------|
| 24 hours before | Agenda reminder | "Tomorrow's team sync at 10am. Here's the agenda: ..." |
| 1 hour before | Quick reminder | "Team sync in 1 hour (10am). Join link: ..." |
| 5 minutes before | Final nudge | Only if customer requests this level of reminders |
| After meeting | Action items | "Here are the action items from today's sync: ..." |

Reminder preferences should be confirmed during onboarding. Not everyone wants frequent reminders.

---

## Meeting Templates

### Standup Agenda
```
Daily Standup — {date}
Duration: 15 minutes (hard stop)

Each person covers:
1. What I did yesterday
2. What I'm doing today
3. Any blockers

Parking lot (discuss after standup):
- ...
```

### Weekly Sync Agenda
```
Weekly Team Sync — {date}
Duration: 30 minutes

1. Wins this week (5 min)
2. Key metrics review (5 min)
3. Blockers and escalations (10 min)
4. Priorities for next week (10 min)

Action Items from Last Week:
- [ ] ...
```

### 1:1 Template
```
1:1 — {manager} / {report} — {date}
Duration: 30 minutes

Standing questions:
1. How are you doing? (Genuinely)
2. What's going well?
3. What's blocking you?
4. Anything I can help with?

Topics for this week:
- ...

Action items:
- ...
```

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Calendar API returns 403 | Credential may have expired — ask customer to re-authenticate |
| No overlapping free time found | Present the "least bad" options with a note about the conflict |
| Attendee email bounces | Verify the email address with the customer |
| Recurring event creation fails | Try creating a single instance first, then set recurrence |
| Room/resource unavailable | Suggest alternative rooms or virtual-only option |
| Double-booking detected | Alert customer immediately with both events and ask which takes priority |

---

## Security Rules

- Never access calendars of people outside the organization via this skill
- Never share calendar details (meeting titles, attendees) with external parties
- When booking with external attendees, only share the minimum necessary info in the invite
- Calendar data (who met with whom, when) is sensitive — don't include in summaries shared externally
- All scheduling actions are logged in team-memory for audit


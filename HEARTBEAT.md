# Heartbeat Instructions

When the heartbeat fires, perform these checks silently. Only speak if there's something worth reporting.

## Notification Rules
- Only notify about NEW items since your last heartbeat
- Use the channel where the owner is most active
- Keep notifications concise (1-2 sentences max)
- During quiet hours (10 PM - 7 AM owner timezone): batch notifications for morning

## If Nothing New
Respond with exactly: `HEARTBEAT_OK`

Do NOT announce "everything is quiet" or "no updates" — silence is the default.

## Memory Write (Only When Something Happened)

**Default: write nothing.** A quiet heartbeat with no new events produces no memory entry.

Only write if this heartbeat found something meaningful:
- A new email, message, or request arrived
- A task was completed or failed
- Something changed in an external system
- A decision was made

### When something happened: log it

```bash
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
MEMORY_DIR="/data/workspace/memory"
mkdir -p "$MEMORY_DIR"
MEMORY_FILE="$MEMORY_DIR/${DATE}.md"

if [ ! -f "$MEMORY_FILE" ]; then
  printf "# Daily Memory: %s\n\n" "$DATE" > "$MEMORY_FILE"
fi

printf "[%s UTC] <1-2 sentence summary of what happened>\n" "$TIME" >> "$MEMORY_FILE"
```

Good entries:
- `"[09:14 UTC] Email from Acme Corp re: invoice #1042 -- replied with payment confirmation."`
- `"[14:30 UTC] HubSpot sync ran -- 3 contacts updated, 1 new lead added."`
- `"[16:00 UTC] Owner asked to always CC finance@acme.com on invoices going forward."`

Bad entries (never write these):
- `"Checked email -- 0 unread."` -- nothing happened, write nothing
- `"Heartbeat complete."` -- useless noise
- `"All systems normal."` -- not a memory, it's a log statement

### When something durable was learned: store to BrainTrust

A durable fact is something that should affect future behavior. Temporary state (a meeting at 3pm) is not durable.

Pick the right type based on what was learned:

| type | use when |
|------|----------|
| `preference` | owner preference ("always CC finance@ on invoices") |
| `contact` | a person, company, or email address to remember |
| `process` | a workflow rule or repeatable step |
| `decision` | a decision made and why |
| `learned` | anything else durable that doesn't fit above |

```bash
curl --max-time 3 -s -X POST "${MEMORY_WORKER_URL}/tenant/memories" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "<one clear sentence describing the fact>",
    "type": "<preference|contact|process|decision|learned>",
    "source_agent": "heartbeat"
  }' || true
```


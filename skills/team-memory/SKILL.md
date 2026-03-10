# Team Memory Skill

**Purpose:** Search and store shared knowledge in the BrainTrust — a persistent memory system shared across all AI employees. Use this to avoid re-learning things, share context between roles, and build organizational knowledge over time.

---

## How It Works

1. All AI employees on this team share a single BrainTrust (semantic memory store)
2. Before answering questions about the business, customers, or processes -- **search first**
3. When you learn something new and useful -- **store it**
4. Memories are ranked by confidence and verified by the team over time

**Important:** If the environment variable `BRAINTRUST_ENABLED` is set to `false`, your administrator has disabled memory storage. You may still respond normally and search existing memories, but you MUST NOT store new memories. Skip all memory store/write calls.

---

## MUST

- Search the BrainTrust BEFORE answering factual questions about the business (customer preferences, processes, contacts, policies)
- Store new facts when you learn them (customer said X, policy is Y, contact for Z is...)
- Verify memories that helped you solve a problem (boosts confidence)
- Flag memories that seem wrong or outdated (reduces confidence)
- Include the `source_agent` field so the team knows who stored the memory

## MUST NOT

- Store raw data dumps, log files, or large documents (store summaries instead)
- Store temporary information ("meeting at 3pm today") — only durable facts
- Store passwords, API keys, tokens, or any credentials
- Store personally identifiable information (emails, phone numbers, SSNs, addresses)
- Trust memories blindly — if something seems wrong, verify with the customer

---

## Usage: Search Memories

Search before answering factual questions. The BrainTrust uses semantic search, so natural language queries work best.

```bash
# Search for relevant knowledge (REQUIRED timeout fallback)
RESULT=$(curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/search" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "what is our refund policy",
    "limit": 5
  }' \
  || echo '{"memories":[]}')

# Parse results
MEMORIES=$(echo "$RESULT" | jq -r '.memories[] | "[\(.confidence)] \(.content)"')
if [ -n "$MEMORIES" ]; then
  echo "Found relevant knowledge:"
  echo "$MEMORIES"
else
  echo "No relevant memories found — will need to ask or research."
fi
```

## Usage: Store a Memory

When you learn a new fact, store it for the whole team.

```bash
curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/memories" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Client prefers email over phone for non-urgent matters. Phone only for emergencies.",
    "type": "pattern",
    "source_agent": "receptionist",
    "tags": ["client-preferences", "communication"]
  }' \
  || echo '{"stored":false}'
```

### Good Memories to Store

| Type | Example |
|------|---------|
| `pattern` | "Client X prefers email over phone" |
| `decision` | "We use net-30 payment terms for enterprise clients" |
| `gotcha` | "HubSpot API rate limits to 100 calls/10s — batch operations" |
| `architecture` | "Support tickets go: Zendesk → Slack #support → assigned agent" |
| `pattern` | "CEO's assistant is Jamie — route VIP requests to her" |

### Bad Memories (Don't Store These)

- "Meeting with John at 3pm" (temporary)
- "API key is sk_live_abc123..." (credentials — NEVER)
- Full email thread contents (too large — store summary)
- "Error: ECONNREFUSED" (raw error — store root cause instead)
- "john@example.com called about order #1234" (PII)

## Usage: Get Context for Current Task

Load relevant memories before starting a task. More efficient than individual searches.

```bash
CONTEXT=$(curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/context" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "task_description": "Handle support ticket from Acme Corp about billing issue"
  }' \
  || echo '{"memories":[]}')
```

## Usage: Verify a Memory (Boost Confidence)

When a memory helped you do your job correctly, verify it:

```bash
curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/memories/${MEMORY_ID}/verify" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  || true
```

## Usage: Flag a Memory (Mark as Wrong/Outdated)

When a memory seems incorrect or outdated, flag it:

```bash
curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/memories/${MEMORY_ID}/flag" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Refund policy changed from 30 to 60 days last month"}' \
  || true
```

---

## Memory Types

| Type | When to Use |
|------|------------|
| `pattern` | Recurring behaviors, preferences, workflows |
| `decision` | Business decisions, policies, chosen approaches |
| `gotcha` | Pitfalls, workarounds, things that break |
| `architecture` | How systems connect, data flows, org structure |
| `bug` | Known issues and their fixes |

---

## Graceful Degradation

**The BrainTrust is a bonus, not a dependency.** If it's down or slow:

- Timeouts: All calls use `--max-time 3` — never block more than 3 seconds
- Fallback: `|| echo '{"memories":[]}'` — treat failure as empty results
- Continue working: Don't refuse to help because memory search failed
- Inform (optionally): "I wasn't able to check our team knowledge base, so I'm working from what I know directly."

```bash
# REQUIRED pattern — every team-memory call must have timeout + fallback
RESULT=$(curl --max-time 3 -s -X POST "${URL}" ... || echo '{"memories":[]}')
```

---

## PII Protection

The BrainTrust has server-side PII detection that will strip or reject:
- Email addresses
- Phone numbers
- Social security numbers
- Credit card numbers
- Physical addresses

If you need to reference a person, use their role or relationship:
- "The CEO's assistant" not "Jamie Smith (jamie@company.com)"
- "Our main vendor contact" not "Bob at 555-0123"

---

## Cost Notes

- BrainTrust search/store calls are lightweight (< $0.01/call)
- Daily reflection (automated overnight) runs on ClawTrust's budget, not yours
- Memory storage is limited per plan tier — focus on quality over quantity
- The system auto-archives low-confidence memories after 2 flags


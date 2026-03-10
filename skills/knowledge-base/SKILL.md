# Knowledge Base Sub-Skill

**Role:** Search documentation, past tickets, and team memory to find answers. Draft comprehensive, accurate responses. Identify gaps in the knowledge base.

**Parent:** `support-lead` (orchestrator routes here for questions and how-to requests)

---

## Trigger

Activated by the support-lead orchestrator when:
- A customer asks a question ("How do I...", "What is...", "Can I...")
- A ticket requires reference to documentation or past solutions
- An agent needs to verify information before responding
- A knowledge base audit or gap analysis is requested

---

## Search Strategy

Follow this search order. Do NOT skip steps — each level catches what the previous missed.

```
[1. EXACT MATCH]
    Search team-memory for the exact question or key phrases
    If found with high confidence (>0.8) → use it
    |
    v
[2. SEMANTIC SEARCH]
    Search team-memory with natural language query
    Broaden terms: "password reset" → "authentication", "login issues", "account access"
    If found with medium+ confidence (>0.5) → use it, but verify currency
    |
    v
[3. KNOWLEDGE BASE URL]
    If USER.md has KNOWLEDGE_BASE_URL configured:
    - Search the external knowledge base via credential-proxy
    - Look for articles matching the customer's question
    If found → cite the source, link the article
    |
    v
[4. PAST TICKET PATTERNS]
    Search team-memory for similar resolved tickets
    Tags to search: "resolved", category keywords, product area
    If found → adapt the past resolution to current context
    |
    v
[5. NOTHING FOUND]
    Escalate with context: "I searched [what you searched] and found no answer.
    This needs human investigation or a new KB article."
```

---

## Search Best Practices

### Query Construction
- Extract the core question from the customer's message
- Remove emotional language, pleasantries, and filler before searching
- Create 2-3 query variants:
  - Exact: "how to export CSV report"
  - Broad: "export data reports"
  - Synonym: "download spreadsheet data"

### Result Evaluation
- **High confidence (0.8+)**: Use directly, cite the source
- **Medium confidence (0.5-0.8)**: Use as a starting point, add caveats ("Based on what I found...")
- **Low confidence (0.2-0.5)**: Mention as a possibility, ask the customer to confirm
- **No results**: Do NOT guess. Escalate honestly.

### Freshness Check
Before using a search result, verify it is still current:
- Does the result mention a specific product version? Is that version current?
- Was the result stored more than 90 days ago? It may be outdated.
- Does the result contradict anything in USER.md? USER.md wins.
- If unsure about freshness, preface with: "Based on our records, [answer]. Please let me know if anything has changed."

---

## Response Drafting

### Structure for Knowledge Base Answers

```
1. DIRECT ANSWER (1-2 sentences answering the question)

2. STEP-BY-STEP (if procedural)
   - Numbered steps
   - Include expected outcomes at each step
   - Note where things commonly go wrong

3. ADDITIONAL CONTEXT (if helpful)
   - Why it works this way
   - Related features they might find useful
   - Link to full documentation

4. FOLLOW-UP OFFER
   - "Does this answer your question?"
   - "Would you like me to walk you through any of these steps?"
```

### Example Response

```
Great question! Here's how to set up the integration:

You can connect your account by going to Settings > Integrations > [Service Name]
and clicking "Connect." Here are the detailed steps:

1. Navigate to Settings in the top-right menu
2. Click "Integrations" in the left sidebar
3. Find [Service Name] and click "Connect"
4. You'll be redirected to [Service] to authorize the connection
5. Once authorized, you'll see a green "Connected" badge

A couple of things to note:
- The sync runs every 15 minutes, so data won't appear immediately
- If you see a "Permission Denied" error, make sure you're logging into
  [Service] with an admin account

Here's our full guide on this: [KNOWLEDGE_BASE_URL/integrations]

Did that help, or would you like me to walk through any of those steps?
```

---

## When No Answer Exists

This is NOT a failure — it is valuable information. Handle it properly.

### Step 1: Be Honest
```
I've searched our documentation and knowledge base for information about
[topic] and wasn't able to find an answer. This is something that needs
input from our team.
```

### Step 2: Summarize What You Searched
```
Here's what I checked:
- Our internal knowledge base (searched for: [terms])
- Past support tickets with similar questions
- Product documentation at [URL]

None of these had information about [specific thing].
```

### Step 3: Escalate with Context
```
I'm flagging this for our team to investigate. They'll have the full
context of what you asked and what I've already checked, so you won't
need to repeat anything.

Expected follow-up time: [based on SLA for the priority level]
```

### Step 4: Flag the KB Gap
Store in team-memory:
```json
{
  "content": "Knowledge base gap: No documentation for [topic]. Customer asked about [specific question]. Needs new article.",
  "type": "gotcha",
  "tags": ["kb-gap", "category-name"],
  "source_agent": "support"
}
```

---

## Knowledge Base Article Suggestions

After resolving a ticket where no KB article existed, evaluate whether a new article should be created.

### Criteria for New Article
- The question has been asked 2+ times (check team-memory)
- The answer is stable (unlikely to change month-to-month)
- The answer can be written in a self-serve format (no agent intervention needed)
- The topic is not too niche (applies to more than one customer)

### Article Suggestion Format

When suggesting a new KB article, store this in team-memory:

```json
{
  "content": "Suggested KB article: [Title]. Question: [what customers ask]. Answer: [summary of resolution]. Asked [N] times in [timeframe].",
  "type": "pattern",
  "tags": ["kb-suggestion", "category-name"],
  "source_agent": "support"
}
```

---

## FAQ Cache

Use team-memory to cache frequently asked questions and their answers. This speeds up response time for repeat questions.

### Caching Rules
- Cache answers that have been verified by customer confirmation
- Include the date in the memory so freshness can be assessed
- Tag with `faq-cache` for easy retrieval
- Update the cache when answers change (flag old memory, store new one)

### Cache Lookup (Before Full Search)
```bash
# Quick FAQ check (fastest path)
RESULT=$(curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/search" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "[customer question]",
    "limit": 3,
    "tags": ["faq-cache"]
  }' \
  || echo '{"memories":[]}')
```

If a cached answer is found with high confidence, use it directly. This avoids the full search pipeline for common questions.

---

## Cross-Reference Protocol

When answering questions that touch on policies, pricing, or capabilities:

1. **Check USER.md first** — This is the customer's source of truth
2. **Check team-memory** — For company-specific knowledge not in USER.md
3. **Check external KB** — For product documentation
4. **Never contradict USER.md** — If team-memory says one thing and USER.md says another, USER.md wins

### Conflicting Information
If you find contradictory information across sources:
- Use the most authoritative source (USER.md > team-memory > external KB)
- Flag the contradiction in team-memory so it can be resolved
- Tell the customer: "I want to make sure I give you the right answer — let me verify this with our team."

---

## Metrics

Track and store in team-memory periodically:

- **KB hit rate**: Percentage of questions answered from the knowledge base
- **KB gap count**: Number of questions with no KB answer (per week)
- **FAQ cache hit rate**: Percentage of questions answered from cached FAQs
- **Average search-to-answer time**: How long it takes to find and draft an answer
- **Article suggestions pending**: Number of suggested articles not yet created


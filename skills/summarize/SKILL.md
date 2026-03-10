# Skill — Content Summarization

**Purpose:** Distill long documents, articles, reports, emails, and meeting notes into actionable briefs. Preserve key data points and action items. Adapt format and depth to the audience.

---

## Core Principle

Summarization is not compression. Compression removes words. Summarization removes noise and amplifies signal. A good summary answers: "What does this say that matters to me, and what should I do about it?"

---

## Summarization Process

### Step 1: Identify the Input Type

| Input Type | Key Focus | Typical Output |
|-----------|-----------|---------------|
| Article/blog post | Main argument, key data, credibility | Executive summary + key takeaways |
| Research report | Methodology, findings, implications | Structured brief with data highlights |
| Email thread | Latest ask, decisions made, action items | TLDR + action items list |
| Meeting notes | Decisions, action items, open questions | Decision log + action items |
| Legal/contract | Key terms, obligations, deadlines, risks | Plain-English term sheet |
| Financial report | Key metrics, trends, anomalies | Dashboard-style bullet points |
| Product documentation | Features, limitations, integration points | Feature comparison or capability brief |
| Long conversation/chat | Key points, agreements, follow-ups | Thread summary with highlights |

### Step 2: Read the Full Content

Never summarize from a skim. Read the entire document. Pay special attention to:
- Opening and closing paragraphs (usually contain the thesis and conclusion)
- Numbers, percentages, and named data points (these survive summarization)
- Quoted sources and attributions (keep these intact)
- Action items, deadlines, and commitments (highlight these)
- Caveats, limitations, and counterarguments (don't erase nuance)

### Step 3: Identify the "So What"

Before writing the summary, answer:
- Why should the reader care about this?
- What decision does this inform?
- What action should follow from this?

If the answer is "nothing" — the document may not be worth summarizing. Say so: "I read through this, and there's no new information or action needed. Key point: [one sentence]. Want me to file it?"

### Step 4: Write the Summary

Choose the appropriate format from the templates below based on the audience and context.

---

## Output Formats

### Format 1: Executive Summary
**Best for:** Reports, whitepapers, research findings
**Audience:** Busy executives who need the bottom line

```
## Executive Summary: {Document Title}

**Source:** {author/publication, date}
**Reading time saved:** {original length} → {summary length}

### Bottom Line
{1-2 sentences: the single most important takeaway}

### Key Findings
1. {Finding with specific data point} — {source/page reference}
2. {Finding with specific data point}
3. {Finding with specific data point}

### Implications for {COMPANY_NAME}
- {What this means for our business specifically}
- {Action to consider}

### Caveats
- {Important limitation or counterpoint}
```

### Format 2: Bullet Points
**Best for:** Quick updates, Slack messages, time-pressed requests
**Audience:** Anyone who needs the gist in 30 seconds

```
## TLDR: {Document Title}

- {Key point 1 — most important first}
- {Key point 2}
- {Key point 3}
- {Action needed: specific next step, if any}
- Source: {link}
```

### Format 3: Detailed Analysis
**Best for:** Strategic documents, competitor reports, complex topics
**Audience:** Team members who need depth but don't have time for the original

```
## Summary: {Document Title}

**Source:** {full citation}
**Original length:** {pages/words}
**Summary by:** {COMPANY_NAME} Research

---

### Context
{Why this document exists, who wrote it, what prompted it}

### Main Argument/Thesis
{The core claim or purpose of the document}

### Supporting Evidence
1. **{Sub-topic 1}:** {Detail with data}
2. **{Sub-topic 2}:** {Detail with data}
3. **{Sub-topic 3}:** {Detail with data}

### Counterarguments Presented
- {Any opposing views the document acknowledges}

### Data Highlights
| Metric | Value | Context |
|--------|-------|---------|
| {metric} | {value} | {why it matters} |

### Gaps and Limitations
- {What the document doesn't cover}
- {Where the methodology is weak}

### Implications
- **Short-term:** {immediate relevance}
- **Long-term:** {strategic relevance}

### Recommended Actions
1. {Specific action the customer should consider}
2. {Specific action}
```

### Format 4: Email Thread Summary
**Best for:** Long email chains, support ticket histories
**Audience:** Anyone jumping into a conversation mid-stream

```
## Thread Summary: {Subject Line}

**Participants:** {names}
**Date range:** {first email} — {latest email}
**Status:** {resolved | pending | needs response}

### What Happened
{Chronological summary of the key exchanges, 3-5 sentences}

### Current Ask
{What the latest message is requesting — the thing that needs action now}

### Decisions Made
- {Decision 1 — who decided, when}
- {Decision 2}

### Open Questions
- {Unanswered question 1}
- {Unanswered question 2}

### Action Items
| Action | Owner | Deadline |
|--------|-------|----------|
| {action} | {person} | {date} |
```

### Format 5: Meeting Notes Summary
**Best for:** Meeting transcripts, recorded meeting notes
**Audience:** Attendees who need a refresher, non-attendees who need to catch up

```
## Meeting Summary: {Meeting Name}

**Date:** {YYYY-MM-DD}
**Attendees:** {names}
**Duration:** {time}

### Decisions Made
1. {Decision — specific, with context}
2. {Decision}

### Action Items
| Item | Owner | Due Date |
|------|-------|----------|
| {specific task} | {person} | {date} |

### Key Discussion Points
- **{Topic 1}:** {What was discussed, any conclusions}
- **{Topic 2}:** {What was discussed, any conclusions}

### Open Items / Parking Lot
- {Item deferred to next meeting}

### Next Steps
- {What happens next, when the next meeting is}
```

### Format 6: Comparison Summary
**Best for:** Multiple documents on the same topic, competing proposals
**Audience:** Decision-makers evaluating options

```
## Comparison: {Topic}

**Documents compared:**
1. {Document A — source}
2. {Document B — source}

### Where They Agree
- {Shared conclusion or data point}

### Where They Disagree
| Dimension | Document A Says | Document B Says |
|-----------|----------------|----------------|
| {topic} | {position} | {position} |

### Which Is More Credible?
{Assessment of methodology, source quality, recency for each}

### Recommendation
{Which to trust more and why, or how to reconcile the differences}
```

---

## Summarization Quality Rules

### Preserve
- Specific numbers and data points (don't round unless the original rounded)
- Direct quotes that are important (attribute them)
- Named sources and citations
- Action items with owners and deadlines
- Caveats and limitations the original author stated

### Remove
- Filler words and throat-clearing ("In today's fast-paced world...")
- Redundant repetition (same point made three different ways)
- Background the reader already knows (unless critical context)
- Self-promotion or marketing language (unless analyzing messaging)
- Tangential anecdotes that don't support the main point

### Never Do
- Change the meaning by omitting a critical qualifier ("Most users..." is not "All users...")
- Remove caveats to make the conclusion sound stronger than it is
- Add your own opinions without labeling them as analysis
- Summarize from headlines/abstracts without reading the full content
- Fabricate data points that weren't in the original

---

## Handling Different Input Methods

### Text Pasted in Chat
- Summarize directly from the provided text
- Ask for source/context if not provided: "Where is this from? Context helps me emphasize what's relevant."

### URL Provided
- Use browser automation to load and read the full page
- If behind a paywall, note it: "This content is paywalled. I can summarize what's visible or you can share the full text."

### File Shared (PDF, Doc)
- Read the full document
- For very long documents (50+ pages), confirm scope: "This is 80 pages. Want the full summary, or should I focus on specific sections?"

### Multiple Documents
- Summarize each individually first, then synthesize
- Use the Comparison format if they cover the same topic
- Highlight where they agree and disagree

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Content is too long for a single pass | Break into sections, summarize each, then create an overall summary |
| Content is in a language you can handle | Summarize and note: "Original in {language}, summarized in English" |
| Content is heavily technical | Adjust language to audience: exec summary for non-technical, preserve jargon for technical team |
| Content is mostly images/charts | Describe what the visual data shows, extract key data points |
| Content quality is low | Note it: "This source has methodological issues: {specifics}. Treat findings with caution." |
| Customer asks for a specific format | Use their preferred format from USER.md, adapting the templates above |
| Summary requested of confidential document | Summarize without including sensitive specifics, or ask about distribution: "Who will see this summary?" |


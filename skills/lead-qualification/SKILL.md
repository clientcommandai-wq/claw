# Lead Qualification Skill

> Research and score leads using the BANT framework. Determine fit, identify decision-makers, and recommend next actions. You are the filter between "everyone" and "the right prospects."

---

## When to Activate

This skill is called by the sales-lead orchestrator when:
- A new inbound lead arrives (from Receptionist AI, website form, or CRM)
- The owner asks to evaluate a specific prospect ("Is [company] a good fit?")
- A batch of prospects needs qualification ("Here's a list of 20 companies, which should we pursue?")
- A lead's qualification needs updating (they responded, deal context changed)

---

## The BANT Framework

BANT is the core qualification methodology. Every prospect gets evaluated on all four criteria.

### B — Budget

**Question to answer:** Can they afford what we sell?

**How to assess:**
- Company size (revenue, headcount, funding stage) — larger companies generally have more budget
- Industry norms — some industries spend more on your category than others
- Funding status — recently funded companies are actively spending
- Public pricing on their website — gives a sense of their revenue scale
- Job postings — hiring signals growth and budget availability
- If in conversation: "What budget range are you working with for this?"

**Scoring:**
| Signal | Points |
|--------|--------|
| Revenue/funding clearly supports your price point | 3 |
| Likely can afford it based on company size | 2 |
| Unclear — could go either way | 1 |
| Clearly too small or budget-constrained | 0 |

### A — Authority

**Question to answer:** Are we talking to someone who can say yes?

**How to assess:**
- Job title: C-suite, VP, Director = high authority. Manager, Coordinator = lower
- Company size matters: at a 10-person startup, a Manager may have full authority. At a 10,000-person company, even a Director may need VP approval
- Check if the contact's title matches the buyer persona in USER.md (`IDEAL_CUSTOMER_PROFILE`)
- LinkedIn: who reports to whom? Who else is in the department?
- If in conversation: "Who else is involved in this decision?" or "What does your evaluation process look like?"

**Scoring:**
| Signal | Points |
|--------|--------|
| C-suite or final decision-maker | 3 |
| VP/Director with budget authority | 2 |
| Manager who influences the decision | 1 |
| Individual contributor, no buying power | 0 |

### N — Need

**Question to answer:** Do they have a problem we can solve?

**How to assess:**
- Industry alignment — is their industry in our `IDEAL_CUSTOMER_PROFILE`?
- Job postings — hiring for roles our product replaces or augments signals need
- Public complaints — reviews, social media posts, forum comments about the problem we solve
- Tech stack — are they using competitors or complementary tools?
- If in conversation: "What's your biggest challenge with [area]?" or "What are you using for [problem] today?"

**Scoring:**
| Signal | Points |
|--------|--------|
| Explicit stated need that matches our offering perfectly | 3 |
| Industry and role suggest strong likely need | 2 |
| Some indicators of need, but unconfirmed | 1 |
| No apparent need, or they've solved this problem already | 0 |

### T — Timeline

**Question to answer:** When do they want to buy?

**How to assess:**
- Urgency signals: "ASAP", "this quarter", "before our next board meeting"
- Trigger events: contract renewal coming up, fiscal year planning, leadership change
- Hiring: if they're hiring for the role our product helps, they're investing soon
- If in conversation: "When are you looking to have something in place?" or "Is there a deadline driving this?"

**Scoring:**
| Signal | Points |
|--------|--------|
| Buying this month / active evaluation | 3 |
| Buying this quarter | 2 |
| Buying this year, no rush | 1 |
| No timeline, "just exploring" | 0 |

---

## Lead Score Calculation

Add up all four BANT scores for a total of 0-12:

| Total Score | Rating | Recommendation |
|-------------|--------|---------------|
| 10-12 | **Hot** | Fast-track: high-priority outreach, request a meeting ASAP, alert the owner |
| 7-9 | **Warm** | Active pursuit: personalized outreach, 3-touch sequence, move to pipeline |
| 4-6 | **Cool** | Nurture: add to long-term sequence, check back in 30-60 days |
| 0-3 | **Not a Fit** | Disqualify: log the reason, don't waste outreach on them |

---

## Research Process

For every prospect, conduct this research before scoring:

### Step 1: Company Research

| Research Area | Sources | What to Look For |
|--------------|---------|-----------------|
| Company overview | Website, LinkedIn company page, Crunchbase | What they do, size, revenue, founding year |
| Recent news | Google News, TechCrunch, industry blogs | Funding rounds, product launches, leadership changes, acquisitions |
| Tech stack | BuiltWith, job postings, GitHub | What tools they use, what they might need |
| Competitors | Website positioning, G2 reviews | Who they compete with (are they our ICP?) |
| Growth signals | Job postings, office expansions, funding | Are they growing? Hiring? Investing? |

### Step 2: Contact Research

| Research Area | Sources | What to Look For |
|--------------|---------|-----------------|
| Role and seniority | LinkedIn profile | Title, tenure, scope of responsibility |
| Background | LinkedIn profile | Previous companies, education, skills |
| Activity | LinkedIn posts, Twitter/X, conference talks | What they talk about, what they care about |
| Connections | LinkedIn mutual connections | Shared connections who could introduce |
| Publications | Blog posts, podcast appearances | Thought leadership, stated opinions |

### Step 3: Check Internal Sources

Before any external research, check what you already know:

```bash
# Check team-memory for prior interactions
curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/search" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"query": "Acme Corp interactions", "limit": 5}' \
  || echo '{"memories":[]}'
```

```bash
# Check CRM for existing records (via credential-proxy)
curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "HUBSPOT_API_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://api.hubapi.com/crm/v3/objects/contacts/search",
      "method": "POST",
      "body": {
        "filterGroups": [{"filters": [{"propertyName": "company", "operator": "CONTAINS_TOKEN", "value": "Acme"}]}],
        "properties": ["email", "firstname", "lastname", "jobtitle", "lifecyclestage"]
      }
    }
  }' || echo '{"success":false}'
```

---

## Qualification Report

After completing research and scoring, produce a structured report:

```
LEAD QUALIFICATION REPORT
=========================

Company: [Name]
Website: [URL]
Industry: [Industry]
Size: [N employees] | Revenue: [if known]
Location: [HQ location]
Founded: [Year]

Contact: [Name], [Title]
LinkedIn: [URL if available]
Email: [if known]

BANT SCORE: [X]/12 — [Hot/Warm/Cool/Not a Fit]

  Budget:    [0-3] — [Evidence: "Series B raised $20M, actively spending on tools"]
  Authority: [0-3] — [Evidence: "VP Ops, reports directly to CEO, has budget authority"]
  Need:      [0-3] — [Evidence: "Job posting for Ops Manager mentions manual workflows"]
  Timeline:  [0-3] — [Evidence: "Fiscal year starts April, likely planning now"]

TRIGGER EVENT: [What makes NOW the right time to reach out]

DECISION-MAKERS IDENTIFIED:
  - [Name], [Title] — [Role in decision: Champion / Decision-maker / Influencer]
  - [Name], [Title] — [Role in decision]

RECOMMENDED ACTION: [Fast-track / Active outreach / Nurture / Disqualify]

RECOMMENDED APPROACH:
  [1-2 sentences on what angle to use in outreach based on your research]

NOTES:
  [Any additional context: competitor they use, shared connections, relevant news]
```

---

## Batch Qualification

When qualifying a list of prospects:

1. Score each prospect independently
2. Sort by score (highest first)
3. Present a summary table:

```
BATCH QUALIFICATION — [Date]
[N] prospects evaluated

| # | Company | Contact | Score | Rating | Recommended Action |
|---|---------|---------|-------|--------|-------------------|
| 1 | Acme Corp | Jane Smith, VP Ops | 10/12 | Hot | Fast-track outreach |
| 2 | Beta Inc | Mark Chen, Director | 8/12 | Warm | Active pursuit |
| 3 | Gamma LLC | No contact found | 5/12 | Cool | Nurture |
| 4 | Delta Co | Sam Jones, Coordinator | 2/12 | Not a Fit | Disqualify |

TOTAL: [N] hot, [N] warm, [N] cool, [N] disqualified

Ready to start outreach to the hot leads?
```

---

## ICP Fit Check

Before scoring BANT, first check against the Ideal Customer Profile in USER.md:

### Quick Fit Check

```
1. Is the company in a target industry?       [YES/NO]
2. Is the company the right size?             [YES/NO]
3. Is the contact the right role?             [YES/NO]
4. Does the company match any disqualifiers?  [YES/NO → immediate disqualify]
```

If 3+ answers are NO, skip BANT scoring and disqualify immediately. Don't waste time researching poor-fit prospects.

---

## Storing Qualification Data

After qualifying a lead, store key insights in team-memory for the whole team:

```bash
curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/memories" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Acme Corp qualified 10/12 (Hot). VP Ops has budget authority, hiring for ops roles, Series B funded. Best angle: automation replacing headcount. Decision-maker is Jane Smith. Trigger: post-Series B scaling pains.",
    "type": "pattern",
    "source_agent": "sales-lead",
    "tags": ["qualification", "acme-corp", "hot-lead"]
  }' || true
```

Also update the CRM via the `crm` skill:
- Create or update the contact record
- Create a deal if score is 7+ (Warm or Hot)
- Add qualification notes with BANT breakdown
- Set the deal stage based on the recommendation

---

## Re-Qualification

Leads should be re-qualified when:
- They respond to outreach (new information available)
- 90 days have passed since last qualification (circumstances change)
- A trigger event occurs (new funding, leadership change, acquisition)
- The owner asks for an updated assessment

When re-qualifying:
1. Pull the original qualification from team-memory or CRM
2. Note what changed
3. Re-score BANT with updated information
4. Update the recommendation
5. Update CRM and team-memory with the new score


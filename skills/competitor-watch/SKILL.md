# Skill — Competitor Watch

**Purpose:** Track, analyze, and report on competitor activities. Monitor pricing, features, announcements, hiring, and market positioning. Maintain an ongoing competitive intelligence database in team-memory.

---

## Competitive Intelligence Framework

### What to Track Per Competitor

For each competitor in USER.md `KEY_COMPETITORS`, maintain intelligence on:

| Category | Data Points | Monitoring Frequency |
|----------|------------|---------------------|
| **Product** | Features, pricing tiers, free plan changes, new launches, deprecated features | Weekly |
| **Pricing** | Plan prices, billing model (monthly/annual), enterprise pricing signals, discounts | Weekly |
| **Positioning** | Homepage messaging, tagline changes, target audience shifts, case studies | Monthly |
| **Team** | Key hires (C-suite, VP+), departures, team size growth, job postings | Bi-weekly |
| **Funding** | Funding rounds, valuations, investors, runway estimates | On event |
| **Customers** | Notable customer wins/losses, case studies published, logo walls | Monthly |
| **Reviews** | G2, Capterra, Trustpilot scores, sentiment trends, common complaints | Monthly |
| **Social** | Twitter/LinkedIn engagement, blog cadence, community activity | Weekly |
| **News** | Press coverage, partnerships, acquisitions, legal issues | Weekly |

### Intelligence Signals (What to Alert On)

These events warrant an immediate alert to the customer:

| Signal | Priority | Example |
|--------|----------|---------|
| Competitor raises funding | HIGH | "Competitor X just raised $50M Series C" |
| Competitor launches new product/feature | HIGH | "Competitor Y launched AI-powered scheduling" |
| Competitor changes pricing | HIGH | "Competitor Z dropped prices by 30%" |
| Key executive departure | MEDIUM | "CTO of Competitor X left (LinkedIn update)" |
| Major customer win/loss | MEDIUM | "Competitor Y landed Enterprise Co. (case study published)" |
| Hiring surge in specific area | MEDIUM | "Competitor Z posted 15 ML engineer roles this week" |
| Negative press or controversy | LOW | "Competitor X data breach reported in TechCrunch" |
| Regulatory action | HIGH | "Competitor Y received FDA warning letter" |

---

## Competitor Profile Template

For each competitor, build and maintain this profile:

```
# Competitor Profile: {Competitor Name}

**Last Updated:** {YYYY-MM-DD}
**Profile Confidence:** {High | Medium | Low}
**Website:** {URL}

---

## Overview
- **Founded:** {year}
- **Headquarters:** {city, country}
- **Team Size:** {approximate, source}
- **Funding:** {total raised, last round, lead investors}
- **Estimated Revenue:** {range if available, source}

## Product
- **Core Offering:** {what they sell}
- **Target Market:** {who they sell to}
- **Key Features:**
  - {feature 1}
  - {feature 2}
  - {feature 3}
- **Unique Differentiator:** {what they claim sets them apart}
- **Tech Stack:** {if known — can signal direction}

## Pricing
| Tier | Price | Key Inclusions |
|------|-------|---------------|
| {Free/Starter} | {$X/mo} | {features} |
| {Pro/Growth} | {$X/mo} | {features} |
| {Enterprise} | {Custom} | {features} |

**Pricing Model:** {per seat / per usage / flat rate}
**Annual Discount:** {% if known}
**Free Trial:** {yes/no, duration}

## Market Position
- **Strengths:** {what they do well}
- **Weaknesses:** {where they struggle, based on reviews/complaints}
- **Customer Sentiment:** {G2 score, Capterra score, common themes in reviews}

## vs. {COMPANY_NAME}
- **They win on:** {areas where competitor is stronger}
- **We win on:** {areas where customer's company is stronger}
- **Neutral:** {areas where they're roughly equal}

## Recent Activity
- {YYYY-MM-DD}: {event description, source URL}
- {YYYY-MM-DD}: {event description, source URL}

## Intelligence Gaps
- {What we don't know and should try to find out}
```

---

## Research Methods by Category

### Pricing Intelligence
1. **Check their website** — pricing page, feature comparison table
2. **Check review sites** — G2 and Capterra often show pricing in reviews
3. **Check web archives** — Wayback Machine for historical pricing changes
4. **Monitor job postings** — pricing strategist roles signal upcoming changes
5. **Check community forums** — users sometimes share pricing details

```
PRICING CHANGE DETECTED:
- Competitor: {name}
- Change: {old_price} → {new_price} for {tier}
- Date detected: {YYYY-MM-DD}
- Source: {URL}
- Implications: {what this means for our positioning}
```

### Feature Tracking
1. **Product changelog** — most SaaS companies publish release notes
2. **Blog announcements** — new feature launches are usually blogged
3. **Social media** — product teams often tweet about releases
4. **Review sites** — users mention new features in recent reviews
5. **Product Hunt** — check if they launched new products/features

### Hiring Signal Analysis
Job postings reveal strategic direction:

| Hiring Pattern | Signal |
|---------------|--------|
| ML/AI engineers in bulk | Building AI capabilities |
| Enterprise sales reps | Moving upmarket |
| International roles | Geographic expansion |
| Compliance/legal roles | Regulatory preparation or government contracts |
| Customer success roles | Focus on retention (may be losing customers) |
| Many roles across all departments | Well-funded, growing fast |
| Backfilling same role repeatedly | Potential retention issues |

### Social Media and Community Monitoring

Track these public channels for each competitor:
- **Twitter/X**: Company account + key executives
- **LinkedIn**: Company page (job postings, employee count, content)
- **Blog/Newsletter**: Product updates, thought leadership positioning
- **Reddit**: Mentions in relevant subreddits
- **Hacker News**: Launches, discussions, complaints
- **YouTube**: Product demos, webinars, conference talks

---

## Competitive Analysis Outputs

### Quick Comparison Table
For "how do we compare to X?" questions:

```
# Competitive Comparison: {COMPANY_NAME} vs. {Competitor}

| Dimension | {COMPANY_NAME} | {Competitor} | Verdict |
|-----------|---------------|-------------|---------|
| Price (equivalent tier) | $X/mo | $Y/mo | {who's cheaper} |
| Core feature A | {Yes/No/Partial} | {Yes/No/Partial} | {who's better} |
| Core feature B | ... | ... | ... |
| Integration count | {N} | {M} | ... |
| G2 rating | {X.X/5} | {X.X/5} | ... |
| Customer support | {channels} | {channels} | ... |
| Free tier | {details} | {details} | ... |

**Bottom line:** {1-2 sentence summary of competitive position}
```

### Market Map
For "who are all the players?" questions:

```
# Market Map: {Category}

## Leaders (established, high market share)
- {Company}: {1-line description, est. revenue, key differentiator}

## Challengers (growing fast, gaining share)
- {Company}: {1-line description, recent funding, growth signals}

## Niche Players (specialized, smaller)
- {Company}: {1-line description, specific focus area}

## Emerging (new entrants, early stage)
- {Company}: {1-line description, when founded, notable backers}

## Adjacent (not direct competitors but overlap)
- {Company}: {1-line description, where they overlap}
```

### Competitive Digest (Weekly/Bi-weekly)

```
# Competitive Intelligence Digest — Week of {date}

## Headlines
- {1-2 sentence summary of most important change this period}

## Changes Detected

### {Competitor A}
- {change description} — Source: {URL}
- Impact: {what this means for us}

### {Competitor B}
- No significant changes this period

## Market Trends
- {relevant industry development}

## Recommended Actions
- {specific thing the customer should consider based on this intelligence}

## Next Week Focus
- {what we're watching next}
```

---

## Storing Intelligence in Team-Memory

Every significant competitive finding should be stored:

```bash
# Store a competitive intelligence finding
curl --max-time 3 -s -X POST \
  "${MEMORY_WORKER_URL}/tenant/memories" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Competitor X raised Series C ($50M) led by Sequoia. Announced expansion into EU market and AI features. Source: TechCrunch 2026-02-10.",
    "type": "architecture",
    "source_agent": "research-analyst",
    "tags": ["competitor-x", "funding", "competitive-intelligence"]
  }' \
  || echo '{"stored":false}'
```

**Tag conventions for competitive intelligence:**
- `competitor-{name}` — competitor-specific
- `competitive-intelligence` — all CI entries
- `pricing-intel` — pricing changes
- `market-trend` — industry-level trends
- `feature-launch` — product updates

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Competitor website is down or changed | Check web archive, note the gap, retry next cycle |
| Pricing page requires demo/sales call | Note as "pricing not publicly available" and suggest customer reach out |
| Conflicting info about competitor | Present both with sources, note the discrepancy |
| Competitor is private (no public financials) | Use proxy signals: team size growth, job postings, funding, review volume |
| Customer asks about a competitor not in USER.md | Research them, then suggest adding to `KEY_COMPETITORS` list |
| Intelligence is getting stale | Proactively refresh profiles every 30 days minimum |


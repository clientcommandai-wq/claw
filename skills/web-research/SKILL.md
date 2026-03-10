# Skill — Web Research

**Purpose:** Conduct deep-dive web research using a structured, multi-source methodology. Find information, verify it, assess its reliability, and present structured findings with confidence levels and source citations.

---

## Research Methodology

Every research task follows this structured approach:

### Phase 1: Define the Question (Before Searching)

Before opening a browser, clarify:
1. **What exactly are we trying to find out?** (Restate the question in your own words)
2. **What would a good answer look like?** (A number? A comparison? A trend?)
3. **What's the decision this supports?** (Context shapes what matters)
4. **What do we already know?** (Check team-memory first)

If the question is vague, ask for clarification before proceeding. "Research our market" is not a research question. "What is the TAM for AI-powered customer service tools in the US SMB segment?" is.

### Phase 2: Search Strategy

Build a search plan before executing:

**Primary searches** (start here):
- Direct queries for the specific data point
- Industry reports and market analyses
- Government and regulatory databases
- Academic papers and research institutions

**Secondary searches** (corroborate and expand):
- News coverage and press releases
- Analyst commentary and expert opinions
- Social media and community discussions (Reddit, HN, Twitter)
- Company websites and investor presentations

**Tertiary searches** (fill gaps):
- Adjacent industries with transferable data
- Historical data for trend extrapolation
- International markets as proxies

### Phase 3: Gather and Verify

For each source found:

1. **Record the source**: URL, publication name, author, date published
2. **Assess credibility**: Primary vs secondary data? Peer-reviewed? Known publication? Potential bias?
3. **Extract key data points**: Specific numbers, quotes, findings
4. **Cross-reference**: Does at least one other source confirm this?
5. **Note limitations**: Sample size, geographic scope, methodology gaps

### Phase 4: Analyze and Synthesize

- Group findings by theme
- Identify patterns and consensus across sources
- Highlight contradictions and explain why they might exist
- Apply findings to the customer's specific context
- Form conclusions with stated confidence levels

### Phase 5: Deliver

Use the research report template below.

---

## Source Credibility Assessment

Rate every source on this scale:

| Tier | Source Types | Weight | Example |
|------|------------|--------|---------|
| **Tier 1 — Primary** | Original research, official data, financial filings, peer-reviewed studies | Highest | SEC 10-K filing, Census Bureau data, Nature paper |
| **Tier 2 — Authoritative** | Major analyst firms, respected publications, industry associations | High | Gartner, McKinsey, Bloomberg, IEEE |
| **Tier 3 — Credible** | Established news outlets, industry blogs, company websites | Medium | TechCrunch, VentureBeat, company press releases |
| **Tier 4 — Community** | Forums, social media, personal blogs, review sites | Low (but useful for sentiment) | Reddit, Hacker News, G2, Capterra |
| **Tier 5 — Unverified** | Anonymous sources, undated content, self-published without review | Very low — flag explicitly | Anonymous blog posts, unsourced statistics |

**Red flags that reduce credibility:**
- No date published (could be years old)
- No author attributed
- Circular sourcing (article A cites article B which cites article A)
- Obvious promotional intent (company blog claiming their own product is best)
- Extraordinary claims without extraordinary evidence
- Sample size not disclosed for survey data
- "According to experts" without naming the experts

---

## Browser Automation for Research

When information requires navigating complex sites:

```bash
# Use browser automation for sites that need interaction
# Examples: paginated results, dynamic content, login-gated public info

# Navigate to a pricing page that loads dynamically
# Extract structured data from comparison tables
# Screenshot charts and data visualizations for reference
# Navigate through multi-step content (next page, expand sections)
```

**When to use browser automation:**
- Pricing pages that load dynamically
- Product comparison tables on review sites
- Job posting aggregation across multiple pages
- Government databases with search interfaces
- News archives with date-filtered search

**When NOT to use browser automation:**
- Standard search engine queries (use regular web search)
- Paywalled content (don't bypass paywalls)
- Sites that require login credentials you don't have
- CAPTCHAs (flag to customer instead)

---

## Research Report Template

Use this structure for standard and deep-dive research:

```
# Research Report: {Title}

**Prepared for:** {customer_name}
**Date:** {YYYY-MM-DD}
**Research depth:** {Quick check | Standard | Deep dive}
**Time invested:** {approximate hours}

---

## Executive Summary
{2-3 sentences: what was the question, what did we find, what does it mean}

## Key Findings

### Finding 1: {Title}
{Description of the finding}
- **Data point:** {specific number or fact}
- **Source:** {publication, author, date, URL}
- **Confidence:** {High | Medium | Low | Unverified}

### Finding 2: {Title}
...

### Finding 3: {Title}
...

## Analysis
{What do the findings mean taken together? What patterns emerge?
 How does this apply to the customer's specific business?}

## Contradictions and Caveats
{Where sources disagree, what data is uncertain, what limitations exist}

## Gaps
{What we couldn't find, what needs more research, where data is stale}

## Implications for {COMPANY_NAME}
{The "so what" — specific, actionable implications for this business}

## Recommendations
{What to do next based on these findings — concrete actions}

## Sources
1. {Author, "Title," Publication, Date. URL}
2. ...

## Methodology
{How the research was conducted: sources searched, date range, search terms}
```

---

## Common Research Patterns

### Market Sizing
1. **Top-down:** Start with total addressable market (TAM), narrow by segment, geography, customer type
2. **Bottom-up:** Count potential customers x average revenue per customer
3. **Triangulate:** Use both approaches and see if they roughly agree
4. **Always state assumptions:** "Assuming 5% adoption rate..." — make assumptions explicit

### Trend Analysis
1. Find data points over at least 3 time periods (more is better)
2. Look for the underlying driver, not just the trend line
3. Distinguish between trends (sustained direction) and fluctuations (temporary)
4. Compare to adjacent industries for leading/lagging indicators

### Company Research
1. Start with their website (products, pricing, team, press)
2. Check Crunchbase/PitchBook for funding and investors
3. Check LinkedIn for team size, hiring patterns, key hires
4. Check Glassdoor for company culture signals
5. Check social media for customer sentiment
6. Check news for recent developments
7. Check SEC filings if public

---

## Error Handling

| Situation | Action |
|-----------|--------|
| No results found for primary query | Broaden search terms, try synonyms, check alternative sources |
| All sources are behind paywalls | Report what's available, note the paywalled sources, suggest customer purchase access |
| Conflicting data from credible sources | Present both with analysis of why they differ (different methodologies, time periods, definitions) |
| Data is outdated (2+ years) | Flag it: "Note: most recent data available is from [year]. Industry conditions may have changed." |
| Browser automation blocked (CAPTCHA, bot detection) | Fall back to direct API access or note the limitation |
| Research scope is too broad to complete in reasonable time | Deliver preliminary findings with a plan for deeper research: "Here's what I found in the first hour. Do you want me to dig deeper on any of these areas?" |

---

## Security and Ethics

- Only access publicly available information unless credentials are provided via credential-proxy
- Never bypass paywalls, CAPTCHAs, or access controls
- Never use social engineering to obtain information
- Always attribute sources — no plagiarism
- Respect robots.txt and rate limits on websites
- Never scrape personal data or PII from the web
- If research reveals sensitive information (unreleased products, internal documents accidentally public), alert the customer before using it


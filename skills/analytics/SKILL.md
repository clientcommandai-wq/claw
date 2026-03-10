# Analytics Sub-Skill

**Role:** Pull marketing metrics, analyze performance, identify trends, and generate actionable reports. Turn raw data into decisions.

**Parent:** `marketing-lead` (orchestrator routes here for data and performance questions)

---

## Trigger

Activated by the marketing-lead orchestrator when:
- The customer asks about marketing performance ("how did X perform?", "what are our numbers?")
- A scheduled report is due (daily, weekly, monthly)
- A campaign needs a post-mortem analysis
- Anomaly detection flags an unusual metric change
- Budget optimization or ROI calculation is needed

---

## Data Sources

Access marketing data via the credential-proxy. Available sources depend on what the customer has configured.

### Common Integrations

| Tool | Credential Key | What It Provides |
|------|---------------|------------------|
| Google Analytics | `GOOGLE_ANALYTICS_KEY` | Website traffic, conversions, user behavior |
| Mailchimp / ConvertKit | `EMAIL_PLATFORM_KEY` | Email open rates, click rates, list growth |
| Google Ads | `GOOGLE_ADS_KEY` | Ad performance, spend, conversions, CPA |
| Facebook/Meta Ads | `META_ADS_KEY` | Ad performance, audience insights, spend |
| Twitter/X Analytics | `TWITTER_API_KEY` | Engagement, impressions, follower growth |
| LinkedIn Analytics | `LINKEDIN_API_KEY` | Post performance, profile views, engagement |
| Stripe | `STRIPE_API_KEY` | Revenue, conversion, customer value (for attribution) |
| HubSpot | `HUBSPOT_API_KEY` | Leads, contacts, pipeline, marketing attribution |

### Data Pull Protocol

```bash
# Always use credential-proxy with timeout
RESULT=$(curl --max-time 10 -s -X POST \
  "https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/tenants/cmmj7q0wu000oe1b0ij5rzbpr/proxy" \
  -H "Authorization: Bearer ${CLAWTRUST_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "credentialKey": "GOOGLE_ANALYTICS_KEY",
    "service": "http-bearer",
    "request": {
      "url": "https://analyticsdata.googleapis.com/v1beta/...",
      "method": "POST",
      "body": { ... }
    }
  }' \
  || echo '{"success":false,"error":"Analytics service unreachable"}')
```

If a data source is not configured:
- Note it in the report: "Google Analytics data unavailable — credential not configured."
- Suggest the customer add the credential: "Want me to include website traffic in future reports? You can connect Google Analytics in the ClawTrust dashboard."
- Never fabricate data to fill a gap.

---

## Key Metrics Guide

### Website Metrics

| Metric | What It Means | Good Benchmark | Red Flag |
|--------|--------------|----------------|----------|
| **Sessions** | Total visits to the website | Growing month-over-month | -20% decline without explanation |
| **Unique Visitors** | Individual people who visited | Growing | Sharp decline |
| **Bounce Rate** | Visitors who left after one page | 40-60% | >70% (content mismatch) |
| **Avg Session Duration** | Time spent on site | >2 minutes | <30 seconds |
| **Pages per Session** | Depth of engagement | >2 pages | <1.5 pages |
| **Conversion Rate** | Visitors who took desired action | 2-5% (varies by industry) | <1% or declining trend |
| **Traffic Sources** | Where visitors come from | Diversified (not 90% one source) | Over-reliance on one channel |

### Email Metrics

| Metric | What It Means | Good Benchmark | Red Flag |
|--------|--------------|----------------|----------|
| **Open Rate** | Percentage who opened the email | 20-30% (varies by industry) | <15% (subject lines or deliverability) |
| **Click Rate (CTR)** | Percentage who clicked a link | 2-5% | <1% |
| **Click-to-Open Rate (CTOR)** | Clickers / Openers | 10-15% | <5% (content relevance issue) |
| **Unsubscribe Rate** | People who opted out | <0.5% per send | >1% per send |
| **Bounce Rate** | Undeliverable emails | <2% | >5% (list hygiene issue) |
| **List Growth Rate** | Net new subscribers per period | Positive | Negative (losing more than gaining) |

### Social Media Metrics

| Metric | What It Means | Good Benchmark | Red Flag |
|--------|--------------|----------------|----------|
| **Engagement Rate** | (Engagements / Reach) x 100 | 1-5% (platform dependent) | <0.5% |
| **Reach** | Unique people who saw the content | Growing | Declining (algorithm or content issue) |
| **Impressions** | Total times content was shown | Higher than reach (repeat views) | Equal to reach (no reshares) |
| **Follower Growth** | Net new followers | Steady positive | Sudden drops (content or controversy) |
| **Share Rate** | Shares / total reach | >1% | Never shared (content not shareable) |
| **Click-Through Rate** | Link clicks / impressions | 1-3% | <0.5% |

### Advertising Metrics

| Metric | What It Means | Good Benchmark | Red Flag |
|--------|--------------|----------------|----------|
| **CPC (Cost Per Click)** | How much each click costs | Industry dependent ($0.50-$5) | Rising rapidly |
| **CPA (Cost Per Acquisition)** | Cost per conversion | Must be < customer LTV | Exceeds product price |
| **ROAS (Return on Ad Spend)** | Revenue / Ad spend | >3x (varies by business) | <1x (losing money) |
| **CTR (Click-Through Rate)** | Clicks / Impressions | 1-3% for search, 0.5-1% for display | <0.5% (ad fatigue or bad targeting) |
| **Impression Share** | Your impressions / total available | >50% for brand terms | <20% (being outbid) |
| **Quality Score** | Google's relevance rating (1-10) | 7+ | <5 (relevance or landing page issue) |

---

## Report Templates

### Daily Snapshot (Quick Update)

```
DAILY MARKETING SNAPSHOT — [Date]
==================================

Website: [sessions] sessions ([+/-X%] vs yesterday)
Email: [opens] opens on last send ([open_rate]% open rate)
Social: [total_engagements] engagements across platforms
Ads: $[spend] spent, [conversions] conversions ($[CPA] CPA)

Notable:
- [1-2 highlights or anomalies]

Action needed: [None / specific action]
```

### Weekly Report

```
WEEKLY MARKETING REPORT — Week of [Date]
==========================================

SUMMARY
-------
Overall: [one sentence — good week / mixed / needs attention]

WEBSITE
-------
Sessions: [number] ([+/-X%] vs last week)
Top traffic source: [source] ([X%] of traffic)
Conversion rate: [X%] ([+/-] vs last week)
Top performing page: [page] ([sessions])

EMAIL
-----
Emails sent: [number] ([campaigns])
Average open rate: [X%]
Average click rate: [X%]
List change: [+/-] subscribers (total: [number])
Best subject line: "[subject]" ([open_rate]%)

SOCIAL MEDIA
------------
| Platform | Posts | Engagements | Reach | Follower Change |
|----------|-------|-------------|-------|----------------|
| Twitter/X | | | | |
| LinkedIn | | | | |
| Instagram | | | | |
| Facebook | | | | |

Top performing post: "[description]" on [platform] ([engagements])

PAID ADS (if active)
--------------------
Total spend: $[amount]
Total conversions: [number]
Average CPA: $[amount]
ROAS: [X]x

INSIGHTS & RECOMMENDATIONS
---------------------------
1. [What worked and why — do more of this]
2. [What underperformed and why — adjust this]
3. [Opportunity identified — consider this]

NEXT WEEK PLAN
--------------
- [Planned content]
- [Tests to run]
- [Campaign milestones]
```

### Monthly Report

```
MONTHLY MARKETING REPORT — [Month Year]
=========================================

EXECUTIVE SUMMARY
-----------------
[2-3 sentences: overall performance, key wins, areas for improvement]

KEY METRICS (Month-over-Month)
------------------------------
| Metric | This Month | Last Month | Change | Target |
|--------|-----------|------------|--------|--------|
| Website sessions | | | | |
| Conversion rate | | | | |
| Email subscribers | | | | |
| Email open rate | | | | |
| Social followers (total) | | | | |
| Social engagement rate | | | | |
| Ad spend | | | | |
| Ad conversions | | | | |
| Marketing-attributed revenue | | | | |

TOP PERFORMING CONTENT
----------------------
1. [Title/Description] — [Platform] — [Key metric]
2. [Title/Description] — [Platform] — [Key metric]
3. [Title/Description] — [Platform] — [Key metric]

UNDERPERFORMING CONTENT
-----------------------
1. [Title/Description] — Why: [analysis]
2. [Title/Description] — Why: [analysis]

CHANNEL PERFORMANCE
-------------------
[Breakdown by channel: what worked, what didn't, trends]

AUDIENCE INSIGHTS
-----------------
[Demographics, behavior patterns, geographic data, new segments identified]

COMPETITIVE OBSERVATIONS
------------------------
[What competitors did this month, how we differentiate]

RECOMMENDATIONS FOR NEXT MONTH
-------------------------------
1. [Strategic recommendation with rationale]
2. [Strategic recommendation with rationale]
3. [Strategic recommendation with rationale]

BUDGET REVIEW
-------------
Planned spend: $[amount]
Actual spend: $[amount]
ROI: [calculation]
Recommendation: [increase / maintain / decrease / reallocate]
```

---

## Trend Analysis

### Identifying Trends
When analyzing data, look for these patterns:

1. **Sustained direction**: 3+ consecutive periods moving in the same direction (not just one data point)
2. **Rate of change**: Is growth/decline accelerating or decelerating?
3. **Correlation**: Did a specific action precede the change? (content published, campaign launched, competitor move)
4. **Seasonality**: Is this expected for this time of year in this industry?
5. **Anomalies**: Sudden spikes or drops that break the pattern

### Anomaly Detection

Flag and investigate when:
- Any key metric changes by >20% week-over-week without an obvious cause
- Email unsubscribe rate exceeds 1% on a single send
- Website traffic drops >30% day-over-day
- Ad CPA increases >50% without bid/budget changes
- Social engagement drops to zero (account issue, shadow ban?)

When an anomaly is detected:
1. Identify it immediately: "I noticed [metric] changed by [amount]. This is unusual."
2. Investigate potential causes (check what changed: content, algorithm, external events)
3. Recommend action: "I recommend [action] to address this."
4. Store in team-memory for pattern tracking

---

## Optimization Recommendations

### When Data Shows Underperformance
Do NOT just report bad numbers. Always pair them with actionable recommendations.

```
BAD: "Our email open rate dropped to 15% this week."

GOOD: "Our email open rate dropped to 15% this week (from 22% last week).
Looking at the data:
- The subject line was 68 characters (our best performers are under 45)
- We sent on Friday at 5pm (our best open rates are Tue-Thu mornings)
- The last 3 emails were all promotional (audience fatigue)

Recommendations:
1. Test shorter subject lines next send (I've drafted 3 options)
2. Move send time to Tuesday 9am
3. Next email should be value-focused, not promotional (80/20 rule)"
```

### Data-Driven Content Suggestions
Use performance data to inform content strategy:

- **High engagement topics** → Create more content on these themes
- **High-performing formats** → Prioritize these formats in the content calendar
- **Best sending times** → Optimize scheduling based on actual data, not general best practices
- **Top traffic sources** → Invest more in channels that drive qualified traffic
- **Conversion paths** → Identify which content leads to conversions and create more like it

---

## Data Limitations

Be transparent about what the data can and cannot tell you.

### Always Disclose
- **Attribution limitations**: "This is last-click attribution — some conversions may have been influenced by earlier touchpoints"
- **Data lag**: "Social media analytics have a 24-48 hour lag — today's numbers are preliminary"
- **Sample size**: "We only had 200 visitors this week — too small for statistically significant conclusions"
- **Missing data**: "We don't have Google Analytics connected, so website data is unavailable"
- **Correlation vs. causation**: "Open rates improved when we changed the send time, but other factors may have contributed"

### Never
- Present incomplete data as complete
- Make definitive claims from small sample sizes
- Attribute causation from correlation alone
- Compare metrics across different time periods without noting seasonal or contextual differences
- Hide unfavorable metrics in a sea of favorable ones


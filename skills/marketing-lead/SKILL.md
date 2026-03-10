# Marketing Lead Orchestrator

**Role:** Primary orchestrator for all marketing operations. Every marketing task flows through this skill first for classification, context loading, and routing.

**Purpose:** Assess incoming marketing requests, check brand context and recent campaign history, then route to the correct sub-skill. After completion, log results and optimize.

---

## Trigger

This skill activates when:
- The customer requests any marketing-related task
- A scheduled content calendar item needs action
- A performance report is due
- Another AI employee on the team requests marketing support
- A campaign milestone or deadline is approaching

---

## Orchestration Flow

```
INCOMING REQUEST
      |
      v
[1. CONTEXT LOAD]
      |  - Read USER.md for brand voice, audience, key messages
      |  - Search team-memory for recent campaigns and results
      |  - Check content calendar for upcoming items
      |  - Note any active campaigns that need consistency
      |
      v
[2. CLASSIFY TASK TYPE]
      |  - social-media (posts, engagement, scheduling)
      |  - content-drafts (blog, email, ad copy, landing pages)
      |  - analytics (metrics, reports, optimization)
      |  - strategy (planning, calendar, campaign design)
      |
      v
[3. CHECK CONSTRAINTS]
      |  - Does this need approval per AGENTS.md?
      |  - Is this consistent with brand voice?
      |  - Does this conflict with active campaigns?
      |  - Is there a deadline or time sensitivity?
      |
      v
[4. ROUTE TO SUB-SKILL]
      |  - social-media → platform-specific content
      |  - content-drafts → long-form creation
      |  - analytics → data pull and reporting
      |  - (strategy stays with orchestrator)
      |
      v
[5. POST-COMPLETION]
      |  - Present output for approval if required
      |  - Log results in team-memory
      |  - Update content calendar
      |  - Schedule follow-up check on performance
      |
      v
    DONE
```

---

## Step 1: Context Load

Before doing anything, load the marketing context. This prevents off-brand content and redundant work.

```
CONTEXT LOAD CHECKLIST:
[ ] Read USER.md: brand voice, target audience, key messages, competitors
[ ] Search team-memory: "recent campaigns", "content performance", "brand guidelines"
[ ] Check: Are there active campaigns running? (don't create conflicting content)
[ ] Check: Is there a content calendar? What's coming up next?
[ ] Check: What was the last thing we published? (avoid repetition)
[ ] Check: Are there any seasonal or time-sensitive opportunities?
```

If USER.md has empty brand voice or target audience sections, trigger the onboarding flow from clawtrust-core. Do NOT create content without knowing the brand voice.

---

## Step 2: Classification Decision Tree

```
What is the customer asking for?
│
├── CONTENT FOR A SPECIFIC PLATFORM (social media post, tweet, LinkedIn article)
│   └── Route → social-media
│
├── CONTENT CREATION (blog, newsletter, email campaign, ad copy, landing page)
│   ├── Is it for email distribution?
│   │   └── Route → content-drafts (type: email)
│   ├── Is it for the blog or website?
│   │   └── Route → content-drafts (type: blog)
│   ├── Is it ad copy?
│   │   └── Route → content-drafts (type: ad)
│   └── General content request
│       └── Route → content-drafts (type: general)
│
├── DATA OR PERFORMANCE QUESTION ("how did X perform?", "what are our metrics?")
│   └── Route → analytics
│
├── STRATEGY REQUEST ("what should we post?", "plan our Q2 campaign", "content calendar")
│   └── Handle in orchestrator (see Strategy Handling below)
│
├── MULTI-PART REQUEST (campaign = strategy + content + analytics)
│   └── Break into components, route each separately, coordinate results
│
└── UNCLEAR
    └── Ask ONE clarifying question, then re-classify
```

---

## Step 3: Constraint Check

Before routing, verify the task is safe to proceed.

### Brand Consistency Check
- Does the requested content align with the brand voice in USER.md?
- If the customer asks for something off-brand (e.g., aggressive sales copy when the brand is "warm and educational"), flag it: "I want to make sure this fits your brand — your voice is [X]. Want me to adapt the request, or is this intentionally different?"

### Authority Check (AGENTS.md)
- Will this task result in content being published? → NEEDS APPROVAL
- Will this involve paid ad spend? → NEEDS APPROVAL
- Will this require external email sends? → NEEDS APPROVAL
- Is this just a draft or internal analysis? → CAN DO autonomously

### Campaign Conflict Check
- Search team-memory for active campaigns
- If the new request contradicts or competes with an active campaign, flag it: "We have a [campaign name] running right now. This new content could [conflict/complement]. How should I handle it?"

### Deadline Assessment
- Is there a hard deadline? (event, launch, seasonal window)
- If yes, note it and prioritize accordingly
- If the deadline is too tight for quality work, say so: "I can have a draft ready by [time], but I'd recommend [more time] for revisions and testing."

---

## Step 4: Routing

### Route to `social-media`
- Any request for social media content (posts, replies, engagement)
- Platform-specific formatting and optimization
- Posting schedule recommendations

### Route to `content-drafts`
- Blog posts, articles, whitepapers, case studies
- Email newsletters and campaign emails
- Ad copy (search, social, display)
- Landing page text, product descriptions
- Any long-form or structured content

### Route to `analytics`
- Performance reports (campaign, channel, overall)
- Metric analysis and trend identification
- ROI calculations and budget optimization
- Audience insight reports

### Strategy (Handle in Orchestrator)
Strategy requests stay in the orchestrator because they often span multiple sub-skills.

**Content Calendar Creation:**
1. Review business goals and upcoming events
2. Identify content themes by month/quarter
3. Map themes to platforms and content types
4. Set publishing frequency per channel
5. Present calendar for approval

**Campaign Planning:**
1. Define campaign goal, audience, and success metrics
2. Identify channels and content types needed
3. Create timeline with milestones
4. Draft key messages and creative direction
5. Set budget recommendations (if paid)
6. Present plan for approval

**Competitive Analysis:**
1. Review competitor content across relevant platforms
2. Identify gaps and opportunities
3. Note what's working for them (and what isn't)
4. Recommend differentiation strategy
5. Store findings in team-memory

---

## Step 5: Post-Completion Protocol

After every completed marketing task, run this checklist:

```
POST-COMPLETION CHECKLIST:
[ ] Output quality: Does it meet the brand voice and quality standards?
[ ] Approval needed: If yes, present to customer with context and rationale
[ ] Content calendar: Update with what was created/published
[ ] Team-memory: Store what was created, why, and initial performance expectations
[ ] Follow-up: Set a reminder to check performance in 24-48 hours (if published)
[ ] Learning: Was this faster/slower than expected? What would I do differently?
```

### Performance Follow-Up

For every piece of published content, check performance after these intervals:
- **24 hours**: Initial engagement (opens, clicks, views, likes)
- **72 hours**: Extended engagement (shares, comments, saves)
- **1 week**: Conversion impact (if trackable)
- **1 month**: Long-tail performance (SEO rankings, evergreen engagement)

Store performance data in team-memory with tags `[content-type]-performance` for future optimization.

---

## Multi-Part Campaign Coordination

Large campaigns involve multiple sub-skills working in sequence. The orchestrator coordinates.

```
CAMPAIGN FLOW:
1. Strategy (orchestrator) → define goals, audience, channels, timeline
2. Content Drafts → create email, blog, landing page content
3. Social Media → create platform-specific promotional posts
4. Analytics → set up tracking and baseline metrics
5. APPROVAL GATE → customer reviews everything
6. Publish (with approval) → execute across channels
7. Analytics → monitor, report, optimize
```

For each step, the orchestrator:
- Provides the sub-skill with campaign context (brief, brand voice, audience, goals)
- Reviews the sub-skill output for consistency with the overall campaign
- Ensures all pieces tell the same story across channels (consistent messaging, CTAs, visuals)

---

## Channel Priority Matrix

When the customer says "promote this" without specifying channels, use this default priority:

| Priority | Channel | Why |
|----------|---------|-----|
| 1 | Email (if list exists) | Highest conversion rate, owned audience |
| 2 | LinkedIn (if B2B) | Professional audience, high engagement for business content |
| 3 | Twitter/X | Broad reach, real-time engagement, easy to produce |
| 4 | Blog/Website | SEO value, evergreen content, authority building |
| 5 | Instagram | Visual brands, consumer-facing, community building |
| 6 | Facebook | Community groups, local business, event promotion |

Adjust based on USER.md SOCIAL_PLATFORMS and TARGET_AUDIENCE.

---

## Metrics to Track

Store in team-memory periodically for reporting:

- **Content output**: Pieces created per week by type
- **Approval turnaround**: Time between draft and approval
- **Publishing cadence**: Actual vs planned posting frequency
- **Engagement rate**: By platform and content type
- **Email performance**: Open rate, click rate, unsubscribe rate trends
- **Top performers**: Best performing content pieces (update monthly)
- **Audience growth**: Follower/subscriber change per platform
- **Content ROI**: Revenue attributed to marketing content (when trackable)


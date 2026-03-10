# Infrastructure Monitoring Sub-Skill

> Activated by the Platform Engineer orchestrator when a task involves health checks, log analysis, alerting, dashboards, capacity planning, or incident detection. You are the eyes of the operation — if you can't see it, you can't fix it.

---

## Trigger

Routed here by the Platform Engineer orchestrator for tasks involving:
- System health assessment (CPU, memory, disk, network)
- Log analysis and error pattern detection
- Alert configuration and tuning
- Dashboard creation and metric selection
- Capacity planning and trend analysis
- Incident detection and initial triage
- Uptime monitoring and SLA tracking

---

## Health Check Assessment

When asked to evaluate system health:

### System Health Checklist

Run through these checks in order. Report findings with severity ratings.

#### Compute Resources
- [ ] **CPU utilization:** Average below 70%? Sustained spikes above 90%? Which processes are consuming most CPU?
- [ ] **Memory utilization:** Average below 80%? Any memory leaks (steadily increasing over time)? Is swap being used?
- [ ] **Disk utilization:** Below 80%? Growth rate — when will it hit 90%? Are old logs, temp files, or artifacts accumulating?
- [ ] **Disk I/O:** Any I/O wait above 20%? Are there disk-intensive operations competing with the application?

#### Application Health
- [ ] **Process status:** Is the application process running? Has it restarted recently (crash loops)?
- [ ] **Response time:** Is the application responding within normal latency? What are p50, p95, p99?
- [ ] **Error rate:** What percentage of requests return 4xx or 5xx? Is the error rate increasing?
- [ ] **Throughput:** Are requests per second within normal range? Any sudden drops (outage) or spikes (attack/viral)?

#### Database Health
- [ ] **Connection pool:** How many connections are in use vs available? Any connection timeouts?
- [ ] **Query performance:** Are there slow queries (> 1 second)? Missing indexes?
- [ ] **Replication lag:** If replicas exist, is replication current?
- [ ] **Storage:** Database disk usage and growth rate?

#### Network
- [ ] **Latency:** Is network latency between services normal? Any packet loss?
- [ ] **DNS resolution:** Are DNS lookups fast and consistent?
- [ ] **TLS certificates:** When do certificates expire? Any certificate errors?
- [ ] **External dependencies:** Are third-party APIs responding normally?

### Health Report Template

```
## System Health Report: [Date]

### Overall Status: [Healthy / Degraded / Critical]

### Resource Summary
| Resource | Current | Threshold | Status |
|----------|---------|-----------|--------|
| CPU | XX% avg | 70% warn / 90% crit | [OK/WARN/CRIT] |
| Memory | XX% avg | 80% warn / 95% crit | [OK/WARN/CRIT] |
| Disk | XX% used | 80% warn / 90% crit | [OK/WARN/CRIT] |
| Connections | XX/XX | 80% warn / 95% crit | [OK/WARN/CRIT] |

### Issues Found
1. **[Issue]** — Severity: [P0-P3]
   - Current state: [metric value]
   - Threshold: [what it should be]
   - Trend: [stable / increasing / decreasing]
   - Recommendation: [specific action]

### Trending Concerns
- [Resource] is growing at [rate]. At current rate, will hit threshold by [date].

### Next Review: [recommended date]
```

---

## Log Analysis and Error Pattern Detection

When investigating errors or anomalies in logs:

### Log Investigation Process

1. **Define the search window:** When did the problem start? Check for changes (deploys, config updates, traffic spikes) around that time.
2. **Filter by severity:** Start with ERROR and FATAL, then check WARN if error logs are insufficient.
3. **Identify patterns:**
   - Are errors coming from one service or multiple?
   - Is there a common request path, user, or input that triggers the error?
   - Are errors correlated with specific times (cron jobs, traffic spikes)?
   - Is the error rate constant or increasing?
4. **Trace to root cause:**
   - Stack traces → which function, which line?
   - Error codes → what do they mean in context?
   - Upstream/downstream → is the error originating here or propagating from another service?
5. **Check for known issues:** Search team-memory for similar error patterns.

### Common Error Patterns

| Pattern | Likely Cause | Investigation Steps |
|---------|-------------|-------------------|
| Sudden spike in 500 errors | Bad deploy, dependency failure, or resource exhaustion | Check recent deploys, external service status, resource metrics |
| Gradual increase in error rate | Memory leak, disk filling up, connection pool exhaustion | Check resource trends over 24-72 hours |
| Periodic error bursts | Cron job failure, scheduled task conflict, rate limiting | Check timing against cron schedule and traffic patterns |
| Errors from one specific endpoint | Code bug, missing validation, unhandled edge case | Check recent changes to that endpoint's code |
| Timeout errors | Slow database query, external API latency, undersized instance | Check database query logs, external service latency, resource usage |
| Authentication errors | Expired credentials, rotated secrets, misconfigured auth | Check credential expiration, recent secret rotations, auth service status |
| Connection refused | Service down, port misconfigured, firewall blocking | Check service status, port bindings, firewall rules |

---

## Alert Configuration and Tuning

When setting up or tuning alerts:

### Alert Design Principles

1. **Every alert must be actionable.** If the on-call person can't do anything about it, it shouldn't be an alert.
2. **Alert on symptoms, not causes.** Alert on "error rate > 5%" not "CPU > 80%" (high CPU isn't always a problem).
3. **Use appropriate thresholds.** Too sensitive = alert fatigue. Too relaxed = missed incidents.
4. **Include context in alerts.** The alert message should tell you what's wrong, how bad it is, and where to start investigating.
5. **Group related alerts.** If a database outage triggers 10 different alerts, group them into one incident.

### Alert Priority Guide

| Priority | Criteria | Notification | Response Time | Examples |
|----------|----------|-------------|---------------|---------|
| **P0 — Critical** | Service down or data at risk | Phone call + SMS + Slack + email | < 5 minutes | Full outage, database corruption, security breach, data loss |
| **P1 — High** | Significant degradation, users impacted | SMS + Slack + email | < 30 minutes | Error rate > 5%, p95 latency > 5x normal, disk > 90% |
| **P2 — Medium** | Minor degradation, approaching limits | Slack + email | < 4 hours | Error rate > 1%, memory > 80%, cert expiring in 7 days |
| **P3 — Low** | Informational, no immediate impact | Slack only (during business hours) | Next business day | Dependency deprecation, minor version drift, cost anomaly |

### Recommended Alert Set (Minimum Viable Monitoring)

Every production service should have at least these alerts:

```
1. Uptime check (external ping every 1 minute)
   - Alert if down for > 2 consecutive checks
   - Priority: P0

2. Error rate
   - Alert if > 1% for 5 minutes (P2)
   - Alert if > 5% for 2 minutes (P1)
   - Alert if > 25% for 1 minute (P0)

3. Response latency (p95)
   - Alert if > 2x baseline for 5 minutes (P2)
   - Alert if > 5x baseline for 2 minutes (P1)

4. Disk usage
   - Alert if > 80% (P2)
   - Alert if > 90% (P1)
   - Alert if > 95% (P0)

5. Memory usage
   - Alert if > 80% sustained for 10 minutes (P2)
   - Alert if > 95% for 2 minutes (P1)

6. SSL certificate expiry
   - Alert if expiring within 30 days (P3)
   - Alert if expiring within 7 days (P2)
   - Alert if expiring within 24 hours (P0)

7. Backup success
   - Alert if last backup > 24 hours old (P1)
   - Alert if backup failed (P1)
```

### Alert Tuning Process

When alerts are too noisy:

1. **Measure alert frequency:** How many alerts per day/week? How many are actionable?
2. **Identify false positives:** Which alerts fire but don't require action?
3. **Adjust thresholds:** Raise thresholds on false-positive alerts, but document why
4. **Add conditions:** Require sustained duration (e.g., CPU > 80% for 10 minutes, not just 1 spike)
5. **Correlate alerts:** If alert A always fires with alert B, suppress A and investigate B
6. **Review monthly:** Alert tuning is ongoing, not one-time

---

## Dashboard Creation and Metric Selection

When building monitoring dashboards:

### Dashboard Design Principles

1. **One dashboard per concern.** Don't cram everything onto one screen. Separate: system overview, application performance, business metrics.
2. **Top-level = health.** The first thing visible should answer: "Is everything working?"
3. **Drill-down available.** From the overview, you should be able to click into details for any service.
4. **Time range matters.** Default to last 1 hour for incident investigation, last 24 hours for daily review, last 30 days for trend analysis.
5. **Include annotations.** Mark deployments, incidents, and configuration changes on time-series graphs.

### Essential Dashboard Panels

**System Overview Dashboard:**
- Service health matrix (green/yellow/red for each service)
- Request rate (total and per service)
- Error rate (total and per service)
- p50, p95, p99 latency
- Active alerts count by severity
- Recent deployments timeline

**Infrastructure Dashboard:**
- CPU utilization per host
- Memory utilization per host
- Disk usage and I/O per host
- Network traffic (in/out)
- Container/process count and restarts
- Database connection pool usage

**Application Dashboard:**
- Request rate by endpoint
- Error rate by endpoint
- Latency distribution by endpoint
- Cache hit rate
- Queue depth and processing rate
- External dependency latency

---

## Capacity Planning

When projecting future resource needs:

### Capacity Planning Process

1. **Baseline current usage:** Collect 30 days of metrics for CPU, memory, disk, network, connections.
2. **Identify peak patterns:** Daily peaks, weekly patterns, monthly cycles, seasonal trends.
3. **Determine growth rate:** Are resources growing linearly, exponentially, or in steps?
4. **Project to thresholds:** At current growth, when will each resource hit 80%? 90%?
5. **Identify the bottleneck:** Which resource will constrain first?
6. **Recommend scaling plan:** What to scale, when, how much, and the cost impact.

### Capacity Report Template

```
## Capacity Planning Report: [Date]

### Current Utilization (30-day average)
| Resource | Average | Peak | Headroom | Projected Exhaustion |
|----------|---------|------|----------|---------------------|
| CPU | XX% | XX% | XX% | [date or "N/A"] |
| Memory | XX GB | XX GB | XX GB | [date or "N/A"] |
| Disk | XX GB | XX GB | XX GB | [date or "N/A"] |
| DB Connections | XX | XX | XX | [date or "N/A"] |

### Growth Trends
- Traffic growth rate: [X%/month]
- Data growth rate: [X GB/month]
- User growth rate: [X users/month]

### Bottleneck Analysis
The first resource to be exhausted will be [resource] at current growth rates,
projected to hit the warning threshold by [date].

### Recommendations
1. [Scaling action] — Before: [date] — Cost: $[amount]/mo
2. [Optimization action] — Could delay scaling by [N months]

### Next Review: [date — recommend monthly for growing services]
```

---

## Incident Detection and Initial Triage

When anomalies are detected or reported:

### Triage Checklist

When something looks wrong, run through this in order:

1. **Confirm the problem is real.** Is it a monitoring false positive? Check from multiple vantage points.
2. **Assess the impact.** Who is affected? How many users? Which features? Is there a workaround?
3. **Determine severity** using the alert priority guide above.
4. **Check for obvious causes:**
   - Recent deployment? (Check deploy history)
   - Recent configuration change? (Check audit logs)
   - External dependency outage? (Check status pages)
   - Resource exhaustion? (Check CPU, memory, disk, connections)
   - Traffic anomaly? (Check request rate for spikes or drops)
5. **Communicate initial findings.** Tell the team what you know, what you don't, and what you're investigating next.
6. **Escalate if needed.** If you can't identify the cause within 15 minutes for P0 or 30 minutes for P1, escalate.


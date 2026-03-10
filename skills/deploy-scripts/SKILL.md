# Deploy Scripts Sub-Skill

> Activated by the Platform Engineer orchestrator when a task involves CI/CD pipelines, deployment processes, release management, rollback procedures, or environment management. You are the guardian of the deployment pipeline — you make shipping safe, fast, and boring.

---

## Trigger

Routed here by the Platform Engineer orchestrator for tasks involving:
- Reviewing deployment scripts and CI/CD pipelines
- Suggesting improvements for deployment safety
- Pre-deployment checklist validation
- Post-deployment verification
- Rollback planning and procedures
- Environment parity checks
- Release management and versioning

---

## Deployment Script Review

When reviewing deployment scripts or CI/CD pipelines:

### Pipeline Review Checklist

#### Build Stage
- [ ] **Dependency installation:** Are dependencies pinned (lockfile committed)? Is the install step deterministic?
- [ ] **Compilation:** Does the build step fail fast on errors? Are TypeScript/compiler errors caught?
- [ ] **Lint and format:** Are code style checks running before tests? Do they block the pipeline on failure?
- [ ] **Environment variables:** Are build-time env vars documented? Are secrets injected securely (not hardcoded)?

#### Test Stage
- [ ] **Test execution:** Do tests run in CI? What's the coverage? Do failing tests block the deploy?
- [ ] **Test isolation:** Do tests use their own database/state? No shared state between test runs?
- [ ] **Test speed:** How long does the test suite take? Is it parallelized where possible?
- [ ] **Flaky tests:** Are there known flaky tests? Are they quarantined or fixed?

#### Deploy Stage
- [ ] **Target environment:** Is the deploy target explicit (not ambiguous or defaulting to production)?
- [ ] **Atomic deployment:** Does the deploy swap all-at-once, or can it leave the system in a partial state?
- [ ] **Health check:** Does the pipeline verify the new version is healthy after deploy?
- [ ] **Rollback capability:** Can the pipeline roll back automatically if the health check fails?
- [ ] **Notifications:** Does the pipeline notify the team on success and failure?
- [ ] **Concurrency:** Is there protection against two deploys running simultaneously?

#### Security
- [ ] **Secret handling:** Are secrets injected at runtime, not baked into artifacts? No secrets in build logs?
- [ ] **Artifact integrity:** Are build artifacts signed or checksummed? Are container images from trusted registries?
- [ ] **Permissions:** Does the CI/CD service account have minimum necessary permissions?
- [ ] **Audit trail:** Is there a log of who triggered each deploy, when, and what was deployed?

### Common Pipeline Anti-Patterns

| Pattern | Risk | Fix |
|---------|------|-----|
| No lockfile committed | Non-deterministic builds, different deps in CI vs local | Always commit `package-lock.json`, `yarn.lock`, or equivalent |
| Tests skipped for speed | Bugs reach production | Run tests in parallel, use test splitting, never skip |
| Manual steps between CI stages | Human error, steps forgotten, not reproducible | Automate the full pipeline end-to-end |
| Secrets in environment variables that are logged | Credentials exposed in CI logs | Use secret masking, dedicated secret stores, never `echo $SECRET` |
| Deploy on every merge to main | No gate between merge and production | Add a staging deploy + approval step, or use feature flags |
| No post-deploy health check | Broken deploys go unnoticed until users report | Add automated health check that triggers rollback on failure |
| Single pipeline for all environments | Dev deploy failure blocks production hotfix | Separate pipelines per environment with shared build step |

---

## Deployment Strategy Recommendations

When suggesting improvements to the deploy process:

### Strategy Comparison

| Strategy | Complexity | Rollback Speed | Risk | Best For |
|----------|-----------|---------------|------|----------|
| **Direct deploy** | Low | Slow (redeploy previous version) | High (all users see new version immediately) | Simple apps, low traffic, dev/staging |
| **Blue-green** | Medium | Fast (switch back to blue) | Low (instant rollback to known-good) | Stateless apps, APIs, web apps |
| **Canary** | High | Fast (route 100% back to old version) | Very low (only % of users see new version) | High-traffic apps, critical paths |
| **Rolling update** | Medium | Medium (roll back in reverse) | Medium (gradual exposure) | Container orchestrators (K8s), multi-instance apps |
| **Feature flags** | Medium | Instant (toggle flag off) | Very low (code deployed but not active) | Any app, especially for A/B testing and gradual rollout |

### Strategy Recommendation Framework

1. **How critical is the service?** Mission-critical = canary or blue-green. Internal tools = direct deploy is fine.
2. **How fast do you need to roll back?** Seconds = blue-green or feature flags. Minutes = rolling update. Hours = you have a problem.
3. **How confident are you in testing?** High confidence = simpler strategy. Low confidence = canary with health checks.
4. **What's the team's experience?** Start simple (direct deploy with health checks), add complexity as maturity grows.

---

## Pre-Deployment Checklist

Present this checklist to the customer before any production deployment:

### Pre-Deploy Validation

```
## Pre-Deployment Checklist: [Service Name] v[Version]

### Code Readiness
- [ ] All tests pass in CI (unit, integration, e2e)
- [ ] Code reviewed and approved by at least one other person
- [ ] No known critical bugs in this release
- [ ] Database migrations tested in staging (if applicable)
- [ ] Feature flags configured for gradual rollout (if applicable)

### Environment Readiness
- [ ] Staging deploy succeeded and was verified
- [ ] Environment variables are set correctly in production
- [ ] Secrets are current (not expired or rotated since last deploy)
- [ ] Sufficient resource headroom (CPU, memory, disk) for the deploy process

### Rollback Readiness
- [ ] Previous version identified and deployable: v[previous version]
- [ ] Rollback procedure documented and tested
- [ ] Database migration is backward-compatible (if applicable)
- [ ] Estimated rollback time: [X minutes]

### Communication
- [ ] Team notified of upcoming deployment
- [ ] Monitoring dashboards open and baseline metrics noted
- [ ] On-call person identified and available
- [ ] Customer-facing status page updated (if applicable)

### Timing
- [ ] Deploy window is NOT during peak traffic hours
- [ ] Deploy window is NOT on Friday after 3 PM
- [ ] No conflicting deployments or maintenance windows
- [ ] At least [X hours] before end of business for observation

### Go/No-Go
- [ ] All items above checked
- [ ] Deployment authorized by: [name]
- [ ] Deploy initiated at: [timestamp]
```

---

## Post-Deployment Verification

After a deployment completes, verify it succeeded:

### Post-Deploy Checklist

```
## Post-Deployment Verification: [Service Name] v[Version]

### Immediate Checks (within 5 minutes)
- [ ] Health endpoint returns 200 OK
- [ ] Application version reported matches expected version
- [ ] No new errors in application logs
- [ ] No spike in error rate on monitoring dashboard
- [ ] Response latency is within normal range

### Short-Term Checks (within 30 minutes)
- [ ] Error rate has not increased compared to pre-deploy baseline
- [ ] No increase in p95/p99 latency
- [ ] Database connection pool is healthy
- [ ] External integrations are functioning (payment, email, auth)
- [ ] No new entries in error tracking system

### Extended Checks (within 2 hours)
- [ ] Memory usage is stable (no memory leak from new code)
- [ ] CPU usage is within expected range
- [ ] No customer reports of issues
- [ ] All background jobs and cron tasks executing normally
- [ ] Cache hit rates are normal

### Verdict
- [ ] **PASS:** All checks pass. Deploy confirmed successful.
- [ ] **INVESTIGATE:** Some anomalies detected. Continue monitoring.
- [ ] **ROLLBACK:** Critical issue detected. Initiate rollback procedure.
```

---

## Rollback Planning and Procedures

Every deployment needs a rollback plan. Here's how to create one:

### Rollback Plan Template

```
## Rollback Plan: [Service Name] v[Version] → v[Previous Version]

### Trigger Conditions
Roll back if ANY of the following occur within 2 hours of deploy:
- Error rate exceeds [X]% (baseline: [Y]%)
- p95 latency exceeds [X]ms (baseline: [Y]ms)
- Health check fails for more than 2 consecutive minutes
- Critical functionality is broken (list specific checks)

### Rollback Procedure
1. [Step 1 — e.g., "Run: vercel rollback --to=DEPLOYMENT_ID"]
2. [Step 2 — e.g., "Verify health endpoint returns 200"]
3. [Step 3 — e.g., "Check error rate returns to baseline within 5 minutes"]
4. [Step 4 — e.g., "Notify team in #deploys channel"]

### Database Rollback (if applicable)
- Migration is backward-compatible: [Yes/No]
- If No: Run migration rollback command: [specific command]
- Estimated data impact: [description]

### Estimated Rollback Time
- Time to initiate: [X minutes]
- Time to complete: [X minutes]
- Time to verify: [X minutes]
- Total: [X minutes]

### Post-Rollback
- [ ] Verify system health
- [ ] Notify team of rollback
- [ ] Create incident report
- [ ] Schedule investigation of root cause
```

---

## Environment Parity Checks

When auditing consistency between environments:

### Environment Comparison Checklist

| Dimension | Dev | Staging | Production | Match? |
|-----------|-----|---------|------------|--------|
| **Runtime version** | | | | |
| **Framework version** | | | | |
| **Database version** | | | | |
| **OS / container base** | | | | |
| **Environment variables** | | | | |
| **External services** | | | | |
| **Instance size** | | | | |
| **Network config** | | | | |

### Parity Violations to Flag

- **Different runtime versions:** Can cause bugs that only appear in production
- **Missing env vars in staging:** Features work in dev but crash in staging/prod
- **Different database engines:** SQLite in dev, PostgreSQL in prod = query behavior differences
- **Mocked services in staging:** Hides integration bugs until production
- **Different instance sizes:** Performance issues invisible until production load

### Parity Maintenance Rules

1. Infrastructure-as-code for all environments with parameterized differences (instance size, replicas) but same architecture
2. Same Docker base images across all environments
3. Environment variable lists are synced — staging has every key production has (values may differ)
4. Database schema is identical across environments (migration state is current everywhere)
5. Review parity quarterly or after any infrastructure change

---

## DORA Metrics Assessment

When measuring deployment performance:

### Four Key Metrics

| Metric | Elite | High | Medium | Low |
|--------|-------|------|--------|-----|
| **Deployment frequency** | Multiple per day | Weekly to monthly | Monthly to semi-annually | Less than semi-annually |
| **Lead time for changes** | Less than 1 hour | 1 day to 1 week | 1 week to 1 month | More than 1 month |
| **Change failure rate** | 0-15% | 16-30% | 31-45% | 46-100% |
| **Mean time to recovery** | Less than 1 hour | Less than 1 day | 1 day to 1 week | More than 1 week |

### Improvement Recommendations by Current Level

**Low to Medium:**
- Automate builds and tests (CI)
- Add staging environment
- Implement basic health checks
- Write deployment runbook

**Medium to High:**
- Automate deployments (CD)
- Add post-deploy health checks with auto-rollback
- Implement feature flags
- Reduce test suite runtime

**High to Elite:**
- Implement trunk-based development
- Canary deployments
- Automated rollback on degradation
- Deploy on merge with confidence


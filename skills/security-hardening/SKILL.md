# Security Hardening Sub-Skill

> Activated by the Platform Engineer orchestrator when a task involves vulnerability management, access control, secret management, network security, compliance, or security incident investigation. Security is not a feature — it's the foundation everything else stands on.

---

## Trigger

Routed here by the Platform Engineer orchestrator for tasks involving:
- Dependency vulnerability scanning and remediation
- Access control review and least privilege enforcement
- Secret management audit and rotation planning
- Network security review (firewalls, ports, TLS)
- Compliance checks (SOC 2, GDPR, HIPAA)
- Security incident investigation
- Security policy documentation

---

## Dependency Vulnerability Scanning

When scanning or triaging dependency vulnerabilities:

### Scanning Process

1. **Run the scanner** appropriate to the stack:
   - Node.js: `npm audit` or `npx snyk test`
   - Python: `pip audit` or `safety check`
   - Go: `govulncheck ./...`
   - Ruby: `bundle audit`
   - General: Snyk, Dependabot, or Renovate
2. **Categorize findings by severity:**
   - Critical: Remote code execution, authentication bypass, SQL injection
   - High: Privilege escalation, information disclosure, denial of service
   - Medium: Cross-site scripting, session fixation, open redirect
   - Low: Information leakage through error messages, minor configuration issues
3. **Assess exploitability in context:**
   - Is the vulnerable code path actually reachable in your application?
   - Is the vulnerability in a dev dependency only (lower risk)?
   - Does your application configuration mitigate the vulnerability?
4. **Recommend remediation** for each finding.

### Vulnerability Remediation Priority

| Severity | Response Time | Action |
|----------|-------------|--------|
| **Critical** | Same day | Update immediately. If no patch exists, implement mitigation or disable the feature. |
| **High** | Within 1 week | Update at next deployment. If blocked, document the mitigation. |
| **Medium** | Within 1 month | Schedule for next maintenance cycle. |
| **Low** | Within 1 quarter | Address during routine dependency updates. |

### Vulnerability Report Template

```
## Dependency Vulnerability Report: [Date]

### Summary
- Total vulnerabilities found: [N]
- Critical: [N] | High: [N] | Medium: [N] | Low: [N]
- Dependencies scanned: [N]
- Scanner used: [tool and version]

### Critical and High Findings

#### [CVE-XXXX-XXXXX]: [Package Name] v[version]
- **Severity:** [Critical/High]
- **Type:** [RCE/Auth Bypass/SQLi/XSS/etc.]
- **Description:** [One-line description of the vulnerability]
- **Exploitability:** [Is this reachable in our application? Yes/No/Unclear]
- **Fix available:** [Yes — upgrade to vX.Y.Z / No — mitigation needed]
- **Recommended action:** [Specific step]

### Medium and Low Findings
[Grouped summary — individual detail only if actionable]

### Recommendations
1. [Immediate actions for critical/high]
2. [Scheduled actions for medium]
3. [Process improvements — e.g., enable Dependabot, add npm audit to CI]

### Next Scan: [recommended date]
```

---

## Access Control Review

When auditing access controls and permissions:

### Access Control Audit Checklist

#### User Access
- [ ] **Inventory all users** with access to production systems (cloud console, servers, databases, CI/CD)
- [ ] **Verify each user still needs access** (anyone who left the company? Changed roles?)
- [ ] **Check for shared accounts** (shared root/admin accounts are a red flag)
- [ ] **MFA enabled** for all human accounts with production access
- [ ] **SSO configured** for cloud providers and critical services (if available)

#### Service Account Access
- [ ] **Inventory all service accounts** and API keys with production access
- [ ] **Verify least privilege:** Does each service account have only the permissions it needs?
- [ ] **Check for over-privileged service accounts** (admin access that should be scoped)
- [ ] **Review key age:** Are any API keys or access tokens older than 90 days?
- [ ] **Check for unused service accounts:** Any accounts that haven't been used in 90+ days?

#### Database Access
- [ ] **Application connects with a dedicated, limited-privilege database user** (not root/admin)
- [ ] **Direct database access** (SSH tunnel, VPN) is restricted to named individuals
- [ ] **Read replicas** use read-only credentials
- [ ] **Backup access** is restricted (backups contain all the data)

#### Repository Access
- [ ] **Branch protection** on main/master (require PR review, pass CI checks)
- [ ] **No direct push** to production branches
- [ ] **Repository visibility** is correct (private repos are private)
- [ ] **Deploy keys** are scoped to specific repositories

### Least Privilege Remediation

When you find over-privileged access:

1. **Document what the current permissions are** and what they should be
2. **Propose the reduced permission set** with a clear explanation of what's being removed and why
3. **Plan the change** — test with reduced permissions in staging first
4. **Execute with customer approval** — never reduce access without confirming it won't break workflows
5. **Verify nothing broke** after the change

---

## Secret Management Audit

When reviewing how secrets are stored, accessed, and rotated:

### Secret Management Checklist

#### Storage
- [ ] **No secrets in code:** Grep codebase for common patterns (API keys, passwords, tokens). Check `.env` files aren't committed.
- [ ] **No secrets in CI/CD logs:** Review pipeline logs for accidentally printed secrets. Enable log masking.
- [ ] **No secrets in chat history:** Remind team never to paste secrets in Slack, email, or tickets.
- [ ] **Encrypted at rest:** Secrets stored in a dedicated secret manager (AWS Secrets Manager, Vault, Vercel env vars) with encryption.
- [ ] **Not in docker images:** Secrets injected at runtime, not baked into container images.

#### Access
- [ ] **Secret access is audited:** There's a log of who accessed which secret and when.
- [ ] **Access is scoped:** Each service can only access the secrets it needs.
- [ ] **No wildcard access:** No service account has `*` access to all secrets.

#### Rotation
- [ ] **Rotation schedule exists:** Each secret has a defined rotation frequency.
- [ ] **Rotation is automated** where possible (database passwords, API keys with provider support).
- [ ] **Rotation is tested:** The rotation process has been tested and documented.
- [ ] **Old secrets are revoked:** After rotation, the old secret is deactivated, not just unused.

### Secret Rotation Schedule

| Secret Type | Recommended Frequency | Notes |
|------------|----------------------|-------|
| Database passwords | 90 days | Coordinate with connection pool restart |
| API keys (third-party) | 90 days | Check provider docs for rotation support |
| JWT signing keys | 180 days | Overlap old and new keys during rotation for active sessions |
| TLS certificates | Before expiry (use auto-renew via Let's Encrypt or provider) | Monitor with 30-day warning alert |
| SSH keys | 180 days | Remove old keys from all authorized_keys |
| OAuth client secrets | 180 days | Update in all consuming services simultaneously |
| Encryption keys (data at rest) | 365 days | Re-encrypt data with new key; keep old key for decryption of old data |

---

## Network Security Review

When auditing network security:

### Network Security Checklist

#### TLS/SSL
- [ ] **TLS 1.2 or higher** enforced on all public endpoints (TLS 1.0 and 1.1 disabled)
- [ ] **Strong cipher suites** configured (no RC4, no DES, no MD5)
- [ ] **HSTS header** set with reasonable max-age (at least 1 year: `max-age=31536000`)
- [ ] **Certificate valid** and not expiring within 30 days
- [ ] **Certificate chain complete** (intermediate certificates included)
- [ ] **HTTP to HTTPS redirect** configured for all public endpoints

#### Firewall and Network
- [ ] **Default deny:** Firewall rules deny all traffic by default, explicitly allow what's needed
- [ ] **No unnecessary exposed ports:** Only ports 80 (redirect to 443) and 443 should be public for web apps
- [ ] **Database not publicly accessible:** Database ports (5432, 3306, 27017) are restricted to application servers
- [ ] **SSH access restricted:** SSH (port 22) limited to specific IP ranges or accessed via VPN/bastion
- [ ] **Internal services not exposed:** Admin panels, monitoring dashboards, debug endpoints are not publicly accessible

#### Application Security Headers
- [ ] **Content-Security-Policy** configured and restrictive
- [ ] **X-Content-Type-Options: nosniff** set
- [ ] **X-Frame-Options: DENY** (or SAMEORIGIN if iframes are needed)
- [ ] **Referrer-Policy:** `strict-origin-when-cross-origin` or stricter
- [ ] **Permissions-Policy:** Restrict browser features (camera, microphone, geolocation) unless needed

#### DNS
- [ ] **CAA records** set to restrict which CAs can issue certificates for your domains
- [ ] **SPF, DKIM, DMARC** configured for email-sending domains
- [ ] **No dangling CNAME records** pointing to decommissioned services (subdomain takeover risk)

---

## Compliance Checks

When assessing compliance readiness:

### SOC 2 Quick Assessment

| Control Area | Key Questions | Status |
|-------------|--------------|--------|
| **Access Control** | MFA on all accounts? Least privilege enforced? Access reviews quarterly? | |
| **Change Management** | Code review required? Deployment approvals? Change logs maintained? | |
| **Incident Response** | Incident response plan documented? Tested annually? Post-mortems conducted? | |
| **Logging and Monitoring** | Security events logged? Logs retained 1+ year? Alert on suspicious activity? | |
| **Data Protection** | Encryption at rest and in transit? Backup and recovery tested? Data classification defined? | |
| **Vendor Management** | Third-party risk assessments? Vendor access reviewed? SLAs defined? | |
| **Risk Assessment** | Annual risk assessment conducted? Risk register maintained? Risks prioritized? | |

### GDPR Quick Assessment

| Requirement | Key Questions | Status |
|------------|--------------|--------|
| **Lawful Basis** | Is there a documented legal basis for processing personal data? | |
| **Data Inventory** | Do you know what personal data you collect, where it's stored, and who has access? | |
| **Consent** | Is consent collected properly where required? Can users withdraw consent? | |
| **Data Subject Rights** | Can users access, export, correct, and delete their data? | |
| **Data Protection** | Is personal data encrypted? Are access controls appropriate? | |
| **Breach Notification** | Is there a process to detect and report breaches within 72 hours? | |
| **Privacy Policy** | Is the privacy policy current, accurate, and accessible? | |

---

## Security Incident Investigation

When investigating a potential security incident:

### Investigation Process

1. **Contain first, investigate second.** If there's an active breach, stop it before analyzing it.
   - Revoke compromised credentials immediately
   - Isolate affected systems if possible
   - Preserve evidence (don't restart services or clear logs)

2. **Assess scope and impact:**
   - What systems were accessed?
   - What data was potentially exposed?
   - How long was the window of exposure?
   - How many users are affected?

3. **Identify the attack vector:**
   - How did they get in? (Stolen credentials, vulnerability exploit, social engineering, insider)
   - What did they do once in? (Data exfiltration, privilege escalation, persistence mechanisms)
   - Are they still in? (Check for backdoors, new accounts, modified files)

4. **Remediate:**
   - Patch the vulnerability or close the attack vector
   - Rotate all potentially compromised credentials
   - Restore affected systems from known-good state
   - Enhance monitoring for the attack pattern

5. **Report:**
   - Document the incident timeline, impact, and response
   - Notify affected parties (customers, regulators) as required
   - Conduct post-mortem and identify prevention measures

### Security Audit Report Template

```
## Security Audit Report: [Date]

### Scope
- Systems reviewed: [list]
- Audit type: [dependency scan / access review / network audit / full audit]
- Period covered: [date range]

### Executive Summary
[2-3 sentences: overall security posture and top concerns]

### Findings by Severity

#### Critical (Immediate Action Required)
[List with details, exploitability, and remediation]

#### High (Action Within 1 Week)
[List with details and remediation]

#### Medium (Action Within 1 Month)
[List with details and remediation]

#### Low (Backlog)
[List with details and remediation]

### Positive Findings
[What's working well — acknowledge good security practices]

### Recommendations Summary
1. [Top priority action] — Effort: [low/medium/high]
2. [Second priority action] — Effort: [low/medium/high]
3. [Third priority action] — Effort: [low/medium/high]

### Next Audit: [recommended date]
```


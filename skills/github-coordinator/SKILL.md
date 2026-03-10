# GitHub Coordinator

**Purpose:** Coordinate with the development team (Chris via Claude Code) through GitHub. GitHub is the shared workspace where you report issues, track fixes, and stay in sync with what's being built.

**Repo:** `autorevai/clawtrust` (private)

---

## Before Using GitHub

Check that GitHub is connected:

```bash
curl -s -H "Authorization: Bearer $CLAWTRUST_AGENT_TOKEN" \
  "$CLAWTRUST_API_URL/integrations/available"
```

If `github` is not in the response, tell your owner to connect GitHub in the ClawTrust dashboard.

---

## When to Create GitHub Issues

Create a GitHub issue whenever you encounter something that needs a code change. You are the eyes and ears of the product. Examples:

- Customer reports a bug or unexpected behavior
- You discover a feature gap while helping someone
- A customer asks for something the product doesn't support yet
- You notice an error pattern in the system
- A customer provides feedback worth tracking

### Issue Format

```bash
curl -s -H "Authorization: Bearer $CLAWTRUST_AGENT_TOKEN" \
  "$CLAWTRUST_API_URL/integrations/github/action" \
  -X POST -H "Content-Type: application/json" \
  -d '{
    "action": "github_create_an_issue",
    "params": {
      "owner": "autorevai",
      "repo": "clawtrust",
      "title": "[type]: short description",
      "body": "## Source\n\nReported by [customer/agent observation] via [channel].\n\n## Description\n\n[What happened or what is needed]\n\n## Steps to Reproduce (if bug)\n\n1. ...\n2. ...\n\n## Expected vs Actual\n\n- Expected: ...\n- Actual: ...\n\n## Customer Impact\n\n[How many customers affected, severity, workaround if any]",
      "labels": ["from-agent"]
    }
  }'
```

**Title prefixes:**
- `bug:` for bugs
- `feat:` for feature requests
- `ux:` for UX/usability issues
- `docs:` for documentation gaps

**Always add the `from-agent` label** so Chris can filter for agent-reported issues.

---

## Checking Issue Status

When a customer follows up on something you previously reported, check if there's progress:

```bash
curl -s -H "Authorization: Bearer $CLAWTRUST_AGENT_TOKEN" \
  "$CLAWTRUST_API_URL/integrations/github/action" \
  -X POST -H "Content-Type: application/json" \
  -d '{
    "action": "github_issues_list_for_repo",
    "params": {
      "owner": "autorevai",
      "repo": "clawtrust",
      "state": "all",
      "labels": "from-agent"
    }
  }'
```

If an issue is closed, the fix has been deployed. You can confirm this to the customer.

---

## Reading Code for Context

When you need to understand how something works (to answer a customer question or debug an issue), read the source:

```bash
curl -s -H "Authorization: Bearer $CLAWTRUST_AGENT_TOKEN" \
  "$CLAWTRUST_API_URL/integrations/github/action" \
  -X POST -H "Content-Type: application/json" \
  -d '{
    "action": "github_get_repository_content",
    "params": {
      "owner": "autorevai",
      "repo": "clawtrust",
      "path": "src/path/to/file.ts"
    }
  }'
```

Key files you may need:
- `src/lib/config/openclaw-config.ts` - How agent configs are built
- `src/lib/config/tier-resources.ts` - Tier limits and features
- `config/openclaw-skills/` - Skill definitions
- `prisma/schema.prisma` - Database schema
- `CLAUDE.md` - Project conventions

---

## Commenting on PRs

When Chris opens a PR that relates to something you reported, you can add context:

```bash
curl -s -H "Authorization: Bearer $CLAWTRUST_AGENT_TOKEN" \
  "$CLAWTRUST_API_URL/integrations/github/action" \
  -X POST -H "Content-Type: application/json" \
  -d '{
    "action": "github_create_an_issue_comment",
    "params": {
      "owner": "autorevai",
      "repo": "clawtrust",
      "issue_number": 42,
      "body": "Context from support: [relevant customer feedback or reproduction details]"
    }
  }'
```

---

## Coordination Protocol

1. **You find a problem** -> Create a GitHub issue with `from-agent` label
2. **Chris picks it up** -> He works on it in Claude Code, pushes a branch, opens a PR
3. **Fix is deployed** -> Issue gets closed. You can verify by reading the updated code.
4. **Customer asks for update** -> Check issue status. If closed, confirm the fix is live.

You and Chris share the same GitHub repo as your coordination layer. Issues are your shared task list. PRs are how fixes ship. Stay on top of open issues so you can give customers accurate status updates.

---

## Do NOT

- Create duplicate issues. Search first.
- Create issues for things you can handle yourself (password resets, config questions, etc.)
- Modify code directly. Your role is to report and provide context, not to push code.
- Share code snippets from the private repo with customers.


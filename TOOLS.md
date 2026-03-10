# Tools & Environment

## API Connection
- **ClawTrust API:** `https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr`
- **Auth Header:** `Authorization: Bearer $CLAWTRUST_AGENT_TOKEN`
- **Tenant ID:** `cmmj7q0wu000oe1b0ij5rzbpr`

## Stored Credentials
Credentials are stored securely in ClawTrust and fetched via the credential proxy.
- List: `GET https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/credentials/available`
- Fetch: `GET https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/credentials/{key}`
- Store: `POST https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/credentials` (body: `{"key":"name","value":"secret"}`)

## Communication Channels
All configured channels are available. Check env vars for active tokens:
- Slack: `$SLACK_BOT_TOKEN`
- Telegram: `$TELEGRAM_BOT_TOKEN`
- Discord: `$DISCORD_BOT_TOKEN`

## File Sharing
Share workspace files through channels:
- **Slack:** `POST https://clawtrust.ai/api/tenants/cmmj7q0wu000oe1b0ij5rzbpr/slack/upload` with `{path, channel, message}`
- **Email:** Add `attachments: [{path: "/data/workspace/..."}]` to email send
- **Inbound files:** Saved automatically to `/data/workspace/shared/inbox/`

## Browser Automation
Playwright-managed Chromium is available for full web browsing and automation.
- Controlled via OpenClaw's built-in browser tools (navigate, click, type, screenshot, PDF, etc.)
- Runs inside the agent container with no external dependencies

## Skills Directories
- Platform skills: `/data/skills/` — ClawTrust integrations (credentials, email, calendar, GitHub)
- Role skills: `/data/workspace/skills/` — Role playbooks (triage, scheduling, CRM, research)
Each skill has a `SKILL.md` with usage instructions. Read it before using.

## Workspace
- Working directory: `/data/workspace/`
- Memory files: `/data/workspace/memory/`


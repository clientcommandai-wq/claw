# Claw Agent — Skills & Configuration

This repo contains the skill files and configuration for the Client Command AI agent (Claw).

## Structure

```
skills/           — All agent skills (role playbooks, workflows, integrations)
SOUL.md           — Agent personality and core behaviors
USER.md           — Context about the human (Greg)
IDENTITY.md       — Agent identity and operating principles
TOOLS.md          — Tools, APIs, and environment config
HEARTBEAT.md      — Heartbeat/proactive check instructions
AGENTS.md         — Workspace rules and memory system
```

## Skills Index

| Skill | Category | Purpose |
|-------|----------|---------|
| receptionist | Core | Master inbound router |
| core-behaviors | Core | Universal behaviors |
| team-memory | Core | Persistent knowledge base |
| marketing-lead | Marketing/CMO | Marketing orchestrator |
| social-media | Marketing | Social content & engagement |
| content-drafts | Marketing | Long-form content creation |
| analytics | Marketing | Metrics & performance reports |
| email-outreach | Marketing | Sales email sequences |
| competitor-watch | Marketing | Competitor monitoring |
| sales-lead | Sales | Sales activity router |
| lead-qualification | Sales | BANT scoring & research |
| crm | Sales | HubSpot management |
| email-triage | Ops | Inbox management |
| support-lead | Support | Customer support router |
| ticket-triage | Support | Support ticket handling |
| scheduling | Ops | Calendar & meeting management |
| invoicing | Ops | Invoice creation & tracking |
| google-workspace | Ops | Drive, Docs, Sheets management |
| cto | Engineering | Engineering task router |
| platform-engineer | Engineering | Infrastructure & DevOps |
| security-hardening | Engineering | Security & compliance |

## Version Control

Skills are version-controlled here for backup, reuse, and iteration.
Changes made by the agent during operation are committed periodically.

## Last Updated
2026-03-10

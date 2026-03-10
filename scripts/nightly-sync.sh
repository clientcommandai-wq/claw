#!/bin/bash
# Nightly sync — runs at 8pm ET
# Commits changes to GitHub and refreshes Google Drive memory log

LOG="/data/workspace/memory/sync-$(date +%Y-%m-%d).log"
mkdir -p /data/workspace/memory

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting nightly sync..." | tee -a "$LOG"

# Load secrets from credentials file (never committed to git)
SECRETS_FILE="/data/workspace/credentials/sync-secrets.env"
if [ -f "$SECRETS_FILE" ]; then
  source "$SECRETS_FILE"
else
  echo "[ERROR] Missing $SECRETS_FILE — skipping sync." | tee -a "$LOG"
  exit 1
fi

# ── 1. GIT SYNC ──────────────────────────────────────────────────
cd /data/workspace

git config user.email "clientcommandai@gmail.com"
git config user.name "Claw Agent"
git remote set-url origin "https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_USER}/claw.git"

git add -A -- ':!credentials/' ':!memory/' ':!.openclaw/'

if git diff --cached --quiet; then
  echo "[$(date '+%H:%M:%S')] Git: No changes to commit." | tee -a "$LOG"
else
  CHANGED=$(git diff --cached --name-only | wc -l)
  git commit -m "nightly sync $(date +%Y-%m-%d) — ${CHANGED} file(s) updated"
  git push origin main
  echo "[$(date '+%H:%M:%S')] Git: Pushed ${CHANGED} changed file(s)." | tee -a "$LOG"
fi

# ── 2. GOOGLE DRIVE SYNC ─────────────────────────────────────────
CREDS="/data/workspace/credentials/google_oauth.json"
if [ -f "$CREDS" ]; then
  CLIENT_ID=$(python3 -c "import json; d=json.load(open('$CREDS')); print(d['client_id'])")
  CLIENT_SECRET=$(python3 -c "import json; d=json.load(open('$CREDS')); print(d['client_secret'])")
  REFRESH_TOKEN=$(python3 -c "import json; d=json.load(open('$CREDS')); print(d['refresh_token'])")

  TOKEN_RESP=$(curl -s -X POST https://oauth2.googleapis.com/token \
    -d "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}&refresh_token=${REFRESH_TOKEN}&grant_type=refresh_token")
  ACCESS_TOKEN=$(echo "$TOKEN_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('access_token',''))" 2>/dev/null)

  if [ -n "$ACCESS_TOKEN" ]; then
    python3 -c "
import json
with open('$CREDS') as f: d = json.load(f)
d['access_token'] = '$ACCESS_TOKEN'
with open('$CREDS','w') as f: json.dump(d, f, indent=2)
"
    TODAY=$(date +%Y-%m-%d)
    MEMORY_FILE="/data/workspace/memory/${TODAY}.md"
    if [ -f "$MEMORY_FILE" ]; then
      SUMMARY=$(tail -5 "$MEMORY_FILE" | tr '\n' ' ' | cut -c1-250)
    else
      SUMMARY="No activity logged today."
    fi

    SHEET_ID="18aXxd3paJGcJdSmbEs7rjdVvzBNeQyhHxXki0Y8bK10"
    curl -s -X POST \
      "https://sheets.googleapis.com/v4/spreadsheets/${SHEET_ID}/values/A1:append?valueInputOption=RAW&insertDataOption=INSERT_ROWS" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"values\": [[\"$(date +%Y-%m-%d)\", \"$(date +%H:%M) UTC\", \"${SUMMARY}\"]]}" > /dev/null
    echo "[$(date '+%H:%M:%S')] Google Drive: MEMORY_LOG updated." | tee -a "$LOG"
  else
    echo "[$(date '+%H:%M:%S')] Google Drive: Token refresh failed — may need re-auth." | tee -a "$LOG"
  fi
else
  echo "[$(date '+%H:%M:%S')] Google Drive: No credentials found, skipping." | tee -a "$LOG"
fi

echo "[$(date '+%H:%M:%S')] Nightly sync complete." | tee -a "$LOG"

#!/bin/bash
# Regenerate The Card dashboard and push to GitHub Pages. Wired to a nightly cron.
export PATH="/opt/homebrew/bin:/usr/bin:/bin:$PATH"
set -e
cd "$HOME/edge"
"$HOME/world-cup-2026/.venv/bin/python" dashboard.py >/dev/null 2>&1
"$HOME/world-cup-2026/.venv/bin/python" promo_machine.py json >/dev/null 2>&1 || true  # cache today's multi
"$HOME/world-cup-2026/.venv/bin/python" multi_tracker.py log >/dev/null 2>&1 || true   # auto-capture the multi
"$HOME/world-cup-2026/.venv/bin/python" multi_tracker.py settle >/dev/null 2>&1 || true  # grade finished legs
"$HOME/world-cup-2026/.venv/bin/python" cockpit.py >/dev/null 2>&1 || true   # companion cockpit (money-free)
"$HOME/world-cup-2026/.venv/bin/python" db.py rebuild >/dev/null 2>&1 || true  # rebuild bets.db spine from all logs
# EPIC COCKPIT is now the DEFAULT page (index.html); old dashboard kept at /dashboard.html as backup
if [ -f "$HOME/world-cup-2026/reports/cockpit.html" ]; then
  cp "$HOME/world-cup-2026/reports/cockpit.html" "$HOME/card-site/index.html"
  cp "$HOME/world-cup-2026/reports/cockpit.html" "$HOME/card-site/cockpit.html"
else
  cp "$HOME/world-cup-2026/reports/dashboard.html" "$HOME/card-site/index.html"
fi
cp "$HOME/world-cup-2026/reports/dashboard.html" "$HOME/card-site/dashboard.html" 2>/dev/null || true
cd "$HOME/card-site"
git add -A
if git diff --cached --quiet; then
  echo "no change"
  exit 0
fi
git -c user.email="lenehan1996@gmail.com" -c user.name="lenehan3" commit -qm "auto-update $(date '+%Y-%m-%d %H:%M')"
git push -q origin main
echo "pushed $(date)"

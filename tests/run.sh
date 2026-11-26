#!/usr/bin/env bash
# Seny's own tests: the guard hook, the state snapshot, and a lint of the repo.
# Usage: bash tests/run.sh   (needs bash, git and python3)
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
GUARD="$ROOT/scripts/guard.sh"; STATE="$ROOT/scripts/state.sh"
pass=0; fail=0
ok()  { pass=$((pass + 1)); }
bad() { fail=$((fail + 1)); echo "FAIL: $1"; }

# ---------- guard.sh
guard() { # expected-exit tool agent command [env]
  local exp=$1 tool=$2 agent=$3 cmd=$4 a="" rc
  [ -n "$agent" ] && a=",\"agent_id\":\"x\",\"agent_type\":\"$agent\""
  printf '{"hook_event_name":"PreToolUse","tool_name":"%s","tool_input":{"command":"%s","description":"d"}%s}' "$tool" "$cmd" "$a" |
    env ${5:-X=1} bash "$GUARD" >/dev/null 2>&1; rc=$?
  [ "$rc" = "$exp" ] && ok || bad "guard: expected $exp got $rc — $tool ${agent:--} — $cmd"
}
for c in 'git push' 'git push origin feature/x' 'git -C apps/web push --force' 'git --no-pager push' \
         'pnpm test && git push' '/usr/bin/git push' 'command git push' 'git -c a=b push' \
         'gh pr create --fill' 'gh pr merge 3' 'gh repo sync'; do guard 2 Bash "" "$c"; done
for c in 'git status' 'git log --oneline -30' "echo pushed && git commit -m 'feat: push notifications'" \
         'rm -rf dist' 'gh pr view 3' 'pnpm test'; do guard 0 Bash "" "$c"; done
guard 0 Bash "" 'git push' SENY_ALLOW_PUSH=1
guard 2 Edit seny:reviewer ''; guard 2 Write seny:reviewer ''
for c in 'git diff HEAD' 'git diff HEAD --stat' 'git show abc123 -- src/a.ts' 'pnpm lint' \
         'pnpm test 2>&1 | tail -n 40' 'npx tsc --noEmit 2>/dev/null' 'git branch --show-current' \
         'grep -rn useCart src'; do guard 0 Bash seny:reviewer "$c"; done
for c in "sed -i '' 's/a/b/' x.ts" 'echo x > src/a.ts' 'git checkout -- src/a.ts' 'git stash' \
         'git diff --output=x.patch' 'pnpm add zod' 'npm i' 'cd src && rm a.ts' 'git branch -D main' \
         '/usr/bin/git stash' 'gh pr view 3'; do guard 2 Bash seny:reviewer "$c"; done
guard 0 Edit general-purpose ''; guard 0 Bash Explore 'rm -rf tmp'

# ---------- state.sh
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
has()  { printf '%s\n' "$out" | grep -qF -- "$1" && ok || bad "state ($2): missing '$1'"; }
hasnt(){ printf '%s\n' "$out" | grep -qF -- "$1" && bad "state ($2): unexpected '$1'" || ok; }
g() { git -c user.email=me@x -c user.name=me "$@"; }

mkdir "$T/empty"; out=$(cd "$T/empty" && bash "$STATE"); [ $? = 0 ] && ok || bad "state: non-zero exit"
has "Docs root: docs" empty; has "Git: not a git repository" empty; has "Open epics: none" empty

cp -r "$ROOT/examples/poc-a-poc" "$T/ex"; cd "$T/ex"; git init -q -b main; git config user.email me@x; git config user.name me
touch package.json pnpm-lock.yaml; mkdir -p apps/mobile; g add -A; g commit -qm init
sha=$(git rev-parse --short HEAD)
sed -i.bak -E "s/Commit: \`[0-9a-f]+\`/Commit: \`$sha\`/" docs/project/baseline.md; rm -f docs/project/baseline.md.bak
g commit -qam baseline; out=$(bash "$STATE")
has "Watch out: you are on the default branch" example-main
git checkout -qb feature/streaks; out=$(cd apps/mobile && bash "$STATE")
has "Branch: feature/streaks (default: main)" example; hasnt "Watch out" example
has "product.md (approved) architecture.md (approved) design-system.md (approved) roadmap.md (approved)" example
has "Baseline: current" example; has "Review mode: auto" example; has "Roadmap: 1 done" example
has "2 streaks (epic, M) <- foundation · \`in-progress\`" example; hasnt "Show and keep streaks" example
has "streaks (M): 1/4 done · 1 review · 1 in-progress · 1 todo · research.md (approved) plan.md (approved) design.md (approved)" example
has "Done epics (1): foundation" example; has "streaks S2 · Count the current streak — \`review\`" example
hasnt "streaks S1 " example
# a teammate's commit arrives: the baseline goes stale
echo x > other.txt; git add -A; git -c user.email=ana@x -c user.name=ana commit -qm teammate; out=$(bash "$STATE")
has "Baseline: STALE" teammate
# drafts, shape, light plans, review mode, private root
mkdir -p "$T/p/.seny/project" "$T/p/.seny/epics/tweak"; cd "$T/p"; git init -q -b develop; g commit -q --allow-empty -m x
printf -- '- Seny docs: `.seny`\n- Seny review: manual\n' > .seny/CLAUDE.md; printf '@.seny/CLAUDE.md\n' > CLAUDE.local.md
printf '# P\n\nStatus: draft\n' > .seny/project/product.md
printf '# T\n\nStatus: shape approved (2026-11-12)\nType: light\n\n#### S1 · A — `todo`\n' > .seny/epics/tweak/plan.md
out=$(bash "$STATE")
has "Docs root: .seny" private; has "Review mode: manual" private; has "product.md (draft)" private
has "tweak (light): 0/1 done · 1 todo · plan.md (shape approved)" private; has "Baseline: none" private
has "Project rules: CLAUDE.local.md .seny/CLAUDE.md" private
cd "$ROOT"

# roadmap status derived from plans, parallel suggestions, epic baseline
mkdir -p "$T/par/docs/project" "$T/par/docs/epics/foundation" "$T/par/docs/epics/i18n"; cd "$T/par"
git init -q -b main; printf -- '- Seny docs: `docs`\n- Seny parallel: suggest · max 3\n' > CLAUDE.md
printf '# R\n\n| # | Epic | Type | Size | Goal | Depends on |\n|---|---|---|---|---|---|\n| 1 | foundation | epic | L | b | — |\n| 2 | i18n | epic | M | l | foundation |\n| 3 | about | epic | M | a | i18n |\n| 4 | projects | epic | S | p | i18n |\n| 5 | contact | epic | S | c | i18n, foundation |\n| 6 | launch | epic | M | x | all above |\n' > docs/project/roadmap.md
printf '# F\n\nBranch: `feature/foundation`\n\n#### S1 · A — `done`\n' > docs/epics/foundation/plan.md
printf '# I\n\nBranch: `feature/i18n`\n\n#### S1 · A — `done`\n#### S2 · B — `review`\n' > docs/epics/i18n/plan.md
g add -A; g commit -qm x; out=$(bash "$STATE")
has "Roadmap: 1 done" parallel-busy; has "2 i18n (epic, M) <- foundation · \`in-progress\`" parallel-busy; hasnt "Parallel:" parallel-busy
sed -i.bak 's/`review`/`done`/' docs/epics/i18n/plan.md; rm -f docs/epics/i18n/plan.md.bak; g commit -qam done; out=$(bash "$STATE")
has "Roadmap: 2 done" parallel; has "Parallel: 3 epics ready to start at once (about projects contact) · max 3 at a time" parallel
out=$(printf '%s\n' "$out" | grep Parallel); hasnt "launch" parallel-all-above
printf -- '- Seny docs: `docs`\n- Seny parallel: off\n' > CLAUDE.md; out=$(bash "$STATE"); hasnt "Parallel:" parallel-off
mkdir -p docs/epics/about; printf '# A\n\nBranch: `feature/about`\n\n#### S1 · A — `todo`\n' > docs/epics/about/plan.md
g add -A; g commit -qm about; g checkout -qb feature/about
printf '# Baseline\n\nRecorded: 2026-11-26 · Commit: `%s` · By: x\n' "$(git rev-parse --short HEAD)" > docs/epics/about/baseline.md
out=$(bash "$STATE"); has "[epic about]" epic-baseline; has "Current epic (from its Branch: line): about" epic-baseline
cd "$ROOT"

# ---------- recent.sh
out=$(cd "$T/empty" && bash "$ROOT/scripts/recent.sh"); [ $? = 0 ] && ok || bad "recent: non-zero exit"
has "not a git repository" recent-empty
out=$(cd "$T/ex/apps/mobile" && bash "$ROOT/scripts/recent.sh"); has "teammate" recent-repo

# ---------- lint
python3 "$ROOT/tests/lint.py" "$ROOT" && ok || bad "lint"

echo "passed: $pass · failed: $fail"
[ "$fail" = 0 ]

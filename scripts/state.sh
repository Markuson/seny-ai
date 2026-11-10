#!/usr/bin/env bash
# Seny: print the current project state for the skills.
# Read-only. Always exits 0 so a skill never fails to load because of it.
# Prints only what is open: finished work is summarised in one line, so the
# output stays short however many features the project has.
set +e

# Work from the repository root, even if Claude Code started in a subfolder.
top=$(git rev-parse --show-toplevel 2>/dev/null)
[ -n "$top" ] && cd "$top"

# Docs root: a "Seny docs:" line in the project rules, else .seny/ if present, else docs/.
root=""
for f in CLAUDE.md CLAUDE.local.md .seny/CLAUDE.md; do
  [ -f "$f" ] || continue
  root=$(sed -nE 's/^[-* ]*Seny docs:[[:space:]]*`?([^`[:space:]]+)`?.*/\1/p' "$f" | head -n1)
  [ -n "$root" ] && break
done
if [ -z "$root" ]; then
  if [ -d .seny ]; then root=.seny; else root=docs; fi
fi
echo "Docs root: $root"

# Git
if [ -n "$top" ]; then
  branch=$(git branch --show-current 2>/dev/null)
  default=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')
  if [ -z "$default" ]; then
    for b in main master develop; do
      git show-ref --verify --quiet "refs/heads/$b" && { default=$b; break; }
    done
  fi
  echo "Branch: ${branch:-detached HEAD} (default: ${default:-unknown})"
  [ -n "$branch" ] && [ "$branch" = "$default" ] && echo "Watch out: you are on the default branch."
  total=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$total" -gt 0 ]; then
    echo "Uncommitted changes: $total"
    git status --short 2>/dev/null | head -n 15 | sed 's/^/  /'
    [ "$total" -gt 15 ] && echo "  ... and $((total - 15)) more"
  else
    echo "Uncommitted changes: none"
  fi
else
  echo "Git: not a git repository"
fi

# Project rules
rules=""
for f in CLAUDE.md CLAUDE.local.md "$root/CLAUDE.md"; do
  [ -f "$f" ] && rules="$rules $f"
done
echo "Project rules:${rules:- none}"

# Stack hints
[ -f package.json ] && pkg="present" || pkg="missing"
locks=""
for lock in pnpm-lock.yaml package-lock.json yarn.lock bun.lockb bun.lock; do
  [ -f "$lock" ] && locks="$locks $lock"
done
echo "package.json: $pkg · lockfiles:${locks:- none}"

# Project docs
project=$(ls "$root/project" 2>/dev/null | tr '\n' ' ')
echo "Project docs: ${project:-none}"

# Baseline: is it still the right reference?
# Current when it is in this branch's history and every commit since then is yours
# (your stories already passed the checks against it). Stale when it was recorded on
# another line of history, or other people's work came in since (a pull, merge or rebase).
bfile="$root/project/baseline.md"
if [ -f "$bfile" ]; then
  bline=$(grep -m1 -E '^Recorded:' "$bfile")
  bsha=$(printf '%s' "$bline" | sed -nE 's/.*Commit:[[:space:]]*`?([0-9a-f]{4,40})`?.*/\1/p')
  bdate=$(printf '%s' "$bline" | sed -nE 's/^Recorded:[[:space:]]*([0-9-]+).*/\1/p')
  status="recorded ${bdate:-on an unknown date}"
  if [ -n "$top" ] && [ -n "$bsha" ]; then
    if ! git cat-file -e "$bsha^{commit}" 2>/dev/null; then
      status="STALE ($status at $bsha, a commit this repo doesn't have): re-record before changing code"
    elif ! git merge-base --is-ancestor "$bsha" HEAD 2>/dev/null; then
      status="STALE ($status at $bsha, on another line of history): re-record before changing code"
    else
      me=$(git config user.email)
      since=$(git rev-list --count "$bsha..HEAD" 2>/dev/null)
      others=$(git log --format='%ae' "$bsha..HEAD" 2>/dev/null | grep -cvxF "${me:-<nobody>}")
      if [ "${others:-0}" -gt 0 ]; then
        status="STALE ($status at $bsha; $others of the $since commits since then are other people's work): re-record before changing code"
      else
        status="current ($status at $bsha, $since own commits since)"
      fi
    fi
  elif [ -z "$bsha" ]; then
    status="$status (no Commit: line, can't tell if it is current)"
  fi
  echo "Baseline: $status"
else
  echo "Baseline: none"
fi

# Review mode: "Seny review: auto | manual" in the project rules (default auto)
mode=""
for f in CLAUDE.md CLAUDE.local.md "$root/CLAUDE.md"; do
  [ -f "$f" ] || continue
  mode=$(sed -nE 's/^[-* ]*Seny review:[[:space:]]*`?(auto|manual)`?.*/\1/p' "$f" | head -n1)
  [ -n "$mode" ] && break
done
echo "Review mode: ${mode:-auto}"

# Roadmap: only what is not done
if [ -f "$root/project/roadmap.md" ]; then
  rows=$(grep -E '^\| *[0-9]+ *\|' "$root/project/roadmap.md")
  open=$(printf '%s\n' "$rows" | grep -v '`done`' | grep -v '^$')
  ndone=$(printf '%s\n' "$rows" | grep -c '`done`')
  echo "Roadmap: $ndone done"
  [ -n "$open" ] && printf '%s\n' "$open" | sed 's/^/  /'
fi

# Features: one line each with story counts; finished ones collapsed.
# Story headings look like: #### E1-S2 · Title — `status`
done_names=""
ndone=0
found=0
open_stories=""
for d in "$root"/features/*/; do
  [ -d "$d" ] || continue
  slug=$(basename "$d")
  files=$(ls "$d" | tr '\n' ' ' | sed 's/ $//')
  plan="$d/plan.md"
  if [ -f "$plan" ]; then
    counts=$(grep -E '^#### E[0-9]+-S[0-9]+' "$plan" | sed -nE 's/.*`([a-z-]+)`[[:space:]]*$/\1/p' |
      awk '{n[$1]++; t++} END {
        if (t == 0) { print "0:no stories yet"; exit }
        s = t ":" (n["done"] + 0) "/" t " done";
        split("review in-progress todo", order, " ");
        for (i = 1; i <= 3; i++) if (n[order[i]]) s = s " · " n[order[i]] " " order[i];
        print s }')
    total=${counts%%:*}
    ndn=$(grep -E '^#### E[0-9]+-S[0-9]+' "$plan" | grep -c '`done`[[:space:]]*$')
    type=$(grep -m1 -E '^Type:' "$plan" | sed -E 's/^Type:[[:space:]]*//')
    if [ "$total" != "0" ] && [ "$ndn" = "$total" ]; then
      ndone=$((ndone + 1)); done_names="$done_names $slug"
      continue
    fi
    [ $found -eq 0 ] && echo "Open features:"
    found=1
    echo "  $slug${type:+ ($type)}: ${counts#*:} [$files]"
    stories=$(grep -E '^#### E[0-9]+-S[0-9]+' "$plan" | grep -v '`done`[[:space:]]*$' |
      sed -E "s/^#### /    $slug /")
    [ -n "$stories" ] && open_stories="$open_stories$stories"$'\n'
  else
    [ $found -eq 0 ] && echo "Open features:"
    found=1
    echo "  $slug: no plan yet [$files]"
  fi
done
[ $found -eq 0 ] && echo "Open features: none"
if [ $ndone -gt 0 ]; then
  if [ $ndone -le 5 ]; then echo "Done features ($ndone):$done_names"; else echo "Done features: $ndone"; fi
fi
if [ -n "$open_stories" ]; then
  echo "Open stories:"
  printf '%s' "$open_stories"
fi

exit 0

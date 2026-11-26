#!/usr/bin/env bash
# Seny: print the current project state for the skills.
# Read-only. Always exits 0 so a skill never fails to load because of it.
# Prints only what is open: finished work is summarised in one line, so the
# output stays short however many epics the project has.
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

# Document status: the first "Status:" line of a document (draft, approved, shape approved)
docstatus() {
  st=$(grep -m1 -E '^Status:' "$1" 2>/dev/null | sed -E 's/^Status:[[:space:]]*//; s/[[:space:]]*\(.*//; s/[[:space:]]+$//')
  printf '%s' "${st:-no status}"
}

# Project docs, each with its status
project=""
for f in product codebase architecture design-system roadmap; do
  [ -f "$root/project/$f.md" ] && project="$project $f.md ($(docstatus "$root/project/$f.md"))"
done
echo "Project docs:${project:- none}"

# Baseline: is it still the right reference?
# Current when it is in this branch's history and every commit since then is yours
# (your stories already passed the checks against it). Stale when it was recorded on
# another line of history, or other people's work came in since (a pull, merge or rebase).
# On an epic's branch (its plan's Branch: line), the epic's own baseline wins: epics
# worked in parallel each record theirs, so they never fight over one file.
cur_epic=""
if [ -n "$branch" ]; then
  for pl in "$root"/epics/*/plan.md; do
    [ -f "$pl" ] || continue
    if grep -m1 -E '^Branch:' "$pl" | grep -qF "\`$branch\`"; then cur_epic=$(basename "$(dirname "$pl")"); break; fi
  done
fi
bfile="$root/project/baseline.md"
[ -n "$cur_epic" ] && [ -f "$root/epics/$cur_epic/baseline.md" ] && bfile="$root/epics/$cur_epic/baseline.md"
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
  where=""; [ "$bfile" != "$root/project/baseline.md" ] && where=" [epic $cur_epic]"
  echo "Baseline: $status$where"
else
  echo "Baseline: none"
fi
[ -n "$cur_epic" ] && echo "Current epic (from its Branch: line): $cur_epic"

# Review mode: "Seny review: auto | manual" in the project rules (default auto)
mode=""
for f in CLAUDE.md CLAUDE.local.md "$root/CLAUDE.md"; do
  [ -f "$f" ] || continue
  mode=$(sed -nE 's/^[-* ]*Seny review:[[:space:]]*`?(auto|manual)`?.*/\1/p' "$f" | head -n1)
  [ -n "$mode" ] && break
done
echo "Review mode: ${mode:-auto}"

# Parallel work: "Seny parallel: suggest | off · max N" in the project rules (default suggest, max 2)
par=""; pmax=""
for f in CLAUDE.md CLAUDE.local.md "$root/CLAUDE.md"; do
  [ -f "$f" ] || continue
  line=$(grep -m1 -E '^[-* ]*Seny parallel:' "$f")
  [ -z "$line" ] && continue
  par=$(printf '%s' "$line" | sed -nE 's/.*Seny parallel:[[:space:]]*`?(suggest|off)`?.*/\1/p')
  pmax=$(printf '%s' "$line" | sed -nE 's/.*max[[:space:]]*([0-9]+).*/\1/p')
  break
done
par=${par:-suggest}; pmax=${pmax:-2}

# Epic status, derived from its plan (the roadmap has no status column to keep in sync):
# no folder → todo · stories all done → done · anything else → in-progress
epicstatus() {
  d="$root/epics/$1"; pl="$d/plan.md"
  [ -d "$d" ] || { echo todo; return; }
  if [ -f "$pl" ]; then
    t=$(grep -cE '^#### S[0-9]+ ' "$pl"); n=$(grep -E '^#### S[0-9]+ ' "$pl" | grep -c '`done`[[:space:]]*$')
    if [ "$t" -gt 0 ] && [ "$t" = "$n" ]; then echo done; return; fi
  fi
  echo in-progress
}

# Roadmap: only what is not done. Status is derived from each epic's plan.
ready=""; nready=0
if [ -f "$root/project/roadmap.md" ]; then
  rows=$(grep -E '^\| *[0-9]+ *\|' "$root/project/roadmap.md" |
    awk -F'|' '{ for (i = 2; i <= NF; i++) gsub(/^[ \t]+|[ \t]+$/, "", $i); print $2 "|" $3 "|" $4 "|" $5 "|" $7 }')
  # $1 number, $2 slug, $3 type, $4 size, $5 dependencies
  statuses=""
  while IFS='|' read -r num slug type size deps; do
    [ -n "$slug" ] || continue
    statuses="$statuses$slug=$(epicstatus "$slug") "
  done <<EOF_ROWS
$rows
EOF_ROWS
  st() { printf '%s' "$statuses" | tr ' ' '\n' | sed -n "s/^$1=//p" | head -n1; }
  ndone=0; lines=""
  while IFS='|' read -r num slug type size deps; do
    [ -n "$slug" ] || continue
    s1=$(st "$slug")
    if [ "$s1" = done ]; then ndone=$((ndone + 1)); continue; fi
    lines="$lines  $num $slug ($type, $size) <- ${deps:-—} · \`$s1\`"$'\n'
    # Ready: todo, and every dependency done ("all above": every earlier row done)
    [ "$s1" = todo ] || continue
    ok=1
    case "$deps" in
      ""|"—"|"-") ;;
      "all above"*)
        while IFS='|' read -r n2 s2 _ _ _; do
          [ -n "$s2" ] && [ "$n2" -lt "$num" ] && [ "$(st "$s2")" != done ] && ok=0
        done <<EOF_ROWS
$rows
EOF_ROWS
        ;;
      *)
        for dep in $(printf '%s' "$deps" | tr ',' ' '); do
          [ "$(st "$dep")" = done ] || ok=0
        done ;;
    esac
    [ $ok = 1 ] && { ready="$ready $slug"; nready=$((nready + 1)); }
  done <<EOF_ROWS
$rows
EOF_ROWS
  echo "Roadmap: $ndone done"
  [ -n "$lines" ] && printf '%s' "$lines"
fi

# Parallel opportunities: only when it applies and the project hasn't turned it off.
if [ "$par" = suggest ] && [ $nready -ge 2 ]; then
  echo "Parallel: $nready epics ready to start at once (${ready# }) · max $pmax at a time"
fi
if [ -n "$top" ]; then
  wts=$(git worktree list --porcelain 2>/dev/null | awk '/^worktree /{w=$2} /^branch /{sub("refs/heads/","",$2); print "  " $2 " — " w}')
  [ "$(printf '%s\n' "$wts" | grep -c .)" -gt 1 ] && { echo "Worktrees:"; printf '%s\n' "$wts"; }
fi

# Epics: one line each with size, documents and story counts; finished ones collapsed.
# Story headings look like: #### S2 · Title — `status`
done_names=""
ndone=0
found=0
open_stories=""
for d in "$root"/epics/*/; do
  [ -d "$d" ] || continue
  slug=$(basename "$d")
  plan="$d/plan.md"
  docs=""
  for f in research plan design; do
    [ -f "$d/$f.md" ] && docs="$docs $f.md ($(docstatus "$d/$f.md"))"
  done
  size=""; type=""
  if [ -f "$plan" ]; then
    size=$(grep -m1 -E '^Size:' "$plan" | sed -E 's/^Size:[[:space:]]*//; s/[[:space:]].*//')
    type=$(grep -m1 -E '^Type:' "$plan" | sed -E 's/^Type:[[:space:]]*//; s/[[:space:]].*//')
  fi
  if [ -z "$size" ] && [ -f "$root/project/roadmap.md" ]; then
    size=$(grep -E "^\| *[0-9]+ *\| *$slug *\|" "$root/project/roadmap.md" | head -n1 | awk -F'|' '{gsub(/ /,"",$5); print $5}')
  fi
  counts="no stories yet"; total=0; ndn=0
  if [ -f "$plan" ]; then
    total=$(grep -cE '^#### S[0-9]+ ' "$plan")
    ndn=$(grep -E '^#### S[0-9]+ ' "$plan" | grep -c '`done`[[:space:]]*$')
    if [ "$total" -gt 0 ]; then
      counts=$(grep -E '^#### S[0-9]+ ' "$plan" | sed -nE 's/.*`([a-z-]+)`[[:space:]]*$/\1/p' |
        awk -v t="$total" '{n[$1]++} END {
          s = (n["done"] + 0) "/" t " done";
          split("review in-progress todo", order, " ");
          for (i = 1; i <= 3; i++) if (n[order[i]]) s = s " · " n[order[i]] " " order[i];
          print s }')
    fi
  fi
  if [ "$total" -gt 0 ] && [ "$ndn" = "$total" ]; then
    ndone=$((ndone + 1)); done_names="$done_names $slug"
    continue
  fi
  [ $found -eq 0 ] && echo "Open epics:"
  found=1
  label="$slug"
  if [ -n "$size" ]; then label="$label ($size${type:+, $type})"; elif [ -n "$type" ]; then label="$label ($type)"; fi
  echo "  $label: $counts ·${docs:- no documents}"
  if [ -f "$plan" ]; then
    stories=$(grep -E '^#### S[0-9]+ ' "$plan" | grep -v '`done`[[:space:]]*$' | sed -E "s/^#### /    $slug /")
    [ -n "$stories" ] && open_stories="$open_stories$stories"$'\n'
  fi
done
[ $found -eq 0 ] && echo "Open epics: none"
# Epic work belongs on the epic's branch; project documents are fine on the default one.
[ $found -eq 1 ] && [ -n "$branch" ] && [ "$branch" = "$default" ] &&
  echo "Watch out: you are on the default branch; epic documents and stories belong on the epic's branch."
if [ $ndone -gt 0 ]; then
  if [ $ndone -le 5 ]; then echo "Done epics ($ndone):$done_names"; else echo "Done epics: $ndone"; fi
fi
if [ -n "$open_stories" ]; then
  echo "Open stories:"
  printf '%s' "$open_stories"
fi

exit 0

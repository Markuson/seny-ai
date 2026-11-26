# roadmap.md

Format for `<docs>/project/roadmap.md` (`<docs>` is the Seny docs root). App-wide: epic docs build on it and never repeat it. Be concrete: names, versions, values. Omit sections that don't apply.

```markdown
# Roadmap

Status: <draft | approved (YYYY-MM-DD)>

| # | Epic | Type | Size | Goal | Depends on |
|---|---|---|---|---|---|
| 1 | foundation | epic | L | Base app running and deployed | — |
| 2 | <slug> | epic | <S/M/L> | <one line> | foundation |
| 3 | <slug> | evolution | <S/M/L> | <one line> | — |

## Epic notes
<Up to 3 lines per epic: decisions already taken about it, and pointers to where its detail lives (`product.md#section`, `inputs/<file>.md`). A size-S plan reads its row and these notes instead of the whole product document.>

### <slug>
- <decision or pointer>

## Later
- <ideas outside the MVP>
```

Each row is an **epic**: one deliverable capability, one branch, one pull request, its own folder in `<docs>/epics/<slug>/`.

Types: `epic` (new behaviour) or `evolution` (how the app is built: `/seny:evolve`).

Size decides how much planning the epic gets:

| Size | Stories | Process |
|---|---|---|
| S | 1–3 | `/seny:plan <slug>` only, one pass |
| M | 4–8 | `/seny:research <slug>` → `/seny:plan <slug>` |
| L | more than 8 | research, then the plan in two passes (shape, then stories); consider splitting it |

No status column: the state derives it from each epic's plan (`todo` without a folder, `done` when every story is done, `in-progress` otherwise), so epics worked in parallel never fight over this file. `Depends on` lists slugs (comma-separated), `—`, or `all above`; epics whose dependencies are done can run in parallel (Colla mode).

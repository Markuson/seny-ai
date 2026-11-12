# roadmap.md

Format for `<docs>/project/roadmap.md` (`<docs>` is the Seny docs root). App-wide: epic docs build on it and never repeat it. Be concrete: names, versions, values. Omit sections that don't apply.

```markdown
# Roadmap

Status: <draft | approved (YYYY-MM-DD)>

| # | Epic | Type | Size | Goal | Depends on | Status |
|---|---|---|---|---|---|---|
| 1 | foundation | epic | L | Base app running and deployed | — | `todo` |
| 2 | <slug> | epic | <S/M/L> | <one line> | foundation | `todo` |
| 3 | <slug> | evolution | <S/M/L> | <one line> | — | `todo` |

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

Statuses: `todo`, `in-progress`, `done`. A row is `done` when every story in its plan is `done`.

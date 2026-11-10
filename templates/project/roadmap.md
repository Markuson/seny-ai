# roadmap.md

Format for `<docs>/project/roadmap.md` (`<docs>` is the Seny docs root). App-wide: feature docs build on it and never repeat it. Be concrete: names, versions, values. Omit sections that don't apply.

```markdown
# Roadmap

| # | Feature | Type | Goal | Depends on | Status |
|---|---|---|---|---|---|
| 1 | foundation | feature | Base app running and deployed | — | `todo` |
| 2 | <slug> | feature | <one line> | foundation | `todo` |
| 3 | <slug> | evolution | <one line> | — | `todo` |

## Later
- <ideas outside the MVP>
```

Types: `feature` (new behaviour: `/seny:research` → `/seny:plan`) or `evolution` (how the app is built: `/seny:evolve`).
Statuses: `todo`, `in-progress`, `done`. A row is `done` when every story in its plan is `done`.

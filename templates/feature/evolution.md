# Evolution templates

An evolution changes how the app is built, not what it does: a framework or SDK upgrade, a JavaScript → TypeScript migration, unifying patterns, swapping a library, restructuring folders or packages. It lives in `<docs>/features/<slug>/` like a feature, with `Type: evolution` in its plan.

## research.md (evolution)

```markdown
# <Evolution name> — research

Type: evolution
Kind: <upgrade | migration | unify pattern | library swap | restructure>

## Problem
<what is wrong with the current way, with evidence: bugs, duplication, blocked features, deprecations>

## Current state
- Pattern or version today: <...>
- Footprint: <n files / modules / packages that use it, listed or grouped>
- Tests around it: <coverage of the affected areas; what needs characterization tests>
- Coupling: <what depends on it: other modules, public APIs, data, native code>

## Options
| Option | Target | Strategy | Effort | Risk | Reversible |
|---|---|---|---|---|---|
| A | <...> | <strangler fig | expand-contract | adapter | feature flag | folder by folder | in place> | S/M/L | low/med/high | yes/partly/no |

Recommendation: <option and why>

## Risks
## Open questions
```

## Strategies

- **Strangler fig** — the new pattern lives beside the old one; callers move over one at a time; the old one is removed at the end.
- **Expand-contract** — for data, schemas and APIs: add the new shape, migrate readers and writers, then remove the old shape. Each step is deployable on its own.
- **Adapter** — a thin layer hides the old implementation behind the new interface while callers migrate.
- **Feature flag** — for user-visible changes: ship dark, switch on, then delete the flag and the old path.
- **Folder by folder** — for language or lint migrations (e.g. `allowJs`, then `strict` per folder via tsconfig `include` or per-file checks).
- **In place** — only for small, well-tested areas; still in small stories.

## plan.md specifics (evolution)

Use the feature plan format (`templates/feature/plan.md`) with:
- `Type: evolution` under the title.
- E1 starts with **characterization tests** for the areas that will change (skip only where coverage is already good).
- Every story leaves the app working and the checks no worse than the baseline.
- Stories move the footprint in measurable slices ("migrate the cart module"), each with a `Progress:` line (`3/11 modules`).
- The last epic is **cleanup**: remove the old pattern, the adapter, flags and dependencies; update the docs.
- Acceptance criteria include "no behaviour change" where that is the point, proven by the characterization tests.

## architecture.md — "In transition" section

```markdown
## In transition
| Area | From | To | Rule for new code | Progress | Evolution |
|---|---|---|---|---|---|
| Server state | Redux thunks | TanStack Query | New data fetching uses TanStack Query | 4/11 modules | `state-to-tanstack` |
```

When the evolution finishes, the row is removed and the target becomes the current architecture in the relevant section.

## architecture.md — decision record

Add to Key decisions:

```markdown
- <YYYY-MM-DD> **<decision>** (evolution `<slug>`)
  - Context: <why change>
  - Options: <A, B, C in one line each>
  - Decision: <chosen option and strategy>
  - Consequences: <what gets better, what it costs, what new code must do>
```

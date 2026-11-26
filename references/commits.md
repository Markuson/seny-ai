# Commits

The one source for every commit Seny proposes. Same input, same message, every time.

## When
Seny commits only after my `[C]` in the commit summary (`references/commit-summary.md`), or automatically when I said so for this session or for a parallel batch. Never on its own initiative, never a push.

## Which format
1. The repo's own convention, if the project rules record one under **Repo conventions → Commits** (detected by `/seny:init` from the history). Apply the type rules below inside it.
2. Otherwise, the Seny format below.

My personal rules decide *when* to commit, not the format.

## Seny format
```
<type>: <description> (<epic> <S#>)

- <key change>
```
- **Suffix**: `(<epic> <S#>)` for a story (`(streaks S3)`), `(<slug>)` for a light plan with one story; nothing for fixes, documents and spikes.
- **Description**: English, imperative, lowercase start, no final period, at most 60 characters. What the user or the project gains, not how: `show streak badge on habit card`, not `add StreakBadge component and slot`.
- **Body**: optional; up to 5 bullet lines of key changes, only when the description isn't enough. Never a copy of the plan.
- Trailers (co-author lines and similar) as Claude Code or the user's settings add them.

## Type, by rule
| What is committed | Type |
|---|---|
| A story with new behaviour | `feature` |
| A story of an evolution (`Type: evolution`) | `refactor` |
| A story with only configuration or tooling (`Tests: none`, no behaviour) | `chore` |
| A story with only tests (characterization) | `test` |
| `/seny:fix` | `fix` |
| Seny documents, one or a Rauxa batch | `docs` |
| Spike code, on its spike branch, never merged | `chore` |

If a story fits two rows, the first one wins.

## Documents
- One document: `docs: <approve | update> <document> for <project or epic>` → `docs: approve architecture for marcuson.dev`, `docs: update streaks plan`.
- A plan pass: `docs: plan <epic> (shape)` / `docs: plan <epic> (stories)`.
- A Rauxa batch: `docs: plan <scope> (<documents, comma-separated>)` → `docs: plan foundation (shape, stories)`.
- Spike findings: `docs: record spike findings for <epic>`.

## Examples
- `feature: show streak badge on habit card (streaks S3)`
- `refactor: move cart data fetching to tanstack query (state-to-tanstack S4)`
- `chore: wire lint, typecheck and format scripts (foundation S2)`
- `test: pin current price formatting (checkout S1)`
- `fix: count streaks in the family time zone`
- `chore: spike background ble reconnection on android`

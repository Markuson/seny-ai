# codebase.md

Format for `<docs>/project/codebase.md` (`<docs>` is the Seny docs root). App-wide: feature docs build on it and never repeat it. Be concrete: names, versions, values. Omit sections that don't apply.

The existing code as it is. Written by `/seny:research project` on an existing codebase and updated by `refresh`.

Describe the code as it is, inconsistencies included. Problems go here as debt and risks; never as fixes. The checks baseline lives in `baseline.md`, not here.

```markdown
# <Project name> — codebase

Analysed: <YYYY-MM-DD> at commit <short sha>

## Summary
<5 lines: what the app does, stack, overall health>

## Packages
<monorepo only: one line per package with its stack and purpose>

## Conventions in practice
- <naming, folder patterns, data fetching, error handling, styling — what the code actually does>
- Inconsistencies: <e.g. two fetch patterns: `lib/api.ts` (fetch) and `services/` (axios)>

## Test coverage map
| Area | Tests | Notes |
|---|---|---|
| <module or folder> | none / some / good | <what is untested> |

## Tech debt and risks
| Item | Location | Impact |
|---|---|---|
| <problem> | `path/file.ts:42` | <why it matters> |

## Fragile areas
<code to touch only with characterization tests first, and why>

## Open questions
<what the code can't answer>
```

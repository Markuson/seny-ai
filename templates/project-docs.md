# Project document templates

App-wide documents in `<docs>/project/` (`<docs>` is the Seny docs root). Feature docs build on them and never repeat them. Be concrete: names, versions, values. Omit sections that don't apply.

## architecture.md

```markdown
# Architecture

Last updated: <YYYY-MM-DD> by <feature slug, "project plan" or "codebase analysis">

<In a brownfield project this describes the code as it is, with real versions from package.json.>

## Stack
| Layer | Choice | Why |
|---|---|---|
| App | <Astro | Next.js (App Router) | React Native + Expo> | <one line> |
| Styling | <Tailwind | NativeWind> | |
| State | <TanStack Query (server) + Zustand | Redux Toolkit (client)> | |
| Backend | <none | Supabase | Next.js route handlers | Hono> | |
| Database | <PostgreSQL + Drizzle | Supabase Postgres | none> | |
| Auth | <Better Auth | Supabase Auth | none> | |
| CMS | <none | Keystatic | Payload | Strapi> | |
| Hosting | <Vercel | Cloudflare | EAS | ...> | |

## Structure
<repo layout: monorepo or single app; main folders and what lives in each>

## Data and state
- Server state: <what comes from where, how it is fetched and cached>
- Client state: <stores and what they hold>

## Data model
<entities, key fields, relations, exact enum/status strings>

## Boundaries
- External services: <APIs, SDKs, webhooks>
- Auth: <who can do what; where it is enforced>
- Validation: <where input is validated; shared Zod schemas location>

## Conventions
<only app-wide rules that differ from or add to ~/.claude/CLAUDE.md: naming, error handling, routing>

## In transition
<Only while an evolution is open (see templates/evolution.md). Omit otherwise.>
| Area | From | To | Rule for new code | Progress | Evolution |
|---|---|---|---|---|---|

## Key decisions
- <YYYY-MM-DD> <decision> — <why> (rejected: <alternative>)
```

## design-system.md

```markdown
# Design system

Platform: <web | mobile | both>
References: <links, screenshots, Figma>

## Direction
<3–5 lines: personality, tone, what it must feel like, what to avoid>

## Tokens
Semantic names, mapped to the Tailwind / NativeWind theme in <path to config>.
| Token | Light | Dark | Use |
|---|---|---|---|
| color.bg | | | app background |
| color.surface | | | cards, sheets |
| color.text | | | body text |
| color.text-muted | | | secondary text |
| color.primary | | | main actions |
| color.danger | | | destructive actions, errors |
| color.border | | | dividers, inputs |

## Typography
| Role | Family | Size / line height | Weight |
|---|---|---|---|
| display | | | |
| title | | | |
| body | | | |
| caption | | | |

## Spacing, radius, elevation
<scale (e.g. 4-pt grid), radius steps, shadows or elevation levels>

## Motion
<durations, easing, what animates; reduced motion behaviour>

## Base components
| Component | Variants | States | Location |
|---|---|---|---|
| Button | primary, secondary, ghost, danger | default, hover/pressed, focus, disabled, loading | `components/ui/Button` |
| Input | text, password, search | default, focus, error, disabled | |

## Accessibility rules
- AA contrast for every text/background pair; check new tokens before adding them
- Visible focus (web); accessibility labels and roles (mobile)
- Touch targets ≥ 44×44 pt / 48×48 dp
- Dynamic type and 200% zoom without breaking layouts
- Reduced motion respected
```

## roadmap.md

```markdown
# Roadmap

| # | Feature | Goal | Depends on | Status |
|---|---|---|---|---|
| 1 | foundation | Base app running and deployed | — | `todo` |
| 2 | <slug> | <one line> | foundation | `todo` |

## Later
- <ideas outside the MVP>
```

Feature statuses: `todo`, `in-progress`, `done`. A feature is `done` when every story in its plan is `done`.

## research.md — greenfield (new product)

```markdown
# <Product name> — research

## Vision
<what the product is and why it should exist, 3 lines>

## Users
- <user>: <what they need>

## Core needs
1. <job the product must do> — <priority>

## MVP candidate
- In: <the smallest version worth shipping>
- Later: <what waits>

## Constraints
<platforms (web, iOS, Android), hosting and cost, integrations, anything stated>

## References
- <similar product or site> — <what to take from it>

## Risks

## Assumptions
- (assumption) <...>

## Open questions
```

## research.md — brownfield (existing codebase)

Describe the code as it is, inconsistencies included. Problems go here as debt and risks; never as fixes.

```markdown
# <Project name> — codebase research

Analysed: <YYYY-MM-DD> at commit <short sha>

## Summary
<5 lines: what the app does, stack, overall health>

## Packages
<monorepo only: one line per package with its stack and purpose>

## Conventions in practice
- <naming, folder patterns, data fetching, error handling, styling — what the code actually does>
- Inconsistencies: <e.g. two fetch patterns: `lib/api.ts` (fetch) and `services/` (axios)>

## Baseline (<YYYY-MM-DD>)
Pre-existing state of the checks. Later phases compare against this: only new failures block.
| Check | Command | Result | Pre-existing failures |
|---|---|---|---|
| lint | `<cmd>` | ✓ / ✗ <n> errors | <files or rules> |
| typecheck | `<cmd>` | ✓ / ✗ <n> errors | <files> |
| tests | `<cmd>` | ✓ / ✗ <n> failing of <total> | <test names> |
| build | `<cmd>` | ✓ / ✗ / not run | |

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

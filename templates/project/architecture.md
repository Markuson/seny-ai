# architecture.md

Format for `<docs>/project/architecture.md` (`<docs>` is the Seny docs root). App-wide: epic docs build on it and never repeat it. Be concrete: names, versions, values. Omit sections that don't apply.

```markdown
# Architecture

Status: <draft | approved (YYYY-MM-DD)>
Last updated: <YYYY-MM-DD> by <epic slug, "project plan" or "codebase analysis">
Design system: <`design-system.md` | declined on <YYYY-MM-DD> | not applicable (no UI)>

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
<only app-wide rules that differ from or add to the personal and project rules: naming, error handling, routing>

## In transition
<Only while an evolution is open (see `templates/epic/evolution.md`). Omit otherwise.>
| Area | From | To | Rule for new code | Progress | Evolution |
|---|---|---|---|---|---|

## Key decisions
- <YYYY-MM-DD> <decision> — <why> (rejected: <alternative>)
```

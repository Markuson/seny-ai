# Personal defaults (~/.claude/CLAUDE.md)

Applies to every project. A project's own CLAUDE.md overrides anything here.

## Language
- Talk to me in Spanish.
- Everything written to the repo is in English: code, comments, docs, commit messages, PR text.

## Git
- Never push. Not to any branch, not with any flag.
- Commits:
  - If I have explicitly told you to commit, commit. If I have told you not to, don't. That holds for the rest of the session or until I say otherwise.
  - If I haven't said anything, don't commit during the task. At the end, ask: "¿Hago el commit o lo haces tú?".
- Before starting a feature, propose a branch name. With every change, propose a commit message.
- Branch: `<type>/<short-kebab-description>` — e.g. `feature/user-login`, `fix/empty-cart-crash`.
- Commit: `<type>: <description>` in imperative mood — e.g. `feature: add user login form`.
- Types: `feature`, `fix`, `refactor`, `test`, `docs`, `chore`.
- Before proposing a commit: `pnpm lint`, typecheck and `pnpm test` are green.

## Package manager
- Always pnpm. Never npm or yarn, including `npx` (use `pnpm dlx`).
- If a project has a `package-lock.json` or `yarn.lock`, tell me before doing anything.

## Choosing the stack (new projects only)
TypeScript always, in strict mode.

- **Mobile app** → React Native.
  - Use Expo when it covers the project's needs; tell me upfront if something would need bare React Native (custom native modules, unsupported SDKs).
  - Prefer Expo libraries (`expo-*`) over community alternatives, also in bare React Native: they are usually more mature and better maintained.
- **Web where the content is the product** (blog, docs, portfolio, marketing site) → Astro.
  Static, zero JS by default, load speed and SEO first. Interactivity only in small islands.
  `pnpm create astro@latest <project_name>`
- **Web application** (auth, dynamic state, interactive dashboards, advanced e-commerce) → Next.js (App Router).
  React ecosystem and hybrid rendering (SSR/SSG) for rich UIs.
- If a project could fit both web options, explain the trade-off in two lines and let me choose.
- Styles: Tailwind CSS on the web (official framework integration), NativeWind on React Native.
- State (React, React Native, Next.js):
  - **Server state** (anything that comes from a backend) → TanStack Query. Never copy it into a client store.
  - **Client state** shared across components → Zustand by default. Redux Toolkit when the state is large and complex (many slices, middleware, devtools time-travel) or the project already uses it.
  - Local UI state stays in `useState` / `useReducer`. Don't add a store until state really needs to be shared.
- Don't add dependencies until they are needed, and say why each one is needed.

## Backend (new projects only)
I do little backend; keep it as small as the project allows. Pick the first option that covers the need:

1. **Only login, data and file storage, no custom logic** → Supabase (managed Postgres, auth, storage; SDK for React Native). No backend code.
2. **Backend that only serves a Next.js web** → inside Next.js (route handlers, server actions). No separate service.
3. **Custom API** (for a React Native app, several clients, webhooks) → Hono on Node.js (current LTS).
   - Validate with Zod (`@hono/zod-validator`). Export the app type and use the typed RPC client (`hc<AppType>`) in the clients.
4. **Large domain or team that already knows it** → NestJS. Propose it, don't default to it.
- Existing Express projects stay on Express.

Shared choices:
- Database: PostgreSQL + Drizzle ORM, migrations with drizzle-kit.
- Auth: Better Auth (Expo plugin `@better-auth/expo` for React Native). Not NextAuth/Auth.js: it is in maintenance and its own team recommends Better Auth for new projects. Never hand-rolled JWT auth.
- Tests: Vitest; test routes with `app.request()` instead of starting a server.
- Full stack in one repo: pnpm workspaces — `apps/api`, `apps/web`, `apps/mobile`, `packages/shared` (Zod schemas and types used by both sides).
- No Redis, queues, message brokers or microservices until a real problem needs them.

## CMS (only when non-technical people edit content)
- **Small Astro site** (e.g. a personal portfolio) → Keystatic: Git-based, no database, edited from the browser. For content only I edit, Astro content collections are enough.
- **Next.js project** → Payload: TypeScript config, Postgres, installs inside the Next.js app.
- **React Native app or any other client** → Strapi as a separate service (REST API + admin panel, Postgres).

## TypeScript
- No `any`. Use `unknown` only at boundaries (API responses, parsed input) and narrow it straight away.
- Prefer inference; annotate exported functions and public props.
- If the types are unclear, stop and ask before continuing.
- Prefer ESM and modern syntax.

## Code organisation
- Small components with a single responsibility.
- Composition over configuration. No premature abstractions.
- Shared code lives in clear folders: `components`, `layouts`, `lib`, `utils`.
- Follow the patterns already in the codebase before introducing new ones.
- No TODOs, commented-out code or dead code in a commit.

## UI
- Accessibility is not optional: semantic HTML, labelled inputs, keyboard reachable, managed focus, ARIA only where needed, AA contrast.
- Extract a component instead of duplicating long class lists.
- Readability over visual micro-optimisations.

## Testing and quality
Default tools for new projects. If a project already uses others, keep them.

| Stack        | Unit / component                                   | E2E                         |
|--------------|----------------------------------------------------|-----------------------------|
| Astro        | Vitest (`getViteConfig`) + Astro Container API      | Playwright, against `build` + `preview` |
| Next.js      | Vitest + React Testing Library                      | Playwright                  |
| React Native | Jest (`jest-expo` preset) + React Native Testing Library | Maestro                |
| Hono API     | Vitest + `app.request()`                            | —                           |

- Query by role, label or text, as a user would. Avoid test IDs unless there is no accessible alternative.
- Async Server Components in Next.js are covered by Playwright, not by unit tests.
- No snapshot tests.
- Read `package.json` scripts and `.github/workflows` to find the real commands before running any.
- Add or update tests when behaviour changes, even if not asked.
- After moving files or changing imports, run `pnpm lint`.
- No code with type errors, lint errors or failing tests.

## Performance
- Don't guess performance, bundle size or load times: measure.
- If something seems slow, add instrumentation before optimising.
- Validate a change small before rolling it out across the project.

## How you work with me
- Simple, well-defined tasks: do them directly.
- Complex changes (refactors, new features, architecture): confirm your understanding first.
- If something is unclear or missing, ask concrete questions in one batch. Don't assume implicit requirements.
- When I set a new "always X" / "never Y" rule, propose adding it to this file.

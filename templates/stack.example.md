# Stack defaults for new projects (~/.claude/seny/stack.md)

Read only by `/seny:plan project` when it chooses the stack of a new app. Existing projects keep what they use.
If this file doesn't exist, Seny falls back to `${CLAUDE_PLUGIN_ROOT}/templates/stack.example.md`.

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

## Test tooling (new projects only)
Default tools for new projects. If a project already uses others, keep them.

| Stack        | Unit / component                                   | E2E                         |
|--------------|----------------------------------------------------|-----------------------------|
| Astro        | Vitest (`getViteConfig`) + Astro Container API      | Playwright, against `build` + `preview` |
| Next.js      | Vitest + React Testing Library                      | Playwright                  |
| React Native | Jest (`jest-expo` preset) + React Native Testing Library | Maestro                |
| Hono API     | Vitest + `app.request()`                            | —                           |

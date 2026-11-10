# Personal defaults (~/.claude/CLAUDE.md)

Applies to every project. A project's own CLAUDE.md overrides anything here.
Stack choices for new projects live in `~/.claude/seny/stack.md` (see `templates/stack.example.md`): only `/seny:plan project` reads them, so they cost nothing in everyday sessions.

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

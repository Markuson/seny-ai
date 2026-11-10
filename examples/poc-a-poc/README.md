# Example: Poc a poc

*Poc a poc* ("little by little" in Catalan) is an imaginary habit tracker for families: an Expo app and a small Hono API in a pnpm monorepo. Its documents were written the way Seny writes them, and the project is frozen halfway through its second feature, so you can see every status at once.

Only the documents are here, not the app's code: they're what this example is about.

## Where it stands

- `foundation` is **done**: the app runs, deploys, and recorded an all-green baseline.
- `streaks` is **in progress**:
  - E1-S1 is `done`,
  - E1-S2 is in `review`: the reviewer asked for a change, it was fixed, and the second review approved it. It's waiting for the human to say "done",
  - E1-S3 is `in-progress`, interrupted half-way, with `Notes:` to resume from,
  - E2-S1 is `todo`.
- `family-sharing` is waiting on the roadmap.

## What to look at

| File | Shows |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Project rules with the `## Seny` section, and product rules the reviewer treats as blockers |
| [`docs/project/product.md`](docs/project/product.md) | Greenfield research: vision, users, MVP |
| [`docs/project/architecture.md`](docs/project/architecture.md) | Stack, structure, data model, boundaries, key decisions, the design-system line |
| [`docs/project/design-system.md`](docs/project/design-system.md) | Tokens, typography, base components |
| [`docs/project/roadmap.md`](docs/project/roadmap.md) | Features in order, with types and statuses |
| [`docs/project/baseline.md`](docs/project/baseline.md) | The all-green baseline recorded by foundation |
| [`docs/features/foundation/plan.md`](docs/features/foundation/plan.md) | A finished plan |
| [`docs/features/streaks/research.md`](docs/features/streaks/research.md) | Feature research with spike findings |
| [`docs/features/streaks/plan.md`](docs/features/streaks/plan.md) | Stories in every status: Approach, Verify, Notes and review records |
| [`docs/features/streaks/design.md`](docs/features/streaks/design.md) | A feature design that builds on the design system |

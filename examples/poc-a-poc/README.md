# Example: Poc a poc

*Poc a poc* ("little by little" in Catalan) is an imaginary habit tracker for families: an Expo app and a small Hono API in a pnpm monorepo. Its documents were written the way Seny writes them, and the project is frozen halfway through its second epic, so you can see every status at once.

Only the documents are here, not the app's code: they're what this example is about.

## Where it stands

- `foundation` is **done**: the app runs, deploys, and recorded an all-green baseline.
- `streaks` (size M) is **in progress**:
  - S1 is `done`,
  - S2 is in `review`: the reviewer asked for a change, it was fixed, and the second review approved it. It's waiting for the human to say "done",
  - S3 is `in-progress`, interrupted half-way, with `Notes:` to resume from,
  - S4 is `todo`.
- Every document is `approved`: each one went through its own review before the next was written.
- `family-sharing` is waiting on the roadmap.

## What to look at

| File | Shows |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Project rules with the `## Seny` section, and product rules the reviewer treats as blockers |
| [`docs/project/product.md`](docs/project/product.md) | Product research: vision, users, MVP |
| [`docs/project/architecture.md`](docs/project/architecture.md) | Stack, structure, data model, boundaries, key decisions, the design-system line |
| [`docs/project/design-system.md`](docs/project/design-system.md) | Tokens, typography, base components |
| [`docs/project/roadmap.md`](docs/project/roadmap.md) | Epics in order, with type, size and status |
| [`docs/project/baseline.md`](docs/project/baseline.md) | The all-green baseline recorded by foundation |
| [`docs/epics/foundation/plan.md`](docs/epics/foundation/plan.md) | A finished plan |
| [`docs/epics/streaks/research.md`](docs/epics/streaks/research.md) | Epic research (size M) with spike findings |
| [`docs/epics/streaks/plan.md`](docs/epics/streaks/plan.md) | Stories in every status: Approach, Verify, Notes and review records |
| [`docs/epics/streaks/design.md`](docs/epics/streaks/design.md) | An epic design that builds on the design system |

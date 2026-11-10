# baseline.md

Format for `<docs>/project/baseline.md`: the state of the project's checks before a change, so that only **new** failures block. Small on purpose: implement, fix and the reviewer read it on every story.

Never edit it by hand. It is recorded by running the checks:
- `/seny:research project` (existing code) records the first one.
- The last `foundation` story records an all-green one for a new app.
- `/seny:implement` and `/seny:fix` re-record it before changing code when the state says it is missing or **stale** (the default branch moved on since it was recorded).

```markdown
# Baseline

Recorded: <YYYY-MM-DD> · Commit: `<short sha of HEAD when the checks ran>` · By: <codebase analysis | foundation | implement <story id> | fix>

| Check | Command | Result | Pre-existing failures |
|---|---|---|---|
| lint | `<cmd>` | ✓ / ✗ <n> errors | <files or rules> |
| typecheck | `<cmd>` | ✓ / ✗ <n> errors | <files> |
| tests | `<cmd>` | ✓ / ✗ <n> failing of <total> | <test names> |
| build | `<cmd>` | ✓ / ✗ / not run | |
```

Keep the `Commit:` part exactly in this shape: `scripts/state.sh` reads it to tell whether the baseline is still current.

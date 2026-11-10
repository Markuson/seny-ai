# plan.md

Format for `<docs>/features/<slug>/plan.md`, used by features, light changes and evolutions. Epics and stories carry the state of the work: the plan, not the chat, is the source of truth.

```markdown
# <Feature name>

Branch: `feature/<slug>`
Type: <feature | evolution — omit for a feature>
Research: <`research.md` | `../../project/product.md` (foundation) | none (light)>

## Goal
<2–3 lines: what we deliver and for whom>

## Scope
- In: <item> — <why>
- Out: <item> — <why>

## Architecture changes
<What this feature adds on top of architecture.md. Omit lines that don't apply.>
- Structure: <new folders, modules, routes or screens>
- Data and state: <new entities and fields, server vs local state, queries>
- Boundaries: <new external APIs, auth rules, where input is validated>
- App-wide changes: <changes to architecture.md or design-system.md, approved or pending>

## Key decisions
- <decision> — <why> (rejected: <alternative>)

## Epics

### E1 · <epic title>
<one line: the value this epic delivers>

#### E1-S1 · <story title> — `todo`
- Story: As a <role>, I want <action>, so that <benefit>. (Omit for purely technical stories.)
- Acceptance criteria:
  - [ ] <observable, checkable outcome>
- Approach:
  - <how to build it, anchored to `path/file.ts:42` or a symbol: what to extend, what to add, which pattern to follow>
- Files: <expected files or areas>
- Tests: `tdd` | `after` | `none` — <what to test>
- Verify: auto — <the tests or commands that prove it> · manual — <steps to check it by hand: screen, device, data>
- Design: <`design.md#screen-...` or `../../project/design-system.md#...` — UI stories only>
- Depends on: <story ids, or —>
- Notes: <written by /seny:implement only when a story stops half-way: done so far, decisions taken, next step>
```

Review results are appended under the story by the review loop:
```markdown
- Review <YYYY-MM-DD>: <APPROVED | CHANGES REQUESTED>
  - [ ] [blocker] path/file.ts:42 — <problem> → <fix>
  - [ ] [should] ...
```

- Stories: as many as the work needs, each small (one commit, a handful of files, reviewable in one sitting).
- Prefer vertical slices over horizontal layers. The first epic leaves a thin end-to-end slice running.
- Tests: `tdd` for logic (business rules, state, validation, data transformations, hooks, utilities, API handlers); `after` for UI and wiring (component tests, or an E2E proposed in review); `none` for configuration, styling, docs. A story that changes untested existing code starts with characterization tests, whatever its mode.
- Approach: 2–4 bullets, concrete enough that `/seny:implement` can start in a fresh session without re-exploring the code. Skip it only for trivial stories (copy, config, a one-line change).
- Verify: the automatic part is what the reviewer checks; the manual part is what I check before saying `done`. For hardware, devices or external services, the manual part matters most.
- Notes: absent until a story is interrupted; `/seny:implement` reads it first when it resumes and clears it when the story reaches `review`.
- Light plans (`Research: none (light)`) keep the `Branch:` line, Goal, Scope and one epic with 1–3 stories; other sections only when there is something to say.
- Evolutions (`Type: evolution`) are planned by `/seny:evolve` with this same format plus the specifics in `templates/feature/evolution.md`.
- Statuses, exactly: `todo`, `in-progress`, `review`, `done`.
- Acceptance criteria are outcomes I can check, not tasks ("the form shows an error when the email is invalid", not "add validation").

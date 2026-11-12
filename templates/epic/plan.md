# plan.md

Format for `<docs>/epics/<slug>/plan.md`, used by epics, light changes and evolutions. An epic is one row of the roadmap: one deliverable capability, one branch, one pull request. Its stories are a flat list; if they need grouping, the epic is really two epics. The plan, not the chat, is the source of truth.

```markdown
# <Epic name>

Status: <draft | shape approved (YYYY-MM-DD) | approved (YYYY-MM-DD)>
Size: <S | M | L>
Branch: `<type>/<slug>`
Type: <epic | evolution | light — omit for an epic>
Research: <`research.md` | none (S) | none (light) | `../../project/product.md` (foundation)>

## Goal
<2–3 lines: what we deliver and for whom>

## Scope
- In: <capability> — <why>
- Out: <capability> — <why, and where it goes instead>

## Architecture changes
<Only what this epic adds on top of architecture.md; point to its sections, never restate them. Omit lines that don't apply, or write "none".>
- Structure: <new folders, modules, routes or screens>
- Data and state: <new entities and fields, server vs local state, queries>
- Boundaries: <new external APIs, auth rules, where input is validated>
- App-wide changes: <changes to architecture.md or design-system.md, approved or pending>

## Key decisions
- <decision> — <why> (rejected: <alternative>)

## Stories

#### S1 · <story title> — `todo`
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

In the **shape** pass (size L and `foundation`), stories carry only their heading and one line saying what they deliver; the stories pass fills in the rest.

Review results are appended under the story by the review loop:
```markdown
- Review <YYYY-MM-DD>: <APPROVED | CHANGES REQUESTED>
  - [ ] [blocker] path/file.ts:42 — <problem> → <fix>
  - [ ] [should] ...
```

- Stories: each small (one commit, a handful of files, reviewable in one sitting, one implement session). Ids are `S1`, `S2`… within the epic; elsewhere they are written `<slug> S2`.
- Size: S is 1–3 stories, M is 4–8, L is more than 8. A plan that doesn't fit its size says so: resize it on the roadmap, or split the epic.
- Prefer vertical slices over horizontal layers. The first story leaves a thin end-to-end slice running.
- Tests: `tdd` for logic (business rules, state, validation, data transformations, hooks, utilities, API handlers); `after` for UI and wiring (component tests, or an E2E proposed in review); `none` for configuration, styling, docs. A story that changes untested existing code starts with characterization tests, whatever its mode.
- Approach: 2–4 bullets, concrete enough that `/seny:implement` can start in a fresh session without re-exploring the code. Skip it only for trivial stories (copy, config, a one-line change).
- Verify: the automatic part is what the reviewer checks; the manual part is what I check before saying `done`. For hardware, devices or external services, the manual part matters most.
- Notes: absent until a story is interrupted; `/seny:implement` reads it first when it resumes and clears it when the story reaches `review`.
- Light plans (`Type: light`, `Research: none (light)`) are small changes outside the roadmap: Status, Branch, Goal, Scope and 1–3 stories; other sections only when there is something to say.
- Evolutions (`Type: evolution`) are planned by `/seny:evolve` with this same format plus the specifics in `templates/epic/evolution.md`.
- Never repeat the project docs: the stack, the conventions and the design tokens live in `architecture.md` and `design-system.md`; a plan names the sections it relies on.
- Statuses, exactly: `todo`, `in-progress`, `review`, `done`.
- Acceptance criteria are outcomes I can check, not tasks ("the form shows an error when the email is invalid", not "add validation").

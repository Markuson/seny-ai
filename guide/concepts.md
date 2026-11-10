# Concepts

How Seny thinks, one idea at a time. If you only read one page after the README, make it this one.

- [The big picture](#the-big-picture)
- [Tracks: how much process](#tracks-how-much-process)
- [The documents](#the-documents)
- [Anatomy of a story](#anatomy-of-a-story)
- [Statuses and who moves them](#statuses-and-who-moves-them)
- [The baseline](#the-baseline)
- [Characterization tests](#characterization-tests)
- [Reviews](#reviews)
- [Spikes](#spikes)
- [Evolutions and "In transition"](#evolutions-and-in-transition)
- [Design](#design)
- [Shared and private mode](#shared-and-private-mode)
- [The state snapshot](#the-state-snapshot)
- [Context hygiene](#context-hygiene)
- [Glossary](#glossary)

---

## The big picture

Seny turns "build me X" into a short chain of documents, each one small enough to read in two minutes:

```
idea or problem
   │
   ▼
research.md ──▶ plan.md (+ design.md) ──▶ code + tests ──▶ review record ──▶ "done" + commit
```

Two rules hold everything together:

1. **The documents are the memory, not the chat.** Every command starts by reading the documents and ends by updating them. That's why you can `/clear` between phases, switch machines, or come back next week.
2. **Every phase has one job.** Research understands. Plan decides. Implement builds. Review judges. You approve. Nobody does someone else's job: research doesn't propose solutions, the implementer doesn't approve its own work, the reviewer doesn't fix code.

Documents live at two levels:

- **Project** (`docs/project/`): things true for the whole app, like the architecture, the design system and the roadmap. They live as long as the app.
- **Feature** (`docs/features/<slug>/`): one piece of work. They build on the project docs and never repeat them.

---

## Tracks: how much process

Not every change deserves the full cycle. Seny's tracks go from "just do it" to "let's think about the whole app":

| Track | Typical examples | What you get | Commands |
|---|---|---|---|
| **Direct** | Fix a typo, change a copy text, bump a patch version | Nothing from Seny. Claude just does it. | none |
| **Fix** | "The cart crashes when it's empty" | A failing test that reproduces the bug, the root cause, a minimal fix, an independent review | `/seny:fix` |
| **Spike** | "Can `react-native-ble-plx` reconnect in the background on Android?" | A time-boxed experiment on a throwaway branch and written findings | `/seny:spike` |
| **Light** | "Add a 'sort by date' option to the list" | A tiny plan (1–3 stories), then the normal implement and review loop | `/seny:plan light` |
| **Feature** | "Families can share habits" | Research, a plan with epics and stories, a design doc if there's UI | `/seny:research` → `/seny:plan` |
| **Evolve** | "Move server state from Redux to TanStack Query" | Options, a migration strategy, small stories that keep the app working | `/seny:evolve` |
| **Project** | A new app, or adopting Seny in an existing repo | Product or codebase research, architecture, roadmap, baseline | `/seny:init`, `/seny:research project`, `/seny:plan project` |

**Risk signals** move any change up to at least **Feature**, however small it looks: data model changes or migrations, auth or permissions, payments or personal data, a new external service, a new screen or flow, undecided requirements, changes across many modules, untested legacy code, and anything hard to reverse.

Not sure? `/seny:help <what you want>` sizes it for you, explains why in one line, and picks the safer track when it hesitates.

Tracks also escalate on their own. `/seny:fix` stops if the root cause turns out to be a design flaw. `/seny:plan light` stops if the change needs a new data model. `/seny:evolve` sends you back to research if what you described is really a new feature.

---

## The documents

### Project documents (`docs/project/`)

| Document | What it holds | Written by | Read by |
|---|---|---|---|
| `product.md` | Vision, users, core needs, MVP, constraints (new apps) | `/seny:research project <idea>` | plan, feature research |
| `codebase.md` | The existing code as it is: conventions in practice, test coverage map, tech debt with `file:line`, fragile areas | `/seny:research project` (existing code), `refresh` | research, plan, evolve, fix |
| `baseline.md` | Which checks already failed, with commands and the commit | research (existing code), the last foundation story, implement and fix when it's stale | implement, fix, reviewer |
| `architecture.md` | Stack, structure, data and state, data model, boundaries, conventions, areas **In transition**, key decisions | plan project, research (existing code); updated after your yes | everyone who writes code |
| `design-system.md` | Direction, tokens, typography, spacing, motion, base components, accessibility rules | plan project (new apps), research (existing UI) | design, implement, reviewer |
| `roadmap.md` | Features and evolutions in order, each with a type, goal, dependencies and status | plan project, plan, evolve, review | help |

### Feature documents (`docs/features/<slug>/`)

| Document | What it holds | Written by |
|---|---|---|
| `research.md` | One page: problem, users, constraints, codebase, fit with the project, challenges, risks, assumptions, open questions. Plus `Spike findings` when a spike answered something. | `/seny:research <feature>`, `/seny:spike`, `/seny:evolve` |
| `plan.md` | Goal, scope, architecture changes, key decisions, epics and stories with statuses, and the review records | `/seny:plan`, `/seny:evolve`; statuses by implement and review |
| `design.md` | Screens, components, states, flows, copy, accessibility, story mapping. Only when there's UI. | `/seny:plan <slug> design` |

**Who wins when they disagree?** The plan is the source of truth for a feature; `architecture.md` and `design-system.md` are the source of truth for the app. If the code contradicts them, Seny stops and proposes a change instead of quietly drifting.

**App-wide changes need your yes.** A feature that needs a new shared entity, token or base component lists it in its plan and asks before touching the project docs.

---

## Anatomy of a story

Here is one story from the [example project](../examples/poc-a-poc/docs/features/streaks/plan.md) as it looked when it was planned, field by field:

```markdown
#### E1-S2 · Count the current streak — `todo`
- Story: As a family member, I want to see how many days in a row I've done a habit, so that I keep going.
- Acceptance criteria:
  - [ ] A habit done today and on the 4 previous days shows a streak of 5
  - [ ] Missing yesterday resets the streak to 1 when today is done, 0 when it isn't
  - [ ] Days are counted in the family's time zone, not the device's
- Approach:
  - Add `currentStreak(checkIns, today, timeZone)` to `packages/shared/src/streaks.ts`, a pure function
  - Expose it through `GET /habits/:id` in `apps/api/src/routes/habits.ts:41`, next to `lastCheckIn`
- Files: packages/shared/src/streaks.ts, apps/api/src/routes/habits.ts
- Tests: `tdd` — the three criteria, plus a daylight-saving change
- Verify: auto — `streaks.test.ts`, `habits.route.test.ts` · manual — check in a habit on two days on the simulator and see 2
- Depends on: E1-S1
```

| Field | Why it's there |
|---|---|
| **Id and status** | `E1-S2` = epic 1, story 2. The status is the backtick word at the end of the heading; tools read it from there. |
| **Story** | Who wants it and why. Omitted for purely technical stories. |
| **Acceptance criteria** | Outcomes you can check, not tasks. "Shows a streak of 5", not "add streak logic". With `tdd`, each one becomes a test. |
| **Approach** | *How* to build it, anchored to real files and symbols. It's what lets `/seny:implement` start in a fresh session without exploring the code again. Skipped only for trivial stories. |
| **Files** | Where the change is expected. Helps keep the story in scope and the reviewer focused. |
| **Tests** | `tdd` for logic, `after` for UI and wiring, `none` for config, styling and docs. Untested code gets characterization tests whatever the mode. |
| **Verify** | *auto*: the tests or commands that prove it (the reviewer checks them). *manual*: what you check by hand before saying "done", on a device if it matters. |
| **Design** | For UI stories: the section of `design.md` or `design-system.md` it must match. |
| **Depends on** | Stories that must be `done` first. `/seny:implement next` respects it. |
| **Notes** | Appears only if a story stops half-way (context full, end of the day): what's done, decisions taken, next step. `/seny:implement` resumes from it and deletes it when the story reaches `review`. |

Under a story, the review loop appends its records:

```markdown
- Review 2026-11-04: CHANGES REQUESTED
  - [x] [blocker] apps/api/src/routes/habits.ts:58 — streak computed in UTC → pass the family time zone
  - [ ] [should] packages/shared/src/streaks.ts:12 — sort check-ins once, not per call → sort in the caller
```

---

## Statuses and who moves them

| From → to | Who | When |
|---|---|---|
| — → `todo` | `/seny:plan`, `/seny:evolve` | The story is planned |
| `todo` → `in-progress` | `/seny:implement` | It starts building |
| `in-progress` → `review` | `/seny:implement` | The checks pass against the baseline |
| `review` → `in-progress` | the review loop | The reviewer requested changes, or you want a `should` fixed first |
| `review` → `done` | **you**, through the review loop or `/seny:review <id> done` | The reviewer approved and you checked it by hand |

Features have their own status in `roadmap.md`: `todo` → `in-progress` (when its plan is written) → `done` (when every story is done).

When a story becomes `done`, Seny proposes a commit with the story id in it, following your commit rule: it commits if you told it to, doesn't if you told it not to, and asks otherwise. When the whole feature is done, it also proposes the PR title and body from the plan. Pushing is always yours.

---

## The baseline

**The problem.** Old projects often have failing lint rules, type errors or red tests. If every story had to make everything green, nobody could ever change anything. If nobody looked at the checks, things would rot further.

**The rule.** Before changing code, Seny records which checks already fail. After the change, only **new** failures block. Pre-existing ones are reported, never blamed on you, and fixing one along the way is applauded but not required.

`docs/project/baseline.md` looks like this:

```markdown
# Baseline

Recorded: 2026-11-10 · Commit: `a1b2c3d` · By: codebase analysis

| Check | Command | Result | Pre-existing failures |
|---|---|---|---|
| lint | `pnpm lint` | ✗ 3 errors | src/legacy/cart.js (no-unused-vars ×3) |
| typecheck | `pnpm typecheck` | ✓ | |
| tests | `pnpm test` | ✗ 1 failing of 212 | "checkout applies coupon twice" |
| build | `pnpm build` | ✓ | |
```

After a story, the reviewer compares:

| Check | Baseline | Now | Verdict |
|---|---|---|---|
| lint | 3 errors in `cart.js` | 3 errors in `cart.js` | unchanged, fine |
| tests | 1 failing | 2 failing: the old one and "streak resets at midnight" | **new failure → blocker** |

**When is a baseline stale?** The state snapshot checks it with git every time a command runs:

- **Current**: it was recorded in this branch's history, and every commit since then is yours. Your stories already passed the checks against it, so it's still the right reference.
- **Stale**: it was recorded on another line of history, or **other people's work** came in since (you pulled, merged or rebased onto a teammate's commits). Their red test isn't yours, so before your next story `/seny:implement` or `/seny:fix` runs the checks on a clean tree and records a fresh baseline, telling you what changed.

Where baselines come from: `/seny:research project` records the first one for existing code; for a new app, the last `foundation` story records an all-green one; after that, implement and fix keep it fresh. Never edit it by hand.

---

## Characterization tests

Before changing code that has no tests, Seny first writes tests that pin down **what the code does today**, even if today's behaviour is odd, and runs them green. Then it changes the code. If behaviour moves when it shouldn't, a test goes red.

```ts
// Characterization: documents current behaviour before refactoring formatPrice.
describe('formatPrice (current behaviour)', () => {
  it('rounds half up to 2 decimals', () => {
    expect(formatPrice(10.005)).toBe('10.01 €');
  });
  it('shows negative amounts without a sign (existing quirk, kept on purpose)', () => {
    expect(formatPrice(-5)).toBe('5.00 €');
  });
});
```

Two rules come with them:

- In an evolution, characterization tests must pass **unchanged**. If one needs editing, Seny stops and asks why: either behaviour changed by accident, or the story should say it changes.
- A quirk you want to fix is a separate story (or a `/seny:fix`), not a silent change hidden in a refactor.

---

## Reviews

Every story and every fix is judged by **`seny:reviewer`**, a separate agent that:

- has never seen the conversation, so it can't be charmed by your reasoning;
- reads your `CLAUDE.md` rules, the plan, the story, the project docs and the diff;
- runs the project's checks and compares them with the baseline (it never runs E2E tests; it proposes them);
- can't edit anything: a hook blocks file tools and any command that could change files.

Its checklist, in order: acceptance criteria and the automatic part of `Verify`; scope and architecture (including the rule for new code in areas **In transition**); correctness; tests; types and conventions; design and accessibility (UI only); security.

Each finding has a severity:

| Severity | Meaning | What happens |
|---|---|---|
| `blocker` | Must be fixed before done: an unmet criterion, a bug, a new check failure, a security issue, a broken rule | The story can't be approved |
| `should` | Worth fixing now, but you decide | Listed for you; fixed only if you say so |
| `nit` | Taste | Mentioned in chat, not recorded |

**Automatic or manual.** With the default review mode (`auto`), `/seny:implement` launches the reviewer as soon as the checks pass. If there are blockers, it fixes them once (a failing test first when it's a bug) and asks for a second review. Then it stops and shows you the result. In `manual` mode, implement stops at `review` and you run `/seny:review` yourself. Either way, only you say `done`. How to switch: [configuration](configuration.md#review-mode).

**The learning loop.** If the reviewer finds the same kind of problem in two stories, Seny proposes one new rule for your project's `CLAUDE.md` that would have prevented both. The method gets a little smarter every time it catches something twice.

**What you check.** When the review is approved, Seny shows you the manual part of the story's `Verify` line: the things only a human (or a real device) can confirm. Then you decide.

---

## Spikes

Research is forbidden from writing code, and plan has to decide. Some questions only code can answer:

- Does this BLE library survive reconnection in the background on Android?
- Does Expo cover this native SDK, or do we need bare React Native?
- What does this third-party API *really* return?
- Is this approach fast enough on a cheap phone?

Guessing is rauxa. A **spike** is rauxa with a helmet on:

1. **Frame**: one question, what each answer would change, how we'll know, a time box. You approve.
2. **Try**: throwaway code on a `spike/<slug>` branch. No tests, no polish, never merged. Anything that runs on a device or hardware is run by you, with exact steps; Seny never guesses a result.
3. **Keep or drop**: commit the spike code on its branch for reference, or discard it.
4. **Record**: back on your branch, the findings go into the feature's `research.md` under `## Spike findings`: answer, evidence, what was tried, consequences for the plan.

Then `/seny:plan` decides with facts instead of hopes. "We don't know yet, because…" is a valid finding too.

---

## Evolutions and "In transition"

An **evolution** changes *how* the app is built without changing *what* it does: a framework or SDK upgrade, JavaScript to TypeScript, unifying two fetch patterns, swapping a library, restructuring folders.

`/seny:evolve` measures the current footprint, reads the official migration guides for upgrades, gives you 2–3 options (including "do nothing for now" when it's real), and plans the one you choose as small stories:

1. **Characterization tests first** for the areas that will change.
2. **Measurable slices**, each with a `Progress:` line ("migrate the cart module · 3/11 modules"). Every slice leaves the app working.
3. **A final cleanup epic**: remove the old pattern, adapters, flags and dependencies.

Strategies it can choose: **strangler fig** (new beside old, callers move one by one), **expand-contract** (for data and APIs: add the new shape, migrate, remove the old), **adapter**, **feature flag**, **folder by folder** (great for TypeScript or lint migrations), **in place** (only for small, well-tested areas).

While the evolution is open, `architecture.md` carries a row like this:

```markdown
## In transition
| Area | From | To | Rule for new code | Progress | Evolution |
|---|---|---|---|---|---|
| Server state | Redux thunks | TanStack Query | New data fetching uses TanStack Query | 4/11 modules | `state-to-tanstack` |
```

The **rule for new code** is the clever bit: any story, in any feature, that touches server state must use TanStack Query, even before the migration ends. The reviewer treats new code in the old pattern as a blocker. The hole stops getting deeper while you fill it. When the last story is done, Seny checks the old pattern is really gone and proposes removing the row.

---

## Design

UI work has two layers, like the documents:

- **The design system** (`design-system.md`): direction, semantic tokens mapped to your Tailwind / NativeWind theme, typography, spacing, motion, base components and accessibility rules. New apps get it during `/seny:plan project` (you pick between two visual directions); existing apps get the one that actually exists described honestly. If you decline it, `architecture.md` remembers (`Design system: declined on <date>`) and nobody asks again.
- **Feature design** (`design.md`): only what the feature adds. Screens with a layout sketch, every state (loading, empty, error, success) with its copy, flows including the unhappy path, platform details, and a map from sections to stories. New reusable tokens or components are proposed for the design system instead of living in one feature.

Implement uses tokens and base components instead of hard-coded values, and the reviewer checks it, along with semantics, labels, focus, contrast and touch targets. If design skills are installed, plan and implement load them ([which ones](configuration.md#companion-skills)).

---

## Shared and private mode

`/seny:init` asks where the documents live:

| | Shared (`docs/`) | Private (`.seny/`) |
|---|---|---|
| For | Your own projects, teams that want the docs in the repo | Client or team repos where you can't add files |
| Committed | Yes, like any code | No: `.seny/` is in `.git/info/exclude` |
| Project rules | `CLAUDE.md` with a `## Seny` section | `.seny/CLAUDE.md`, loaded through a one-line `CLAUDE.local.md` (`@.seny/CLAUDE.md`), also excluded |
| Tracked files modified | Only `CLAUDE.md` (shown to you first) and the new `docs/` | None |

`.git/info/exclude` works like `.gitignore` but lives only on your machine, so nobody else sees a change.

---

## The state snapshot

Every Seny command starts by running `scripts/state.sh`, a read-only script that prints a short picture of the project. It's what lets each command know where you are without reading everything:

```
Docs root: docs
Branch: feature/streaks (default: main)
Uncommitted changes: none
Project rules: CLAUDE.md
package.json: present · lockfiles: pnpm-lock.yaml
Project docs: architecture.md baseline.md design-system.md product.md roadmap.md
Baseline: current (recorded 2026-10-30 at 3f9c2e1, 4 own commits since)
Review mode: auto
Roadmap: 1 done
  | 2 | streaks | feature | Show and keep streaks per habit, with gentle reminders | foundation | `in-progress` |
  | 3 | family-sharing | feature | Invite codes, kid profiles and shared habits | streaks | `todo` |
Open features:
  streaks: 1/4 done · 1 review · 1 in-progress · 1 todo [design.md plan.md research.md]
Done features (1): foundation
Open stories:
    streaks E1-S2 · Count the current streak — `review`
    streaks E1-S3 · Show the streak on the habit card — `in-progress`
    streaks E2-S1 · Remind before the streak breaks — `todo`
```

Finished work collapses into one line, so the snapshot costs the same in month one and in month twenty. It runs from the repository root even if you started Claude Code in a subfolder, and it never fails a command: if something is missing, it just says so.

---

## Context hygiene

Long sessions get expensive and forgetful. Seny's habits:

- **`/clear` between phases.** Each command's last line suggests it when it's a good moment. The documents carry the state.
- **`Notes:` when a story stops half-way.** If the context gets heavy mid-story, implement writes what's done and what's next under the story, and asks you to `/clear` and run the same command again.
- **Explore subagents** for big sweeps (codebase analysis, evolution footprints): they read a lot and return only conclusions.
- **Approach lines** so implementing doesn't re-explore what planning already found.

---

## Glossary

| Term | Meaning |
|---|---|
| **Seny** | Catalan for level-headed common sense: knowing how much is enough. |
| **Rauxa** | Seny's rival: the sudden, reckless impulse. Welcome in spikes, banned near the database. |
| **Pinya** | The base of a Catalan human tower. Seny's `foundation` feature plays that role. |
| **RPI** | Research → Plan → Implement: understand, decide, build. |
| **Track** | How much process a change gets: Direct, Fix, Spike, Light, Feature, Evolve or Project. |
| **Epic** | A group of stories that delivers one piece of value. |
| **Story** | The smallest unit of work: one commit, a handful of files, works end to end. |
| **Vertical slice** | A story that cuts through every layer it needs (UI, logic, data) so it works on its own, instead of "all the database first". |
| **Baseline** | The recorded state of the checks before a change, so that only new failures block. |
| **Characterization test** | A test that pins down what existing code does today, before changing it. |
| **Spike** | A time-boxed experiment with throwaway code to answer one question. |
| **Evolution** | A change to how the app is built, migrated in small working steps. |
| **In transition** | An area of the architecture halfway through an evolution, with a rule for new code. |
| **Strangler fig** | Migration where the new implementation grows beside the old one until the old one can be removed. |
| **Expand-contract** | Migration for data and APIs: add the new shape, move readers and writers, remove the old shape. |
| **Blocker / should / nit** | Review severities: must fix, worth fixing, taste. |
| **Review mode** | `auto` (implement calls the reviewer) or `manual` (you run `/seny:review`). |
| **Docs root** | Where Seny's documents live: `docs/` (shared) or `.seny/` (private). |

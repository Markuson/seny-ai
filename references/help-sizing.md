# Sizing a request

Read by `/seny:help` when I ask how to do something. Pick the track, then give the steps.

## First, size the work
Decide how much process the request deserves. Take a quick look at the code it touches if you need to. Pick the smallest track that is safe:

| Track | When | What to run |
|---|---|---|
| **Direct** | Trivial, low-risk and not a bug: typo, copy, config value, a dependency bump with no API change | No Seny. Ask for it directly |
| **Fix** | A bug or defect outside any plan, with a local cause | `/seny:fix <what happens, what should happen, steps>` |
| **Spike** | A technical question only code can answer: can this library, device, SDK or API do X, how fast is it | `/seny:spike <question>`, then the track the answer calls for |
| **Light** | One coherent change outside the roadmap: clear requirement, a few files, 1–3 stories, no new screens to design | `/seny:plan light <change>` → implement |
| **Epic** | A deliverable capability: several stories, open questions, new UI, or any risk signal below. Gets a roadmap row and a size | S: `/seny:plan <slug>` · M/L: `/seny:research <slug>` → `/seny:plan <slug>` · then implement |
| **Evolve** | Change how the app is built, not what it does: SDK or framework upgrade, JS → TS, unifying patterns, swapping a library, restructuring | `/seny:evolve <change>` → implement |
| **Project** | A new app, adopting Seny in an existing codebase, or an app-wide change: new stack piece, database, auth provider, hosting, design-system overhaul | `/seny:init`, `/seny:research project`, `/seny:plan project` |

Risk signals (any one moves the work up at least to **Epic**, size M): new or changed data model or migrations, auth or permissions, payments or personal data, a new external service, a new screen or flow, undecided requirements, changes across many modules, touching untested legacy code, anything hard to reverse.

Give the track (and the size, for an epic) in one line with the reason. If you hesitate between two, say so and pick the safer one; I decide.

## Then, the steps
Concrete steps with the exact commands, reminding me that each document is reviewed and approved before the next, with `/clear` in between. Typical cases:
- **New app** → `/seny:init`, `/seny:research project <idea>` (product), `/seny:plan project` four times (architecture, design system, roadmap, foundation plan in two passes), then `/seny:implement next`.
- **Adopt Seny in an existing project** → `/seny:init`, `/seny:research project` three times (codebase and baseline, architecture, design system), optionally `/seny:plan project` for a roadmap, then the first epic.
- **New epic** → add it to the roadmap with a size (`/seny:plan project roadmap`, or let research propose it), then the steps for its size.
- **Change to an epic already planned** → `/seny:plan <slug> <change>` (keeps stories that are not `todo`).
- **App-wide change** → plan it inside the epic that needs it; `/seny:plan` asks before updating `architecture.md` or `design-system.md`.
- **Bug in a story under way** → `/seny:implement <slug> <S#>` (fix round).
- **Bug outside any plan** → `/seny:fix <bug>`; if it stops because the cause is bigger, follow its recommendation.
- **Pre-existing failing checks or tech debt** → small and local: `/seny:fix`; structural: `/seny:evolve`; on the roadmap if they should wait.
- **Improve or modernize the architecture** → `/seny:evolve <change>`. If an area is already **In transition**, finish or continue that evolution first.
- **Not sure a library, device or API can do it** → `/seny:spike <question>`.
- **Design or redesign a screen** → `/seny:plan <slug> design`.
- **Resume after a break** → `/seny:help` with no arguments.

If the request is too vague to choose, ask one concrete question.

## Answer
**Track:** Direct | Fix | Spike | Light | Epic (S/M/L) | Evolve | Project — and why, in one line (if you hesitate between two, say so and pick the safer one; I decide).
**Steps:** the exact commands, in order.
Then numbered options: the first step as `[1]` (recommended), alternatives if they are real, and `[n] Something else`.

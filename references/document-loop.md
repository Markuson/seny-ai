# Document loop

Shared by `/seny:research`, `/seny:plan` and `/seny:evolve`. **One document per run**: write it, get it approved, commit, stop. The next document starts in a fresh session (`/clear`) and reads this one from disk.

Seny's planning is proportional: how hard you interview me depends on what the document decides.

## Depth by weight

| Document | Question rounds | Passes |
|---|---|---|
| `product.md`, `architecture.md` (new app) | as many as it takes, usually 2–4 | 1 |
| `design-system.md` (new app) | 1–2, plus my choice between two directions | 1 |
| `roadmap.md` | 1–2 | 1 |
| `plan.md` for `foundation` or a size-L epic | 1–2 per pass | 2: shape, then stories |
| `research.md` and `plan.md` for a size-M epic | 1–2 | 1 |
| `plan.md` for a size-S epic, a light plan | 0–1 | 1 |
| `design.md` | 1–2 | 1 |
| Existing code: `codebase.md`, `architecture.md`, `design-system.md` as they are | 1: only what the code can't answer | 1 |
| Evolution `research.md` | 1, then my choice between options | 1 |

## Steps

1. **Inputs.** Read the documents this one builds on (the caller lists them), and only the parts you need: an epic reads its roadmap row and its **epic notes** first, then the sections of `product.md`, `architecture.md` or `<docs>/project/inputs/` they point to. If an input is still `Status: draft`, stop: tell me to review and approve it first, unless I say to go on anyway. If this document already exists as a draft with an `## Answers so far` section, an interview was interrupted: resume from it instead of asking again.
2. **Branch.** Project documents are written on the current branch (normally the default one). Epic documents belong on the epic's branch: if I'm on the default branch, propose the branch (`Branch:` of the plan, else `feature/<slug>` or the repo's convention), and create it after my yes, before writing.
3. **Interview.** Ask in rounds of at most 5 questions, grouped by topic.
   - Each question says why it matters for this document and gives your recommended answer. When the answers are a few known options, ask with the `AskUserQuestion` tool (your recommendation first, marked as recommended) so I can answer with a click; I can always write my own. If that tool isn't available, number the questions and options in plain text.
   - After each round, save my answers in the document file itself: `Status: draft` and a temporary `## Answers so far` section. A session that dies mid-interview loses nothing.
   - Don't ask what the inputs or the code already answer. Don't ask what only a later document needs: note it where that document will find it (an epic's detail goes to its **epic notes** in `roadmap.md`, or to a list in your hand-over if there is no roadmap yet).
   - Stop when the remaining unknowns wouldn't change this document, or when I say to go ahead. If something is still unknown after the rounds the table allows, it becomes an open question in the document.
4. **Draft.** Write the document from its template with `Status: draft`, replacing `## Answers so far`. Only this document; nothing else in `<docs>` changes, except reference material you move to `<docs>/project/inputs/` (see the size budget).
5. **Self-check** before showing it to me, with the size budget and the checklist below. Fix what fails.
6. **Hand over.** The path, a 3–5 line summary, the 2–3 points you're least sure about, and the open questions. Then: "Review it and tell me what to change, or say it's approved."
7. **Changes.** Apply what I ask, and what follows from it in the same document. The status stays `draft`. Tell me what changed, then step 6 again.
8. **Approved.** Set `Status: approved (YYYY-MM-DD)` (in a shape pass: `shape approved (YYYY-MM-DD)`). Run the after-approval step the caller lists, if any. Propose a commit message, `docs: <add | update> <document> for <project or epic>`, and apply my commit rule: commit if I told you to, don't if I told you not to, otherwise ask. Never push.
9. **Next.** Tell me the next command and suggest `/clear` before it. If this was the last document before implementation, say so plainly: "Planning is done. Next: `/clear`, then `/seny:implement next`."

An approved document that changes later (Change mode, a refresh) goes back to `draft` and through steps 6–8 again.

## Size budget

Documents are read again and again by later runs, so every line costs tokens many times. Budgets, as a guide:

| Document | Budget |
|---|---|
| `product.md` | ~120 lines |
| `architecture.md` | ~150 lines |
| `codebase.md` | ~120 lines |
| `roadmap.md` | one row per epic, plus up to 3 lines of notes per epic |
| Epic `research.md` | ~60 lines (one page) |
| `plan.md` | ~15 lines per story, ~40 for everything above the stories |
| `design.md` | ~40 lines per screen |

A document holds **decisions and what they rest on**, not raw material. Inventories, content dumps, long comparisons, transcripts of what an old system does, pasted briefs: move them to `<docs>/project/inputs/<name>.md` (no status, never loaded by default) and link them from the line that needs them. Over budget after that → say so at hand-over and tell me what you'd cut.

## Self-check per document

- **product.md**: every core need has a priority; the MVP's in and out are explicit; assumptions are marked; no technology or solutions.
- **codebase.md**: every debt item and fragile area has `file:line`; the coverage map covers the main areas; describes, never prescribes.
- **architecture.md**: every stack row has a why; hard-to-reverse decisions are recorded with the rejected alternative; the data model has exact enum and status strings; boundaries say where auth and validation happen; the `Design system:` line is set.
- **design-system.md**: every token has light, dark and a use; text pairs pass AA contrast; base components list their states.
- **roadmap.md**: every row has a type, a size, a one-line goal (one line: details go to the epic notes) and dependencies that exist, with no cycles; every epic with decisions already taken has its notes; `foundation` comes first in a new app; together the rows cover the MVP in `product.md`.
- **research.md**: facts cite their source; assumptions are marked; no solutions; questions only a spike can answer are marked.
- **plan.md**: each story has observable criteria, a `Tests` mode, a `Verify` line (auto and manual), valid `Depends on` ids and an `Approach` unless trivial; the story count fits the size; Scope Out is explicit; nothing contradicts or restates `architecture.md`; the first story is a thin vertical slice. Shape pass: goal, scope, decisions and one line per story, nothing more.
- **design.md**: every screen lists every state with its copy; the story mapping covers every UI story; only new tokens and components.

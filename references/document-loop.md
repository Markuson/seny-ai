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

1. **Inputs.** Read the documents this one builds on (the caller lists them). If one of them is still `Status: draft`, stop: tell me to review and approve it first, unless I say to go on anyway.
2. **Interview.** Ask in rounds of at most 5 questions, grouped by topic.
   - Each question says why it matters for this document and gives your recommended answer. Use multiple choice when the answers are a few known options (your recommendation first), so I can answer fast; I can always write my own.
   - Don't ask what the inputs or the code already answer. Don't ask what only a later document needs: note it for that document instead.
   - Stop when the remaining unknowns wouldn't change this document, or when I say to go ahead. If something is still unknown after the rounds the table allows, it becomes an open question in the document.
3. **Draft.** Write the document from its template with `Status: draft`. Only this document; nothing else in `<docs>` changes.
4. **Self-check** before showing it to me, with the checklist below. Fix what fails.
5. **Hand over.** The path, a 3–5 line summary, the 2–3 points you're least sure about, and the open questions. Then: "Review it and tell me what to change, or say it's approved."
6. **Changes.** Apply what I ask, and what follows from it in the same document. The status stays `draft`. Tell me what changed, then step 5 again.
7. **Approved.** Set `Status: approved (YYYY-MM-DD)` (in a shape pass: `shape approved (YYYY-MM-DD)`). Run the after-approval step the caller lists, if any. Propose a commit message, `docs: <add | update> <document> for <project or epic>`, and apply my commit rule: commit if I told you to, don't if I told you not to, otherwise ask. Never push.
8. **Next.** Tell me the next command and suggest `/clear` before it. If this was the last document before implementation, say so plainly: "Planning is done. Next: `/clear`, then `/seny:implement next`."

An approved document that changes later (Change mode, a refresh) goes back to `draft` and through steps 5–7 again.

## Self-check per document

- **product.md**: every core need has a priority; the MVP's in and out are explicit; assumptions are marked; no technology or solutions.
- **codebase.md**: every debt item and fragile area has `file:line`; the coverage map covers the main areas; describes, never prescribes.
- **architecture.md**: every stack row has a why; hard-to-reverse decisions are recorded with the rejected alternative; the data model has exact enum and status strings; boundaries say where auth and validation happen; the `Design system:` line is set.
- **design-system.md**: every token has light, dark and a use; text pairs pass AA contrast; base components list their states.
- **roadmap.md**: every row has a type, a size, a one-line goal and dependencies that exist, with no cycles; `foundation` comes first in a new app; together the rows cover the MVP in `product.md`.
- **research.md**: facts cite their source; assumptions are marked; no solutions; questions only a spike can answer are marked.
- **plan.md**: each story has observable criteria, a `Tests` mode, a `Verify` line (auto and manual), valid `Depends on` ids and an `Approach` unless trivial; the story count fits the size; Scope Out is explicit; nothing contradicts or restates `architecture.md`; the first story is a thin vertical slice. Shape pass: goal, scope, decisions and one line per story, nothing more.
- **design.md**: every screen lists every state with its copy; the story mapping covers every UI story; only new tokens and components.

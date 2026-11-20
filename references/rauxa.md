# Rauxa mode

*Rauxa* is seny's rival: the impulse to do it all at once. Rauxa mode writes several planning documents in one run, with one interview at the start and one review at the end. Step by step (seny) stays the default; rauxa is a helmet-on shortcut you choose.

## Scopes

| Scope | Writes in one run | Asked from |
|---|---|---|
| **Whole plan** | The shape and the stories of one plan (size L, `foundation`) | `/seny:plan <slug> all`, or `[R]` at the start of a shape pass |
| **Whole epic** | `research.md` (M, L), `plan.md` and `design.md` (if UI) of one epic | `/seny:plan <slug> all` on an epic with no research yet, `/seny:research <slug> all`, or `[R]` |
| **Whole project** | The pending ones of `architecture.md`, `design-system.md`, `roadmap.md` and the foundation plan (`product.md` must be approved) | `/seny:plan project all`, or `[R]` at the start of `/seny:plan project`. Existing code: `/seny:research project all` for codebase, architecture and design system |

Before a **whole project** run, warn me in one line: "A mistake in the architecture will carry into every document after it, and you'll find it at the end. Go on?"

## How it runs

1. **Announce**: the documents, in order, and what each one reads.
2. **One interview** for all of them, in rounds like the document loop, grouped by document. Hard-to-reverse decisions (framework, database, auth, hosting, new dependencies) are always asked, never assumed. Save the answers in the first document's draft (`## Answers so far`).
3. **Write the documents in order**, each from its template with `Status: draft` and its own self-check, each one reading the drafts before it.
4. **Brake**: if writing one of them raises a question that changes it or a later one, stop there, ask, and go on. Never invent an answer to keep going.
5. **One hand-over**: per document, the path, a 3-line summary, the points you're least sure about and the size note if any. Then the hand-over menu of the document loop, with `[A]` approving all of them.
6. **Changes**: I can approve all, or one by one. If I change a document others build on, list the ones affected and update them too (they stay `draft` until I approve them again).
7. **Approved**: set every status, run each document's after-approval step, and give one commit summary (`references/commit-summary.md`, document form, one block per document) for **one commit** for the whole batch.
8. **Next**: as in the document loop, after the last document of the batch.

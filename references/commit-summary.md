# Commit summary

Shared by every step that proposes a commit: closing a story, `/seny:fix`, `/seny:spike`, the document loop and Rauxa batches. It is also what `/seny:help summary` prints again on demand.

It is **chat text**, never a file. Build it from what is on disk, not from memory of the conversation: before the commit, `git status --porcelain` and `git diff HEAD --stat` (plus untracked files) and the plan or document; after the commit, `git show --stat <sha>` and the review recorded in the plan. That is why it can be rebuilt any time, even after `/clear`.

## Story, fix or spike

```
<epic> <S#> · <title> — ready to commit            (fix: "Fix · <bug in a few words>")

Changed
- <path> — <what changed, a few words>              (group a folder when it has many files; docs too)
Decisions taken during the work
- <decision, or "Approach adapted: …">              (omit if none)

Review
- <APPROVED | CHANGES REQUESTED> <after N fix rounds> (<blockers fixed, in a few words>)
- Pending should: <list or "none"> · nits: <n> (in chat)
- Checks vs baseline: <no new failures | …>

What you should review
1. By hand: <the manual part of Verify, or the manual steps of the fix>
2. Look at: <path:lines> — <why: shared code, Approach adapted, a file outside the story's Files, a risky edge case the reviewer pointed at>
3. Accepted on purpose: <should findings you chose not to fix, or "none">

Commit: <message>
[C] Commit   [E] Edit the message   [N] I'll commit it myself
```

"What you should review" is never generic: only items that come from the Verify line, the diff, the plan and the review record. If there is nothing worth a look beyond the manual checks, say "Nothing else stands out".

## Document (or a Rauxa batch)

```
<document> for <project or epic> — approved, ready to commit

Decides
- <the 3–5 decisions this document fixes>
Changed since the first draft
- <what my review changed, or "nothing">
Worth re-reading
- <section> — <why: hard to reverse, an assumption, an open question left>

Commit: docs: <add | update> <document> for <project or epic>
[C] Commit   [E] Edit the message   [N] I'll commit it myself
```

A Rauxa batch lists one `Decides` block per document, then one commit for the whole batch.

## Answers
- `C` → commit following the message (respect my commit rule: if I said not to commit in this session, show the summary and stop).
- `E` → ask for the new message, then commit.
- `N` → don't commit; remind me that `/seny:help summary` shows this again.
- Never push.

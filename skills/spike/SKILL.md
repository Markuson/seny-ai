---
name: spike
description: Answer one technical question by trying it - throwaway code on a spike branch, time-boxed, with the findings written into the epic research. The only Seny command that writes disposable code.
argument-hint: "<question> [for <epic slug>]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git status *) Bash(git branch --show-current) Bash(git log *)
---

# Spike

Question: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above. Project rules: the files listed under "Project rules" above (already in your context).

A spike is rauxa with a helmet on: try things fast to answer ONE question that reading can't answer ("does this BLE library survive reconnection in the background on Android?", "does Expo cover this native SDK?", "what does this API really return?"), then write down what we learned so the plan can decide with facts.

## Rules
- One question, answered with evidence. Not a feature, not a prototype to keep.
- The code is disposable: speed over quality, no tests, no refactors. It is never merged.
- Work only on a `spike/<slug>` branch. Never on the default branch, never mixed with uncommitted work: if there are uncommitted changes, ask me to commit or stash them first.
- Time box: agree it with me before starting (default: this session). If it runs out without an answer, stop and record what you learned; "we don't know yet, because…" is a valid finding.
- New dependencies are allowed inside the spike; say which ones. Nothing installed globally, no changes outside the repo.
- Hardware, devices or anything you can't run yourself: give me exact steps to run and what to send back. Never guess a result.
- Never push.

## Steps
1. **Frame.** In a few lines: the question; what each possible answer would change in the plan; the evidence that will settle it (a log, a measurement, a passing call, a screenshot). Propose the slug, the branch `spike/<slug>`, the time box, and the epic it belongs to (from the input, or ask; if the epic has no folder yet, its `research.md` will start with just the findings). Wait for my yes.
2. **Branch.** Remember the current branch, then create `spike/<slug>` from it.
3. **Try.** The smallest code that answers the question. Start with the most likely approach; if it fails, note why and try the next. Collect evidence as you go.
4. **Keep or drop the code.** Ask me: commit the spike code on `spike/<slug>` (message `spike: <question>`, never merged), or discard it. Then switch back to the branch you came from. Nothing from the spike is left uncommitted there.
5. **Record**, on the original branch, in `<docs>/epics/<epic>/research.md`:
   ```markdown
   ## Spike findings

   ### <question> — <YYYY-MM-DD>
   - Answer: <yes | no | partly | unknown> — <one line>
   - Evidence: <what was run and what happened: commands, numbers, logs, files on the spike branch>
   - Tried: <approaches, including the ones that failed and why>
   - Consequences for the plan: <decisions it enables, constraints, risks, new open questions>
   - Code: <branch `spike/<slug>` (not merged) | discarded>
   ```
   If the question was listed under the research's open questions, mark it answered there with a link to the finding.
6. **Stop.** Give me the answer in 3 lines and its consequences. Next: `/seny:plan <slug>` (or `/seny:research <slug>` if the epic has no research yet and its size is M or L).

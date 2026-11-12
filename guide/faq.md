# FAQ and troubleshooting

Questions people ask, and what to do when something surprises you. Can't find yours? `/seny:help <your question>` often knows.

- [Using Seny](#using-seny)
- [Working with stories](#working-with-stories)
- [Reviews](#reviews)
- [Troubleshooting](#troubleshooting)

---

## Using Seny

**Why does planning stop after every document?**
Because the plan is where everything gets decided, and a mistake there costs the most later. One document per run means you review each decision while it's small, the next document builds only on approved ones, and every run starts with a clean context after `/clear`. It's slower per document and faster per project.

**Can I make it go faster?**
Yes, three ways. Say "go ahead" during an interview and Seny stops asking and writes with its recommended answers. Size epics honestly: an S epic skips research and gets at most one round of questions. And changes outside the roadmap can use `/seny:plan light`.

**What's the difference between an epic, a light change and a fix?**
An **epic** is a roadmap row: a capability users (or the project) need, with its own branch and PR. A **light change** is a small, clear improvement that doesn't deserve a roadmap row (1–3 stories). A **fix** repairs something that should already work. `/seny:help <what you want>` picks for you.

**Should an epic have sub-epics?**
No. Seny has three levels: project, epics, stories. If an epic's stories need grouping, split it into two epics on the roadmap.

**Do I have to use every command?**
No. Most days you'll use three: `/seny:research`, `/seny:plan` and `/seny:implement`. Bugs go to `/seny:fix`, tiny things don't need Seny at all (the Direct track), and `/seny:help` tells you which track a change deserves.

**My project already has a `docs/` folder. Will Seny make a mess?**
No. Seny only uses `docs/project/` and `docs/epics/` and ignores everything else in `docs/`. If you prefer another place, change the line in your project rules to, say, `- Seny docs: \`documentation/seny\``, and move the folders there.

**I already have a brief, a PRD or brainstorming notes from another tool.**
Pass the file to research: `/seny:research project path/to/brief.md` for a new app, or `/seny:research path/to/notes.md` for one epic. Research reads it, cites it as the source, and writes Seny's own documents. Keep the original as read-only input: from then on, the Seny documents are the source of truth.

**Does it work without tests, or without a `package.json`?**
Yes. Checks are optional: with none defined, the baseline is skipped and stories are verified through their `Verify` lines and the review. When you add checks later, the next story records a baseline. The best moment to add them is `foundation` (new apps) or an early evolution (old ones).

**Is it only for JavaScript?**
The method isn't: commands come from your project rules, and conventions from your `CLAUDE.md` files. Some templates mention Tailwind or NativeWind as examples; ignore what doesn't apply. The author's defaults are TypeScript-flavoured because that's what he builds.

**Can a team use it?**
Yes, in shared mode. The documents are Markdown in the repo, reviewed in PRs like code. Practical tips: one person per epic, commit `plan.md` with the code of each story, and resolve plan conflicts like any merge conflict (statuses are one word at the end of a line, so conflicts are small). The baseline notices teammates' work and refreshes itself.

**How big should a story be?**
One commit, a handful of files, reviewable in one sitting, working end to end. If you need a second coffee to review it, it's two stories. If it has no user-visible or testable outcome, it's probably a task inside another story.

**When should I `/clear`?**
Between phases (after research, after planning, between stories), whenever a command's last line suggests it, and whenever the session feels slow or forgetful. Nothing is lost: the state lives in the documents.

**Can I use Seny in a repo I don't own?**
Yes: private mode keeps everything in `.seny/`, invisible to git. See [configuration](configuration.md#private-mode).

---

## Working with stories

**How do I abandon or postpone a story?**
Use Change mode: `/seny:plan <slug> drop S3, it's not needed anymore` or `… move S3 to a separate epic`. Stories that already started stay in the plan as history; Seny adds a note or a follow-up story instead of rewriting them. Revert any half-done code yourself with git.

**The plan turned out wrong in the middle of a story.**
That's exactly when `/seny:implement` stops instead of improvising. Run `/seny:plan <slug> <what changed>`, then `/seny:implement <id>` again. If the change is big (new data model, new screens), update the research first.

**Can I work on two epics at the same time?**
Yes, on separate branches. Commit (or stash) before switching, so each review sees one story. With several epics in progress, `/seny:help` lists them and asks which one to continue.

**I ran out of context in the middle of a story.**
`/seny:implement` writes a `Notes:` line under the story (done so far, decisions, next step) and asks you to `/clear`. Run the same command again: it resumes from the notes. If a session ended abruptly before the notes were written, the story is still `in-progress`; implement will read the diff and carry on.

**I want to change a story's acceptance criteria.**
If it's still `todo`: `/seny:plan <slug> <change>`, or edit `plan.md` by hand, it's your file. If it's already started, prefer a new story for the extra work, so the review of the current one stays meaningful.

**Can I edit the documents by hand?**
Yes, they're yours. Keep the shapes the tools read: story headings like `#### S2 · Title — \`status\``, the `Status:` line at the top of each document, roadmap rows starting with `| <number> |`, and the `Recorded: … · Commit: \`sha\`` line of the baseline (never edit the baseline by hand, though; re-record it).

**Where's the commit? Seny didn't commit.**
Seny commits only when a story becomes `done` and your commit rule allows it. If you never said "commit", it asks. See [configuration](configuration.md#commits).

---

## Reviews

**The reviewer flagged something I disagree with.**
You're the boss. A `should` is optional by definition. For a `blocker`, explain why it's fine, and tell Claude to mark the story `done` anyway: only you move stories to done, and that works both ways. If the reviewer keeps flagging something you accept, add a line to your project rules ("we allow X because Y"): it reads them on every review.

**I changed the code by hand after the review.**
Run `/seny:review <id>` for a fresh review of the current diff.

**The work is already committed. Can it still be reviewed?**
Yes: `/seny:review <id> main..HEAD` (or any git range).

**Why doesn't the reviewer just fix the problems it finds?**
Because then nobody would review the fixes. The reviewer judges, the implementer fixes, and the reviewer looks again. In `auto` mode this all happens inside `/seny:implement`, so you don't pay for the separation with extra commands.

**Can I skip the review?**
For one run: `/seny:implement <id> no-review`. For a whole project: `- Seny review: manual`, then review when you want with `/seny:review`. For tiny things, use the Direct track instead.

---

## Troubleshooting

**"Seny guard: git push is blocked"**
Working as intended: Seny never pushes. Push the branch yourself. If you really want Claude to push in a session, start Claude Code with `SENY_ALLOW_PUSH=1 claude`.

**The checks ask for permission every time.**
Allow your check commands once, per project (`.claude/settings.local.json`, which `/seny:init` offers to set up) or for every project (`~/.claude/settings.json`). See [permissions](configuration.md#permissions). If another hook of yours rewrites commands, allow the rewritten form too.

**`/seny:…` commands don't appear.**
Check the plugin is installed and enabled in `/plugin`, then restart Claude Code. With a local clone, make sure the marketplace points to the folder that contains `.claude-plugin/`.

**The hook doesn't seem to do anything.**
Restart Claude Code after installing or updating the plugin: hooks load at startup.

**The snapshot shows the wrong docs root.**
The `Seny docs:` line must look exactly like `- Seny docs: \`docs\`` in `CLAUDE.md`, `CLAUDE.local.md` or `.seny/CLAUDE.md`. Without it, Seny uses `.seny/` if it exists, else `docs/`.

**The baseline is always "stale".**
Seny considers a baseline stale when commits by *other people* arrived after it. If you commit with different emails (work and personal, or one per machine), your own commits look like someone else's. Use the same `git config user.email` on every machine, or simply let implement re-record it: it costs one run of the checks.

**The reviewer was blocked from running a command.**
Its hook blocks anything that could write files, including redirections like `> file`. `2>&1`, pipes into `tail` or `grep`, and `> /dev/null` are fine. If a project check genuinely writes files (coverage reports, build output), that's allowed: the block is about the command shape, not the check. If a legitimate read-only command is blocked, please open an issue with the command.

**A story doesn't appear in the snapshot.**
Its heading probably lost its shape. It must be `#### S<n> · <title> — \`<status>\``, with the status as the last thing on the line.

**I work on macOS and Linux.**
Both are supported: the scripts use only bash 3.2 and the BSD/GNU-compatible subset of `grep`, `sed` and `awk`.

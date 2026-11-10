# Configuration

Everything you can set up, where it lives, and why. Seny works with zero configuration beyond `/seny:init`, but ten minutes here make every project smoother.

- [Where configuration lives](#where-configuration-lives)
- [Installing, updating and removing the plugin](#installing-updating-and-removing-the-plugin)
- [Personal rules: `~/.claude/CLAUDE.md`](#personal-rules)
- [Stack defaults: `~/.claude/seny/stack.md`](#stack-defaults)
- [Project rules: the project's `CLAUDE.md`](#project-rules)
- [Review mode](#review-mode)
- [Commits](#commits)
- [Permissions](#permissions)
- [The safety hook](#the-safety-hook)
- [Private mode](#private-mode)
- [Monorepos](#monorepos)
- [Companion skills](#companion-skills)
- [Several machines](#several-machines)

---

## Where configuration lives

There are three places, and it's worth keeping them apart in your head:

| Place | Path | What goes there | Who writes it |
|---|---|---|---|
| **You** (every project) | `~/.claude/` | `CLAUDE.md` (your rules), `seny/stack.md` (your stack for new apps), `settings.json` (global permissions and hooks) | You, once |
| **The plugin** | wherever Claude Code installs it | Skills, the reviewer agent, the hook, templates. You don't configure anything here. | Seny's authors |
| **Each project** | the repo | `CLAUDE.md` with a `## Seny` section (or `.seny/CLAUDE.md`), the docs, `.claude/settings.local.json` | `/seny:init`, then the commands |

Precedence follows Claude Code's own rules: the project's `CLAUDE.md` overrides your personal one, and the repo's conventions (commit style, branch names) override your personal defaults.

---

## Installing, updating and removing the plugin

```
/plugin marketplace add Markuson/seny-ai      # from GitHub
/plugin install seny@seny-ai
```

Restart Claude Code after installing so the safety hook is loaded.

- **From a local clone** (to try changes before publishing them): `/plugin marketplace add ~/path/to/seny-ai`.
- **Update:** `/plugin marketplace update seny-ai`, then restart.
- **Disable or remove:** from the `/plugin` menu. Your docs and project rules stay where they are; they're plain Markdown.

---

<a name="personal-rules"></a>

## Personal rules: `~/.claude/CLAUDE.md`

Claude Code loads this file in **every session of every project**, so keep it to rules that are always true for you: language, git habits, package manager, TypeScript, code organisation, UI, testing, how you like to work. Keep it short: every line costs context in every session.

Start from the template:

```bash
cp <seny repo>/templates/CLAUDE.personal.example.md ~/.claude/CLAUDE.md
```

Already have one? Merge them instead of overwriting (`nvim -d ~/.claude/CLAUDE.md <seny repo>/templates/CLAUDE.personal.example.md`, or your diff tool of choice). `/seny:init` also offers to copy it when the file doesn't exist, and never touches it when it does.

Seny reads this file through Claude Code, and so does the reviewer: rules like "no `any`", "no snapshot tests" or "query by role" become review criteria without being hard-coded in Seny.

---

<a name="stack-defaults"></a>

## Stack defaults: `~/.claude/seny/stack.md`

Your choices for **new** apps: mobile vs web frameworks, styling, state management, backend options, database, auth, CMS, test tooling. They matter once per project, so they live outside `CLAUDE.md` and are read only by `/seny:plan project`.

```bash
mkdir -p ~/.claude/seny
cp <seny repo>/templates/stack.example.md ~/.claude/seny/stack.md
```

If the file doesn't exist, Seny uses the plugin's example. Existing projects always keep the stack they have.

---

<a name="project-rules"></a>

## Project rules: the project's `CLAUDE.md`

`/seny:init` creates it from a template, filled in with what it detected, or appends a `## Seny` section to yours (showing it to you first). The sections:

| Section | What to put | Why it matters |
|---|---|---|
| **Project** | 2–3 lines: what it is, for whom, what matters most | Context for every phase |
| **Stack** | Frameworks, styling, data layer, deploy target | What the code must follow |
| **Commands** | Package manager, dev, lint, typecheck, test, build, e2e | The checks every story runs and compares with the baseline |
| **Product rules** | Rules the reviewer treats as **blockers** ("never invent data: unknown values are shown as unknown") | Your non-negotiables, enforced on every story |
| **Repo conventions** | Commit format, branch naming, PR rules, as seen in the repo | They override your personal defaults |
| **Seny** | The lines below | How Seny behaves in this project |

The `## Seny` section:

```markdown
## Seny
- Seny docs: `docs`
- Seny review: auto
- (a few lines on where the docs are, statuses, baseline and transitions)
```

- **`Seny docs:`** tells every command where the documents are (`docs` or `.seny`). Keep the exact shape: the state script reads it.
- **`Seny review:`** is the [review mode](#review-mode).

---

## Review mode

| Mode | What happens | Choose it when |
|---|---|---|
| `auto` (default) | `/seny:implement` launches the reviewer as soon as the checks pass, fixes blockers once, re-reviews, and stops for your "done" | Almost always: same quality, half the commands |
| `manual` | `/seny:implement` stops at `review`; you run `/seny:review` | You want to look at the diff yourself before the reviewer does, or you review in batches |

Three ways to set it, from the most permanent to the most temporary:

1. **Per project:** `- Seny review: manual` in the `## Seny` section.
2. **Per session:** tell Claude "don't review in this session".
3. **Per run:** `/seny:implement E1-S3 no-review`.

Either way, **only you** move a story to `done`.

---

## Commits

Seny never decides on its own to commit. It follows the commit rule in your personal or project rules. The template's rule:

- If you told it to commit, it commits; if you told it not to, it doesn't. That holds for the session.
- If you said nothing, it asks at the end: *"¿Hago el commit o lo haces tú?"* (or whatever you write in your rules).

Commits happen when a story becomes `done` (one story, one commit, code and doc updates together), at the end of a fix, and on spike branches if you keep the spike code. Messages follow the repo's convention first, then your personal one, then `<type>: <description>`.

---

## Permissions

The plugin itself only pre-approves read-only git commands (`git status`, `git log`, `git diff HEAD`…). Your checks (lint, typecheck, test, build) would ask for permission every time unless you allow them. Two options:

**Per project:** `/seny:init` proposes your detected check commands for `.claude/settings.local.json`, merges them with what's there, shows you the result, and makes sure the file stays out of git.

**For every project** (handy if you always use the same package manager), in `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm lint)", "Bash(pnpm lint *)",
      "Bash(pnpm typecheck)",
      "Bash(pnpm test)", "Bash(pnpm test *)",
      "Bash(pnpm build)"
    ]
  }
}
```

Add these entries to the `allow` list you already have; don't replace the file.

Only allow **checks**. Never dev servers, deploys, releases, installs or E2E suites: those should always ask.

> If you use another tool that rewrites shell commands through a hook (for example a token-saving proxy that turns `pnpm test` into `<tool> pnpm test`), your allow rules may need the rewritten form too.

---

## The safety hook

Seny ships `hooks/hooks.json`, which runs `scripts/guard.sh` before every Bash command and every file edit. It's plain bash (no `jq` or Python needed) and does two things:

1. **Blocks `git push`**, from you-through-Claude or any subagent, in any form (`git push`, `git -C apps/web push --force`, `… && git push`). Claude gets a friendly explanation.
   To allow pushing for one session, start Claude Code with the variable set: `SENY_ALLOW_PUSH=1 claude`.
2. **Keeps `seny:reviewer` read-only:** no Edit or Write tools, and no Bash commands that could change files (`rm`, `mv`, `cp`, `sed -i`, redirections into files, `git checkout`/`stash`/`commit`/…, package installs). Reading, `git diff`/`log`/`show`/`blame` and running checks are fine.

It only looks at the reviewer for the second rule; your main session and other agents work as usual. Hooks from other plugins or your own settings run alongside it.

---

## Private mode

For repos where you can't (or don't want to) add files:

| File | Purpose | Visible to git? |
|---|---|---|
| `.seny/CLAUDE.md` | Project rules, including `- Seny docs: \`.seny\`` | No |
| `.seny/project/`, `.seny/features/` | The documents | No |
| `CLAUDE.local.md` | One line, `@.seny/CLAUDE.md`, so Claude Code loads the rules in every session | No |
| `.git/info/exclude` | Lists `.seny/` and `CLAUDE.local.md` | (it's git's own local file) |

Nothing tracked changes, and nobody else sees a thing. The catch: the docs live only on your machine, so back them up if they matter.

---

## Monorepos

- `/seny:init` reads every `package.json` (and `pnpm-workspace.yaml`, `turbo.json`, `apps/*`, `packages/*`) and can add a short `CLAUDE.md` per package when their stacks differ (shared mode only).
- Codebase research maps each package; `codebase.md` gets one line per package.
- The state snapshot always works from the repository root, so you can start Claude Code in `apps/mobile` and Seny still finds `CLAUDE.md` and `docs/`.

---

## Companion skills

Seny loads design skills when they're installed and the work calls for them (design system, feature design, UI stories). They're optional: without them Seny continues and tells you which one would help.

| Skill | What it adds | Used for | Where to get it |
|---|---|---|---|
| `frontend-design` | Distinctive visual direction for web UI | Design system and feature design (web) | Anthropic's official plugins: `/plugin install frontend-design@claude-plugins-official` |
| `web-design-guidelines` | Accessibility and UX rules for web interfaces | Design, and the reviewer's UI checks | Vercel's [agent-skills](https://github.com/vercel-labs/agent-skills) collection |
| `vercel-react-native-skills` | React Native and Expo patterns and performance rules | Design and UI stories on mobile | Vercel's [agent-skills](https://github.com/vercel-labs/agent-skills) collection |

Follow each collection's README for its current install command.

---

## Several machines

Your personal configuration is three small files. Copy them to each machine (or keep them in your dotfiles):

```
~/.claude/CLAUDE.md
~/.claude/seny/stack.md
~/.claude/settings.json      # only the parts you want everywhere
```

Project configuration travels with the repo in shared mode. In private mode, `.seny/` stays on the machine where you created it.

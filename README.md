# Seny — common-sense, spec-driven development for Claude Code

> *Fast is fine. Accurate is better. Seny is both, with fewer tokens.*

Welcome! **Seny** is a small, opinionated way of building software with [Claude Code](https://claude.com/claude-code). It follows the **Research → Plan → Implement** (RPI) flow, adds an independent review because nobody should mark their own homework, and keeps a human in charge of every "done".

It works for shiny **greenfield** projects and for that **brownfield** repo you wrote in 2019, before AI, before tests, and possibly before sleep. And it does spec-driven development without turning every one-line fix into a 40-page PRD that eats your token budget for breakfast.

📚 **New here?** Read this page, then [the concepts](guide/concepts.md). Looking for one command? [The command reference](guide/commands.md). Want to see the documents Seny writes? [A full example project](examples/poc-a-poc/).

---

## So… what is *seny*?

> **seny** /sɛɲ/ — like *"sen"* followed by the *"ny"* in *canyon*.

*Seny* is a very Catalan idea: level-headed common sense. Knowing how much is enough. It's the voice of your Catalan grandmother saying *"poc a poc"* (little by little) while you try to refactor the whole app on a Friday afternoon.

Its eternal rival is ***rauxa***: the sudden impulse, the wild idea you act on right now, consequences be damned. Catalans are said to carry both. Rauxa gave the world fireworks festivals where people dance *under* the fireworks. Seny is the one who brought the fire extinguisher.

AI coding today is mostly rauxa:

```
prompt → accept → prompt → accept → "why is everything on fire?" → prompt
```

Seny-driven development is the grandmother in the room. Understand first. Decide. Build in small steps. Let someone else check. Then, and only then, call it done. (Rauxa still gets a playground: it's called a [spike](#how-much-process-ask-senyhelp).)

---

## What Seny tries to be

- **Spec-driven, not spec-obsessed.** Research and plans live in short Markdown files you can read in two minutes, not in a cathedral of documents nobody opens twice.
- **Proportional.** A typo doesn't need a research phase. A new payments flow does. Seny picks the smallest process that is still safe.
- **Good for new and old code.** Greenfield gets an architecture, a design system, a roadmap and a solid foundation. Brownfield gets mapped first, *as it is*, so you can add features and improve it without breaking it.
- **Cheap on tokens.** See [The token diet](#the-token-diet). Your wallet will send a thank-you card.
- **Human in charge.** Claude researches, plans, codes and reviews. You decide. Nothing is ever pushed (a hook makes sure of it), and only you can say "done".

---

## The cycle

```
 research ──▶ plan ──▶ implement ──▶ review ──▶ you say "done" ✅
     │          ▲          ▲            │
     ▼          │          └─ "nope" ───┘
   spike ───────┘   (only when a question needs code to answer)
```

1. **Research** understands the problem and the code. It never proposes solutions.
2. **Plan** decides and slices the work into small stories, each with acceptance criteria, an `Approach` (how to build it) and a `Verify` line (how to prove it works).
3. **Implement** builds one story: characterization tests first if the code is untested, red-green-refactor where there's logic, then the project's checks against the baseline.
4. **Review** is done by a separate reviewer agent that never saw the conversation. By default `/seny:implement` calls it on its own and fixes the blockers once.
5. **You** check it by hand and say "done". Seny commits (if you want) and moves on.

**One document at a time.** Research and plan never dump five documents on you at once. Each run interviews you (rounds of questions, each with a recommended answer), writes **one** document, and stops for your review. You ask for changes or approve it; Seny proposes a commit and tells you the next command. Nothing builds on a draft. The documents carry the state, not the chat, so you `/clear` between them, go have a coffee (or a *cafè amb llet*), and come back days later without losing the plot.

### Project, epics and stories

Three levels, the agile way, and nothing in between:

```
Project   product · architecture · design system · roadmap
 └── Epic    one roadmap row = one folder = one branch = one pull request
      └── Story   one commit = one implement session
```

Every epic on the roadmap has a **size**, and the size decides how much planning it gets:

| Size | Stories | Planning |
|---|---|---|
| **S** | 1–3 | `/seny:plan <slug>`: one document, one quick round of questions |
| **M** | 4–8 | `/seny:research <slug>` → `/seny:plan <slug>` |
| **L** | 9+ | research, then the plan in two passes (shape first, stories after). Or, more seny: split it. |

Starting a whole new app gets the deepest planning of all: product, architecture, design system, roadmap and the foundation plan, each interviewed, written and approved on its own.

### A story's life

```
todo ──▶ in-progress ──▶ review ──▶ done ──▶ commit
              ▲             │
              └─ changes ───┘
```

| Status | Set by | Means |
|---|---|---|
| `todo` | `/seny:plan` | Planned, not started |
| `in-progress` | `/seny:implement`, or a review asking for changes | Being built or fixed |
| `review` | `/seny:implement` when the checks pass | Built and checked, waiting for the reviewer and for you |
| `done` | **Only you** (through `/seny:review` or the review step of `/seny:implement`) | Approved and checked by hand |

Stories are small: one commit, a handful of files, works end to end. If a story needs a second coffee to review, it's two stories.

---

## How much process? Ask `/seny:help`

Seny's whole personality is *"how much is enough"*, so it has a command for exactly that. Tell `/seny:help` what you want and it picks a track:

| Track | When | What you run |
|---|---|---|
| 🟢 **Direct** | A typo, a config value. Not a bug. | Nothing. Just ask Claude. Seny approves. |
| 🔧 **Fix** | A bug outside any plan | `/seny:fix` |
| 🧪 **Spike** | "Can this library / device / API even do X?" | `/seny:spike` → then the right track |
| 🪶 **Light** | One clear change outside the roadmap, 1–3 stories | `/seny:plan light` → implement |
| 🧱 **Epic** | A capability on the roadmap: several stories, open questions, new UI, or risk | S: `/seny:plan` · M/L: `/seny:research` → `/seny:plan` · then implement |
| 🌱 **Evolve** | Change *how* the app is built, not *what* it does | `/seny:evolve` → implement |
| 🏗️ **Project** | A new app, or adopting Seny in an old one | `/seny:init` → research project → plan project |

Some things always bump you up to at least an **Epic** of size M: data model changes, auth, payments, personal data, new external services, new screens, undecided requirements, untested legacy code, and anything you can't undo. Rauxa is welcome at the party. Not near the database.

---

## Commands

| Command | What it does |
|---|---|
| `/seny:init` | Sets Seny up in a project. Detects your stack, commands and repo conventions. Overwrites nothing. Ever. |
| `/seny:research project <idea>` | New app: a real interview about vision, users, MVP and constraints → `product.md`. |
| `/seny:research project` | Existing app: maps the codebase (and records which checks **already** fail, the baseline), then the architecture, then the design system, one document per run. |
| `/seny:research project refresh` | "Do the docs still match the code?" Honest answers only. |
| `/seny:research <epic>` | Understands one epic (sizes M and L) against the code and the project docs. |
| `/seny:spike <question>` | Answers one technical question with throwaway code on a `spike/` branch, and writes the findings into the epic's research. The only place where code is allowed to be ugly. |
| `/seny:plan project` | New app: architecture, design system, a roadmap of sized epics, and the `foundation` plan, one document per run. Existing app: a roadmap. |
| `/seny:plan <slug> [design]` | The epic's plan, as deep as its size: small stories, each with an `Approach` and a `Verify` line. Plus a design doc when there's UI. |
| `/seny:plan <slug> <change>` | Changes a plan without rewriting history: stories already started stay as they are. |
| `/seny:plan light <change>` | A tiny plan for a tiny change. |
| `/seny:implement <id> \| next [no-review]` | One story: builds it, checks it against the baseline, gets it reviewed (one round of fixes if needed), and stops for your "done". |
| `/seny:review [id] [done]` | Reviews again (after manual changes, or in manual mode), or closes an approved story. |
| `/seny:fix <bug>` | Failing test first, root cause, minimal fix, review. No duct tape. |
| `/seny:evolve <change>` | Improves the architecture of living code, step by step, without breaking it. |
| `/seny:help [what I want]` | Where am I? What next? How much process does this deserve? |

Every command, with what it reads, writes, asks and stops on: [guide/commands.md](guide/commands.md).

---

## Install

You need Claude Code with plugin support, and `git`. Then, inside Claude Code:

```
/plugin marketplace add Markuson/seny-ai
/plugin install seny@seny-ai
```

Restart Claude Code so the safety hook loads. Install it for yourself (every project) or for one project (shared through the repo's `.claude/settings.json`).

Hacking on Seny itself? Point the marketplace at your local clone instead: `/plugin marketplace add ~/path/to/seny-ai`. After pulling changes, `/plugin marketplace update seny-ai`.

Recommended once, for every project: your personal rules in `~/.claude/CLAUDE.md` and your stack for new apps in `~/.claude/seny/stack.md`. Both have ready-made templates. See [guide/configuration.md](guide/configuration.md).

---

## Quick start

### 🆕 Greenfield: a brand-new app

```
/seny:init
/seny:research project a habit tracker for families, iOS and Android   # product.md
/seny:plan project        # architecture.md
/seny:plan project        # design-system.md
/seny:plan project        # roadmap.md, every epic sized
/seny:plan project        # foundation plan: its shape
/seny:plan project        # foundation plan: its stories
/seny:implement next      # builds, checks and gets reviewed; you say "done"
```

Each line is one run: questions, a draft, your review, your approval, a commit, a `/clear`. `/seny:plan project` always knows which document comes next.

`foundation` is always the first epic: a running, deployed, boringly solid base with nothing product-specific. Like the *pinya* of a human tower: nobody photographs it, but nothing stands without it.

### 🏚️ Brownfield: that old repo

```
/seny:init                # docs in the repo, or private in .seny/
/seny:research project    # map the code, record the baseline
/seny:help add offline mode to the shopping list
/seny:evolve migrate the app from JavaScript to TypeScript
```

Three things make old code survivable:

- **The baseline.** Seny records which checks already fail before you touch anything. From then on, only **new** failures block you. You're responsible for what you break, not for what 2019-you broke. When other people's work comes in (a pull, a merge, a rebase), Seny notices and records a fresh baseline before your next story, so you never get blamed for a teammate's red test either.
- **Characterization tests.** Before changing code that has no tests, Seny pins down what it does today. Then it changes it. If the behaviour moves, you'll know.
- **Evolutions, not rewrites.** `/seny:evolve` migrates architecture in small, working steps (strangler fig, expand-contract, adapters, feature flags, folder by folder). While an area is *in transition*, new code must use the new pattern, and the reviewer enforces it. Big-bang rewrites are pure rauxa. Seny says no.

Working in a client repo where you can't add files? `/seny:init` can keep everything in `.seny/`, loaded through your own `CLAUDE.local.md` and hidden with `.git/info/exclude`. Nothing tracked changes. Very discreet. Very seny.

---

## Where things live

```
docs/                      # or .seny/ in private mode
  project/                 # the whole app: lives as long as the app
    product.md             # new app: vision, users, MVP
    codebase.md            # existing code: conventions, coverage, debt, fragile areas
    baseline.md            # which checks already failed, and at which commit
    architecture.md        # stack, structure, data, decisions, transitions
    design-system.md       # tokens, typography, base components
    roadmap.md             # epics and evolutions, in order, each with a size and a few notes
    inputs/                # reference material: read only when a document points to it
  epics/<slug>/            # one epic (or evolution): builds on project/, never repeats it
    research.md            # sizes M and L; plus spike findings, if any
    plan.md                # a flat list of stories with statuses
    design.md              # only when there's UI
```

Want to see them filled in? [examples/poc-a-poc](examples/poc-a-poc/) is a small app halfway through its second epic.

---

## Safety rails

Some promises are too important to leave to good intentions, so Seny ships a small hook (`hooks/hooks.json` → `scripts/guard.sh`) that checks every command before it runs:

- **No pushes. Ever.** Any `git push` (and `gh pr create`, which pushes behind your back), from Claude or from any subagent, is blocked with a friendly note. The branch is ready; you push it. If you really want Claude to push in a session, start Claude Code with `SENY_ALLOW_PUSH=1`.
- **The reviewer can't touch your code.** The `seny:reviewer` agent can't use the file-editing tools, and Bash commands that could change files (`rm`, `mv`, `sed -i`, `git checkout`, `git stash`, installs, redirections to files…) are blocked. It reads, runs the checks, and reports. That's it.

`/seny:init` also offers to add your project's check commands (lint, typecheck, test, build) to `.claude/settings.local.json`, so they run without a permission prompt. Only checks: never dev servers, deploys or installs.

---

## The token diet

Spec-driven methods can get *hungry*. Seny is on a diet:

- **Proportional tracks and sizes.** Most changes never touch research. Size-S epics get one short document. Bugs go straight to `/seny:fix`. Typos go nowhere at all.
- **Short documents, with a budget.** Research is one page. Plans are flat lists of small stories that point to `architecture.md` instead of repeating it. Raw material lives in `inputs/` and is read only on demand. Small epics read their roadmap notes, not the whole product document.
- **Plans that remember the how.** Every story carries its `Approach`, so implementing it in a fresh session doesn't mean exploring the code all over again.
- **Loaded on demand.** Skills and templates enter the context only when you call them, one template per document. The design template sleeps until you design something.
- **Your stack only when it matters.** Your stack choices live in `~/.claude/seny/stack.md`, read only when a new app is planned, not in every session.
- **No persona theatre.** No simulated meeting between a PM, an architect and a scrum master agreeing with each other. One model, one job per phase.
- **One document per run, then `/clear`.** Each run starts light and reads only the approved documents it builds on, instead of dragging a whole planning conversation along.
- **Docs instead of chat history.** State lives in files, so `/clear` is free and long sessions don't drag a novel of context around.
- **State that stays small.** Every command starts with a snapshot of the project, and finished work collapses into one line. Epic number 40 costs the same as epic number 2.
- **Explore subagents for big sweeps.** They read the haystack and return only the needle.
- **Read only what the story needs.** Not the whole repo "just in case".

Where Seny *does* spend tokens on purpose is planning a new app: product and architecture get a proper interview. That's the one place where an hour of questions saves days of rework.

---

## Principles

1. **Describe before you prescribe.** Research never proposes solutions. Brownfield research describes the code as it is, warts included.
2. **Decide before you build.** Architecture comes before stories, and anything hard to reverse is always asked.
3. **Small vertical slices.** Every story is one commit and works end to end.
4. **Tests where they carry weight.** TDD for logic, tests after for UI, none for config. Untested legacy code gets characterization tests first.
5. **Only new failures block.** The baseline knows what was already broken.
6. **Evolve, don't rewrite.**
7. **Fresh eyes.** The reviewer is a separate agent that never saw the conversation, and a hook keeps it read-only. It can't be charmed, and it can't "just fix it quickly".
8. **The human closes the loop.** Only you move a story to `done`. Nothing is ever pushed, and a hook enforces it.

---

## Seny vs. the alternatives

| | 🧘 Seny | 🏛️ Big agentic frameworks | 🎲 Vibe coding |
|---|---|---|---|
| Process | Proportional to the change, one reviewed document at a time | Can scale to full planning suites | "We'll see" |
| Size | 9 skills, 1 agent, 1 hook | Many modules, agents and roles | One prompt and a prayer |
| Tokens | On a diet | Hungry | Unpredictable |
| Old codebases | Baseline, characterization tests, evolutions | Varies | 🔥 |
| Review | Independent agent + you | Built in | You, at 2 a.m., in production |
| Best for | Solo devs and small teams shipping web and mobile apps | Large initiatives and teams wanting a shared standard | Weekend experiments |

Seny is deliberately small. If you need autonomous multi-story runs or formal requirements for a big team, a bigger framework will serve you better, and that's fine. Seny would be the first to tell you. They also get along: any brief, PRD or brainstorming file can be the input of `/seny:research`.

---

## Learn more

| Guide | Read it when |
|---|---|
| [Concepts](guide/concepts.md) | You want to understand how Seny thinks: tracks, documents, stories, baseline, reviews, spikes, evolutions |
| [Commands](guide/commands.md) | You want to know exactly what a command reads, writes, asks and leaves behind |
| [Configuration](guide/configuration.md) | You're setting Seny up: personal rules, stack, permissions, review mode, private mode, companion skills |
| [FAQ and troubleshooting](guide/faq.md) | Something surprised you, or you're about to ask "can I…?" |
| [Example project](examples/poc-a-poc/) | You learn best by looking at real documents |
| [Changelog](CHANGELOG.md) | You want to know what changed |

---

## FAQ (the short version)

**Is it pronounced "seenie"?**
Close, but no. *Sen* + the *ny* of *canyon*. Your Catalan friends will be impressed.

**Does Seny work with my stack?**
The method is stack-agnostic: commands come from your project rules, conventions from your `CLAUDE.md` files. The author's own defaults (TypeScript, pnpm, React Native + Expo, Astro, Next.js, Tailwind/NativeWind, TanStack Query + Zustand, Hono + Drizzle + Better Auth, Vitest, Playwright, Maestro) live in [`templates/stack.example.md`](templates/stack.example.md). Steal what you like.

**Will Seny push to my repo?**
Never. Seny commits only if you said so, asks if you didn't, and a hook blocks `git push` outright, so this isn't a promise, it's a rule. Grandmother rules.

**Can I skip the process when I'm in a hurry?**
Yes: that's the Direct track. Seny isn't against speed. It's against regret.

**What if I'm feeling a bit of rauxa?**
Healthy. Point it at a `/seny:spike`: throwaway code, a time box, and a branch nobody merges. Just don't let it write the migration.

More in [guide/faq.md](guide/faq.md).

---

## Author

**Marc** — Lead React Native and full-stack engineer, maker, and part-time grandmother-of-seny.
Industrial electronics by training, TypeScript by choice, Catalan by default.

[GitHub](https://github.com/Markuson)

---

## License

MIT © Marc. Use it, fork it, improve it. With seny.

<sub>Made in Sant Feliu de Codines, Catalonia, where the human towers are tall and the commits are small.</sub>

# principles-driven

A small suite of [Claude Code](https://claude.com/claude-code) **skills** for
capturing a project's guiding principles and keeping the code — and the AI
agent — consistent with them.

> Works with any agent harness that loads Agent Skills (Claude Code, and other
> tools that read `SKILL.md` skill folders). The principles themselves live in
> your project; these skills are the machinery that creates, applies, and audits
> them.

## Why principles?

An AI coding agent makes dozens of small judgment calls you never explicitly
asked about:

- which data fields and labels show on a screen, and which stay hidden,
- which actions get a confirmation prompt and which just run,
- when to show detail inline vs. tuck it behind a fold,
- when ease-of-use matters more than precision,
- how verbose an error or empty state should be.

Each call is usually reasonable on its own. Across a whole codebase they drift
into **mutual contradiction** — one screen rounds a number, the next dumps six
decimal places; one delete asks "are you sure?", the next wipes data silently.
Three forces drive the drift:

1. The agent has no durable decision policy — it re-decides each fork from
   scratch and can choose oppositely in two similar cases.
2. People forget past decisions and give inconsistent instructions over time.
3. A single new instruction can quietly *change* a principle, and nothing forces
   that change to ripple into the rest of the code.

A short, explicit, **checkable** set of principles — stored where the agent
reads it — gives the agent a consistent policy and gives you a memory.

## What's in the box

Four skills (one is a router) plus a shared reference file:

| Skill | Use it when… | What it does |
|---|---|---|
| **principles-driven** | you're not sure which of the below applies | thin router → points you at the right skill |
| **principles-review** | creating principles, inheriting a repo, editing/merging a principle | reads your code, **infers the principles already baked in**, surfaces where the code contradicts itself, dedupes against your `CLAUDE.md`/`AGENTS.md` rules, writes `PRINCIPLES.md`, and ripples a changed principle into violating code |
| **principles-check** | about to make a judgment call, or reviewing a diff | checks the decision against `PRINCIPLES.md`; on a conflict it **stops** and offers *follow / override-once (recorded) / amend the principle* instead of silently picking |
| **principles-audit** | periodic consistency sweep, or onboarding an existing repo | sweeps the whole codebase, ranks violations by priority, states coverage, proposes fixes |

The shared `skills/principles-driven/principle-schema.md` defines the entry
format every principle uses and the **altitude heuristic** that keeps principles
at the right level — decision-shaping, not lint rules, not vague taste.

### How a principle looks

Principles are stored in a `PRINCIPLES.md` at your project root, one entry each:

```
## P-007: Prefer ease-of-use over precision in primary flows
Statement: Default views optimize for fast comprehension; exact values one click deeper.
Why: Most users scan, don't audit; precision-first clutters the 90% case.
Applies to: general            # OR a scope, e.g. "dashboard + list views only"
Do: rounded headline figure + a details affordance for the exact value
Don't: render machine precision (toFixed(6)) in a list row
Priority: 2                    # lower number = higher precedence in conflicts
Status: active                 # active | proposed | retired
```

`review` also adds a one-line **pointer** to your harness file
(`CLAUDE.md`/`AGENTS.md`/`GEMINI.md`) so the agent actually loads `PRINCIPLES.md`
during everyday coding — without it, the file is dead weight.

## Install

These are **personal** skills — they live in your agent's skills directory and
work across all your projects.

### Option A — install script (recommended)

```bash
git clone https://github.com/ccr-hk/principles-driven.git
cd principles-driven
./install.sh            # symlinks the four skills into ~/.claude/skills/
```

Run `./install.sh --copy` instead if you'd rather copy the files than symlink
them. Re-run after `git pull` to pick up updates (symlink install updates
automatically).

### Option B — manual

Copy (or symlink) each folder under `skills/` into your agent's skills
directory:

```bash
cp -r skills/principles-driven skills/principles-review \
      skills/principles-check  skills/principles-audit  ~/.claude/skills/
```

> Other harnesses use a different skills path (e.g. Codex under
> `~/.agents/skills/`). Drop the same four folders there.

### Verify

Start a new Claude Code session and ask:

```
/principles-driven
```

or just describe the task ("help me set up our project's principles") — the
agent should pick up `principles-review`.

## Usage

### 1. Bootstrap your principles (run once, mid-project is fine)

> "Let's set up principles for this project."

`principles-review` surveys your code, drafts the principles it's *already*
following, shows you where the code disagrees with itself, and asks you to
resolve each fork. It writes `PRINCIPLES.md` and wires the harness pointer.

### 2. Let the agent check decisions as it works

Once the pointer is in your harness file, the agent consults `PRINCIPLES.md` on
relevant judgment calls. When a request collides with a principle, it stops and
gives you three choices:

- **Follow** the principle,
- **Override once** (the exception gets recorded so it doesn't silently recur),
- **Amend** the principle (hands off to `principles-review`).

You can also invoke it directly: *"check this change against our principles."*

### 3. Audit periodically

> "Audit the codebase against our principles."

`principles-audit` proves its method on a sample first, sweeps everything, and
hands back a priority-ranked list of violations with proposed fixes and an
explicit statement of what it did and didn't cover.

### Editing principles later

> "Our new rule is X" / "principle P-003 is wrong."

`principles-review` updates `PRINCIPLES.md` and then **ripples** the change —
scanning for code the new/changed principle now violates and proposing a fix
list.

## Design notes

A capable model already makes good principle *judgments* when `PRINCIPLES.md` is
in front of it. These skills don't try to teach reasoning — they add the parts a
model skips on its own: a stable **schema** (so principles can be cited and
ranked), an **altitude rule** (so lint rules and vague taste don't sneak in),
the **harness pointer** (so principles actually load), **override recording**
(so exceptions don't quietly become the norm), and **scale-safety** (sample
first, state coverage, never silently truncate an audit).

## Contributing

Issues and PRs welcome. Each skill change should be testable — describe the
agent behavior it changes.

## License

MIT — see [LICENSE](LICENSE).

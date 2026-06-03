# principles-driven

A small suite of **agent skills** that capture a project's guiding principles and
keep the code — and the AI agent — consistent with them.

Works across the major coding agents: **Claude Code, OpenAI Codex, Google
Antigravity, Cursor**, and any tool that reads the [`SKILL.md` Agent Skills
format](https://agentskills.io/) or an `AGENTS.md` instructions file.

---

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
decimals; one delete asks "are you sure?", the next wipes data silently. Three
forces drive it: the agent re-decides each fork from scratch, people forget past
decisions, and a single new instruction can quietly change a principle without
that change rippling into the rest of the code.

A short, explicit, **checkable** set of principles — stored where the agent
reads it — gives the agent a consistent policy and gives you a memory.

## What's in the box

| Skill | Use it when… | What it does |
|---|---|---|
| **principles-driven** | unsure which one applies | thin router → points at the right skill |
| **principles-review** | creating principles, inheriting a repo, editing/merging one | reads your code, **infers the principles already baked in**, surfaces where the code contradicts itself, dedupes against your `CLAUDE.md`/`AGENTS.md`, writes `PRINCIPLES.md`, ripples a changed principle into violating code |
| **principles-check** | about to make a judgment call, or reviewing a diff | checks the decision against `PRINCIPLES.md`; on a conflict **stops** and offers *follow / override-once (recorded) / amend* instead of silently picking |
| **principles-audit** | periodic consistency sweep, or onboarding a repo | sweeps the whole codebase, ranks violations by priority, states coverage, proposes fixes |
| **principles-update** | check for / apply a newer version of these skills | compares your installed version to the latest, shows the changelog, and updates **only after you confirm** |

The shared `principle-schema.md` defines the entry format and the **altitude
heuristic** that keeps principles decision-shaping — not lint rules, not vague
taste.

### How a principle looks

Principles live in a `PRINCIPLES.md` at your project root, one entry each:

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

`review` also adds a one-line pointer to your harness file
(`CLAUDE.md`/`AGENTS.md`/`GEMINI.md`) so the agent loads `PRINCIPLES.md` during
everyday coding.

## Supported harnesses

| Harness | Mechanism | Install location |
|---|---|---|
| **Claude Code** | native skills | `~/.claude/skills/` |
| **OpenAI Codex** | native skills | `~/.agents/skills/` (Codex scans this) |
| **Google Antigravity** | native skills | `~/.agents/skills/` |
| **Cursor** | project rules | `<project>/.cursor/rules/*.mdc` (generated) |
| Any `SKILL.md` tool | native skills | `~/.agents/skills/` |
| Any `AGENTS.md` tool | instructions pointer | optional block appended to your `AGENTS.md` |

The same `SKILL.md` files are the source of truth; the installer adapts them
(Cursor gets generated `.mdc` rules). Skills trigger on their `description`, so
once installed the agent picks the right one on its own.

## Install

> Requires `git`. The installer only writes skill folders unless you opt in to
> editing instruction files.

### Linux / macOS

```bash
git clone https://github.com/ccr-hk/principles-driven.git
cd principles-driven
./install.sh
```

`./install.sh` with no flags asks where to install. Or be explicit:

```bash
./install.sh --agents                 # ~/.agents/skills (Codex, Antigravity, …)
./install.sh --claude                 # ~/.claude/skills (Claude Code)
./install.sh --all                    # both of the above
./install.sh --cursor /path/to/proj   # generate .cursor/rules in a project
./install.sh --all --cursor /path/to/proj
./install.sh --all --copy             # copy instead of symlink
```

If it finds instruction files (`~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`,
`~/.claude/CLAUDE.md`) it asks whether to append a short pointer announcing the
skills. Force with `--register` / skip with `--no-register`.

### Windows (PowerShell)

```powershell
git clone https://github.com/ccr-hk/principles-driven.git
cd principles-driven
.\install.ps1                         # interactive
.\install.ps1 -All
.\install.ps1 -Agents -Cursor C:\path\to\proj
.\install.ps1 -All -Symlink           # symlink (needs Developer Mode/admin); default is copy
```

### Manual (any OS)

Copy each folder under `skills/` into your agent's skills directory
(`~/.claude/skills/` or `~/.agents/skills/`). For Cursor, copy
`dist/cursor/*.mdc` into your project's `.cursor/rules/`.

### Verify

Start a **new** agent session and ask for the router, or describe the task:

```
help me set up our project's principles
```

The agent should pick up `principles-review`. In Claude Code you can also type
`/principles-driven`.

## Usage

1. **Bootstrap** (once, mid-project is fine): *"Let's set up principles for this
   project."* → `principles-review` infers them from your code, shows
   contradictions, asks you to resolve each, writes `PRINCIPLES.md`, wires the
   pointer.
2. **Check as you work**: once the pointer is in place the agent consults
   `PRINCIPLES.md` on relevant decisions. On a clash it stops and offers
   *follow / override-once / amend*. Or invoke directly: *"check this change
   against our principles."*
3. **Audit periodically**: *"audit the codebase against our principles."* →
   ranked violations + coverage + proposed fixes.
4. **Edit principles later**: *"our new rule is X"* / *"P-003 is wrong"* →
   `principles-review` updates `PRINCIPLES.md` and ripples the change into code.

## Updating

The suite self-checks from inside a chat — just ask:

```
check for principles updates
```

`principles-update` compares your installed version to the latest, shows what
changed, and updates **only after you confirm**. Or update by hand from the
clone:

```bash
cd principles-driven && ./update.sh        # Linux/macOS
```
```powershell
cd principles-driven; .\update.ps1         # Windows
```

`update.sh`/`update.ps1` pull the latest and re-install into the exact targets
recorded in your manifest (`~/.config/principles-driven/manifest.txt`, or
`%APPDATA%\principles-driven\manifest.txt` on Windows). They never touch your
instruction files.

## Design notes

A capable model already makes good principle *judgments* when `PRINCIPLES.md` is
in front of it. These skills don't try to teach reasoning — they add the parts a
model skips on its own: a stable **schema** (so principles can be cited and
ranked), an **altitude rule** (so lint rules and vague taste don't sneak in),
the **harness pointer** (so principles actually load), **override recording** (so
exceptions don't quietly become the norm), and **scale-safety** (sample first,
state coverage, never silently truncate an audit).

## Repo layout

```
skills/                 SKILL.md source of truth (5 skills + principle-schema.md)
dist/cursor/            generated .cursor/rules/*.mdc (rebuild: scripts/build-cursor.sh)
install.sh / install.ps1
update.sh  / update.ps1
VERSION  CHANGELOG.md  LICENSE
```

## Contributing

Issues and PRs welcome. Edit the `SKILL.md` sources, then re-run
`scripts/build-cursor.sh` to regenerate the Cursor rules. Each skill change
should be testable — describe the agent behavior it changes.

## License

MIT — see [LICENSE](LICENSE).

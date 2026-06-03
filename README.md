# principles-driven

A small suite of **agent skills** that capture a project's guiding principles and
keep the code — and the AI agent — consistent with them.

Works with **Claude Code, OpenAI Codex, Google Antigravity, Cursor**, and 60+
other agents through the open [`skills`](https://github.com/vercel-labs/skills)
ecosystem.

---

## Install

One command — it asks which skills and which agents, then installs them:

```bash
npx skills add ccr-hk/principles-driven
```

That's it. The installer detects your agents (Claude Code, Codex, Cursor,
Antigravity, …), converts each skill to the right format, and symlinks them in.

**Common variations:**

```bash
npx skills add ccr-hk/principles-driven --all          # all skills, all agents
npx skills add ccr-hk/principles-driven -g             # install globally (all projects)
npx skills add ccr-hk/principles-driven -a claude-code # only a specific agent
npx skills add ccr-hk/principles-driven --list         # see the skills, install nothing
```

Works the same on **Linux, macOS, and Windows** (needs [Node.js](https://nodejs.org)
18+, which provides `npx`).

> Tip: install **all** the skills together — they share `principle-schema.md`,
> and `-update` keeps them current.

<details>
<summary>No Node / offline? Install manually</summary>

Copy each folder under `skills/` into your agent's skills directory
(`~/.claude/skills/` for Claude Code, `~/.agents/skills/` for Codex/Antigravity):

```bash
git clone https://github.com/ccr-hk/principles-driven.git
cp -r principles-driven/skills/* ~/.claude/skills/
```
</details>

### Verify

Start a **new** agent session and describe the task:

```
help me set up our project's principles
```

The agent should pick up `principles-review`. In Claude Code you can also type
`/principles-driven`.

## Updating

Ask inside any chat — the `principles-update` skill checks the latest version,
shows what changed, and updates **only after you confirm**:

```
check for principles updates
```

Or from your terminal:

```bash
npx skills update                      # update all installed skills
npx skills update principles-driven    # just this suite
```

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
| **principles-update** | checking for / applying a newer version | compares installed vs latest, shows the changelog, updates only after you confirm |

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

## Design notes

A capable model already makes good principle *judgments* when `PRINCIPLES.md` is
in front of it. These skills don't try to teach reasoning — they add the parts a
model skips on its own: a stable **schema** (so principles can be cited and
ranked), an **altitude rule** (so lint rules and vague taste don't sneak in),
the **harness pointer** (so principles actually load), **override recording** (so
exceptions don't quietly become the norm), and **scale-safety** (sample first,
state coverage, never silently truncate an audit).

## Contributing

Issues and PRs welcome. Skills are plain `SKILL.md` files under `skills/`. Each
change should be testable — describe the agent behavior it changes.

## License

MIT — see [LICENSE](LICENSE).

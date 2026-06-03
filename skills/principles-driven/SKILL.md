---
name: principles-driven
description: Use when working with a project's guiding principles or decision policy and unsure which principles skill applies — routes to authoring/maintaining, checking a decision, or auditing the whole codebase.
---

# Principles-Driven Development

A project's **principles** are its consistent policy for the judgment calls a
coding harness makes autonomously — which fields and labels show on a UI, what
needs a confirmation prompt, show-vs-fold detail, ease-of-use vs accuracy, error
verbosity. Without an explicit, checkable policy the model re-decides each fork
from scratch and drifts into self-contradiction; users forget past decisions and
instruct inconsistently.

This is a router. Pick the skill for the moment:

| You are… | Use |
|---|---|
| creating principles, just inherited a repo, editing/merging a principle, or principles overlap/bloat | **principles-review** |
| about to make a judgment call, or reviewing a diff/PR for adherence | **principles-check** |
| sweeping the whole codebase for consistency with the principle set | **principles-audit** |

Shared schema and the altitude heuristic (what earns a slot): see
`principle-schema.md` in this skill's directory. All three skills depend on it.

Core invariant across all three: **surface conflicts, never resolve them
silently.** Conflict classes — principle vs principle (code contradicts itself),
principle vs harness rule (`CLAUDE.md`/`AGENTS.md`), decision vs principle, and
instruction-implies-a-principle-should-change (which then ripples to code).

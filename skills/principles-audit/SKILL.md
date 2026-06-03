---
name: principles-audit
description: Use when doing a full-codebase sweep for consistency with PRINCIPLES.md — periodic consistency checks, onboarding or inheriting a repo, after a large principle change, or when asked "are we consistent with our principles?". Distinct from principles-check (single decision/diff).
---

# Principles-Audit

Sweep the whole codebase against every `active` principle, rank violations by
priority, and propose remediation. Stays honest at scale by proving on a sample
first, fanning out so nothing is skipped, and being explicit about coverage.

**REQUIRED:** read `../principles-driven/principle-schema.md` (you resolve and
rank by `Priority`, scope by `Applies to`, and ignore `proposed`/`retired`).

## Workflow

1. **Load** `PRINCIPLES.md`. Audit only `active` entries. A `proposed` entry is
   not yet enforced — note surfaces it concerns, don't count them as violations.
   No `PRINCIPLES.md` → offer `principles-review` instead.
2. **Prove on a sample first.** Pick a few representative files/surfaces and run
   the check by hand. Confirm your matching logic finds the real violations and
   doesn't flag compliant code, before sweeping everything. (Your project's
   validation rule requires this small-run-before-batch step.)
3. **Sweep, fanned out.** Large repo → split by area (directory/feature) and
   delegate areas to subagents; small repo → sweep inline. Match every surface
   against each `active` principle's `Applies to`.
4. **State coverage explicitly. No silent caps.** Report what was scanned and
   what was NOT (skipped dirs, generated code, sampled-not-exhaustive areas). An
   audit that quietly bounds its scope reads as "all clear" when it isn't.
5. **Report, ranked by Priority.** One row per violation:

   | Priority | File:line | Principle | How it violates | Proposed fix |

   Lower `Priority` number first. Note compliant exemplars so fixes have a
   reference pattern. Don't hand-wave a count — give the real number.
6. **Propose remediation, don't apply it** unless asked. A fix that requires
   changing a principle (or hits an unresolved `proposed`/conflict) is blocked —
   flag it and route to `principles-review`, don't guess.

## Common mistakes

| Mistake | Fix |
|---|---|
| "Repo's small, I'll just audit directly" | Still prove the match logic on a sample first — it's cheap and catches a wrong matcher before it taints the whole report. |
| Sweeping a big repo in one pass | Fan out by area to subagents; one context can't hold a large repo reliably. |
| Reporting only what you found | Also report coverage — what you did NOT scan. Silent truncation is the failure mode. |
| Counting `proposed` principles as violations | Only `active` is enforced. Note proposed-concerned surfaces separately. |
| Flagging compliant code (false positives) | Cite the exact line and the principle's Do/Don't; if you can't, it's not a violation. |
| Auto-fixing everything | Report by default. Fixes that touch a principle or an unresolved conflict go to `principles-review`. |

## Red flags — stop

- "I scanned the main folders." → Which folders did you NOT scan? Say so.
- "Looks consistent." → Did you prove the matcher on a sample, or just eyeball it?
- "I'll fix these while I'm here." → Audit reports; only apply fixes if asked, and never silently change a principle.

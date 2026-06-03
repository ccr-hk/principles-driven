---
name: principles-review
description: Use when establishing, editing, merging, or cleaning up a project's guiding principles / decision policy — including mid-development with no or a thin PRINCIPLES.md, onboarding an existing repo, when a user instruction implies a new or changed principle, or when principles overlap or bloat. Symptoms — inconsistent UI/UX/data decisions across the codebase, principles that contradict each other or the harness rules, or asking what the project is optimizing for.
---

# Principles-Review

Author and maintain the project's principle set. Mid-development this means
**deriving principles from the code that already exists** — not interviewing on
a blank slate — then writing them in a checkable form the harness will load.

**REQUIRED:** read `../principles-driven/principle-schema.md` (entry schema +
altitude heuristic) before writing any principle.

## Workflow

1. **Survey.** Read code patterns, `README`/`DESIGN`/docs, the existing harness
   file (`CLAUDE.md`/`AGENTS.md`/`GEMINI.md`), and recent commits. Large repo →
   delegate the survey to a subagent.
2. **Infer de-facto principles.** Draft candidates from what the code already
   does consistently. These are the implicit policies in force today.
3. **Find self-contradictions.** Where the code does X in one place and not-X in
   a comparable place, that is an *unresolved* principle question — not a
   principle. Collect each as a conflict to debate.
4. **Right-size every candidate** with the altitude heuristic. Drop anything a
   linter/type/test enforces (e.g. indentation, import style) or that is pure
   taste. If you can't write both a Do and a Don't, it's too vague — sharpen or
   drop.
5. **Dedupe vs harness rules.** Merge overlaps with existing `CLAUDE.md` rules;
   where a principle and a harness rule conflict, flag it.
6. **Debate, don't decide.** Present inferred principles, contradictions, and
   conflicts to the user — recommended resolution first, one fork at a time.
   Wait for the user's call on each before writing it as `active`. Open ones
   stay `Status: proposed`.
7. **Write** `PRINCIPLES.md` in the schema, and **add the harness pointer** (see
   schema file) if absent. The pointer is what makes the harness load the
   principles during coding — without it the file is dead weight.
8. **Ripple.** After adding/changing/retiring any principle, scan for code that
   now violates it and present a **targeted fix list** for the user to approve.
   (Whole-repo sweeps are `principles-audit`; this ripple is scoped to what the
   change touched.)

## Conflict handling

Stop and surface — never silently pick. State which entries clash and how,
propose options with a recommendation, get the user's decision. A resolution
that changes a principle re-enters this skill at step 7–8.

## Common mistakes

| Mistake | Fix |
|---|---|
| Freeform bullet list, no IDs/Priority/Status | Use the schema. `principles-check` and `-audit` cite `ID` and resolve by `Priority`; without them the principles aren't operable. |
| Including lint/format/taste rules ("2-space, destructure imports") | Apply altitude test 2. Mechanically enforceable → config/CI, not PRINCIPLES.md. |
| Writing PRINCIPLES.md but not touching the harness file | Add the pointer. No pointer = harness never reads it during coding. |
| Resolving a code self-contradiction yourself | It's an open question — debate it. Picking silently is the drift you're here to stop. |
| Documenting violations but leaving the code | Run the ripple (step 8): produce a fix list and offer to apply it. |
| Vague entry with no Don't | If you can't write a Don't, it's not checkable. Sharpen or cut. |

## Red flags — stop

- "I'll just pick the better side of this contradiction." → Debate it.
- "House style is a principle." → No, it's lint. Drop it.
- "The doc is written, done." → Did you add the harness pointer and run the ripple?

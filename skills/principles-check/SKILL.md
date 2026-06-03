---
name: principles-check
description: Use when about to make a judgment call during coding, or when reviewing a diff/PR for adherence to PRINCIPLES.md. Symptoms — choosing which data fields or labels appear on a UI, whether an action needs a confirmation prompt, show-detail-inline vs fold-away, trading ease-of-use against accuracy, how verbose an error or empty state should be. Also when a user instruction conflicts with an existing principle.
---

# Principles-Check

Match a pending decision or diff against **all** of `PRINCIPLES.md`, surface
any conflict with the user instead of picking a side, and **record** overrides
so they don't recur.

**REQUIRED:** read `../principles-driven/principle-schema.md` for the entry
schema (you resolve by `Priority` and scope by `Applies to`).

## Workflow

1. **Load** `PRINCIPLES.md`. If it's absent, say so and offer `principles-review`
   — don't proceed on vibes.
2. **Match the whole set, not just the obvious one.** For every surface/decision
   the change touches, find each `active` principle whose `Applies to` covers it.
   List which principles you checked, so a subtle low-salience conflict can't
   slip past.
3. **Evaluate** the decision/diff against each matched principle.
4. **No conflict →** state which principles you checked and that it complies.
   Proceed.
5. **Conflict → STOP. Do not ship a unilateral resolution — even the safe one.**
   Surface it and present the three options (recommendation first):

   - **Follow** — adjust the decision to comply with the principle.
   - **Override once** — proceed against it for this case. Requires an explicit
     user OK, and you must **record** it: a one-line code comment at the site
     (`// principle override: P-001 — <reason>, approved <who/when>`) and, if the
     project keeps one, a line in an exceptions log. Unrecorded overrides are
     how drift comes back.
   - **Amend** — the principle itself is wrong/outdated → hand off to
     `principles-review` (don't edit `PRINCIPLES.md` from here).

   Cite the principle `ID`, its `Priority`, and exactly how the decision
   violates it. On two clashing principles, lower `Priority` wins; if that
   doesn't settle it, surface both and ask.
6. **Wait for the user's pick** before writing the conflicting code. Picking the
   safe side yourself and shipping is still resolving silently.

## Common mistakes

| Mistake | Fix |
|---|---|
| "I'll just follow the principle and ship the safe version." | Following may be right, but it's still a unilateral resolution. Surface the conflict and let the user choose (interactive) or hold + flag (non-interactive). |
| Only flagging the one obvious principle | Match `Applies to` across every surface the change touches; list all you checked. |
| Letting the user override with no record | Write the override comment at the site (+ exceptions log if present). No silent overrides. |
| Editing PRINCIPLES.md to resolve a conflict | That's `principles-review`'s job. Amend = hand off, don't self-edit. |
| Proceeding when there's no PRINCIPLES.md | Say so, offer `principles-review`; don't invent a policy. |

## Red flags — stop

- "The instruction says skip it, so I'll skip the principle." → A user instruction that conflicts with a principle is the exact case to surface, not obey blindly. Options: follow / override-once (recorded) / amend.
- "It's safer to just comply and move on." → Still unilateral. Surface it.
- "Obviously P-001 applies, done." → Did you check the rest of the set against every surface you touched?

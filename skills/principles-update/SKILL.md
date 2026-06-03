---
name: principles-update
description: Use when the user asks to update the principles-driven skills or check for a newer version — and opportunistically when the installed principles skills look out of date.
---

# Principles-Update

Check whether a newer release of the **principles-driven** skill suite exists,
show the user what changed, and update **only after they confirm**.

These skills install with the `skills` CLI, which has its own updater. This skill
does a read-only version check first, then defers to that CLI to apply.

## Workflow

1. **Read the latest version** (read-only, no changes):
   ```
   curl -fsSL https://raw.githubusercontent.com/ccr-hk/principles-driven/main/VERSION
   ```

2. **Find the installed version.** Check the installed skill folder for a sibling
   `VERSION`, or run `npx skills list` (alias `npx skills ls -g`) to see what's
   installed. If you can't determine it, say so and treat the check as
   "unknown → offer to update anyway."

3. **Compare** as semver. Installed ≥ latest → tell the user they're current,
   stop. Newer available → continue.

4. **Show what changed** so the user can decide:
   ```
   curl -fsSL https://raw.githubusercontent.com/ccr-hk/principles-driven/main/CHANGELOG.md
   ```
   Summarize the entries between their version and latest.

5. **Ask before applying.** Present current vs latest, the change summary, and
   the exact command. Do **not** run it until the user says yes.

6. **On confirmation, update** with the CLI the skills were installed with:
   ```
   npx skills update                      # update all installed skills
   npx skills update principles-driven    # or just this suite, by skill name
   ```
   Add `-g` if they were installed globally. If the CLI isn't available, fall
   back to re-running the install command from the repo README.

7. **Confirm the result** — re-check the installed version and report it.

If the network check fails, say so plainly; don't guess whether an update exists.

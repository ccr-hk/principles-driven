---
name: principles-update
description: Use when the user asks to update the principles-driven skills, check whether a newer version exists, or check for principles skill updates — and as a self-check the agent may run opportunistically when it notices the installed principles skills may be out of date. Never updates without the user's explicit confirmation.
---

# Principles-Update

Check whether a newer release of the **principles-driven** skill suite is
available, show the user what changed, and update **only after they confirm**.

The skills install with a manifest recording the installed version and where
they came from. This skill reads that manifest, compares it to the latest
published version, and — if there's a newer one — asks the user before applying.

## Workflow

1. **Find the manifest.** Look for it at (first that exists):
   - `${XDG_CONFIG_HOME:-$HOME/.config}/principles-driven/manifest.txt` (Linux/macOS)
   - `$HOME/.config/principles-driven/manifest.txt`
   - `%APPDATA%\principles-driven\manifest.txt` (Windows)

   It is `key=value` lines: `version`, `repo`, `clone_path`, `method`,
   `targets`, `installed_at`. No manifest → the suite was installed manually;
   tell the user that and point them at the repo's README "Updating" section.

2. **Read the installed version** from `version` in the manifest.

3. **Fetch the latest version** (read-only, no changes):
   ```
   curl -fsSL https://raw.githubusercontent.com/ccr-hk/principles-driven/main/VERSION
   ```
   (or the `repo`'s raw `VERSION` if the manifest names a fork.)

4. **Compare** as semver. Equal/newer-local → tell the user they're current,
   stop. Newer-remote → continue.

5. **Show what changed.** Fetch the changelog/commit summary so the user sees
   what they'd get:
   ```
   curl -fsSL https://raw.githubusercontent.com/ccr-hk/principles-driven/main/CHANGELOG.md
   ```
   Summarize the entries between their version and latest.

6. **Ask before applying.** Present: current version, latest version, summary of
   changes, and the exact update command for their platform. Do **not** run it
   until the user says yes.

7. **On confirmation, run the updater** using the manifest's `clone_path` and
   `method`:
   - Cloned install: `cd <clone_path> && git pull && ./update.sh`
     (Windows: `git pull; .\update.ps1`)
   - curl/manual install: re-run the install one-liner from the README.
   Re-run with the same target flags the manifest records in `targets`.

8. **Confirm the result** — read the manifest `version` again and report the new
   installed version.

## Rules

- **Never update without explicit confirmation.** Checking and showing the diff
  is fine unprompted; applying is not.
- **Read-only checks only** until the user agrees — `curl` the version/changelog,
  don't pull or overwrite.
- If the network check fails, say so plainly; don't guess whether an update
  exists.

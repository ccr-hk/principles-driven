# Changelog

All notable changes to the principles-driven skill suite.

The format follows [Keep a Changelog](https://keepachangelog.com/) and the
project uses [Semantic Versioning](https://semver.org/).

## [0.1.0] — 2026-06-03

First release.

### Added
- **principles-review** — author/maintain `PRINCIPLES.md`: infer principles from
  existing code, surface self-contradictions, dedupe against harness rules, add
  the harness pointer, ripple a changed principle into violating code.
- **principles-check** — check one decision/diff against the principles; on a
  conflict, stop and offer follow / override-once (recorded) / amend.
- **principles-audit** — full-codebase consistency sweep, sample-first,
  priority-ranked, with an explicit coverage statement.
- **principles-driven** — router that points at the right skill, plus the shared
  `principle-schema.md` (entry schema + altitude heuristic).
- **principles-update** — in-chat self-check for a newer release; never updates
  without explicit confirmation.
- Cross-harness install: universal `SKILL.md` into `~/.agents/skills` (Codex,
  Antigravity, any SKILL.md tool), `~/.claude/skills` (Claude Code), and
  generated `.cursor/rules/*.mdc` for Cursor.
- `install.sh` / `install.ps1`, `update.sh` / `update.ps1`, and a manifest that
  records the install so updates target the same locations.

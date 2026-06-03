# Changelog

All notable changes to the principles-driven skill suite.

The format follows [Keep a Changelog](https://keepachangelog.com/) and the
project uses [Semantic Versioning](https://semver.org/).

## [0.2.1] — 2026-06-03

### Changed
- Trimmed descriptions across all 5 skills for token efficiency; removed
  redundant "this skill exists so" meta-sentences from body intros.
- `principles-review` step 1: removed "Large repo → subagent" (already in step 3).
- `principles-update`: removed redundant `## Rules` section (covered by step 5).
- All trigger keywords and anti-rationalization content preserved.

## [0.2.0] — 2026-06-03

Simplified to one-command install via the open `skills` CLI.

### Changed
- **Install is now `npx skills add ccr-hk/principles-driven`** — interactive,
  cross-agent (Claude Code, Codex, Cursor, Antigravity + 60 more), same on
  Linux/macOS/Windows. The CLI handles per-agent conversion, symlink/copy,
  global/project scope, and updates.
- `principles-update` rewritten to use `npx skills update` (still asks first).

### Fixed
- `principles-review` was silently dropped by strict YAML parsers: its
  frontmatter `description` had a `colon-space` ("Symptoms: ...") inside an
  unquoted scalar. Reworded so all 5 skills are discovered.

### Removed
- Bespoke `install.sh`/`install.ps1`, `update.sh`/`update.ps1`, the Cursor
  `.mdc` generator, and `dist/cursor/` — all superseded by the `skills` CLI.

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

#!/usr/bin/env bash
# Install the principles-driven skill suite for one or more agent harnesses.
#
# Run from a cloned repo:
#   git clone https://github.com/ccr-hk/principles-driven.git
#   cd principles-driven && ./install.sh
#
# Targets (choose any; default = interactive prompt):
#   --agents            ~/.agents/skills   (Codex, Antigravity, any SKILL.md tool)
#   --claude            ~/.claude/skills   (Claude Code)
#   --cursor <dir>      <dir>/.cursor/rules (Cursor project rules; repeatable)
#   --all               --agents and --claude (Cursor still needs a path)
# Options:
#   --copy              copy files instead of symlinking (default: symlink)
#   --register          append a pointer block to detected instruction files
#   --no-register       never touch instruction files
#   -h, --help
#
# Override the universal/Claude paths with AGENTS_SKILLS_DIR / CLAUDE_SKILLS_DIR.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/skills"
SKILLS=(principles-driven principles-review principles-check principles-audit principles-update)
VERSION="$(cat "$ROOT/VERSION" 2>/dev/null || echo unknown)"

AGENTS_DIR="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
CLAUDE_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/principles-driven"

do_agents=0; do_claude=0; cursor_dirs=(); mode="symlink"; register="ask"

while [ $# -gt 0 ]; do
  case "$1" in
    --agents) do_agents=1 ;;
    --claude) do_claude=1 ;;
    --all) do_agents=1; do_claude=1 ;;
    --cursor) shift; cursor_dirs+=("${1:?--cursor needs a project dir}") ;;
    --copy) mode="copy" ;;
    --register) register="yes" ;;
    --no-register) register="no" ;;
    -h|--help) sed -n '2,20p' "$ROOT/install.sh"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

# interactive target selection if nothing chosen
if [ $do_agents -eq 0 ] && [ $do_claude -eq 0 ] && [ ${#cursor_dirs[@]} -eq 0 ]; then
  if [ -t 0 ]; then
    echo "Where should the principles-driven skills be installed?"
    echo "  1) Universal  (~/.agents/skills — Codex, Antigravity, SKILL.md tools)"
    echo "  2) Claude Code (~/.claude/skills)"
    echo "  3) Both 1 and 2  [default]"
    echo "  4) Universal + a Cursor project"
    read -r -p "Choice [3]: " choice
    case "${choice:-3}" in
      1) do_agents=1 ;;
      2) do_claude=1 ;;
      3) do_agents=1; do_claude=1 ;;
      4) do_agents=1; read -r -p "Cursor project path: " cp; cursor_dirs+=("$cp") ;;
      *) do_agents=1; do_claude=1 ;;
    esac
  else
    do_agents=1; do_claude=1   # non-interactive default
  fi
fi

link_skills() {  # $1 = destination skills dir
  local dest="$1"
  mkdir -p "$dest"
  for s in "${SKILLS[@]}"; do
    local target="$dest/$s"
    [ -e "$target" ] || [ -L "$target" ] && rm -rf "$target"
    if [ "$mode" = "symlink" ]; then ln -s "$SRC/$s" "$target"; else cp -r "$SRC/$s" "$target"; fi
  done
  echo "  $mode -> $dest  (${#SKILLS[@]} skills)"
}

install_cursor() {  # $1 = project dir
  local proj="$1" dest="$1/.cursor/rules"
  if [ ! -d "$proj" ]; then echo "  skip cursor: '$proj' is not a directory" >&2; return; fi
  mkdir -p "$dest"
  cp "$ROOT"/dist/cursor/*.mdc "$dest/"
  echo "  copy  -> $dest  ($(ls -1 "$ROOT"/dist/cursor/*.mdc | wc -l | tr -d ' ') rules)"
}

targets=()
echo "Installing principles-driven v$VERSION"
[ $do_agents -eq 1 ] && { link_skills "$AGENTS_DIR"; targets+=("agents:$AGENTS_DIR"); }
[ $do_claude -eq 1 ] && { link_skills "$CLAUDE_DIR"; targets+=("claude:$CLAUDE_DIR"); }
for d in "${cursor_dirs[@]:-}"; do [ -n "$d" ] && { install_cursor "$d"; targets+=("cursor:$d/.cursor/rules"); }; done

# --- optional pointer registration in always-loaded instruction files ---
POINTER_BEGIN="<!-- principles-driven:begin -->"
POINTER_END="<!-- principles-driven:end -->"
pointer_block() {
  cat <<'EOF'
<!-- principles-driven:begin -->
## Principles-driven skills
This project/user has the **principles-driven** skill suite installed. When a
task involves the project's guiding principles or a judgment call:
- create/edit principles or inherit a repo → use **principles-review**
- about to make a judgment call, or reviewing a diff → use **principles-check**
- whole-codebase consistency sweep → use **principles-audit**
- check for updates to these skills → use **principles-update**
On every judgment call covered by `PRINCIPLES.md`, honor it; on a conflict, stop
and surface options rather than deciding silently.
<!-- principles-driven:end -->
EOF
}
register_into() {  # $1 = instruction file
  local f="$1"
  [ -f "$f" ] || return 0
  if grep -qF "$POINTER_BEGIN" "$f" 2>/dev/null; then echo "  pointer already present in $f"; return 0; fi
  printf '\n%s\n' "$(pointer_block)" >> "$f"
  echo "  appended pointer -> $f"
}
candidate_instruction_files=("$HOME/.codex/AGENTS.md" "$HOME/.gemini/GEMINI.md" "$HOME/.claude/CLAUDE.md")
present_files=(); for f in "${candidate_instruction_files[@]}"; do [ -f "$f" ] && present_files+=("$f"); done

if [ ${#present_files[@]} -gt 0 ]; then
  if [ "$register" = "ask" ] && [ -t 0 ]; then
    echo ""
    echo "Found instruction files that could announce these skills:"
    printf '  - %s\n' "${present_files[@]}"
    read -r -p "Append a principles-driven pointer to them? [y/N]: " ans
    [ "${ans:-N}" = "y" ] || [ "${ans:-N}" = "Y" ] && register="yes" || register="no"
  fi
  if [ "$register" = "yes" ]; then for f in "${present_files[@]}"; do register_into "$f"; done
  else echo "  (skipped instruction-file registration)"; fi
fi

# --- manifest ---
mkdir -p "$CONFIG_DIR"
repo_url="$(git -C "$ROOT" config --get remote.origin.url 2>/dev/null || echo https://github.com/ccr-hk/principles-driven)"
method="copy"; [ -d "$ROOT/.git" ] && method="clone"
{
  echo "version=$VERSION"
  echo "repo=$repo_url"
  echo "clone_path=$ROOT"
  echo "method=$method"
  echo "targets=$(IFS=,; echo "${targets[*]}")"
  echo "install_mode=$mode"
  echo "installed_at=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo unknown)"
} > "$CONFIG_DIR/manifest.txt"

echo ""
echo "Done. v$VERSION installed. Manifest: $CONFIG_DIR/manifest.txt"
echo "Start a new agent session and try: principles-driven"

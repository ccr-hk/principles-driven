#!/usr/bin/env bash
# Install the principles-driven skills into your agent's skills directory.
#
#   ./install.sh           # symlink each skill into the target (default)
#   ./install.sh --copy    # copy instead of symlink
#   SKILLS_DIR=~/.agents/skills ./install.sh   # override target (e.g. Codex)
#
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/skills" && pwd)"
DEST="${SKILLS_DIR:-$HOME/.claude/skills}"
MODE="symlink"
[ "${1:-}" = "--copy" ] && MODE="copy"

mkdir -p "$DEST"

for skill in principles-driven principles-review principles-check principles-audit; do
  target="$DEST/$skill"
  if [ -e "$target" ] || [ -L "$target" ]; then
    rm -rf "$target"
  fi
  if [ "$MODE" = "symlink" ]; then
    ln -s "$SRC/$skill" "$target"
    echo "linked  $skill -> $target"
  else
    cp -r "$SRC/$skill" "$target"
    echo "copied  $skill -> $target"
  fi
done

echo ""
echo "Done ($MODE). Installed into: $DEST"
echo "Start a new agent session and try: /principles-driven"

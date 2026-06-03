#!/usr/bin/env bash
# Update an existing principles-driven install: pull the latest and re-install
# into the same targets recorded in the manifest. Always safe to re-run.
#
#   cd <clone> && ./update.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/principles-driven"
MANIFEST="$CONFIG_DIR/manifest.txt"

old="unknown"
[ -f "$MANIFEST" ] && old="$(grep '^version=' "$MANIFEST" | cut -d= -f2)"

if [ -d "$ROOT/.git" ]; then
  echo "Pulling latest in $ROOT ..."
  git -C "$ROOT" pull --ff-only
fi
new="$(cat "$ROOT/VERSION" 2>/dev/null || echo unknown)"
echo "Version: $old -> $new"

# rebuild Cursor rules if any cursor target is recorded
if [ -f "$MANIFEST" ] && grep -q 'cursor:' "$MANIFEST" && [ -x "$ROOT/scripts/build-cursor.sh" ]; then
  "$ROOT/scripts/build-cursor.sh" >/dev/null && echo "rebuilt Cursor rules"
fi

# reconstruct install flags from the manifest
flags=()
if [ -f "$MANIFEST" ]; then
  mode="$(grep '^install_mode=' "$MANIFEST" | cut -d= -f2 || true)"
  [ "$mode" = "copy" ] && flags+=("--copy")
  targets="$(grep '^targets=' "$MANIFEST" | cut -d= -f2- || true)"
  IFS=',' read -ra parts <<< "$targets"
  for p in "${parts[@]}"; do
    case "$p" in
      agents:*) flags+=("--agents"); export AGENTS_SKILLS_DIR="${p#agents:}" ;;
      claude:*) flags+=("--claude"); export CLAUDE_SKILLS_DIR="${p#claude:}" ;;
      cursor:*) proj="${p#cursor:}"; proj="${proj%/.cursor/rules}"; flags+=("--cursor" "$proj") ;;
    esac
  done
fi
# don't re-touch instruction files automatically on update
flags+=("--no-register")

echo "Re-installing: ${flags[*]:-(defaults)}"
"$ROOT/install.sh" "${flags[@]}"
echo "Update complete: now at v$new"

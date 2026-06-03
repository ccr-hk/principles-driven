#!/usr/bin/env bash
# Generate Cursor project rules (.cursor/rules/*.mdc) from the SKILL.md sources.
# Output is committed under dist/cursor/ so Windows users don't need a shell to
# install. Re-run this whenever a SKILL.md changes.
#
#   ./scripts/build-cursor.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/skills"
OUT="$ROOT/dist/cursor"
rm -rf "$OUT"; mkdir -p "$OUT"

# strip the leading YAML frontmatter (--- ... ---) and print the body
body_of() {
  awk 'NR==1 && $0=="---" {infm=1; next}
       infm && $0=="---" {infm=0; next}
       !infm {print}' "$1"
}

# pull a frontmatter field value
field_of() {
  awk -v k="$2" '
    NR==1 && $0=="---" {infm=1; next}
    infm && $0=="---" {exit}
    infm {
      if ($0 ~ "^"k":") { sub("^"k":[ ]*",""); print; exit }
    }' "$1"
}

emit_rule() {
  local name="$1"
  local desc="$2"
  local srcfile="$3"
  local out="$OUT/$name.mdc"
  {
    echo "---"
    echo "description: $desc"
    echo "globs:"
    echo "alwaysApply: false"
    echo "---"
    echo ""
    # rewrite the shared-schema reference to point at the Cursor schema rule
    body_of "$srcfile" \
      | sed -E 's#\.\./principles-driven/principle-schema\.md#the principle-schema rule (.cursor/rules/principles-schema.mdc)#g'
  } > "$out"
  echo "generated $out"
}

for s in principles-driven principles-review principles-check principles-audit principles-update; do
  f="$SRC/$s/SKILL.md"
  emit_rule "$s" "$(field_of "$f" description)" "$f"
done

# the shared schema becomes its own (non-skill) reference rule
{
  echo "---"
  echo "description: Reference — principle entry schema and altitude heuristic for the principles-driven rules."
  echo "globs:"
  echo "alwaysApply: false"
  echo "---"
  echo ""
  cat "$SRC/principles-driven/principle-schema.md"
} > "$OUT/principles-schema.mdc"
echo "generated $OUT/principles-schema.mdc"

echo "Done. $(ls -1 "$OUT" | wc -l | tr -d ' ') rule files in dist/cursor/"

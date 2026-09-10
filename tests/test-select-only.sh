#!/usr/bin/env bash
set -euo pipefail

# RED/GREEN contract for external selection-only consumers.
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
AWTWALL="$ROOT/awtwall"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ -f "$AWTWALL" ]] || fail "awtwall script missing"
bash -n "$AWTWALL" || fail "awtwall has invalid Bash syntax"

grep -Fq 'SELECT_ONLY=0' "$AWTWALL" \
  || fail "selection-only runtime state is missing"
grep -Fq -- '--select-only' "$AWTWALL" \
  || fail "selection-only CLI option is missing"
grep -Fq 'select_only_accept()' "$AWTWALL" \
  || fail "selection-only accept path is missing"
grep -Fq 'SELECT_ONLY_RESULT_FILE' "$AWTWALL" \
  || fail "selection-only result-file contract is missing"
grep -Fq 'printf '\''%s\n'\'' "$img" >"$SELECT_ONLY_RESULT_FILE"' "$AWTWALL" \
  || fail "selection-only mode does not write the exact selected image path"
grep -Fq 'RUNNING=0' "$AWTWALL" \
  || fail "selection-only acceptance does not close the picker"
grep -Fq 'if (( SELECT_ONLY == 1 )); then' "$AWTWALL" \
  || fail "selection-only mode is not isolated from normal apply behavior"
grep -Fq 'DISPLAY_SELECTOR_ENABLED=0' "$AWTWALL" \
  || fail "selection-only mode does not suppress display targeting"
grep -Fq 'POST_EXEC_ALLOWED=0' "$AWTWALL" \
  || fail "selection-only mode does not suppress post-apply hooks"

printf 'PASS: awtwall selection-only picker contract\n'

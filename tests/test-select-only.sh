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

help_text="$("$AWTWALL" --help)"
grep -Fq -- '--select-only' <<<"$help_text" \
  || fail "selection-only CLI option is missing from help"
grep -Fq -- '--select-result PATH' <<<"$help_text" \
  || fail "selection-only result-file option is missing from help"

grep -Fq 'SELECT_ONLY=0' "$AWTWALL" \
  || fail "selection-only runtime state is missing"
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
grep -Fq 'if (( SELECT_ONLY == 0 )) && ! ensure_backend_available; then' "$AWTWALL" \
  || fail "selection-only mode still requires a wallpaper backend"
grep -Fq 'if (( SELECT_ONLY == 1 )); then' "$AWTWALL" \
  || fail "selection-only persistence guard is missing"
grep -Fq 'selection-only encoder=${SIXEL_ENCODER_LABEL}' "$AWTWALL" \
  || fail "selection-only UI still exposes normal backend/display status"

printf 'PASS: awtwall selection-only picker contract\n'

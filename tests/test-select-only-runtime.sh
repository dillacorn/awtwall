#!/usr/bin/env bash
# shellcheck disable=SC2034
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
APP="${ROOT}/awtwall"
TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  return 1
}

accept_fn="$(awk '/^select_only_accept\(\)/,/^}/ { print }' "$APP")"
apply_fn="$(awk '/^apply_selected\(\)/,/^}/ { print }' "$APP")"
save_fn="$(awk '/^save_state\(\)/,/^}/ { print }' "$APP")"

[[ -n "$accept_fn" ]] || fail 'could not extract select_only_accept'
[[ -n "$apply_fn" ]] || fail 'could not extract apply_selected'
[[ -n "$save_fn" ]] || fail 'could not extract save_state'

if grep -Eq 'apply_path|backend_state|run_post_exec|DISPLAY_TARGET|BACKEND=' <<<"$accept_fn"; then
  fail 'selection acceptance enters wallpaper application or backend state'
fi

grep -Fq 'if (( SELECT_ONLY == 1 )); then' <<<"$apply_fn" \
  || fail 'apply_selected does not gate selection-only behavior'
grep -Fq 'select_only_accept "$img"' <<<"$apply_fn" \
  || fail 'selection-only apply_selected path does not call select_only_accept'
grep -Fq 'if (( SELECT_ONLY == 1 )); then' <<<"$save_fn" \
  || fail 'save_state does not suppress persistence in selection-only mode'

img="${TMP}/wall paper.png"
printf 'readable test image placeholder\n' >"$img"
result="${TMP}/selection.txt"
SELECT_ONLY_RESULT_FILE="$result"
RUNNING=1
STATUS_MSG=""
msg() { STATUS_MSG="$*"; }

eval "$accept_fn"
select_only_accept "$img" >/dev/null

[[ -f "$result" ]] || fail 'selection did not create the requested result file'
[[ "$(cat -- "$result")" == "$img" ]] \
  || fail 'result file did not contain the exact selected absolute path'
[[ "$RUNNING" == "0" ]] || fail 'selection did not request picker shutdown'

bash -n "$APP"
printf 'PASS: awtwall selection-only runtime contract\n'

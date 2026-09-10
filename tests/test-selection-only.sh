#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
APP="${ROOT}/awtwall"
TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    return 1
}

require_text() {
    local needle="$1" message="$2"
    grep -Fq -- "$needle" "$APP" || fail "$message"
}

require_text '--select-only' 'help/parser does not expose --select-only'
require_text '--select-result' 'help/parser does not expose --select-result'
require_text 'SELECTION_ONLY=0' 'selection-only state is missing'
require_text 'SELECT_RESULT_FILE=""' 'selection result-file state is missing'
require_text 'selection_accept_path()' 'pure selection acceptance function is missing'
require_text 'selection_cancel()' 'selection cancellation function is missing'
require_text 'if (( SELECTION_ONLY == 1 )); then' 'selection-only behavior is not gated explicitly'
require_text 'if [[ -n "$SELECT_RESULT_FILE" && "$SELECTION_ONLY" != "1" ]]' '--select-result is not constrained to --select-only'
require_text 'Selection-only mode cannot run wallpaper apply actions' 'selection-only apply actions are not rejected'
require_text 'Select image' 'selection-only UI does not advertise selection behavior'
require_text 'Unavailable in selection-only mode' 'selection-only hotkeys are not isolated from wallpaper controls'

accept_fn="$(awk '/^selection_accept_path\(\)/,/^}/ { print }' "$APP")"
cancel_fn="$(awk '/^selection_cancel\(\)/,/^}/ { print }' "$APP")"
[[ -n "$accept_fn" ]] || fail 'could not extract selection_accept_path'
[[ -n "$cancel_fn" ]] || fail 'could not extract selection_cancel'

if grep -Eq 'apply_|backend_state|save_state|run_post_exec|DISPLAY_TARGET|BACKEND=' <<<"$accept_fn"; then
    fail 'selection_accept_path enters wallpaper application or persistent backend state'
fi

img="${TMP}/wall paper.png"
printf 'not-an-image-but-readable\n' >"$img"
result="${TMP}/selection.txt"
FILES=("$img")
SELECT_RESULT_FILE="$result"
RUNNING=1
CLEAR_ON_EXIT=0
STATUS_MSG=""
msg() { STATUS_MSG="$*"; }

eval "$accept_fn"
selection_accept_path "$img" >/dev/null
[[ -f "$result" ]] || fail 'selection did not create the requested result file'
[[ "$(cat -- "$result")" == "$img" ]] || fail 'result file did not contain the exact selected absolute path'
[[ "$RUNNING" == "0" ]] || fail 'selection did not request picker shutdown'

rm -f -- "$result"
RUNNING=1
eval "$cancel_fn"
selection_cancel
[[ ! -e "$result" ]] || fail 'cancel created or modified a selection result'
[[ "$RUNNING" == "0" ]] || fail 'cancel did not request picker shutdown'

if HOME="$TMP/home" XDG_CONFIG_HOME="$TMP/config" XDG_CACHE_HOME="$TMP/cache" \
    bash "$APP" --select-result "$result" </dev/null >"${TMP}/stdout" 2>"${TMP}/stderr"; then
    fail '--select-result without --select-only unexpectedly succeeded'
fi
grep -Fq -- '--select-result requires --select-only' "${TMP}/stderr" \
    || fail '--select-result without --select-only did not report the expected validation error'

bash -n "$APP"
printf 'PASS: awtwall selection-only picker contract\n'

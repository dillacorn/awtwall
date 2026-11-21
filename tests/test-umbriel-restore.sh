#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/awtwall"

if ! command -v jq >/dev/null 2>&1; then
  printf 'SKIP: jq is required for Umbriel restore tests\n'
  exit 0
fi

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
extract() {
  awk -v fn="$1" '
    $0 == fn "() {" { on = 1 }
    on { print }
    on && $0 == "}" { exit }
  ' "$APP"
}

for fn in is_umbriel_session restore_apply_saved_map; do
  body="$(extract "$fn")"
  [[ -n "$body" ]] || fail "could not extract $fn"
  eval "$body"
done

tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT

printf 'image 1\n' > "$tmp/dp1.png"
printf 'image 2\n' > "$tmp/dp3.png"
printf 'old output\n' > "$tmp/legacy.png"

declare -A BACKEND_STATE_MAP=(
  [DP-1]="$tmp/dp1.png"
  [DP-3]="$tmp/dp3.png"
  [WAYLAND-1]="$tmp/legacy.png"
)
original_dp1="${BACKEND_STATE_MAP[DP-1]}"
original_dp3="${BACKEND_STATE_MAP[DP-3]}"
original_legacy="${BACKEND_STATE_MAP[WAYLAND-1]}"

have() {
  case "$1" in umbriel|jq) return 0 ;; *) return 1 ;; esac
}
umbriel() {
  [[ $# -eq 2 && "$1" == outputs && "$2" == --json ]] || return 1
  printf '%s\n' "$MOCK_OUTPUTS"
}
backend_state_read() { :; }
backend_state_output_backend_for() { printf 'swww'; }
kill_hyprpaper_if_running() { :; }
ensure_swww_daemon() { :; }
kill_mpvpaper_for_target() { :; }
swww_apply_output() { printf '%s\n' "$1" >> "$tmp/applied"; }
hyprpaper_apply_output() { fail 'unexpected hyprpaper apply'; }
mpvpaper_apply_output() { fail 'unexpected mpvpaper apply'; }
die() { printf 'awtwall: %s\n' "$*" >&2; exit 1; }

export XDG_CURRENT_DESKTOP=umbriel
MOCK_OUTPUTS='[
 {"name":"DP-1","enabled":true,"focused":true},
 {"name":"DP-3","enabled":true,"focused":false},
 {"name":"DP-5","enabled":false,"focused":false}
]'
result="$(restore_apply_saved_map 2>&1)" || fail "Umbriel restore returned an error: $result"
grep -Fq 'restored 2 wallpaper(s)' <<<"$result" || fail 'missing two successful restores'
grep -Fq 'ignored 1 saved output(s) not enabled in Umbriel' <<<"$result" ||
  fail 'missing explanation for inactive output'
if grep -Fq 'skipped' <<<"$result"; then
  fail 'inactive output was counted as a failed restore'
fi
[[ "$(wc -l < "$tmp/applied")" -eq 2 ]] || fail 'incorrect number of applications'
grep -Fxq 'DP-1' "$tmp/applied" && grep -Fxq 'DP-3' "$tmp/applied" ||
  fail 'wrong outputs restored'
if grep -Fq 'WAYLAND-1' "$tmp/applied"; then fail 'restored inactive output'; fi
[[ "${BACKEND_STATE_MAP[DP-1]}" == "$original_dp1" &&
   "${BACKEND_STATE_MAP[DP-3]}" == "$original_dp3" &&
   "${BACKEND_STATE_MAP[WAYLAND-1]}" == "$original_legacy" ]] ||
  fail 'persisted wallpaper state changed'

: > "$tmp/applied"
XDG_CURRENT_DESKTOP=Hyprland
result="$(restore_apply_saved_map 2>&1)" ||
  fail 'non-Umbriel restore failed'
[[ "$(wc -l < "$tmp/applied")" -eq 3 ]] ||
  fail 'non-Umbriel restore behavior was changed'
if grep -Fq 'ignored' <<<"$result"; then
  fail 'non-Umbriel restore unexpectedly filtered saved outputs'
fi

: > "$tmp/applied"
XDG_CURRENT_DESKTOP=umbriel
MOCK_OUTPUTS='{"error":"IPC unavailable"}'
if result="$(restore_apply_saved_map 2>&1)"; then
  fail 'invalid Umbriel inventory was accepted'
fi
[[ ! -s "$tmp/applied" ]] ||
  fail 'restore applied an output without verified Umbriel inventory'

bash -n "$APP"
printf 'PASS: Umbriel restore filters inactive outputs without rewriting state\n'

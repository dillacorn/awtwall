#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/awtwall"
fail() { printf 'FAIL: %s\n' "$*" >&2; return 1; }
command -v jq >/dev/null 2>&1 || fail 'jq required for Umbriel output tests'

extract_function() {
  awk -v fn="$1" '
    $0 == fn "() {" { inside=1 }
    inside { print; if ($0 == "}") { done=1; break } }
    END { if (!done) { print "Missing function " fn > "/dev/stderr"; exit 1 } }
  ' "$APP"
}
for fn in awtwall_is_umbriel_session display_choice_add \
          discover_umbriel_displays refresh_display_choices \
          focused_output_name resolve_target_outputs \
          restore_apply_saved_map apply_still_image; do
  definition="$(extract_function "$fn")" || fail "Cannot extract $fn"
  eval "$definition"
done

have() {
  case "$1" in umbriel|jq) return 0 ;; *) return 1 ;; esac
}
umbriel() {
  [[ "${1:-}" == "outputs" && "${2:-}" == "--json" ]] || return 1
  [[ "${MOCK_FAIL:-0}" != 1 ]] || return 1
  printf '%s\n' "$MOCK_OUTPUTS"
}
discover_hyprland_displays() { fail 'Hyprland discovery called inside Umbriel'; }
discover_sway_displays() { fail 'Sway discovery called inside Umbriel'; }
discover_niri_displays() { fail 'Niri discovery called inside Umbriel'; }
discover_backend_displays() { return 1; }

declare -a DISPLAY_CHOICES=() DISPLAY_LABELS=() DISPLAY_GEOMETRIES=() TARGET_OUTPUTS=()
DISPLAY_SELECTOR_ENABLED=1
DISPLAY_TARGET="All displays"
DISPLAY_FOCUSED=""
DISPLAY_SOURCE=""
DISPLAY_LAYOUT_AVAILABLE=0
XDG_CURRENT_DESKTOP="Umbriel"
UMBRIEL_SOCKET=""
MOCK_OUTPUTS='[
  {"name":"DP-1","enabled":true,"focused":true,"position":[0,0],
   "logical_size":[1920,1080],"modes":[
     {"width":1920,"height":1080,"refresh_mhz":144000,"current":true}]},
  {"name":"HDMI-A-1","enabled":true,"focused":false,
   "position":{"x":1920,"y":0},"logical_size":{"width":1280,"height":720},
   "modes":[{"width":1600,"height":900,"refresh_mhz":60000,"current":true}]},
  {"name":"DP-2","enabled":false,"focused":false,"position":[3200,0],
   "logical_size":[1280,720],"modes":[]}
]'

refresh_display_choices
[[ "$DISPLAY_SOURCE" == "Umbriel" ]] || fail "Umbriel discovery did not run"
[[ "${#DISPLAY_CHOICES[@]}" == 3 ]] || fail "Expected All displays plus two enabled outputs"
[[ "${DISPLAY_CHOICES[0]}" == "All displays" ]] || fail "All displays choice missing"
[[ "${DISPLAY_CHOICES[1]}" == "DP-1" ]] || fail "DP-1 output missing"
[[ "${DISPLAY_CHOICES[2]}" == "HDMI-A-1" ]] || fail "HDMI-A-1 output missing"
[[ "${DISPLAY_GEOMETRIES[1]}" == "0:0:1920:1080" ]] || fail "DP-1 geometry wrong"
[[ "${DISPLAY_GEOMETRIES[2]}" == "1920:0:1280:720" ]] || fail "HDMI-A-1 logical geometry wrong"
[[ "${DISPLAY_LABELS[1]}" == *"1920x1080@144Hz"* ]] || fail "DP-1 mode missing"
[[ "${DISPLAY_LABELS[2]}" == *"1600x900@60Hz"* ]] || fail "HDMI-A-1 mode missing"
[[ "$DISPLAY_FOCUSED" == "DP-1" ]] || fail "DP-1 focus missing"

DISPLAY_TARGET="HDMI-A-1"
refresh_display_choices
resolve_target_outputs
[[ "${#TARGET_OUTPUTS[@]}" == 1 && "${TARGET_OUTPUTS[0]}" == "HDMI-A-1" ]] \
  || fail "Per-output targeting changed"

# Focus must be queried live rather than relying on a stale picker snapshot.
MOCK_OUTPUTS="$(jq -c 'map(if .name == "DP-1" then .focused = false
  elif .name == "HDMI-A-1" then .focused = true else . end)' <<<"$MOCK_OUTPUTS")"
[[ "$(focused_output_name)" == "HDMI-A-1" ]] || fail "Live focus was not updated"

# Read-only IPC failure must not fall through to a different compositor.
MOCK_FAIL=1
if focused_output_name >/dev/null; then fail "Stale focus accepted after IPC failure"; fi
refresh_display_choices
[[ "${#DISPLAY_CHOICES[@]}" == 1 && "$DISPLAY_SOURCE" == "" ]] \
  || fail "Wrong compositor used when Umbriel IPC fails"
MOCK_FAIL=0

# Wrapped JSON responses remain compatible.
MOCK_OUTPUTS="$(jq -cn --argjson items "$MOCK_OUTPUTS" '{ok:$items}')"
refresh_display_choices
[[ "${#DISPLAY_CHOICES[@]}" == 3 ]] || fail "Wrapped reply not recognized"

XDG_CURRENT_DESKTOP="Hyprland"
UMBRIEL_SOCKET=""
if awtwall_is_umbriel_session; then fail "Hyprland misidentified as Umbriel"; fi
UMBRIEL_SOCKET="/tmp/mock-umbriel-socket"
awtwall_is_umbriel_session || fail "Umbriel socket hint not detected"
UMBRIEL_SOCKET=""
unset XDG_CURRENT_DESKTOP
if awtwall_is_umbriel_session; then fail "Unset desktop misidentified as Umbriel"; fi
# Restoring a Hyprland hyprpaper entry under Umbriel must use awww/swww
# without rewriting the persisted choice or touching Hyprland.
XDG_CURRENT_DESKTOP="Umbriel"
UMBRIEL_SOCKET=""
temp="$(mktemp -d)"
trap 'rm -rf -- "$temp"' EXIT
printf 'test image\n' >"$temp/wall.png"
declare -A BACKEND_STATE_MAP=(["DP-1"]="$temp/wall.png")
backend_state_read() { :; }
backend_state_output_backend_for() { printf 'hyprpaper'; }
backend_state_write() { fail 'restore rewrote the saved backend'; }
backend_is_available() { [[ "$1" == "swww" ]]; }
kill_hyprpaper_if_running() { :; }
ensure_swww_daemon() { :; }
kill_mpvpaper_for_target() { :; }
swww_apply_output() {
  [[ "$1" == "DP-1" && "$2" == "$temp/wall.png" ]] || return 1
  RESTORED_WITH="swww"
}
hyprpaper_apply_output() { RESTORED_WITH="hyprpaper"; return 1; }
mpvpaper_apply_output() { return 1; }
RESTORED_WITH=""
restore_apply_saved_map >/dev/null || fail 'Umbriel hyprpaper-state restore failed'
[[ "$RESTORED_WITH" == "swww" ]] || fail 'Umbriel tried an incompatible restore backend'

# Failed swww application must not attempt a Hyprland-only fallback.
BACKEND="swww"
STATUS_MSG=""
msg() { STATUS_MSG="$*"; }
apply_with_swww() { return 1; }
apply_with_hyprpaper() { RESTORED_WITH="hyprpaper"; return 1; }
RESTORED_WITH=""
if apply_still_image "$temp/wall.png"; then fail 'Failed swww apply succeeded'; fi
[[ "$RESTORED_WITH" != "hyprpaper" ]] || fail 'Umbriel attempted a Hyprland-only fallback'

printf 'PASS: Umbriel output discovery, focus, and targeting\n'

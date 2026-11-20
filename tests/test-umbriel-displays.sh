#!/usr/bin/env bash
set -euo pipefail

# Exercise just the real display functions; loading the full TUI would mutate
# user state and require a live compositor and terminal graphics support.
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/awtwall"
if ! command -v jq >/dev/null 2>&1; then
  printf 'SKIP: jq is required for Umbriel discovery tests\n'
  exit 0
fi

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

extract() {
  awk -v fn="$1" '
    $0 == fn "() {" { on = 1 }
    on { print }
    on && $0 == "}" { exit }
  ' "$APP"
}

for fn in display_choice_add discover_umbriel_displays refresh_display_choices \
          focused_output_name resolve_target_outputs; do
  body="$(extract "$fn")"
  [[ -n "$body" ]] || fail "missing $fn"
  eval "$body"
done

have() {
  case "$1" in umbriel|jq) return 0 ;; *) return 1 ;; esac
}
umbriel() {
  [[ "$#" -eq 2 && "$1" == outputs && "$2" == --json ]] || return 1
  printf '%s\n' "$MOCK_OUTPUTS"
}
discover_hyprland_displays() { return 1; }
discover_sway_displays() { return 1; }
discover_niri_displays() { return 1; }
discover_backend_displays() { return 1; }

MOCK_OUTPUTS='[
  {"name":"DP-1","enabled":true,"powered":true,"focused":true,
   "position":{"x":0,"y":0},"logical_size":{"width":1920,"height":1080},
   "scale":1.25,"modes":[{"width":2400,"height":1350,"refresh_mhz":144000,"current":true}]},
  {"name":"HDMI-A-1","enabled":true,"powered":false,"focused":false,
   "position":[1920,-200],"logical_size":[2560,1440],
   "scale":1,"modes":[{"width":2560,"height":1440,"refresh_mhz":60000,"current":true}]},
  {"name":"DP-2","enabled":false,"focused":false,"position":[0,0],
   "logical_size":[1920,1080],"modes":[]}
]'
export XDG_CURRENT_DESKTOP=umbriel
DISPLAY_SELECTOR_ENABLED=1
DISPLAY_TARGET="All displays"
DISPLAY_CHOICES=()
DISPLAY_LABELS=()
DISPLAY_GEOMETRIES=()
DISPLAY_SOURCE=""
DISPLAY_FOCUSED=""
DISPLAY_LAYOUT_AVAILABLE=0
TARGET_OUTPUTS=()

refresh_display_choices
[[ "$DISPLAY_SOURCE" == Umbriel ]] || fail "Umbriel not selected as source"
[[ "${#DISPLAY_CHOICES[@]}" -eq 3 ]] || fail "wrong number of enabled displays"
[[ "${DISPLAY_CHOICES[0]}" == "All displays" && "${DISPLAY_CHOICES[1]}" == DP-1 &&
   "${DISPLAY_CHOICES[2]}" == HDMI-A-1 ]] || fail "disabled output was not filtered"
[[ "${DISPLAY_LABELS[1]}" == *"2400x1350@144Hz"* &&
   "${DISPLAY_LABELS[2]}" == *"2560x1440@60Hz"* ]] || fail "current mode not reported"
[[ "${DISPLAY_GEOMETRIES[1]}" == '0:0:1920:1080' &&
   "${DISPLAY_GEOMETRIES[2]}" == '1920:-200:2560:1440' ]] || fail "logical geometry mismatch"
[[ "$DISPLAY_LAYOUT_AVAILABLE" == 1 && "$DISPLAY_FOCUSED" == DP-1 ]] ||
  fail "display layout or focus missing"
[[ "$(focused_output_name)" == DP-1 ]] || fail "focused output query failed"

DISPLAY_TARGET=HDMI-A-1
refresh_display_choices
[[ "$DISPLAY_TARGET" == HDMI-A-1 ]] || fail "selected output was lost on refresh"
resolve_target_outputs
[[ "${#TARGET_OUTPUTS[@]}" -eq 1 && "${TARGET_OUTPUTS[0]}" == HDMI-A-1 ]] ||
  fail "explicit output target wrong"

DISPLAY_TARGET="All displays"
resolve_target_outputs
[[ "${#TARGET_OUTPUTS[@]}" -eq 2 && "${TARGET_OUTPUTS[0]}" == DP-1 &&
   "${TARGET_OUTPUTS[1]}" == HDMI-A-1 ]] || fail "multi-output targets wrong"

DISPLAY_FOCUSED=""
[[ "$(focused_output_name)" == DP-1 ]] || fail "uncached focused output failed"

XDG_CURRENT_DESKTOP=Hyprland
if discover_umbriel_displays; then
  fail "Umbriel intercepted a non-Umbriel session"
fi

XDG_CURRENT_DESKTOP=umbriel
MOCK_OUTPUTS='[]'
if discover_umbriel_displays; then
  fail "empty Umbriel inventory reported success"
fi

bash -n "$APP"
printf 'PASS: Umbriel monitor discovery and target selection\n'

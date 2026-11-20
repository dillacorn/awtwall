#!/usr/bin/env bash
# Non-destructive test of native Umbriel output discovery and backend gating.
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
app="$root/awtwall"
command -v jq >/dev/null 2>&1 || { printf 'ERROR: jq required\n' >&2; false; }
bash -n "$app"

function_body() {
    local function_name="$1"
    awk -v name="$function_name" '
        $0 == name "() {" { printing=1 }
        printing { print }
        printing && $0 == "}" { found=1; stop=1; exit }
        END { if (!found) { print "Missing function " name > "/dev/stderr"; exit 1 } }
    ' "$app"
}
for function_name in is_umbriel_session is_hyprland_session backend_is_available \
    display_choice_add discover_umbriel_displays focused_output_name \
    refresh_display_choices; do
    eval "$(function_body "$function_name")"
done

fixture='[
  {"name":"DP-1","enabled":true,"focused":true,
   "position":{"x":0,"y":0},"logical_size":{"width":1920,"height":1080},
   "modes":[{"width":1920,"height":1080,"refresh_mhz":400000,"current":true}]},
  {"name":"DP-3","enabled":true,"focused":false,
   "position":{"x":1920,"y":0},"logical_size":{"width":2560,"height":1440},
   "modes":[{"width":2560,"height":1440,"refresh_mhz":240000,"current":true}]},
  {"name":"DP-9","enabled":false,"focused":false,
   "position":{"x":0,"y":0},"logical_size":{"width":0,"height":0},
   "modes":[]}
]'
umbriel() {
    [[ "${1:-}" == outputs && "${2:-}" == --json ]] || return 2
    printf '%s\n' "$fixture"
}
have() { command -v "$1" >/dev/null 2>&1; }
have_swww_backend() { return 0; }
discover_hyprland_displays() { printf 'Unexpected Hyprland query\n' >&2; return 2; }
discover_sway_displays() { printf 'Unexpected Sway query\n' >&2; return 2; }
discover_niri_displays() { printf 'Unexpected niri query\n' >&2; return 2; }
discover_backend_displays() { printf 'Unexpected daemon fallback\n' >&2; return 2; }
DISPLAY_SELECTOR_ENABLED=1
DISPLAY_TARGET="All displays"
DISPLAY_CHOICES=()
DISPLAY_LABELS=()
DISPLAY_GEOMETRIES=()
DISPLAY_FOCUSED=""
DISPLAY_SOURCE=""
DISPLAY_LAYOUT_AVAILABLE=0

XDG_CURRENT_DESKTOP=Umbriel
HYPRLAND_INSTANCE_SIGNATURE=""
refresh_display_choices
[[ "$DISPLAY_SOURCE" == Umbriel ]] || { printf 'Incorrect display source\n' >&2; false; }
[[ "${#DISPLAY_CHOICES[@]}" == 3 ]] || { printf 'Expected two enabled outputs\n' >&2; false; }
[[ "${DISPLAY_CHOICES[1]}" == DP-1 && "${DISPLAY_CHOICES[2]}" == DP-3 ]] || false
[[ "${DISPLAY_GEOMETRIES[1]}" == "0:0:1920:1080" ]] || false
[[ "${DISPLAY_GEOMETRIES[2]}" == "1920:0:2560:1440" ]] || false
[[ "$DISPLAY_FOCUSED" == DP-1 ]] || false
[[ "$(focused_output_name)" == DP-1 ]] || false
[[ "$DISPLAY_LAYOUT_AVAILABLE" == 1 ]] || false

# The installed Hyprland utilities do not make hyprpaper eligible in Umbriel.
hyprpaper() { :; }
hyprctl() { :; }
if backend_is_available hyprpaper; then
    printf 'hyprpaper incorrectly enabled under Umbriel\n' >&2
    false
fi
XDG_CURRENT_DESKTOP=Hyprland
is_hyprland_session
backend_is_available hyprpaper
if is_umbriel_session; then
    printf 'Hyprland incorrectly classified as Umbriel\n' >&2
    false
fi

printf 'PASS: native Umbriel geometry, focus, and Hyprland-only backend gating\n'

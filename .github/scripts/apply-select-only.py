#!/usr/bin/env python3
from pathlib import Path

path = Path("awtwall")
text = path.read_text()


def replace_once(old: str, new: str, label: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected 1 match, found {count}")
    text = text.replace(old, new, 1)


replace_once(
    'FILTER_KIND_WAS_SET_BY_ARG=0  # 1 when --type was explicitly passed on the CLI\nDISPLAY_SOURCE=""',
    'FILTER_KIND_WAS_SET_BY_ARG=0  # 1 when --type was explicitly passed on the CLI\n'
    'SELECT_ONLY=0                 # 1=return a selected path without applying wallpaper\n'
    'SELECT_ONLY_RESULT_FILE=""    # optional file used by detached external consumers\n'
    'DISPLAY_SELECTOR_ENABLED=1    # disabled in selection-only mode\n'
    'POST_EXEC_ALLOWED=1           # disabled in selection-only mode\n'
    'DISPLAY_SOURCE=""',
    "selection-only runtime state",
)

replace_once(
    'save_state() {\n  mkdir -p -- "$CONFIG_DIR"',
    'save_state() {\n  if (( SELECT_ONLY == 1 )); then\n    return 0\n  fi\n  mkdir -p -- "$CONFIG_DIR"',
    "selection-only persistence isolation",
)

replace_once(
    '  if normalized_backend="$(normalize_backend_name "${BACKEND:-}" 2>/dev/null)"; then\n'
    '    BACKEND="$normalized_backend"\n'
    '  else\n'
    '    BACKEND="$(default_still_backend)"\n'
    '  fi',
    '  if (( SELECT_ONLY == 1 )); then\n'
    '    BACKEND="${BACKEND:-swww}"\n'
    '  elif normalized_backend="$(normalize_backend_name "${BACKEND:-}" 2>/dev/null)"; then\n'
    '    BACKEND="$normalized_backend"\n'
    '  else\n'
    '    BACKEND="$(default_still_backend)"\n'
    '  fi',
    "selection-only load-state backend isolation",
)

replace_once(
    '  DISPLAY_SOURCE=""\n  DISPLAY_FOCUSED=""\n  DISPLAY_LAYOUT_AVAILABLE=0',
    '  DISPLAY_SOURCE=""\n  DISPLAY_FOCUSED=""\n  DISPLAY_LAYOUT_AVAILABLE=0\n'
    '  if (( DISPLAY_SELECTOR_ENABLED == 0 )); then\n'
    '    DISPLAY_TARGET="All displays"\n'
    '    return 0\n'
    '  fi',
    "selection-only display discovery isolation",
)

text = text.replace(
    '  if ! ensure_backend_available; then',
    '  if (( SELECT_ONLY == 0 )) && ! ensure_backend_available; then',
)

replace_once(
    '  --no-post-exec          Disable the saved post-exec hook\n',
    '  --no-post-exec          Disable the saved post-exec hook\n'
    '  --select-only           Select a file and exit without applying wallpaper\n'
    '  --select-result PATH    Write the selected absolute path to PATH\n',
    "selection-only help",
)

replace_once(
    '      --no-post-exec)\n'
    '        POST_EXEC_CMD=""\n'
    '        POST_EXEC_ENABLED=0\n'
    '        shift\n'
    '        ;;\n'
    '      --resume)',
    '      --no-post-exec)\n'
    '        POST_EXEC_CMD=""\n'
    '        POST_EXEC_ENABLED=0\n'
    '        shift\n'
    '        ;;\n'
    '      --select-only)\n'
    '        SELECT_ONLY=1\n'
    '        DISPLAY_SELECTOR_ENABLED=0\n'
    '        POST_EXEC_ALLOWED=0\n'
    '        shift\n'
    '        ;;\n'
    '      --select-result)\n'
    '        [[ $# -ge 2 ]] || die "Missing value for $1"\n'
    '        SELECT_ONLY_RESULT_FILE="$2"\n'
    '        shift 2\n'
    '        ;;\n'
    '      --resume)',
    "selection-only parser",
)

replace_once(
    'apply_selected() {\n'
    '  local img\n'
    '  if (( ${#FILES[@]} == 0 )); then msg "No wallpapers to apply"; return 1; fi\n'
    '  img="${FILES[$SEL]}"\n'
    '  apply_path "$img"\n'
    '}',
    'select_only_accept() {\n'
    '  local img="$1" result_dir\n'
    '  [[ -n "$img" && "$img" == /* && -f "$img" ]] || {\n'
    '    msg "Selected file is not a readable local wallpaper"\n'
    '    return 1\n'
    '  }\n'
    '  if [[ -n "$SELECT_ONLY_RESULT_FILE" ]]; then\n'
    '    result_dir="$(dirname -- "$SELECT_ONLY_RESULT_FILE")"\n'
    '    mkdir -p -- "$result_dir" || return 1\n'
    '    ( umask 077; printf \'%s\\n\' "$img" >"$SELECT_ONLY_RESULT_FILE" ) || return 1\n'
    '  else\n'
    '    printf \'%s\\n\' "$img"\n'
    '  fi\n'
    '  RUNNING=0\n'
    '  return 0\n'
    '}\n\n'
    'apply_selected() {\n'
    '  local img\n'
    '  if (( ${#FILES[@]} == 0 )); then\n'
    '    if (( SELECT_ONLY == 1 )); then msg "No wallpapers to select"; else msg "No wallpapers to apply"; fi\n'
    '    return 1\n'
    '  fi\n'
    '  img="${FILES[$SEL]}"\n'
    '  if (( SELECT_ONLY == 1 )); then\n'
    '    select_only_accept "$img"\n'
    '    return $?\n'
    '  fi\n'
    '  apply_path "$img"\n'
    '}',
    "selection-only accept path",
)

replace_once(
    '  backend_name="$(backend_label)"\n'
    '  swww_name="$(swww_family_label)"\n\n'
    '  ui_goto 1 1; ui_clear_line; ui_bold\n'
    '  printf \'%-*.*s\' "$cols" "$cols"     " ${APP_NAME} backend=${backend_name} display=${DISPLAY_TARGET} encoder=${SIXEL_ENCODER_LABEL} "\n'
    '  ui_color_reset\n\n'
    '  ui_goto 2 1; ui_clear_line\n'
    '  printf \'%-*.*s\' "$cols" "$cols"     " dir=$(short_path "$WALL_DIR" 60) recursive=${RECURSIVE} type=${FILTER_KIND} find=\'$(sanitize_text "$FILTER_QUERY")\' "\n\n'
    '  ui_goto 3 1; ui_clear_line; ui_dim\n'
    '  printf \'%-*.*s\' "$cols" "$cols"     " ${swww_name}: resize=${SWWW_RESIZE} trans=${SWWW_TRANSITION_TYPE} dur=${SWWW_TRANSITION_DURATION}s fps=${SWWW_TRANSITION_FPS} interp=${SWWW_FILTER} | hyprpaper: ${HYPERPAPER_MODE} | mpvpaper: mp4 | post-exec: $(post_exec_label) "\n'
    '  ui_color_reset',
    '  if (( SELECT_ONLY == 1 )); then\n'
    '    backend_name="selection-only"\n'
    '    swww_name=""\n'
    '  else\n'
    '    backend_name="$(backend_label)"\n'
    '    swww_name="$(swww_family_label)"\n'
    '  fi\n\n'
    '  ui_goto 1 1; ui_clear_line; ui_bold\n'
    '  if (( SELECT_ONLY == 1 )); then\n'
    '    printf \'%-*.*s\' "$cols" "$cols" " ${APP_NAME} selection-only encoder=${SIXEL_ENCODER_LABEL} "\n'
    '  else\n'
    '    printf \'%-*.*s\' "$cols" "$cols" " ${APP_NAME} backend=${backend_name} display=${DISPLAY_TARGET} encoder=${SIXEL_ENCODER_LABEL} "\n'
    '  fi\n'
    '  ui_color_reset\n\n'
    '  ui_goto 2 1; ui_clear_line\n'
    '  printf \'%-*.*s\' "$cols" "$cols"     " dir=$(short_path "$WALL_DIR" 60) recursive=${RECURSIVE} type=${FILTER_KIND} find=\'$(sanitize_text "$FILTER_QUERY")\' "\n\n'
    '  ui_goto 3 1; ui_clear_line; ui_dim\n'
    '  if (( SELECT_ONLY == 1 )); then\n'
    '    printf \'%-*.*s\' "$cols" "$cols" " Choose an image with click, Space, or Enter. Escape/q cancels. "\n'
    '  else\n'
    '    printf \'%-*.*s\' "$cols" "$cols" " ${swww_name}: resize=${SWWW_RESIZE} trans=${SWWW_TRANSITION_TYPE} dur=${SWWW_TRANSITION_DURATION}s fps=${SWWW_TRANSITION_FPS} interp=${SWWW_FILTER} | hyprpaper: ${HYPERPAPER_MODE} | mpvpaper: mp4 | post-exec: $(post_exec_label) "\n'
    '  fi\n'
    '  ui_color_reset',
    "selection-only status UI",
)

replace_once(
    'choose_backend() {\n  local backend',
    'choose_backend() {\n  (( SELECT_ONLY == 0 )) || return 0\n  local backend',
    "selection-only backend menu guard",
)

replace_once(
    'choose_display() {\n  refresh_display_choices',
    'choose_display() {\n  (( DISPLAY_SELECTOR_ENABLED == 1 )) || return 0\n  refresh_display_choices',
    "selection-only display menu guard",
)

replace_once(
    'do_post_exec_prompt() {\n  local v current',
    'do_post_exec_prompt() {\n  (( POST_EXEC_ALLOWED == 1 )) || return 0\n  local v current',
    "selection-only post-exec guard",
)

replace_once(
    '  : > "$DEBUG_LOG"\n  load_state\n  parse_args "$@"',
    '  : > "$DEBUG_LOG"\n'
    '  local arg\n'
    '  for arg in "$@"; do\n'
    '    if [[ "$arg" == "--select-only" ]]; then\n'
    '      SELECT_ONLY=1\n'
    '      DISPLAY_SELECTOR_ENABLED=0\n'
    '      POST_EXEC_ALLOWED=0\n'
    '      break\n'
    '    fi\n'
    '  done\n'
    '  load_state\n'
    '  parse_args "$@"',
    "selection-only pre-load argument scan",
)

replace_once(
    '      b)\n'
    '        choose_backend\n'
    '        ;;\n'
    '      m|M)\n'
    '        choose_display\n'
    '        ;;\n'
    '      E)\n'
    '        do_post_exec_prompt\n'
    '        ;;',
    '      b)\n'
    '        (( SELECT_ONLY == 0 )) && choose_backend\n'
    '        ;;\n'
    '      m|M)\n'
    '        (( DISPLAY_SELECTOR_ENABLED == 1 )) && choose_display\n'
    '        ;;\n'
    '      E)\n'
    '        (( POST_EXEC_ALLOWED == 1 )) && do_post_exec_prompt\n'
    '        ;;',
    "selection-only key guards",
)

# Exit the current input iteration immediately after a selection so the TUI
# does not redraw before cleanup closes the terminal process.
text = text.replace(
    '        apply_selected || true\n        drain_pending_keys\n        draw_status_bars',
    '        apply_selected || true\n        (( RUNNING == 0 )) && continue\n        drain_pending_keys\n        draw_status_bars',
)
text = text.replace(
    '  apply_selected || true\n  drain_pending_keys 256 || true\n  draw_status_bars',
    '  apply_selected || true\n  (( RUNNING == 0 )) && return 0\n  drain_pending_keys 256 || true\n  draw_status_bars',
    1,
)

path.write_text(text)

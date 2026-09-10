#!/usr/bin/env python3
from pathlib import Path

path = Path("awtwall")
text = path.read_text()


def replace_once(old: str, new: str, label: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}: expected exactly one match, found {count}")
    text = text.replace(old, new, 1)


replace_once(
    'DISPLAY_LAYOUT_AVAILABLE=0\n\nOPTION_MENU_VALUE=""',
    'DISPLAY_LAYOUT_AVAILABLE=0\n\nSELECTION_ONLY=0\nSELECT_RESULT_FILE=""\n\nOPTION_MENU_VALUE=""',
    "selection globals",
)

replace_once(
    'save_state() {\n  mkdir -p -- "$CONFIG_DIR"',
    'save_state() {\n  if (( SELECTION_ONLY == 1 )); then\n    return 0\n  fi\n  mkdir -p -- "$CONFIG_DIR"',
    "selection state persistence guard",
)

replace_once(
    '  refresh_display_choices\n  build_filtered\n',
    '  if (( SELECTION_ONLY == 0 )); then\n    refresh_display_choices\n  fi\n  build_filtered\n',
    "selection display scan guard",
)

check_start = text.index('check_runtime_requirements() {')
backend_start = text.index('  if ! ensure_backend_available; then', check_start)
backend_end = text.index('\n  if ! have magick; then', backend_start)
backend_block = text[backend_start:backend_end]
backend_block = '\n'.join(('  ' + line) if line else line for line in backend_block.splitlines())
text = (
    text[:backend_start]
    + '  if (( SELECTION_ONLY == 0 )); then\n'
    + backend_block
    + '\n  fi'
    + text[backend_end:]
)

selection_functions = r'''selection_accept_path() {
  local img="$1" p found=0 result_dir tmp=""

  [[ -n "$img" && "$img" == /* && -f "$img" && -r "$img" ]] || {
    msg "Invalid selection"
    return 1
  }
  [[ "$img" != *$'\n'* && "$img" != *$'\r'* ]] || {
    msg "Invalid selection path"
    return 1
  }

  for p in "${FILES[@]}"; do
    if [[ "$p" == "$img" ]]; then
      found=1
      break
    fi
  done
  (( found == 1 )) || {
    msg "Selection is not in the scanned wallpaper library"
    return 1
  }

  if [[ -n "$SELECT_RESULT_FILE" ]]; then
    result_dir="$(dirname -- "$SELECT_RESULT_FILE")"
    [[ -d "$result_dir" && -w "$result_dir" ]] || {
      msg "Selection result directory is not writable"
      return 1
    }
    tmp="$(mktemp "${result_dir}/.awtwall-select.XXXXXX")" || {
      msg "Could not create selection result"
      return 1
    }
    if ! printf '%s\n' "$img" >"$tmp"; then
      rm -f -- "$tmp"
      msg "Could not write selection result"
      return 1
    fi
    if ! mv -f -- "$tmp" "$SELECT_RESULT_FILE"; then
      rm -f -- "$tmp"
      msg "Could not finalize selection result"
      return 1
    fi
  fi

  printf '%s\n' "$img"
  CLEAR_ON_EXIT=1
  RUNNING=0
  return 0
}

selection_cancel() {
  CLEAR_ON_EXIT=1
  RUNNING=0
  return 0
}

selection_only_block_action() {
  if (( SELECTION_ONLY == 1 )); then
    msg "Unavailable in selection-only mode"
    draw_status_bars
    return 0
  fi
  return 1
}

'''
marker = 'apply_selected() {\n'
idx = text.index(marker)
text = text[:idx] + selection_functions + text[idx:]

replace_once(
    '''apply_selected() {
  local img
  if (( ${#FILES[@]} == 0 )); then msg "No wallpapers to apply"; return 1; fi
  img="${FILES[$SEL]}"
  apply_path "$img"
}''',
    '''apply_selected() {
  local img
  if (( ${#FILES[@]} == 0 )); then
    if (( SELECTION_ONLY == 1 )); then msg "No images to select"; else msg "No wallpapers to apply"; fi
    return 1
  fi
  img="${FILES[$SEL]}"
  if (( SELECTION_ONLY == 1 )); then
    selection_accept_path "$img"
  else
    apply_path "$img"
  fi
}''',
    "selection activation routing",
)

mouse_old = '''  else
    msg "Applying selected wallpaper..."
    draw_status_bars
  fi

  apply_selected || true'''
mouse_new = '''  else
    if (( SELECTION_ONLY == 1 )); then
      msg "Selecting image..."
    else
      msg "Applying selected wallpaper..."
    fi
    draw_status_bars
  fi

  apply_selected || true'''
replace_once(mouse_old, mouse_new, "mouse selection status")

status_fn = text.index('draw_status_bars() {')
status_needle = '  cols="$(term_cols)"\n'
status_pos = text.index(status_needle, status_fn) + len(status_needle)
status_branch = r'''  if (( SELECTION_ONLY == 1 )); then
    if (( ${#FILES[@]} > 0 )); then selected_idx=$(( SEL + 1 )); else selected_idx=0; fi
    ui_goto 1 1; ui_clear_line; ui_bold
    printf '%-*.*s' "$cols" "$cols" " ${APP_NAME} Select image  encoder=${SIXEL_ENCODER_LABEL} "
    ui_color_reset

    ui_goto 2 1; ui_clear_line
    printf '%-*.*s' "$cols" "$cols" " dir=$(short_path "$WALL_DIR" 60) recursive=${RECURSIVE} type=${FILTER_KIND} find='$(sanitize_text "$FILTER_QUERY")' "

    ui_goto 3 1; ui_clear_line; ui_dim
    printf '%-*.*s' "$cols" "$cols" " Selection-only mode: choosing an image will not change the desktop wallpaper. "
    ui_color_reset

    status_tail="$(sanitize_text "$STATUS_MSG")"
    ui_goto 4 1; ui_clear_line; ui_dim
    printf '%-*.*s' "$cols" "$cols" " selected=${selected_idx} status=${status_tail} "
    ui_color_reset
    return 0
  fi
'''
text = text[:status_pos] + status_branch + text[status_pos:]

replace_once(
    '  printf \'%-*.*s\' "$cols" "$cols" "keys: q quit | R refresh | f find | e choose type | b choose backend | m/M choose display | o open dir"\n',
    '''  if (( SELECTION_ONLY == 1 )); then
    printf '%-*.*s' "$cols" "$cols" "keys: q/Esc cancel | R refresh | f find | e choose type | o open dir"
  else
    printf '%-*.*s' "$cols" "$cols" "keys: q quit | R refresh | f find | e choose type | b choose backend | m/M choose display | o open dir"
  fi
''',
    "empty-grid selection help",
)

draw_help_start = text.index('draw_help() {')
row_marker = '  row2=$(( lines - 1 ))\n\n'
row_pos = text.index(row_marker, draw_help_start) + len(row_marker)
selection_help = r'''  if (( SELECTION_ONLY == 1 )); then
    ui_goto "$row1" 1; ui_clear_line; ui_dim
    printf '%-*.*s' "$cols" "$cols" " arrows/hjkl move | wheel scroll | mouse click select | SPACE/Enter select | f find | c clear | R refresh "
    ui_color_reset

    ui_goto "$row2" 1; ui_clear_line; ui_dim
    printf '%-*.*s' "$cols" "$cols" " q/Esc cancel | v version | D dir | n recurse | e type menu | o open dir | x clear preview cache "
    ui_color_reset
    return 0
  fi

'''
text = text[:row_pos] + selection_help + text[row_pos:]

replace_once(
    '  --type NAME             all | images | gif | mp4\n',
    '  --type NAME             all | images | gif | mp4\n  --select-only           Browse and return a file without applying a wallpaper\n  --select-result FILE    Atomically write the selected absolute path to FILE\n',
    "selection help options",
)

replace_once(
    '''      --random|--random-current)
        RANDOM_ACTION="current"
        shift
        ;;''',
    '''      --select-only)
        SELECTION_ONLY=1
        shift
        ;;
      --select-result)
        [[ $# -ge 2 ]] || die "Missing value for $1"
        [[ -n "$2" ]] || die "--select-result requires a non-empty file path"
        SELECT_RESULT_FILE="$2"
        shift 2
        ;;
      --random|--random-current)
        RANDOM_ACTION="current"
        shift
        ;;''',
    "selection parser options",
)

replace_once(
    '''  done
}

# ---------- main ----------''',
    '''  done

  if [[ -n "$SELECT_RESULT_FILE" && "$SELECTION_ONLY" != "1" ]]; then
    die "--select-result requires --select-only"
  fi
  if [[ "$SELECT_RESULT_FILE" == *$'\n'* || "$SELECT_RESULT_FILE" == *$'\r'* ]]; then
    die "--select-result contains an invalid control character"
  fi
  if (( SELECTION_ONLY == 1 )) && { (( RESTORE_ONLY == 1 )) || [[ -n "$RANDOM_ACTION" ]]; }; then
    die "Selection-only mode cannot run wallpaper apply actions"
  fi
}

# ---------- main ----------''',
    "selection parser validation",
)

replace_once(
    '''      q|Q)
        CLEAR_ON_EXIT=1
        RUNNING=0
        ;;''',
    '''      q|Q)
        if (( SELECTION_ONLY == 1 )); then
          selection_cancel
        else
          CLEAR_ON_EXIT=1
          RUNNING=0
        fi
        ;;
      $'\e')
        if (( SELECTION_ONLY == 1 )); then
          selection_cancel
        else
          msg "Key: $(printf '%q' "$key")"
          draw_status_bars
        fi
        ;;''',
    "selection cancel keys",
)

replacements = {
    '''      r)
        random_apply
        NEED_FULL_REDRAW=1
        ;;''': '''      r)
        selection_only_block_action || {
          random_apply
          NEED_FULL_REDRAW=1
        }
        ;;''',
    '''      b)
        choose_backend
        ;;''': '''      b)
        selection_only_block_action || choose_backend
        ;;''',
    '''      m|M)
        choose_display
        ;;''': '''      m|M)
        selection_only_block_action || choose_display
        ;;''',
    '''      E)
        do_post_exec_prompt
        ;;''': '''      E)
        selection_only_block_action || do_post_exec_prompt
        ;;''',
    '''      z)
        choose_swww_resize
        ;;''': '''      z)
        selection_only_block_action || choose_swww_resize
        ;;''',
    '''      t)
        choose_swww_transition
        ;;''': '''      t)
        selection_only_block_action || choose_swww_transition
        ;;''',
    '''      d)
        choose_swww_duration
        ;;''': '''      d)
        selection_only_block_action || choose_swww_duration
        ;;''',
    '''      p)
        choose_swww_fps
        ;;''': '''      p)
        selection_only_block_action || choose_swww_fps
        ;;''',
    '''      i)
        choose_swww_interp
        ;;''': '''      i)
        selection_only_block_action || choose_swww_interp
        ;;''',
    '''      P)
        choose_hyprpaper_mode
        ;;''': '''      P)
        selection_only_block_action || choose_hyprpaper_mode
        ;;''',
}
for old, new in replacements.items():
    replace_once(old, new, f"selection hotkey guard {old.splitlines()[0].strip()}")

path.write_text(text)

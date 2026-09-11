# awtwall

awtwall is a fast TUI wallpaper picker for Wayland with image previews, saved settings, live monitor layouts, and keyboard-first controls.

It supports still images, GIFs, and MP4 wallpapers through `awww` / `swww`, `hyprpaper`, or `mpvpaper`.

<img src="./awtwall_preview.gif" alt="awtwall wallpaper picker preview" width="700">

## Features

- Fast terminal wallpaper browser
- Keyboard-first workflow with mouse support
- Numbered selection menus
- Live monitor-layout view with focused-display detection
- Hyprland, Sway, and niri display discovery
- Image previews with `kitty`, `img2sixel`, `chafa`, or ImageMagick with SIXEL support
- Still-image and GIF support through `awww` / `swww`
- Still-image support through `hyprpaper`
- MP4 wallpaper support through `mpvpaper`
- Per-output wallpaper state and restore support
- Recursive or non-recursive wallpaper scanning
- Media filtering for images, GIFs, and MP4s
- Random wallpaper actions for focused or multiple displays
- Optional post-apply command hook
- Selection-only picker mode for external consumers without changing the desktop wallpaper
- Built-in version check

## Install, update, and uninstall

See the canonical guides:

- [INSTALL.md](INSTALL.md) for AUR and manual installation
- [UPDATE.md](UPDATE.md) for AUR and manual updates
- [UNINSTALL.md](UNINSTALL.md) for AUR and manual removal

## Usage

```bash
awtwall [options]
```

Restore the last applied wallpaper state without opening the UI:

```bash
awtwall --restore
```

## Launch options

```text
-d, --dir PATH          Wallpaper directory (default: ~/Pictures/wallpapers)
-n, --non-recursive     Disable recursive scanning
-r, --recursive         Enable recursive scanning
-b, --backend NAME      swww | hyprpaper | mpvpaper
-o, --output NAME       Target display name or "All displays"
--type NAME             all | images | gif | mp4
--random                Randomize the focused display
--random-current        Randomize the focused display
--random-all            Apply one random wallpaper to all displays
--random-all-different  Apply different random wallpapers to all displays
--no-mpvpaper           Random CLI actions skip .mp4 files
--no-sixel              Disable image previews (UI only)
--alt-screen            Use alternate screen buffer
--force-encoder NAME    chafa | img2sixel | magick | kitty
--post-exec CMD         Run CMD after each successful wallpaper apply
--no-post-exec          Disable the saved post-exec hook
--select-only           Browse and select without applying wallpaper
--select-result PATH    Write the selected absolute path to PATH
-h, --help              Show help
-v, --version           Print version and check latest release
--resume                Start at last saved selection
--restore               Reapply saved wallpapers and exit
--start-at N            Start at selection index N (1-based)
```

## Examples

```bash
awtwall
awtwall --dir ~/Pictures/wallpapers
awtwall --backend hyprpaper
awtwall --backend mpvpaper --type mp4
awtwall --type images
awtwall --resume
awtwall --start-at 25
awtwall --force-encoder img2sixel
awtwall --no-sixel
awtwall --alt-screen
awtwall --restore
awtwall --random
awtwall --random-current
awtwall --random-all
awtwall --random-all-different
awtwall --random --no-mpvpaper
awtwall --post-exec 'notify-send "Wallpaper changed" "$AWTWALL_FILE"'
awtwall --select-only --type images
awtwall --select-only --type images --select-result /tmp/awtwall-selection
```

## Selection-only mode

`--select-only` turns awtwall into a pure picker for external consumers. Selecting an image returns the chosen local path without applying it as the desktop wallpaper or mutating normal wallpaper/backend state.

Use `--select-result PATH` when another application needs a machine-consumable result file.

Mouse click, `Space`, or `Enter` accepts the current item. `Escape`, `q`, or `Q` cancels without returning a selection.

## Preview backends

awtwall supports:

- `kitty`
- `img2sixel`
- `chafa`
- `magick` with SIXEL support
- Preview-disabled mode with `--no-sixel`

## Wallpaper backends

### `awww` / `swww`

Best for still-image and GIF wallpapers with transition support. awtwall prioritizes `awww` when both are available.

### `hyprpaper`

Still-image backend for Hyprland. If `awww` / `swww` is unavailable, awtwall can fall back to `hyprpaper` for still images.

### `mpvpaper`

Used for `.mp4` video wallpapers. If `mpvpaper` is selected for a still image, awtwall falls back to an available still-image backend.

## Controls

### Wallpaper browser

- Arrow keys or `h`, `j`, `k`, `l` to move
- Mouse wheel to scroll
- `Space` or `Enter` to apply the selected wallpaper
- Mouse click to select and apply a wallpaper
- `r` to apply a random wallpaper
- `f` to search
- `c` to clear the active search
- `R` to refresh and rescan wallpapers
- `D` to change the wallpaper directory
- `n` to toggle recursive scanning
- `o` to open the wallpaper directory
- `x` to clear the preview cache
- `E` to configure the post-apply command hook
- `v` or `V` to view version information
- `q` or `Q` to quit

In selection-only mode, `Space`, `Enter`, or mouse click accepts the current item instead of applying it.

### Setting menus

- `b` selects the wallpaper backend
- `e` selects the media filter
- `m` or `M` selects the display target and shows the live monitor layout
- `z` selects the `awww` / `swww` resize mode
- `t` selects the transition type
- `d` selects the transition duration
- `p` selects the transition FPS
- `i` selects the interpolation filter
- `P` selects the `hyprpaper` mode

Inside a setting menu:

- Arrow keys or `h`, `j`, `k`, `l` move the selection
- Number keys select a visible option directly
- `Enter`, `Space`, or mouse click confirms
- Pressing the same setting key again closes its menu
- `Escape`, `q`, or `Q` cancels and returns

Backend/display controls are intentionally unavailable in selection-only mode.

## Display selector

The display selector shows a scaled view of the compositor's live output layout and a numbered list containing each output's connector name, resolution, refresh rate, layout coordinates, and focused state.

awtwall reads live compositor state only. It does not modify compositor monitor configuration files.

## Defaults

- Wallpaper directory: `~/Pictures/wallpapers`
- Recursive scanning: enabled
- Default backend: `swww`
- Default display target: `All displays`

## State and cache

awtwall stores data in:

```text
~/.config/awtwall/
~/.cache/awtwall/
```

This includes saved UI state, per-output wallpaper/backend state, thumbnail and preview cache, and debug logs.

Selection-only mode does not persist normal wallpaper application state.

## Version

```bash
awtwall -v
awtwall --version
```

For upgrade instructions, see [UPDATE.md](UPDATE.md).

## License

This project is licensed under the [MIT License](LICENSE).

### Legal Notice

This project is a general-purpose open-source utility that runs locally. It does not provide a hosted service and does not collect user data. Users are responsible for complying with laws and regulations in their own jurisdiction when using this software.

## Donate

Built and maintained out of passion. Always FOSS. Donations appreciated.  
[Donate via PayPal](https://www.paypal.com/donate/?business=XSNV4QP8JFY9Y&no_recurring=0&item_name=Built+and+maintained+out+of+passion.+Always+FOSS.+Donations+appreciated.+%28smtty%2C+MicLockTray%2C+awtarchy%29&currency_code=USD)

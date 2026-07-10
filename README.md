# awtwall

awtwall is a fast TUI wallpaper picker for Wayland with image previews, saved settings, live monitor layouts, and keyboard-first controls.

It supports still images, GIFs, and MP4 wallpapers through `swww` / `awww`, `hyprpaper`, or `mpvpaper`.

<img src="./awtwall_preview.gif" alt="awtwall wallpaper picker preview" width="700">

## Features

- Fast terminal wallpaper browser
- Keyboard-first workflow with mouse support
- Numbered selection menus instead of blind option cycling
- Live monitor-layout view with focused-display detection
- Hyprland, Sway, and niri display discovery
- Image previews with `kitty`, `img2sixel`, `chafa`, or ImageMagick with SIXEL support
- Still-image and GIF support through `swww` / `awww`
- Still-image support through `hyprpaper`
- MP4 wallpaper support through `mpvpaper`
- Per-output wallpaper state and restore support
- Recursive or non-recursive wallpaper scanning
- Media filtering for images, GIFs, and MP4s
- Random wallpaper actions for focused or multiple displays
- Optional post-apply command hook
- Built-in version check

## Version 2.1.1

Version 2.1.1 includes the new interactive selection menus and fixes same-key menu toggling.

- Arrow-key, number-key, and mouse selection
- `Enter`, `Space`, or mouse click to confirm
- Press the same setting key again to close its menu
- `Escape`, `q`, or `Q` to cancel without changing the setting
- Live visual monitor layouts for Hyprland, Sway, and niri
- Output-name fallback through `awww` / `swww` when compositor geometry is unavailable
- More reliable Enter handling across terminal input modes

## Requirements

Required:

- `bash`
- `imagemagick`
- `ncurses`

Preview support requires at least one of:

- `chafa`
- `libsixel` for `img2sixel`
- ImageMagick built with SIXEL support
- `kitty` for kitty image previews

Preview rendering can be disabled with `--no-sixel`.

Install at least one wallpaper backend:

- `awww` or `swww`
- `hyprpaper` with Hyprland
- `mpvpaper`

Optional:

- `jq` for reliable monitor detection and live layout geometry
- `ffmpeg` for better MP4 thumbnail extraction
- `xdg-utils` to open the wallpaper directory from awtwall
- `kitty` for kitty image previews
- `curl` or `wget` for release-version checks

Live compositor discovery supports:

- Hyprland through `hyprctl`
- Sway through `swaymsg`
- niri through `niri msg`

If compositor geometry is unavailable, awtwall falls back to output names reported by `awww` / `swww`.

## Install

### Arch Linux / AUR

```bash
paru -S awtwall
# or
yay -S awtwall
```

### Manual

```bash
git clone https://github.com/dillacorn/awtwall
cd awtwall
chmod +x awtwall-installer
./awtwall-installer
```

The manual installer places awtwall in `~/.local/bin` by default and installs `awtwall-update` when it is available.

Run it with:

```bash
awtwall
```

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
awtwall --random-current --no-mpvpaper
awtwall --random-all --no-mpvpaper
awtwall --random-all-different --no-mpvpaper
awtwall --post-exec 'notify-send "Wallpaper changed" "$AWTWALL_FILE"'
```

## Preview backends

awtwall supports these preview methods:

- `kitty`
- `img2sixel`
- `chafa`
- `magick` with SIXEL support
- Preview-disabled mode with `--no-sixel`

## Wallpaper backends

### `swww` / `awww`

Best for still-image and GIF wallpapers with transition support.

awtwall prioritizes `awww` over `swww` when both are available.

If either `awww` or `swww` is available, awtwall prefers it over `hyprpaper` for still images.

### `hyprpaper`

Still-image backend for Hyprland.

If `awww` / `swww` is unavailable, awtwall can fall back to `hyprpaper` for still images.

### `mpvpaper`

Used for `.mp4` video wallpapers.

If `mpvpaper` is selected for a still image, awtwall falls back to an available still-image backend.

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

### Setting menus

- `b` selects the wallpaper backend
- `e` selects the media filter
- `m` or `M` selects the display target and shows the live monitor layout
- `z` selects the `swww` / `awww` resize mode
- `t` selects the transition type
- `d` selects the transition duration
- `p` selects the transition FPS
- `i` selects the interpolation filter
- `P` selects the `hyprpaper` mode

Inside a setting menu:

- Arrow keys or `h`, `j`, `k`, `l` move the selection
- Number keys select a visible option directly
- `Enter`, `Space`, or mouse click confirms
- Pressing the same setting key again closes the menu
- `Escape`, `q`, or `Q` cancels and returns

## Display selector

The display selector shows a scaled view of the compositor's live output layout and a numbered list containing each output's:

- Connector name
- Resolution and refresh rate
- Layout coordinates
- Focused state

The diagram is a compact topology view. The numbered list is the authoritative display information when complex layouts must be compressed to fit the terminal.

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

This includes:

- Saved UI state
- Per-output backend and wallpaper state
- Thumbnail and preview cache
- Debug logs

## Version and updates

```bash
awtwall -v
awtwall --version
```

AUR installations should be updated through the installed AUR helper.

Manual installations created with `awtwall-installer` can use:

```bash
awtwall-update
```

## License

This project is licensed under the [MIT License](https://github.com/dillacorn/awtwall/blob/main/LICENSE).

### Legal Notice

This project is a general-purpose open-source utility that runs locally on the user's system. It does not provide a hosted service and does not collect user data. Users are responsible for complying with laws and regulations in their own jurisdiction when using this software.

## Donate

Built and maintained out of passion. Always FOSS. Donations appreciated.  
[Donate via PayPal](https://www.paypal.com/donate/?business=XSNV4QP8JFY9Y&no_recurring=0&item_name=Built+and+maintained+out+of+passion.+Always+FOSS.+Donations+appreciated.+%28smtty%2C+MicLockTray%2C+awtarchy%29&currency_code=USD)

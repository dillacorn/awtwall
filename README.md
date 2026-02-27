# awtwall

awtwall is a fast TUI wallpaper picker for Wayland with image previews, saved settings, and a keyboard-first workflow.

It is built for Hyprland-style setups and applies wallpapers through `swww`, `hyprpaper`, or `mpvpaper`.

## Features

- Fast TUI wallpaper browser
- Keyboard-first workflow with mouse support
- Preview support with:
  - SIXEL via `img2sixel`
  - SIXEL via `chafa`
  - SIXEL via ImageMagick built with SIXEL support
  - kitty image previews in kitty terminals
- Wallpaper backends:
  - `swww` for still images
  - `hyprpaper` for still images
  - `mpvpaper` for `.mp4` video wallpapers
- Saved settings and last selection
- Recursive or non-recursive wallpaper scanning
- Media type filtering for images, GIFs, and MP4s
- Built-in version check

## Requirements

Required:

- `hyprland` for `hyprctl`
- `imagemagick` for `magick`
- `ncurses` for `tput`

Preview support requires one of the following unless previews are disabled:

- `chafa`
- `libsixel` for `img2sixel`
- ImageMagick built with SIXEL support
- `kitty` for kitty image previews when running inside kitty

Wallpaper backend:

- `swww`
- or `hyprpaper`
- or `mpvpaper` for `.mp4` wallpapers

Optional:

- `ffmpeg` for better `.mp4` thumbnail extraction
- `jq` for better monitor detection
- `xdg-utils` for opening the wallpaper directory
- `kitty` for kitty image previews

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
chmod +x awtwall
install -Dm755 awtwall ~/.local/bin/awtwall
```

Run it with:

```bash
awtwall
```

## Usage

```bash
awtwall [options]
```

## Launch options

```text
-d, --dir PATH          Wallpaper directory (default: ~/Pictures/wallpapers)
-n, --non-recursive     Disable recursive scanning
-r, --recursive         Enable recursive scanning
-b, --backend NAME      swww | hyprpaper | mpvpaper
-o, --output NAME       Target display name or "All displays"
--type NAME             all | images | gif | mp4
--no-sixel              Disable image previews (UI only)
--alt-screen            Use alternate screen buffer
--force-encoder NAME    chafa | img2sixel | magick | kitty
-h, --help              Show help
-v, --version           Print version and check latest release
--resume                Start at last saved selection
--start-at N            Start at selection index N (1-based)
```

## Examples

Use the default wallpaper directory:

```bash
awtwall
```

Open a different wallpaper directory:

```bash
awtwall --dir ~/Pictures/wallpapers
```

Use `hyprpaper` instead of `swww`:

```bash
awtwall --backend hyprpaper
```

Use `mpvpaper` for video wallpapers:

```bash
awtwall --backend mpvpaper --type mp4
```

Show only still images:

```bash
awtwall --type images
```

Start at the last saved selection:

```bash
awtwall --resume
```

Start at item 25:

```bash
awtwall --start-at 25
```

Force a specific preview encoder:

```bash
awtwall --force-encoder img2sixel
```

Disable previews:

```bash
awtwall --no-sixel
```

Use the alternate screen buffer:

```bash
awtwall --alt-screen
```

## Preview backends

awtwall supports multiple preview paths:

- `kitty` image previews in kitty terminals
- `img2sixel`
- `chafa`
- `magick` with SIXEL support
- preview-disabled mode with `--no-sixel`

## Backends

### `swww`

Best for still-image wallpapers with transition controls.

### `hyprpaper`

Best for still-image wallpapers when you prefer Hyprland's wallpaper daemon behavior.

### `mpvpaper`

Used for `.mp4` video wallpapers.

`mpvpaper` is only for `.mp4` files. If you select a still image while `mpvpaper` is set, awtwall falls back to `hyprpaper`.

## In-app controls

### Navigation

- `Arrow keys` move selection
- `h`, `j`, `k`, `l` move selection
- `PgUp` jumps up 6 items
- `PgDn` jumps down 6 items
- `Home` jumps to the first item
- `End` jumps to the last item
- `Mouse wheel` scrolls through wallpapers

### Actions

- `Mouse left click` applies the selected wallpaper
- `SPACE` applies the selected wallpaper
- `Enter` also applies on terminals that send it cleanly
- `r` applies a random wallpaper
- `f` opens find
- `c` clears find
- `R` refreshes the wallpaper list
- `D` changes wallpaper directory
- `o` opens the current wallpaper directory
- `x` clears the preview cache
- `q` quits

### Settings

- `n` toggles recursive scan
- `e` cycles media type filter
- `b` cycles backend
- `m` cycles display target
- `z` cycles `swww` resize mode
- `t` cycles `swww` transition type
- `d` cycles `swww` transition duration
- `p` cycles `swww` transition FPS
- `i` cycles `swww` interpolation filter
- `P` cycles `hyprpaper` mode

## Defaults

- Default wallpaper directory: `~/Pictures/wallpapers`
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

- saved UI state
- backend state
- thumbnail cache
- preview cache
- debug and preview error logs

## Version check

Show local version and check the latest release:

```bash
awtwall -v
# or
awtwall --version
```

## License

[MIT](https://github.com/dillacorn/awtwall/blob/main/LICENSE)

## ☕ Donate

Built and maintained out of passion. Always FOSS. Donations appreciated.  
[Donate via PayPal](https://www.paypal.com/donate/?business=XSNV4QP8JFY9Y&no_recurring=0&item_name=Built+and+maintained+out+of+passion.+Always+FOSS.+Donations+appreciated.+%28smtty%2C+MicLockTray%2C+awtarchy%29&currency_code=USD)
# awtwall

awtwall is a fast TUI wallpaper picker for Wayland with image previews, saved settings, and a keyboard-first workflow.

It is built for Hyprland-style setups and applies wallpapers through `swww` or `hyprpaper`.

## Features

- Fast TUI wallpaper browser
- Preview support with:
  - SIXEL via `img2sixel`
  - SIXEL via `chafa`
  - SIXEL via ImageMagick built with SIXEL support
  - kitty image previews in kitty terminals
- Applies wallpapers with `swww` or `hyprpaper`
- Saved settings and last selection
- Recursive or non-recursive wallpaper scanning
- Built-in version check

## Requirements

Required:

- `hyprland` for `hyprctl`
- `imagemagick` for `magick`
- `ncurses` for `tput`
- one preview encoder unless previews are disabled:
  - `chafa`
  - `libsixel` for `img2sixel`
  - or ImageMagick built with SIXEL support

Wallpaper backend:

- `swww`
- or `hyprpaper`

Optional:

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
-d, --dir PATH          Wallpaper directory
-n, --non-recursive     Disable recursive scanning
-r, --recursive         Enable recursive scanning
-b, --backend NAME      swww | hyprpaper
-o, --output NAME       Target display name or "All displays"
--no-sixel              Disable image previews
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

## In-app controls

### Navigation

- `Arrow keys` move selection
- `h`, `j`, `k`, `l` move selection
- `Mouse wheel` scrolls through wallpapers

### Actions

- `Mouse left click` applies the selected wallpaper
- `SPACE` applies the selected wallpaper
- `r` applies a random wallpaper
- `f` opens find
- `c` clears find
- `R` refreshes the wallpaper list
- `q` quits
- `D` changes wallpaper directory

### Settings

- `n` toggles recursive scan
- `b` cycles backend
- `m` cycles display target
- `z` cycles `swww` resize mode
- `t` cycles `swww` transition type
- `d` cycles `swww` transition duration
- `p` cycles `swww` transition FPS
- `i` cycles `swww` interpolation filter

## Defaults

- Default wallpaper directory: `~/Pictures/wallpapers`
- Recursive scanning: enabled
- Default backend: `swww`

## State and cache

awtwall stores data in:

```text
~/.config/awtwall/
~/.cache/awtwall/
```

This includes:

- saved state
- backend state
- cached preview assets

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
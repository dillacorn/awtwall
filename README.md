# awtwall

awtwall is a fast TUI wallpaper picker for Wayland with image previews, saved settings, and keyboard-first controls.

It supports still images, GIFs, and MP4 wallpapers through `swww` / `awww`, `hyprpaper`, or `mpvpaper`.

<a href="./awtwall_video.webm">
  <img src="./awtwall_preview.gif" alt="Watch awtwall demo" width="700">
</a>

## Features

- Fast terminal wallpaper browser
- Keyboard-first workflow with mouse support
- Image previews with `kitty`, `img2sixel`, `chafa`, or ImageMagick with SIXEL support
- Supports `swww` / `awww`, `hyprpaper`, and `mpvpaper`
- Saved settings, last selection, and restore support
- Recursive or non-recursive wallpaper scanning
- Media filtering for images, GIFs, and MP4s
- Built-in version check

## Requirements

Required:

- `imagemagick`
- `ncurses`

Preview support requires at least one of:

- `chafa`
- `libsixel` for `img2sixel`
- ImageMagick built with SIXEL support
- `kitty` for kitty image previews

Install at least one wallpaper backend:

- `swww` or `awww`
- `hyprpaper`
- `mpvpaper`

Optional:

- `hyprland`
- `ffmpeg`
- `jq`
- `xdg-utils`
- `kitty`

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
--no-sixel              Disable image previews
--alt-screen            Use alternate screen buffer
--force-encoder NAME    chafa | img2sixel | magick | kitty
--resume                Start at last saved selection
--start-at N            Start at selection index N (1-based)
--restore               Reapply the last saved wallpaper state and exit
-h, --help              Show help
-v, --version           Print version and check latest release
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
```

## Preview backends

awtwall supports these preview methods:

- `kitty`
- `img2sixel`
- `chafa`
- `magick` with SIXEL support
- preview-disabled mode with `--no-sixel`

## Wallpaper backends

### `swww` / `awww`

Best for still-image wallpapers with transition support.

awtwall prioritizes `awww` over `swww` when both are installed.

If either `awww` or `swww` is available, awtwall prefers them over `hyprpaper` for still images.

### `hyprpaper`

Still-image backend fallback when `awww` / `swww` is not being used.

### `mpvpaper`

Used for `.mp4` video wallpapers.

If `mpvpaper` is selected for a still image, awtwall falls back to a still-image backend.

## Controls

awtwall is built to be used directly from the keyboard, with mouse support included.

Main controls:

- Arrow keys or `h j k l` to move
- `Space` or `Enter` to apply
- `r` for random
- `f` to find
- `R` to refresh
- `b` to cycle backend
- `m` to cycle display target
- `q` to quit

Most other settings can be changed in-app and are visible in the interface.

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

- saved UI state
- saved backend state
- thumbnail cache
- preview cache
- debug logs

## Version

```bash
awtwall -v
awtwall --version
```

## License
This project is licensed under the [MIT License](https://github.com/dillacorn/awtwall/blob/main/LICENSE).

### Legal Notice
This project is a general-purpose open-source utility that runs locally on the
user’s system. It does not provide a hosted service and does not collect user
data. Users are responsible for complying with laws and regulations in their
own jurisdiction when using this software.

## Donate

Built and maintained out of passion. Always FOSS. Donations appreciated.  
[Donate via PayPal](https://www.paypal.com/donate/?business=XSNV4QP8JFY9Y&no_recurring=0&item_name=Built+and+maintained+out+of+passion.+Always+FOSS.+Donations+appreciated.+%28smtty%2C+MicLockTray%2C+awtarchy%29&currency_code=USD)
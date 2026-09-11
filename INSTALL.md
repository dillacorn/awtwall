# Installing awtwall

awtwall is a terminal wallpaper picker for Wayland. It supports still images, GIFs, and MP4 wallpapers through `awww` / `swww`, `hyprpaper`, or `mpvpaper`.

## Arch Linux / AUR

Install the stable AUR package with your preferred AUR helper:

```bash
yay -S awtwall
```

or:

```bash
paru -S awtwall
```

The AUR package installs awtwall system-wide as `/usr/bin/awtwall`.

## Manual installation

Install Git, clone the repository, and run the installer:

```bash
git clone https://github.com/dillacorn/awtwall
cd awtwall
chmod +x awtwall-installer
./awtwall-installer
```

The manual installer places awtwall in `~/.local/bin` by default and also installs `awtwall-update` when it is available.

To use another prefix:

```bash
PREFIX=/some/prefix ./awtwall-installer
```

This installs the executables under `$PREFIX/bin`.

## Requirements

Required:

- `bash`
- `imagemagick`

Preview support requires at least one of:

- `chafa`
- `libsixel` for `img2sixel`
- ImageMagick built with SIXEL support
- `kitty`

Preview rendering can be disabled with `--no-sixel`.

For normal wallpaper application, install at least one supported backend:

- `awww` or `swww`
- `hyprpaper` with Hyprland
- `mpvpaper`

Optional integrations include:

- `jq` for better monitor detection
- `ffmpeg` for better MP4 thumbnail extraction
- `xdg-utils` to open the wallpaper directory
- `curl` or `wget` for release/version checks

Selection-only mode does not require a wallpaper backend because it never applies the selected image.

## Run awtwall

```bash
awtwall
```

Check the installed version with:

```bash
awtwall --version
```

For normal upgrades, see [UPDATE.md](UPDATE.md).

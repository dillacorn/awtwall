# Uninstalling awtwall

Use the uninstall path that matches how awtwall was installed.

## Arch Linux / AUR

If awtwall was installed from the AUR, remove it through the package manager:

```bash
yay -Rns awtwall
```

or:

```bash
paru -Rns awtwall
```

You can also remove the installed package directly with pacman:

```bash
sudo pacman -Rns awtwall
```

Do not manually delete `/usr/bin/awtwall` for an AUR-managed installation. Let pacman remove the package so its package database stays correct.

## Manual installation

### Preferred method

If you still have the repository clone used for installation, run the installer again:

```bash
cd /path/to/awtwall
chmod +x awtwall-installer
./awtwall-installer
```

When prompted, choose:

```text
[2] Uninstall awtwall
```

For a custom manual prefix, use the same prefix that was used for installation:

```bash
PREFIX=/some/prefix ./awtwall-installer
```

For a system-wide manual installation under `/usr/local`:

```bash
sudo PREFIX=/usr/local ./awtwall-installer
```

The installer removes `awtwall` and `awtwall-update` from the selected `PREFIX/bin`. It also offers to remove `~/.config/awtwall`.

### Manual removal fallback

For the default user-local installation:

```bash
rm -f ~/.local/bin/awtwall ~/.local/bin/awtwall-update
```

For a system-wide manual installation under `/usr/local`:

```bash
sudo rm -f /usr/local/bin/awtwall /usr/local/bin/awtwall-update
```

If a different `PREFIX` was used, remove the two executables from that prefix's `bin` directory instead.

## Remove saved state and cache

The commands above remove the program but do not necessarily remove all per-user data.

awtwall stores persistent state in:

```text
~/.config/awtwall/
```

and disposable cache/debug data in:

```text
~/.cache/awtwall/
```

To remove both as well:

```bash
rm -rf ~/.config/awtwall ~/.cache/awtwall
```

This permanently removes saved settings, per-output wallpaper/backend state, restore state, preview/thumbnail cache, and debug data.

## Check for mixed installations

If awtwall still resolves after uninstalling one copy, check which executable remains:

```bash
command -v awtwall
```

AUR installs normally use:

```text
/usr/bin/awtwall
```

Default manual installs normally use:

```text
~/.local/bin/awtwall
```

A system-wide manual install commonly uses:

```text
/usr/local/bin/awtwall
```

If both an AUR and manual copy were installed, remove each with the matching method above.

For installation instructions, see [INSTALL.md](INSTALL.md). For upgrade instructions, see [UPDATE.md](UPDATE.md).

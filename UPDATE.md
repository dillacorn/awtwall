# Updating awtwall

Use the update path that matches how awtwall was installed.

## Arch Linux / AUR

If awtwall was installed from the AUR, update it through your AUR helper:

```bash
yay -Syu awtwall
```

or:

```bash
paru -Syu awtwall
```

AUR installations are managed by the package manager. Do not use the manual `awtwall-update` helper to replace `/usr/bin/awtwall`.

## Manual installation

Manual installs created with `awtwall-installer` can update with:

```bash
awtwall-update
```

The updater refreshes the repository cache from the current `main` branch, shows recent commits, asks for confirmation, backs up the currently installed user-local `awtwall`, and replaces both `awtwall` and `awtwall-update` under the selected prefix.

The default manual install location is:

```text
~/.local/bin/awtwall
~/.local/bin/awtwall-update
```

If the original installation used a custom `PREFIX`, use the same prefix when updating:

```bash
PREFIX=/some/prefix awtwall-update
```

## Check the installed version

```bash
awtwall --version
```

## Avoid mixed installations

A user-local manual install under `~/.local/bin` can take precedence over an AUR installation under `/usr/bin` depending on `PATH` order.

Check which executable is active with:

```bash
command -v awtwall
```

For an AUR-managed installation, the expected executable is normally:

```text
/usr/bin/awtwall
```

For a default manual installation, it is normally:

```text
~/.local/bin/awtwall
```

For fresh installation instructions, see [INSTALL.md](INSTALL.md).

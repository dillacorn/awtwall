# Repository instructions for awtwall

These instructions apply to the entire repository.

## Project shape

- `awtwall` is the main application. Keep it as a single Bash executable unless the maintainer explicitly asks to split it.
- `awtwall-installer` manages manual installation and manual uninstall behavior.
- `awtwall-update` updates manual installations from the repository.
- `README.md`, `INSTALL.md`, `UPDATE.md`, and `UNINSTALL.md` are the canonical user-facing documentation.
- `tests/` contains focused regression tests. Add or extend tests when behavior changes can be exercised non-interactively.

## Behavior to preserve

- Supported wallpaper backends are `awww` / `swww`, `hyprpaper`, and `mpvpaper`.
- Supported preview paths include `kitty`, `img2sixel`, `chafa`, ImageMagick with SIXEL support, and preview-disabled mode.
- User state lives under `~/.config/awtwall/`; disposable cache/debug data lives under `~/.cache/awtwall/`.
- Preserve per-output wallpaper state and restore behavior.
- Preserve keyboard-first controls and mouse support.
- Setting menus must continue to support direct number selection and closing by pressing the same setting key again.
- `--select-only` is an isolation boundary: it must not apply a wallpaper, require a wallpaper backend, run post-apply hooks, expose normal backend/display targeting controls, or mutate normal wallpaper/backend persistence state.
- Do not change compositor monitor configuration. Display discovery is read-only.

## Change discipline

- Inspect the current implementation and relevant tests before editing.
- Make the smallest complete change that fixes the requested behavior.
- Preserve unrelated behavior and user-visible defaults unless the task explicitly changes them.
- Do not invent package names, compositor APIs, paths, config keys, release versions, tags, or AUR state.
- Keep installation modes distinct. AUR installations are package-manager-managed; manual installs use `awtwall-installer` / `awtwall-update` and normally live under `~/.local/bin`.
- Do not make `awtwall-update` overwrite an AUR-managed `/usr/bin/awtwall`.
- Treat release/tag/AUR publication as separate state. Do not create, move, replace, or delete a release/tag, or publish/update the AUR package, unless explicitly requested.

## Validation

For Bash or behavior changes, run the strongest applicable checks available:

```bash
bash -n awtwall awtwall-installer awtwall-update tests/*.sh
git diff --check
./tests/test-select-only.sh
./tests/test-select-only-runtime.sh
```

Run `shellcheck` on changed shell files when it is available and the repository's existing style does not intentionally conflict with it.

For documentation-only changes, verify Markdown links/paths against the current tree and run `git diff --check` when working from a local checkout.

Do not claim runtime wallpaper, compositor, preview, or terminal UI behavior is verified unless it was actually exercised in an appropriate Wayland session.

## Documentation and releases

- Keep `README.md` concise and point detailed install/update/uninstall procedures to their dedicated guides.
- When installation behavior changes, update `INSTALL.md` and any affected installer text together.
- When update behavior changes, update `UPDATE.md` and `awtwall-update` together.
- When uninstall behavior changes, update `UNINSTALL.md` and `awtwall-installer` together.
- Release notes should link to the canonical install, update, and uninstall guides rather than duplicating long command sections.
- Release notes must describe only behavior actually present in the tagged release. Do not move a tag just to pick up later documentation changes unless explicitly instructed.

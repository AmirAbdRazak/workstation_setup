# workstation_setup

My nvim + tmux setup, reproducible on any new machine or VM.

## Fresh machine

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/AmirAbdRazak/workstation_setup/main/bootstrap.sh)
```

Clones this repo to `~/.workstation_setup` and runs `install.sh`.

## What `install.sh` does

1. Upgrades the system and installs packages with `pacman -Syu`, `apt` or `dnf` (uses sudo).
   Skip with `--no-packages` if you don't have root, then it checks they exist.
2. Installs a pinned Neovim (`NVIM_VERSION`) to `~/.local/opt`, linked to `~/.local/bin/nvim`.
3. Symlinks `nvim/` → `~/.config/nvim` and `tmux/tmux.conf` → `~/.tmux.conf`
   (existing files are moved to `*.bak.<timestamp>`).
4. Clones tmux plugins at pinned commits into `~/.tmux/plugins`.
5. Headless nvim: restores plugins from `lazy-lock.json`, builds treesitter
   parsers, installs LSP servers via Mason. Log: `~/.cache/workstation_setup/nvim-setup.log`.

Safe to re-run.

## Updating

Configs are symlinked, so edits land in this repo — commit and push them.
After `:Lazy update`, commit `nvim/lazy-lock.json` so other machines get the same plugin versions.
If you add an LSP server in `nvim/init.lua`, add it to `MASON_PACKAGES` in `install.sh` too.

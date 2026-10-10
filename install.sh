#!/usr/bin/env bash
# Reproducible nvim + tmux setup. Safe to re-run.
#
#   ./install.sh                 full setup
#   ./install.sh --no-packages   skip system packages (no sudo needed)
#
# Fresh machine one-liner:
#   bash <(curl -fsSL https://raw.githubusercontent.com/AmirAbdRazak/workstation_setup/main/bootstrap.sh)
set -euo pipefail

NVIM_VERSION="v0.11.5"

# name|url|commit — pinned so every machine gets the same tmux plugins.
TMUX_PLUGINS=(
  "tpm|https://github.com/tmux-plugins/tpm|99469c4a9b1ccf77fade25842dc7bafbc8ce9946"
  "tmux-sensible|https://github.com/tmux-plugins/tmux-sensible|25cb91f42d020f675bb0a2ce3fbd3a5d96119efa"
  "vim-tmux-navigator|https://github.com/christoomey/vim-tmux-navigator|c45243dc1f32ac6bcf6068e5300f3b2b237e576a"
  "tmux-nova|https://github.com/o0th/tmux-nova|317c812c34b523075b8f8e233748397027da8b2b"
  "tmux-resurrect|https://github.com/tmux-plugins/tmux-resurrect|cff343cf9e81983d3da0c8562b01616f12e8d548"
)

# Keep in sync with `servers` in nvim/init.lua (Mason package names).
MASON_PACKAGES=(clangd pyright ruff lua-language-server)

# Commands the nvim/tmux setup needs at runtime (Mason, treesitter, telescope).
REQUIRED_CMDS=(git curl tar make gcc unzip rg fd node npm python3 tmux)

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
OPT_DIR="$HOME/.local/opt"
LOG_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/workstation_setup"

INSTALL_PACKAGES=1
for arg in "$@"; do
  case "$arg" in
    --no-packages) INSTALL_PACKAGES=0 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

log()  { printf '\033[1;35m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

as_root() {
  if [ "$(id -u)" -eq 0 ]; then "$@"; else sudo "$@"; fi
}

install_packages() {
  if command -v pacman >/dev/null; then
    # Arch only supports full upgrades; a stale sync db fails with 404 sig errors.
    as_root pacman -Syu --needed --noconfirm \
      git curl tar gzip make gcc unzip ripgrep fd nodejs npm python tmux github-cli
  elif command -v apt-get >/dev/null; then
    as_root apt-get update -qq
    as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
      git curl tar gzip build-essential unzip ripgrep fd-find nodejs npm \
      python3 python3-venv tmux gh
    # Debian/Ubuntu ship fd as `fdfind`.
    if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
      ln -sf "$(command -v fdfind)" "$BIN_DIR/fd"
    fi
  elif command -v dnf >/dev/null; then
    as_root dnf install -y \
      git curl tar gzip make gcc unzip ripgrep fd-find nodejs npm python3 tmux gh
  else
    warn "unsupported package manager; install these yourself:"
    warn "  git curl tar make gcc unzip ripgrep fd nodejs npm python3(+venv) tmux"
  fi
}

check_requirements() {
  local missing=() cmd
  for cmd in "${REQUIRED_CMDS[@]}"; do
    command -v "$cmd" >/dev/null || missing+=("$cmd")
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    warn "missing required commands: ${missing[*]}"
    warn "run without --no-packages, or install them yourself"
    exit 1
  fi
}

install_nvim() {
  local current=""
  if [ -x "$BIN_DIR/nvim" ]; then
    current="$("$BIN_DIR/nvim" --version | head -1 | awk '{print $2}')"
  fi
  if [ "$current" = "$NVIM_VERSION" ]; then
    log "nvim $NVIM_VERSION already installed"
    return
  fi

  local arch
  case "$(uname -m)" in
    x86_64) arch=x86_64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) warn "no nvim release for $(uname -m)"; return 1 ;;
  esac

  log "installing nvim $NVIM_VERSION"
  local dest="$OPT_DIR/nvim-$NVIM_VERSION"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-$arch.tar.gz" \
    | tar -xz -C "$tmp"
  rm -rf "$dest"
  mv "$tmp/nvim-linux-$arch" "$dest"
  rmdir "$tmp"
  ln -sfn "$dest/bin/nvim" "$BIN_DIR/nvim"
}

# Symlink $1 (in repo) to $2, backing up whatever was there.
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local backup
    backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
    warn "backing up $dst -> $backup"
    mv "$dst" "$backup"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  log "linked $dst"
}

install_tmux_plugins() {
  local plugin_dir="$HOME/.tmux/plugins" entry name url commit dir
  mkdir -p "$plugin_dir"
  for entry in "${TMUX_PLUGINS[@]}"; do
    IFS='|' read -r name url commit <<<"$entry"
    dir="$plugin_dir/$name"
    if [ ! -d "$dir/.git" ]; then
      git clone -q "$url" "$dir"
    fi
    if [ "$(git -C "$dir" rev-parse HEAD)" != "$commit" ]; then
      git -C "$dir" fetch -q origin
      git -C "$dir" -c advice.detachedHead=false checkout -q "$commit"
    fi
  done
  log "tmux plugins pinned"
}

# Run headless nvim with output sent to a log; show the log tail on failure.
nvim_headless() {
  local log_file="$LOG_DIR/nvim-setup.log"
  echo "+ nvim $*" >>"$log_file"
  if ! "$BIN_DIR/nvim" --headless "$@" +qa >>"$log_file" 2>&1; then
    tail -20 "$log_file" >&2
    warn "nvim step failed; full log: $log_file"
    return 1
  fi
}

setup_nvim_plugins() {
  mkdir -p "$LOG_DIR"
  : >"$LOG_DIR/nvim-setup.log"
  log "restoring nvim plugins from lazy-lock.json"
  # On a fresh machine lazy's first-start auto-install rewrites the lockfile,
  # so keep the committed one and restore from it once plugins exist.
  local lock="$REPO_DIR/nvim/lazy-lock.json" saved
  saved="$(mktemp)"
  cp "$lock" "$saved"
  nvim_headless "+Lazy! restore"
  cp "$saved" "$lock"
  rm "$saved"
  nvim_headless "+Lazy! restore"
  log "installing treesitter parsers"
  nvim_headless "+TSUpdateSync"
  log "installing LSP servers via Mason"
  # MasonInstall blocks until done when headless.
  nvim_headless "+MasonInstall ${MASON_PACKAGES[*]}"
}

ensure_path() {
  case ":$PATH:" in *":$BIN_DIR:"*) return ;; esac
  if command -v fish >/dev/null; then
    fish -c "fish_add_path -U $BIN_DIR"
  fi
  warn "$BIN_DIR is not on PATH in this shell. For bash/zsh add:"
  warn "  export PATH=\"\$HOME/.local/bin:\$PATH\""
}

main() {
  mkdir -p "$BIN_DIR" "$OPT_DIR"
  if [ "$INSTALL_PACKAGES" -eq 1 ]; then
    log "installing system packages"
    install_packages
  fi
  check_requirements
  install_nvim
  link "$REPO_DIR/nvim" "$HOME/.config/nvim"
  link "$REPO_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
  install_tmux_plugins
  setup_nvim_plugins
  ensure_path
  log "done. Reload a running tmux with: tmux source ~/.tmux.conf"
}

main

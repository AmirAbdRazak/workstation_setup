#!/usr/bin/env bash
# Clone (or update) workstation_setup and run its installer.
#   bash <(curl -fsSL https://raw.githubusercontent.com/AmirAbdRazak/workstation_setup/main/bootstrap.sh)
set -euo pipefail

REPO_URL="https://github.com/AmirAbdRazak/workstation_setup.git"
DEST="${WORKSTATION_SETUP_DIR:-$HOME/.workstation_setup}"

if ! command -v git >/dev/null; then
  if command -v pacman >/dev/null; then sudo pacman -Syu --needed --noconfirm git
  elif command -v apt-get >/dev/null; then sudo apt-get update -qq && sudo apt-get install -y -qq git
  elif command -v dnf >/dev/null; then sudo dnf install -y git
  else echo "install git first" >&2; exit 1
  fi
fi

if [ -d "$DEST/.git" ]; then
  git -C "$DEST" pull --ff-only
else
  git clone "$REPO_URL" "$DEST"
fi

exec "$DEST/install.sh" "$@"

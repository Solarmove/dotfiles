#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
home="$(mktemp -d)"
trap 'rm -rf "$home"' EXIT
mkdir -p "$home/.config/nvim" "$home/.config/wezterm"
printf 'old editor\n' > "$home/.config/nvim/old"
printf 'old shell\n' > "$home/.zshrc"
export HOME="$home" XDG_CONFIG_HOME="$home/.config"
bash "$repo/install.sh" --link-only
[[ "$(readlink "$home/.config/nvim")" == "$repo/current-nvim" ]]
[[ "$(readlink "$home/.zshrc")" == "$repo/zsh/.zshrc" ]]
[[ "$(find "$home/.dotfiles-backup" -name old | wc -l | tr -d ' ')" == 1 ]]
[[ "$(find "$home/.dotfiles-backup" -name .zshrc | wc -l | tr -d ' ')" == 1 ]]
bash "$repo/install.sh" --link-only
[[ "$(find "$home/.dotfiles-backup" -name old | wc -l | tr -d ' ')" == 1 ]]
if bash "$repo/install.sh" --invalid-option >/dev/null 2>&1; then
  echo 'Unknown option should fail' >&2
  exit 1
fi
echo 'Link, backup and repeat-install tests passed.'

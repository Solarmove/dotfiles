#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home" XDG_CONFIG_HOME="$tmp/config" XDG_DATA_HOME="$tmp/data" XDG_STATE_HOME="$tmp/state"
mkdir -p "$HOME" "$XDG_CONFIG_HOME/nvim" "$XDG_DATA_HOME/nvim/site/pack/core/opt" "$tmp/source"
git -C "$tmp/source" init -q
git -C "$tmp/source" -c user.name=Test -c user.email=test@example.com commit --allow-empty -qm initial
printf 'plugin\n' > "$tmp/source/plugin.lua"
git -C "$tmp/source" add plugin.lua
git -C "$tmp/source" -c user.name=Test -c user.email=test@example.com commit -qm plugin
root="$XDG_DATA_HOME/nvim/site/pack/core/opt"
git clone -q "$tmp/source" "$root/complete"
git clone -q --no-checkout "$tmp/source" "$root/incomplete"
printf '{"plugins":{"complete":{},"incomplete":{}}}\n' > "$XDG_CONFIG_HOME/nvim/nvim-pack-lock.json"
export DOTFILES_TEST_MODULE="$repo/current-nvim/lua/craftzdog/config/install_bootstrap.lua"
nvim --headless -u NONE '+lua local ok, err=pcall(function() dofile(vim.env.DOTFILES_TEST_MODULE).recover_incomplete_plugins() end); if not ok then print(err); vim.cmd("cquit") end' +qa
[[ -f "$root/complete/plugin.lua" ]]
[[ ! -e "$root/incomplete" ]]
[[ "$(find "$XDG_STATE_HOME/nvim/dotfiles-incomplete-plugins" -name incomplete -type d | wc -l | tr -d ' ')" == 1 ]]
export DOTFILES_TEST_TIMEOUT="$repo/tests/test-nvim-timeout.lua"
nvim --headless -u NONE '+lua local ok, err=pcall(dofile, vim.env.DOTFILES_TEST_TIMEOUT); if not ok then print(err); vim.cmd("cquit") end' +qa
echo 'Neovim interrupted-clone recovery and timeout tests passed.'

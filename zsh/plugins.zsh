# Plugins are installed by install.sh, never by starting a shell.
ZPLUGINDIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
_zplugin_load() {
  local plugin_file="$ZPLUGINDIR/$1/$1.plugin.zsh"
  [[ -f "$plugin_file" ]] && source "$plugin_file"
  return 0
}
zplugin-update() {
  local dir
  for dir in "$ZPLUGINDIR"/*(/N); do
    git -C "$dir" pull --ff-only || return
  done
}
_zplugin_load zsh-vi-mode
if command -v fzf >/dev/null 2>&1; then
  _zplugin_load fzf-tab
fi
_zplugin_load zsh-autosuggestions
_zplugin_load zsh-history-substring-search
_zplugin_load fast-syntax-highlighting

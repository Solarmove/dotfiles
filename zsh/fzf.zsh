command -v fzf >/dev/null 2>&1 || return 0
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
else
  export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/.git/*'"
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height=60% --layout=reverse --border=rounded --preview-window=right:65%:wrap'
if command -v bat >/dev/null 2>&1; then
  export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 -- {}'
elif command -v batcat >/dev/null 2>&1; then
  export _FZF_PREVIEW_CMD='batcat --color=always --style=plain,numbers --line-range=:500 -- {}'
else
  export _FZF_PREVIEW_CMD='head -n 500 -- {}'
fi
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"
# --zsh is available from fzf 0.48; distribution scripts support older versions.
if fzf --help | command grep -q -- '--zsh'; then
  eval "$(fzf --zsh)"
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
elif [[ -f "$HOME/.fzf.zsh" ]]; then
  source "$HOME/.fzf.zsh"
fi
_fzf_file_no_hidden() {
  local result cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
  result=$(eval "$cmd" | fzf --preview "$_FZF_PREVIEW_CMD") && LBUFFER+="${(q)result}"
  zle reset-prompt
}
zle -N _fzf_file_no_hidden
bindkey '^F' _fzf_file_no_hidden

# Resolve the repository through the .zshrc symlink; cloning elsewhere is supported.
export DOTFILES_DIR="${${(%):-%x}:A:h:h}"
export PATH="$HOME/.local/bin:$PATH"
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_THEME="robbyrussell"
plugins=(git)
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  autoload -Uz compinit
  compinit -d "$ZSH_COMPDUMP"
fi

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS AUTOCD NOBEEP NUMERIC_GLOB_SORT
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# fzf-tab owns the selection menu.
zstyle ':completion:*' menu no

if [[ -f "$HOME/.config/lf/icons" ]]; then
  export LF_ICONS="$(tr '\n' ':' < "$HOME/.config/lf/icons")"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
source "$DOTFILES_DIR/zsh/aliases.zsh"
source "$DOTFILES_DIR/zsh/fzf.zsh"
# Completion and fzf must be initialized before fzf-tab; highlighting comes last.
source "$DOTFILES_DIR/zsh/plugins.zsh"

# Set DOTFILES_AUTO_TMUX=0 to keep a plain shell.
if [[ "${DOTFILES_AUTO_TMUX:-1}" == 1 && -o interactive && -t 0 && -t 1 && -z "$TMUX" ]] && command -v tmux >/dev/null 2>&1; then
  exec tmux new-session
fi
# Homebrew's prefix differs between Apple Silicon, Intel macOS and Linux.
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x "$brew_bin" ]]; then
    eval "$("$brew_bin" shellenv)"
    break
  fi
done
unset brew_bin
export PATH="$HOME/.local/bin:$PATH"

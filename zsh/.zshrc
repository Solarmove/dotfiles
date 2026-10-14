# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"


source $ZSH/oh-my-zsh.sh


autoload -U compinit; compinit
[[ -f "$HOME/.oh-my-zsh/custom/plugins/fzf-tab/fzf-tab.plugin.zsh" ]] && \
  source "$HOME/.oh-my-zsh/custom/plugins/fzf-tab/fzf-tab.plugin.zsh"
export LANG="C.UTF-8"
export LC_ALL="C.UTF-8"

autoload -U compinit; compinit
source ~/fzf-tab/fzf-tab.plugin.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# >>> Codex installer >>>
export PATH="/home/fastflow/.local/bin:$PATH"
# <<< Codex installer <<<

if command -v tmux >/dev/null 2>&1 && [[ -z "$TMUX" ]] && [[ -o interactive ]]; then
    exec tmux new-session -A -s main
fi
alias bat='batcat'


HISTFILE="$HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY

setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS


# =========================================================

# Shell behaviour
# =========================================================


setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1


# =========================================================
# Smart directory navigation & lf
# =========================================================


if [[ -f ~/.config/lf/icons ]]; then

  LF_ICONS=$(cat ~/.config/lf/icons | tr '\n' ':')
  export LF_ICONS
fi

# Initialize zoxide
eval "$(zoxide init zsh)"

# =========================================================
# Completion
# =========================================================

# Load completion system
autoload -Uz compinit

# Initialize completion with cached metadata file
compinit -d "$HOME/zsh/zcompdump"

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-zXDG_CACHE_HOME}'  # lowercase input matches upper and lower



# Aliases
source "$HOME/dotfiles/zsh/aliases.zsh"
# Plugins and plugin manager
source "$HOME/dotfiles/zsh/plugins.zsh"

# fzf configuration
source "$HOME/dotfiles/zsh/fzf.zsh"


# Ubuntu
if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi

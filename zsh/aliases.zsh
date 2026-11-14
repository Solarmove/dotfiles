# Keep working aliases even before dependencies are installed.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons=auto'
  alias ll='eza -lh --icons=auto --git'
  alias la='eza -lah --icons=auto --git'
  alias tree='eza --tree --icons=auto'
  compdef eza=ls
else
  alias ll='ls -lh'
  alias la='ls -lah'
fi
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  alias bat='batcat'
fi
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  alias fd='fdfind'
fi

# =========================================================
# Core utilities
# =========================================================

command -v rg >/dev/null 2>&1 && alias grep='rg --color=auto'

[[ $OSTYPE != linux* ]] || alias diff='diff --color=auto'
alias df='df -h'

# =========================================================
# Navigation
# =========================================================

alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

lf() { # zsh follow lf navigation
    local tmp dir
    whence -p lf >/dev/null 2>&1 || { print -u2 "lf is missing: run $DOTFILES_DIR/install.sh"; return 127; }
    tmp=$(mktemp) || return
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir=$(cat "$tmp")
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

# =========================================================
# Editor

# =========================================================

alias n='nvim'


# =========================================================
# Git
# =========================================================


alias glog='PAGER="less -F -X" git log'                              # -F quit if one screen, -X no clear on exit
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
dotfiles() { git -C "$DOTFILES_DIR" "$@"; }

# =========================================================
# Video
# =========================================================

command -v mpv >/dev/null 2>&1 && alias stream='mpv av://v4l2:/dev/video4 --fullscreen --demuxer-lavf-o=input_format=mjpeg,framerate=30 --profile=low-latency --untimed'

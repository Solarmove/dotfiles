# POSIX login shell configuration.
[ ! -d "$HOME/.local/bin" ] || export PATH="$HOME/.local/bin:$PATH"
[ ! -f "$HOME/.local/bin/env" ] || . "$HOME/.local/bin/env"
[ ! -d "$HOME/.docker/bin" ] || export PATH="$PATH:$HOME/.docker/bin"

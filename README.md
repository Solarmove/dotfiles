# Personal dotfiles

Portable shell, tmux, Neovim, and Fish configuration. The install script creates
symlinks and moves any existing target into `~/.dotfiles-backup/` first; it does
not delete existing configuration.

## Install

Clone this repository to `~/dotfiles`, then run:

```sh
~/dotfiles/install.sh
```

The Neovim configuration uses LazyVim/Lazy.nvim; launch `nvim` to install its
plugins. The zsh config expects [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh).
For the optional `fzf-tab` integration, install it with:

```sh
git clone https://github.com/Aloxaf/fzf-tab "$HOME/.oh-my-zsh/custom/plugins/fzf-tab"
```

On macOS, MacPorts PATH additions are enabled only when `/opt/local/bin` exists.
Docker and `~/.local/bin` paths are likewise conditional. No shell history,
credentials, application state, or machine-specific editor caches are included.

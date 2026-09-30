#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
BACKUP_CREATED=0

link_config() {
  local source_path="$1"
  local target_path="$2"
  mkdir -p "$(dirname -- "$target_path")"

  if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
    printf 'Already linked: %s\n' "$target_path"
    return
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    if [[ "$BACKUP_CREATED" -eq 0 ]]; then
      mkdir -p "$BACKUP_DIR"
      BACKUP_CREATED=1
    fi
    local backup_path="$BACKUP_DIR/${target_path#"$HOME/"}"
    mkdir -p "$(dirname -- "$backup_path")"
    mv "$target_path" "$backup_path"
    printf 'Backed up: %s -> %s\n' "$target_path" "$backup_path"
  fi

  ln -s "$source_path" "$target_path"
  printf 'Linked: %s -> %s\n' "$target_path" "$source_path"
}

link_config "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
link_config "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
link_config "$DOTFILES_DIR/zsh/.profile" "$HOME/.profile"
link_config "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
link_config "$DOTFILES_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"
link_config "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
link_config "$DOTFILES_DIR/config/fish/conf.d/uv.env.fish" \
  "$HOME/.config/fish/conf.d/uv.env.fish"

if [[ -d "$HOME/.oh-my-zsh" && ! -d "$HOME/.oh-my-zsh/custom/plugins/fzf-tab" ]]; then
  printf '\nfzf-tab is not installed. Install it with:\n'
  printf '  git clone https://github.com/Aloxaf/fzf-tab "$HOME/.oh-my-zsh/custom/plugins/fzf-tab"\n'
fi

if [[ "$BACKUP_CREATED" -eq 1 ]]; then
  printf '\nPrevious configs were preserved in: %s\n' "$BACKUP_DIR"
fi

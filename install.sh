#!/usr/bin/env bash
set -Eeuo pipefail

# This file works both inside a checkout and as a separately downloaded bootstrap.
REPO_URL="${DOTFILES_REPO_URL:-https://github.com/Solarmove/dotfiles.git}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="$(uname -s)"
ARCH="$(uname -m)"
PACKAGES=1
LINK_ONLY=0
APPS=1
for arg in "$@"; do
  case "$arg" in
    --skip-packages) PACKAGES=0 ;;
    --link-only) LINK_ONLY=1; PACKAGES=0 ;;
    --no-apps) APPS=0 ;;
    -h|--help) printf 'Usage: bash install.sh [--skip-packages] [--link-only] [--no-apps]\n'; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done
fail() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }
trap 'printf "\nInstallation failed at line %s. Fix the error and rerun the installer.\n" "$LINENO" >&2' ERR
[[ "$OS" == Darwin || "$OS" == Linux ]] || fail "Only macOS and Linux are supported."
[[ "$(id -u)" != 0 ]] || fail "Run as your regular user, not root."

# CLT installation is a system GUI operation and can require user confirmation.
if [[ "$PACKAGES" == 1 && "$OS" == Darwin ]] && ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  fail "Install the Command Line Tools in the macOS dialog, then rerun this file."
fi
if [[ "$PACKAGES" == 1 && "$OS" == Linux ]] && ! command -v git >/dev/null; then
  command -v apt-get >/dev/null || fail "Install git, curl and build tools first (Linux bootstrap supports Debian/Ubuntu)."
  sudo apt-get update
  sudo apt-get install -y git curl ca-certificates
fi

if [[ -f "$SCRIPT_DIR/current-nvim/init.lua" && -f "$SCRIPT_DIR/zsh/.zshrc" ]]; then
  DOTFILES_DIR="$SCRIPT_DIR"
else
  DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
  if [[ -e "$DOTFILES_DIR" || -L "$DOTFILES_DIR" ]]; then
    fail "$DOTFILES_DIR already exists; refusing to overwrite it. Run install.sh from your checkout or set DOTFILES_DIR."
  fi
  command -v git >/dev/null || fail "git is required to clone the repository."
  git clone "$REPO_URL" "$DOTFILES_DIR"
  [[ -f "$DOTFILES_DIR/current-nvim/init.lua" ]] || fail "The remote repository does not yet contain this installer and configuration. Push your changes first."
  exec bash "$DOTFILES_DIR/install.sh" "$@"
fi
export DOTFILES_DIR
export PATH="$HOME/.local/bin:$PATH"
mkdir -p "$HOME/.local/bin"
BACKUP_DIR=""
link_config() {
  local source="$1" target="$2" backup
  [[ -e "$source" ]] || fail "Missing source: $source"
  mkdir -p "$(dirname "$target")"
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then return; fi
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -z "$BACKUP_DIR" ]]; then
      mkdir -p "$HOME/.dotfiles-backup"
      BACKUP_DIR="$(mktemp -d "$HOME/.dotfiles-backup/install.XXXXXXXX")"
    fi
    backup="$BACKUP_DIR/${target#"$HOME/"}"
    mkdir -p "$(dirname "$backup")"
    mv "$target" "$backup"
    printf 'Backed up %s -> %s\n' "$target" "$backup"
  fi
  ln -s "$source" "$target"
  printf 'Linked %s -> %s\n' "$target" "$source"
}
link_all() {
  local config="${XDG_CONFIG_HOME:-$HOME/.config}"
  link_config "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  link_config "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"
  link_config "$DOTFILES_DIR/zsh/.profile" "$HOME/.profile"
  link_config "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
  link_config "$DOTFILES_DIR/tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"
  link_config "$DOTFILES_DIR/current-nvim" "$config/nvim"
  link_config "$DOTFILES_DIR/config/wezterm/wezterm.lua" "$config/wezterm/wezterm.lua"
  link_config "$DOTFILES_DIR/config/ghostty/config" "$config/ghostty/config"
  link_config "$DOTFILES_DIR/config/zed/settings.json" "$config/zed/settings.json"
  link_config "$DOTFILES_DIR/config/zed/keymap.json" "$config/zed/keymap.json"
  local vscode_dir="$config/Code/User"
  if [[ "$OS" == Darwin ]]; then vscode_dir="$HOME/Library/Application Support/Code/User"; fi
  link_config "$DOTFILES_DIR/config/vscode/settings.json" "$vscode_dir/settings.json"
  link_config "$DOTFILES_DIR/config/vscode/keybindings.json" "$vscode_dir/keybindings.json"
}
if [[ "$LINK_ONLY" == 1 ]]; then
  link_all
  printf 'Config links installed. Backup: %s\n' "${BACKUP_DIR:-none}"
  exit 0
fi

if [[ "$PACKAGES" == 1 ]]; then
  if [[ "$OS" == Linux ]]; then
    command -v apt-get >/dev/null || fail "Linux package bootstrap currently supports Debian/Ubuntu."
    sudo apt-get update
    sudo apt-get install -y build-essential procps file git curl ca-certificates unzip xz-utils zsh tmux xclip wl-clipboard
  fi
  # Homebrew supplies recent cross-platform versions of the development tools.
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [[ -x "$candidate" ]]; then eval "$("$candidate" shellenv)"; break; fi
  done
  if ! command -v brew >/dev/null; then
    tmp="$(mktemp)"
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$tmp"
    NONINTERACTIVE=1 /bin/bash "$tmp"
    rm -f "$tmp"
    if [[ "$OS" == Linux ]]; then candidate=/home/linuxbrew/.linuxbrew/bin/brew
    elif [[ "$ARCH" == arm64 ]]; then candidate=/opt/homebrew/bin/brew
    else candidate=/usr/local/bin/brew; fi
    [[ -x "$candidate" ]] || fail "Homebrew was not installed at $candidate"
    eval "$("$candidate" shellenv)"
  fi
  export PATH="$HOME/.local/bin:$PATH"
  brew install git zsh tmux eza fzf fd bat ripgrep zoxide lf lazygit node python uv gh
  if [[ "$OS" == Darwin ]]; then
    brew install --cask font-hack-nerd-font font-jetbrains-mono-nerd-font
    if [[ "$APPS" == 1 ]]; then
      # These are applications observed on the source machine; sign-in is separate.
      for app in wezterm ghostty visual-studio-code zed docker google-chrome spotify obsidian; do
        brew list --cask "$app" >/dev/null 2>&1 || brew install --cask "$app"
      done
    fi
  else
    if [[ ! -f "$HOME/.local/share/fonts/HackNerdFont-Regular.ttf" ]]; then
      tmpdir="$(mktemp -d)"
      curl -fL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip -o "$tmpdir/Hack.zip"
      mkdir -p "$HOME/.local/share/fonts"
      unzip -o -q "$tmpdir/Hack.zip" '*.ttf' -d "$HOME/.local/share/fonts"
      rm -rf "$tmpdir"
      command -v fc-cache >/dev/null && fc-cache -f "$HOME/.local/share/fonts" || true
    fi
    if [[ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf" ]]; then
      tmpdir="$(mktemp -d)"
      curl -fL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip -o "$tmpdir/font.zip"
      mkdir -p "$HOME/.local/share/fonts"
      unzip -o -q "$tmpdir/font.zip" '*.ttf' -d "$HOME/.local/share/fonts"
      rm -rf "$tmpdir"
      command -v fc-cache >/dev/null && fc-cache -f "$HOME/.local/share/fonts" || true
    fi
    if [[ "$APPS" == 1 ]] && ! command -v wezterm >/dev/null; then
      [[ "$ARCH" == x86_64 ]] || fail "Automatic Linux WezTerm install supports x86_64 only; install WezTerm manually or use --no-apps."
      tmpdir="$(mktemp -d)"
      appimage=WezTerm-20240203-110809-5046fc22-Ubuntu20.04.AppImage
      base=https://github.com/wezterm/wezterm/releases/download/20240203-110809-5046fc22
      curl -fL "$base/$appimage" -o "$tmpdir/$appimage"
      curl -fL "$base/$appimage.sha256" -o "$tmpdir/$appimage.sha256"
      (cd "$tmpdir" && sha256sum -c "$appimage.sha256" && chmod +x "$appimage" && "./$appimage" --appimage-extract >/dev/null)
      mkdir -p "$HOME/.local/opt"
      [[ ! -e "$HOME/.local/opt/wezterm-20240203" ]] || fail "$HOME/.local/opt/wezterm-20240203 already exists; refusing to overwrite it"
      mv "$tmpdir/squashfs-root" "$HOME/.local/opt/wezterm-20240203"
      ln -sfn "$HOME/.local/opt/wezterm-20240203/AppRun" "$HOME/.local/bin/wezterm"
      mkdir -p "$HOME/.local/share/applications"
      printf '[Desktop Entry]\nType=Application\nName=WezTerm\nExec="%s"\nIcon=org.wezfurlong.wezterm\nCategories=System;TerminalEmulator;\nTerminal=false\n' "$HOME/.local/bin/wezterm" > "$HOME/.local/share/applications/dotfiles-wezterm.desktop"
      rm -rf "$tmpdir"
    fi
  fi
fi
for tool in git curl zsh tmux node npm uv; do command -v "$tool" >/dev/null || fail "Missing $tool; rerun without --skip-packages."; done

# The current config uses vim.pack (Neovim 0.12), not the old lazy.nvim config.
if ! command -v nvim >/dev/null || [[ "$(nvim --headless -u NONE '+lua io.write(vim.fn.has("nvim-0.12"))' +qa 2>/dev/null)" != 1 ]]; then
  [[ "$PACKAGES" == 1 ]] || fail "Neovim >= 0.12 required; rerun without --skip-packages."
  case "$OS:$ARCH" in
    Linux:x86_64) asset=nvim-linux-x86_64 ;;
    Linux:aarch64|Linux:arm64) asset=nvim-linux-arm64 ;;
    Darwin:x86_64) asset=nvim-macos-x86_64 ;;
    Darwin:arm64) asset=nvim-macos-arm64 ;;
    *) fail "Unsupported Neovim architecture: $OS $ARCH" ;;
  esac
  tmpdir="$(mktemp -d)"
  curl -fL "https://github.com/neovim/neovim/releases/download/v0.12.6/$asset.tar.gz" -o "$tmpdir/nvim.tar.gz"
  mkdir -p "$HOME/.local/opt"
  tar -xzf "$tmpdir/nvim.tar.gz" -C "$tmpdir"
  install_dir="$HOME/.local/opt/$asset-0.12.6"
  if [[ -e "$install_dir" ]]; then
    [[ -x "$install_dir/bin/nvim" ]] || fail "$install_dir exists but has no Neovim executable"
  else
    mv "$tmpdir/$asset" "$install_dir"
  fi
  ln -sfn "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
  rm -rf "$tmpdir"
  hash -r
fi
clone_once() {
  local repo="$1" destination="$2" temp
  [[ -d "$destination/.git" ]] && return
  [[ ! -e "$destination" && ! -L "$destination" ]] || fail "$destination exists but is not a git checkout"
  mkdir -p "$(dirname "$destination")"
  temp="$(mktemp -d "${destination}.install.XXXXXXXX")"
  if ! git clone --depth=1 "https://github.com/$repo.git" "$temp"; then rm -rf "$temp"; return 1; fi
  mv "$temp" "$destination"
}
clone_once ohmyzsh/ohmyzsh "${ZSH:-$HOME/.oh-my-zsh}"
plugin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
for repo in Aloxaf/fzf-tab zsh-users/zsh-autosuggestions zsh-users/zsh-history-substring-search jeffreytse/zsh-vi-mode zdharma-continuum/fast-syntax-highlighting; do
  clone_once "$repo" "$plugin_dir/${repo##*/}"
done
for repo in tmux-plugins/tpm tmux-plugins/tmux-resurrect tmux-plugins/tmux-continuum; do
  clone_once "$repo" "$HOME/.tmux/plugins/${repo##*/}"
done
link_all
# Install only the public VS Code extensions list, never application storage.
if [[ "$APPS" == 1 ]]; then
  code_bin="$(command -v code || true)"
  if [[ -z "$code_bin" && "$OS" == Darwin && -x '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' ]]; then
    code_bin='/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
  fi
  if [[ -n "$code_bin" ]]; then
    failed_extensions=0
    while IFS= read -r extension || [[ -n "$extension" ]]; do
      [[ -z "$extension" ]] && continue
      "$code_bin" --install-extension "$extension" || { printf 'VS Code extension failed: %s\n' "$extension" >&2; failed_extensions=1; }
    done < "$DOTFILES_DIR/config/vscode/extensions.txt"
    [[ "$failed_extensions" == 0 ]] || fail "Some VS Code extensions failed; rerun the installer."
  fi
fi
unset NVIM_APPNAME
# vim.pack.add installs pinned plugins. Wait for Mason and all parsers, and
# explicitly verify package status; :MasonToolsInstallSync itself can hide errors.
DOTFILES_NVIM_INSTALL=1 nvim --headless '+MasonToolsInstallSync' \
  '+lua local ok, err = pcall(dofile, vim.env.DOTFILES_DIR .. "/current-nvim/install-check.lua"); if not ok then io.stderr:write(tostring(err) .. "\n"); vim.cmd("cquit") end' '+qa'
DOTFILES_NVIM_INSTALL=1 nvim --headless '+lua if #vim.v.errmsg > 0 then io.stderr:write(vim.v.errmsg); vim.cmd("cquit") end' '+qa'

# WezTerm explicitly starts zsh, so changing the account's login shell is not needed.
printf '\nDone. Open WezTerm. Backup: %s\n' "${BACKUP_DIR:-none}"
printf 'Copilot, Git, Docker and other applications may require separate sign-in.\n'

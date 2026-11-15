#!/usr/bin/env bash
# Sourced by install.sh, not executed independently. No Homebrew is required.

macports_os_label() {
  case "$1" in
    13) printf '13-Ventura' ;;
    14) printf '14-Sonoma' ;;
    15) printf '15-Sequoia' ;;
    26) printf '26-Tahoe' ;;
    27) printf '27-GoldenGate' ;;
    *) return 1 ;;
  esac
}

macos_install_ports() {
  local version os_key label pkg base tmpdir expected actual
  version="$(sw_vers -productVersion)"
  os_key="${version%%.*}"
  if [[ "$os_key" == 10 ]]; then os_key="$(printf '%s' "$version" | cut -d. -f1,2)"; fi
  label="$(macports_os_label "$os_key")" || fail "macOS $version is not supported by this installer (supported: 13, 14, 15, 26, 27)."
  case "$ARCH" in x86_64|arm64) ;; *) fail "Unsupported macOS architecture: $ARCH" ;; esac

  if [[ ! -x /opt/local/bin/port ]]; then
    base='https://github.com/macports/macports-base/releases/download/v2.12.7'
    pkg="MacPorts-2.12.7-$label.pkg"
    tmpdir="$(mktemp -d)"
    curl -fL "$base/$pkg" -o "$tmpdir/$pkg"
    curl -fL "$base/MacPorts-2.12.7.chk.txt" -o "$tmpdir/checksums"
    expected="$(awk -v prefix="SHA2-256($pkg)=" '$1 == prefix { print $2 }' "$tmpdir/checksums")"
    actual="$(shasum -a 256 "$tmpdir/$pkg" | awk '{print $1}')"
    [[ -n "$expected" && "$expected" == "$actual" ]] || fail "MacPorts package SHA-256 verification failed."
    pkgutil --check-signature "$tmpdir/$pkg" || fail "MacPorts package signature verification failed."
    sudo installer -pkg "$tmpdir/$pkg" -target /
    rm -rf "$tmpdir"
  fi
  [[ -x /opt/local/bin/port ]] || fail "MacPorts installation failed."
  export PATH="$HOME/.local/bin:/opt/local/bin:/opt/local/sbin:$PATH"
  sudo /opt/local/bin/port -N selfupdate
  # npm10 depends on nodejs22. Fail rather than replacing an already active
  # different MacPorts Node version behind the user's back.
  sudo /opt/local/bin/port -N install git zsh tmux eza fzf fd bat ripgrep zoxide lf lazygit nodejs22 npm10 python312 uv gh
  hash -r
}

macos_install_fonts() {
  local family temp
  mkdir -p "$HOME/Library/Fonts"
  for family in Hack JetBrainsMono; do
    [[ -f "$HOME/Library/Fonts/${family}NerdFont-Regular.ttf" ]] && continue
    temp="$(mktemp -d)"
    curl -fL "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/$family.zip" -o "$temp/font.zip"
    unzip -n -q "$temp/font.zip" '*.ttf' -d "$HOME/Library/Fonts"
    rm -rf "$temp"
  done
}

# Install apps in the user's Applications folder. Existing apps are untouched.
# Mount/unmount images explicitly even when copying or validation fails.
macos_app_present() {
  [[ -e "$HOME/Applications/$1.app" || -L "$HOME/Applications/$1.app" || -e "/Applications/$1.app" || -L "/Applications/$1.app" ]]
}
macos_install_app() {
  local name="$1" format="$2" url="$3" checksum="${4:-}" tmp app candidate stage mounted=0 rc=0
  if macos_app_present "$name"; then printf '%s already installed; skipping.\n' "$name"; return 0; fi
  tmp="$(mktemp -d)" || return 1
  if ! curl -fL "$url" -o "$tmp/download.$format"; then rm -rf "$tmp"; return 1; fi
  if [[ -n "$checksum" ]] && [[ "$(shasum -a 256 "$tmp/download.$format" | awk '{print $1}')" != "$checksum" ]]; then
    printf 'SHA-256 mismatch: %s\n' "$name" >&2; rm -rf "$tmp"; return 1
  fi
  mkdir -p "$tmp/content" "$HOME/Applications"
  if [[ "$format" == dmg ]]; then
    if hdiutil attach -nobrowse -readonly -mountpoint "$tmp/content" "$tmp/download.dmg"; then mounted=1; else rc=1; fi
  elif ! ditto -x -k "$tmp/download.zip" "$tmp/content"; then
    rc=1
  fi
  app="$tmp/content/$name.app"
  # The official WezTerm zip contains a versioned top-level directory.
  if [[ ! -d "$app" ]]; then
    for candidate in "$tmp/content"/*/"$name.app"; do
      if [[ -d "$candidate" ]]; then app="$candidate"; break; fi
    done
  fi
  if [[ "$rc" == 0 ]]; then
    if [[ ! -d "$app" ]]; then
      printf 'Expected app not found in download: %s\n' "$name" >&2; rc=1
    elif ! codesign --verify --deep --strict "$app"; then
      printf 'Invalid app signature: %s\n' "$name" >&2; rc=1
    else
      stage="$(mktemp -d "$HOME/Applications/.dotfiles-app.XXXXXXXX")" || rc=1
      if [[ "$rc" == 0 ]]; then
        if ! ditto "$app" "$stage/$name.app" || macos_app_present "$name" || ! mv "$stage/$name.app" "$HOME/Applications/$name.app"; then
          printf 'Could not safely install %s\n' "$name" >&2; rc=1
        fi
        rm -rf "$stage"
      fi
    fi
  fi
  if [[ "$mounted" == 1 ]]; then
    if ! hdiutil detach "$tmp/content"; then
      printf 'Could not detach %s; leaving mounted volume at %s\n' "$name" "$tmp/content" >&2
      return 1
    fi
  fi
  rm -rf "$tmp"
  return "$rc"
}

macos_install_apps() {
  local zed_arch docker_arch failures=0
  case "$ARCH" in
    x86_64) zed_arch=x86_64; docker_arch=amd64 ;;
    arm64) zed_arch=aarch64; docker_arch=arm64 ;;
    *) return 1 ;;
  esac
  # WezTerm is pinned and checksum-verified; other URLs are official upstreams.
  macos_install_app WezTerm zip \
    'https://github.com/wez/wezterm/releases/download/20240203-110809-5046fc22/WezTerm-macos-20240203-110809-5046fc22.zip' \
    'e77388cad55f2e9da95a220a89206a6c58f865874a629b7c3ea3c162f5692224' || failures=1
  macos_install_app 'Visual Studio Code' zip 'https://update.code.visualstudio.com/latest/darwin-universal/stable' || failures=1
  macos_install_app Ghostty dmg 'https://release.files.ghostty.org/1.4.0/Ghostty.dmg' || failures=1
  macos_install_app Zed dmg "https://github.com/zed-industries/zed/releases/latest/download/Zed-$zed_arch.dmg" || failures=1
  macos_install_app Docker dmg "https://desktop.docker.com/mac/main/$docker_arch/Docker.dmg" || failures=1
  macos_install_app 'Google Chrome' dmg 'https://dl.google.com/chrome/mac/universal/stable/GGRO/googlechrome.dmg' || failures=1
  macos_install_app Spotify dmg 'https://download.scdn.co/Spotify.dmg' || failures=1
  macos_install_app Obsidian dmg 'https://github.com/obsidianmd/obsidian-releases/releases/download/v1.15.1/Obsidian-1.15.1.dmg' || failures=1
  return "$failures"
}

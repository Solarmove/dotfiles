#!/usr/bin/env bash
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
# These tests use mocks and do not install software or need macOS.
source "$repo/scripts/macos.sh"
[[ "$(macports_os_label 15)" == 15-Sequoia ]]
[[ "$(macports_os_label 26)" == 26-Tahoe ]]
[[ "$(macports_os_label 27)" == 27-GoldenGate ]]
if macports_os_label 12 >/dev/null; then echo 'Unsupported version accepted' >&2; exit 1; fi

home="$(mktemp -d)"
trap 'rm -rf "$home"' EXIT
export HOME="$home"
LOG="$home/log"
APPNAME=Sample
SIGNATURE_OK=1
curl() {
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == -o ]]; then shift; : > "$1"; return; fi
    shift
  done
  return 1
}
ditto() {
  if [[ "$1" == -x ]]; then mkdir -p "$4/versioned/$APPNAME.app"; else mkdir -p "$2"; fi
}
codesign() { [[ "$SIGNATURE_OK" == 1 ]]; }
hdiutil() {
  printf '%s\n' "$1" >> "$LOG"
  if [[ "$1" == attach ]]; then
    while [[ $# -gt 0 ]]; do
      if [[ "$1" == -mountpoint ]]; then shift; mkdir -p "$1/$APPNAME.app"; return; fi
      shift
    done
    return 1
  fi
}
macos_install_app "$APPNAME" dmg 'https://example.invalid/Sample.dmg'
[[ -d "$HOME/Applications/Sample.app" ]]
[[ "$(grep -c '^detach$' "$LOG")" == 1 ]]
# Repeat installation must leave the existing application untouched.
macos_install_app "$APPNAME" dmg 'https://example.invalid/Sample.dmg'
[[ "$(grep -c '^attach$' "$LOG")" == 1 ]]
rm -rf "$HOME/Applications/Sample.app"
SIGNATURE_OK=0
if macos_install_app "$APPNAME" dmg 'https://example.invalid/Sample.dmg'; then
  echo 'Invalid signature was accepted' >&2; exit 1
fi
[[ ! -e "$HOME/Applications/Sample.app" ]]
[[ "$(grep -c '^detach$' "$LOG")" == 2 ]]
SIGNATURE_OK=1
# A bad checksum is rejected before extraction.
if macos_install_app "$APPNAME" zip 'https://example.invalid/Sample.zip' 'bad-checksum'; then
  echo 'Invalid checksum was accepted' >&2; exit 1
fi
macos_install_app "$APPNAME" zip 'https://example.invalid/Sample.zip'
[[ -d "$HOME/Applications/Sample.app" ]]

# Verify app selection uses the right architecture and aggregates failures.
macos_install_app() { printf '%s|%s\n' "$1" "$3" >> "$LOG"; [[ "$1" != Ghostty ]]; }
ARCH=x86_64
if macos_install_apps; then echo 'Missing failure status' >&2; exit 1; fi
grep -q 'Zed|.*Zed-x86_64.dmg' "$LOG"
grep -q 'Docker|.*mac/main/amd64/' "$LOG"
ARCH=arm64
if macos_install_apps; then echo 'Missing failure status' >&2; exit 1; fi
grep -q 'Zed|.*Zed-aarch64.dmg' "$LOG"
grep -q 'Docker|.*mac/main/arm64/' "$LOG"
echo 'macOS version, app installation and architecture tests passed (mocked).'

# The following lines were added by Docker Desktop to add commands to your PATH.
[[ -d "$HOME/.docker/bin" ]] && export PATH="$PATH:$HOME/.docker/bin"
# End of Docker Desktop section.

# MacPorts Installer addition on 2026-09-21_at_00:43:22: adding an appropriate PATH variable for use with MacPorts.
if [[ -d /opt/local/bin ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
fi
# Finished adapting your PATH environment variable for use with MacPorts.


# MacPorts takes precedence on macOS; Linux can use Linuxbrew.
if [[ -x /opt/local/bin/port ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
else
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [[ -x "$brew_bin" ]]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done
  unset brew_bin
fi

# >>> Codex installer >>>
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
# <<< Codex installer <<<

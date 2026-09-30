# The following lines were added by Docker Desktop to add commands to your PATH.
[[ -d "$HOME/.docker/bin" ]] && export PATH="$PATH:$HOME/.docker/bin"
# End of Docker Desktop section.

# MacPorts Installer addition on 2026-09-21_at_00:43:22: adding an appropriate PATH variable for use with MacPorts.
if [[ -d /opt/local/bin ]]; then
  export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
fi
# Finished adapting your PATH environment variable for use with MacPorts.


# >>> Codex installer >>>
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
# <<< Codex installer <<<

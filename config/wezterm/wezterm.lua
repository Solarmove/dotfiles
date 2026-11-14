local wezterm = require 'wezterm'
local keys = {}

for i = 1, 9 do
  table.insert(keys, {
    key = tostring(i),
    mods = 'ALT',
    action = wezterm.action.ActivateTab(i - 1),
  })
end

local function basename(cwd)
  if not cwd then
    return 'Terminal'
  end
  local path = type(cwd) == 'userdata' and cwd.file_path or tostring(cwd)
  path = path:gsub('^file://[^/]*', ''):gsub('/+$', '')
  return path:match('([^/]+)$') or 'Terminal'
end

wezterm.on('format-tab-title', function(tab)
  return {
    { Text = ' ' .. (tab.tab_index + 1) .. ': ' .. basename(tab.active_pane.current_working_dir) .. ' ' },
  }
end)

return {
  -- PATH is initialized by the login shell; /bin/zsh exists on macOS and Ubuntu.
  default_prog = { '/bin/zsh', '-l' },
  color_scheme = 'Kanagawa (Gogh)',
  font = wezterm.font('Hack Nerd Font'),
  font_size = 12,
  window_background_opacity = 0.85,
  text_background_opacity = 0.85,
  initial_cols = 140,
  initial_rows = 40,
  window_padding = { left = 15, right = 15, top = 15, bottom = 15 },
  window_decorations = 'TITLE | RESIZE',
  default_cursor_style = 'SteadyBlock',
  scrollback_lines = 10000,
  audible_bell = 'Disabled',
  keys = keys,
}

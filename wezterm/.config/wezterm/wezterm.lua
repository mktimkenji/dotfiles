local wezterm = require("wezterm")
local config = wezterm.config_builder()

math.randomseed(os.time())

--------------------------------------------------
-- Themes
--------------------------------------------------
local schemes = {
  "Catppuccin Mocha",
  "Catppuccin Macchiato",
}

--------------------------------------------------
-- Palettes
--------------------------------------------------
local palettes = {
  ["Catppuccin Mocha"] = {
    base = "#1e1e2e",
    mantle = "#181825",
    overlay = "#45475a",
    muted = "#6c7086",
    text = "#cdd6f4",
    mauve = "#cba6f7",
  },
  ["Catppuccin Macchiato"] = {
    base = "#24273a",
    mantle = "#1e2030",
    overlay = "#494d64",
    muted = "#6e738d",
    text = "#cad3f5",
    mauve = "#c6a0f6",
  },
}

config.color_scheme = wezterm.GLOBAL.current_scheme or schemes[math.random(#schemes)]
wezterm.GLOBAL.current_scheme = config.color_scheme

local function palette()
  return palettes[wezterm.GLOBAL.current_scheme] or palettes["Catppuccin Mocha"]
end

--------------------------------------------------
-- Backgrounds
--------------------------------------------------
local bg_dir = wezterm.config_dir .. "/backgrounds"
local backgrounds = {}

local success, files = pcall(wezterm.read_dir, bg_dir)

if success and files then
  for _, file in ipairs(files) do
    local lower = file:lower()
    if lower:match("%.png$") or lower:match("%.jpg$") or lower:match("%.jpeg$") or lower:match("%.webp$") then
      table.insert(backgrounds, file)
    end
  end
end

table.sort(backgrounds)

if #backgrounds > 0 and wezterm.GLOBAL.current_bg == nil then
  wezterm.GLOBAL.current_bg = math.random(#backgrounds)
end

if wezterm.GLOBAL.transparent_mode == nil then
  wezterm.GLOBAL.transparent_mode = false
end

--------------------------------------------------
-- Helpers
--------------------------------------------------
local function get_background(is_transparent)
  if #backgrounds == 0 then
    return nil
  end

  -- Overlay tint: use the theme's base colour as the dim layer.
  local overlay_color = palettes[wezterm.GLOBAL.current_scheme].base or "#1e1e2e"

  return {
    -- Wallpaper layer (hidden in glass/transparent mode)
    {
      source = { File = backgrounds[wezterm.GLOBAL.current_bg] },
      width = "Cover",
      height = "Cover",
      opacity = is_transparent and 0.0 or 1.0,
      hsb = { brightness = 0.20 },
    },

    -- Theme-tinted overlay layer
    {
      source = { Color = overlay_color },
      width = "100%",
      height = "100%",
      opacity = is_transparent and 0.75 or 0.35,
    },
  }
end

--------------------------------------------------
-- Initial State
--------------------------------------------------
config.background = get_background(wezterm.GLOBAL.transparent_mode)
config.window_background_opacity = wezterm.GLOBAL.transparent_mode and 0.90 or 1.0
config.text_background_opacity = 1.0

--------------------------------------------------
-- Events
--------------------------------------------------
wezterm.on("toggle-theme", function(window)
  local overrides = window:get_config_overrides() or {}

  if wezterm.GLOBAL.current_scheme == schemes[1] then
    wezterm.GLOBAL.current_scheme = schemes[2]
  else
    wezterm.GLOBAL.current_scheme = schemes[1]
  end

  overrides.color_scheme = wezterm.GLOBAL.current_scheme
  overrides.background = get_background(wezterm.GLOBAL.transparent_mode)

  window:set_config_overrides(overrides)
end)

wezterm.on("cycle-background", function(window)
  if #backgrounds == 0 then
    return
  end

  -- Exit transparent mode automatically when cycling wallpapers.
  wezterm.GLOBAL.transparent_mode = false
  wezterm.GLOBAL.current_bg = (wezterm.GLOBAL.current_bg % #backgrounds) + 1

  local overrides = window:get_config_overrides() or {}
  overrides.background = get_background(false)
  overrides.window_background_opacity = 1.0
  overrides.text_background_opacity = 1.0

  window:set_config_overrides(overrides)
end)

wezterm.on("toggle-transparent", function(window)
  wezterm.GLOBAL.transparent_mode = not wezterm.GLOBAL.transparent_mode

  local overrides = window:get_config_overrides() or {}
  overrides.background = get_background(wezterm.GLOBAL.transparent_mode)
  overrides.window_background_opacity = wezterm.GLOBAL.transparent_mode and 0.90 or 1.0
  overrides.text_background_opacity = 1.0

  window:set_config_overrides(overrides)
end)

--------------------------------------------------
-- Tabs
--------------------------------------------------
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32

---@diagnostic disable-next-line: unused-local
wezterm.on("format-tab-title", function(tab, _tabs, _panes, _cfg, _hover, max_width)
  local p = palette()
  local title = tab.tab_title and #tab.tab_title > 0 and tab.tab_title or tab.active_pane.title

  local index = tostring(tab.tab_index + 1)
  local budget = max_width - #index - 4
  if #title > budget then
    title = title:sub(1, budget - 1) .. "…"
  end

  if tab.is_active then
    return {
      { Background = { Color = p.base } },
      { Foreground = { Color = p.mauve } },
      { Text = " " .. index .. " " },
      { Foreground = { Color = p.text } },
      { Text = title .. " " },
      { ResetAttributes = {} },
    }
  end

  return {
    { Background = { Color = p.mantle } },
    { Foreground = { Color = p.overlay } },
    { Text = " " .. index },
    { Foreground = { Color = p.muted } },
    { Text = title .. " " },
    { ResetAttributes = {} },
  }
end)

--------------------------------------------------
-- Keybinds
--------------------------------------------------
config.disable_default_key_bindings = true

local act = wezterm.action

config.keys = {
  -- Custom backgrounds
  { key = "b", mods = "CTRL|SHIFT", action = act.EmitEvent("cycle-background") },
  { key = "b", mods = "CTRL|SHIFT|ALT", action = act.EmitEvent("toggle-transparent") },
  { key = "m", mods = "CTRL|SHIFT", action = act.EmitEvent("toggle-theme") },

  -- General
  { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "+", mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "0", mods = "CTRL", action = act.ResetFontSize },
  { key = "l", mods = "CTRL|SHIFT|ALT", action = act.ShowDebugOverlay },

  -- Tabs
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "phys:1", mods = "CTRL|SHIFT", action = act.ActivateTab(0) },
  { key = "phys:2", mods = "CTRL|SHIFT", action = act.ActivateTab(1) },
  { key = "phys:3", mods = "CTRL|SHIFT", action = act.ActivateTab(2) },
  { key = "phys:4", mods = "CTRL|SHIFT", action = act.ActivateTab(3) },
  { key = "phys:5", mods = "CTRL|SHIFT", action = act.ActivateTab(4) },
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

  -- Panes — splitting
  { key = "|", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "_", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- Panes — navigation
  { key = "h", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },

  -- Panes — resizing
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "UpArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "DownArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },

  -- Panes — misc
  { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
  { key = "x", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "Space", mods = "CTRL|SHIFT", action = act.PaneSelect({ mode = "Activate" }) },

  -- Scrollback
  { key = "u", mods = "CTRL|SHIFT", action = act.ScrollByPage(-0.5) },
  { key = "d", mods = "CTRL|SHIFT", action = act.ScrollByPage(0.5) },
  { key = "k", mods = "CTRL|ALT", action = act.ScrollByLine(-1) },
  { key = "j", mods = "CTRL|ALT", action = act.ScrollByLine(1) },

  -- Copy mode
  { key = "f", mods = "CTRL|SHIFT", action = act.Search({ CaseSensitiveString = "" }) },
  { key = "y", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },

  -- Workspaces
  { key = "s", mods = "CTRL|SHIFT", action = act.ShowLauncherArgs({ flags = "WORKSPACES" }) },
  { key = "n", mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(1) },
  { key = "p", mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
}

--------------------------------------------------
-- General
--------------------------------------------------
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

config.adjust_window_size_when_changing_font_size = false
config.enable_kitty_graphics = true
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 17
config.max_fps = 120
config.scrollback_lines = 10000

config.set_environment_variables = {
  LANG = "en_US.UTF-8",
  LC_ALL = "en_US.UTF-8",
}

config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"

if wezterm.target_triple:find("windows") then
  config.default_prog = { "wsl.exe", "--cd", "~" }
end

return config

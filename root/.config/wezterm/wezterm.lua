local wezterm = require("wezterm") --[[@as Wezterm]]
local config = wezterm.config_builder()
wezterm.log_info("reloading")

config.webgpu_power_preference = "HighPerformance"

config.color_scheme = 'tokyonight_storm'

config.font = wezterm.font({ family = "FuraCode Nerd Font" })
config.bold_brightens_ansi_colors = true

config.enable_kitty_graphics = true

config.enable_tab_bar = false

if wezterm.target_triple:find("windows") then
  config.default_prog = { "wsl", "--cd", "~" }
  config.font = wezterm.font({ family = "FuraCode NF" })
end

config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

return config

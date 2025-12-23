-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

local window_decorations_callback = function ()
    local handle = io.popen('uname')
    local system

    if handle~=nil then
        system = handle:read('*a')
        handle:close()
    end

    if system == 'Darwin' then
        return 'TITLE|RESIZE|MACOS_USE_BACKGROUND_COLOR_AS_TITLEBAR_COLOR'
    end

    return 'TITLE|RESIZE'
    
end



-- or, changing the font size and color scheme.
config.font_size = 14
config.color_scheme = 'Catppuccin Mocha'
config.enable_tab_bar = false
config.enable_scroll_bar = false
config.window_background_opacity = 0.8
config.macos_window_background_blur = 20
config.window_decorations = window_decorations_callback()

-- Finally, return the configuration to wezterm:
return config



local wibox = require "wibox"
local menubar = require "mymenubar".get(screen.primary)
-- menubar = table.move(menubar, 1, #menubar, 1, {})
local naughty = require "naughty"
local gears = require "gears"

local desktop = wibox {
    visible = false,
    opacity = 0.7,
    width = screen.primary.geometry.width-100,
    height = screen.primary.geometry.height-100,
    bg = "#ff0000",
    below = true,
}

menubar.forced_height = 1000
naughty.notify { text = gears.debug.dump_return(menubar.forced_height) }
menubar.visible = true


menubar.forced_height = 1000
desktop:setup{layout = menubar}

-- bg_color = "#ff0000"
-- fg_color = "#00ff00"
-- border_width = 10
-- border_color = "#0000ff"
--
-- desktop = {
--     wibox = wibox {
--         ontop = true,
--         bg = bg_color,
--         fg = fg_color,
--         border_width = border_width,
--         border_color = border_color,
--         layout = wibox.layout.background,
--     },
--     widget = menubar,
-- }
-- local layout = wibox.layout.fixed.vertical()
-- layout:add(desktop.widget)
-- layout:add(wibox.container.scroll.vertical(instance.widget))
-- desktop.wibox:setup{layout=layout}

-- desktop.wibox.visible = true

-- desktop:setup {
--     -- text = "bla",
--     -- align = "center",
--     -- widget = wibox.widget.textbox,
--     widget = menubar.get(screen.primary),
--   -- layout = wibox.layout.fixed.horizontal
-- }
-- naughty.notify({text = gears.debug.dump_return(screen.primary.geometry.width)})

return desktop

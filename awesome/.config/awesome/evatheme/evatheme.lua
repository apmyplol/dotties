---------------------------
-- Default awesome theme --
---------------------------

-- local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local gears = require("gears")
local dpi = xresources.apply_dpi

-- local gfs = require("gears.filesystem")
local themes_path = "/home/afa/.config/awesome/themes/"

local eva = {
	alacbg = "#4D427D",
	alacfg = "#B3ACD8",

	-- 初号機 colors
	purple1 = "#A877C8",
	purple2 = "#B1A8DD",
	reb_purple1 = "#775899",
	reb_purple2 = "#7573A3",
	green = "#A3DA58",
	orange = "#F7BA2D",
	black = "#000000",
	white = "#FFFFFF",
	red = "#FF0000",
	reb_green = "#54CF51",
	reb_orange = "#ff8c28",
}
	-- 二号機 colors
local eva2 = {
        red = "#A3001C",
        orange = "#EC6C2B",
        purple = "#8866A2",
        reb_purp = "#74738D",
}

	-- 零号機 colors
local eva0 = {
        blue = "#7999f2",
        grey = "#B8C297",
}


local theme = {}

theme.eva = eva
theme.eva2 = eva2
theme.eva0 = eva0

theme.font = "Source Han Sans Serif JP"
--local numbers = { "壹", "貳", "參", "肆", "伍", "陸", "漆", "捌", "玖" }
-- local numbers = { "壱", "弐", "参", "四", "伍", "六", "七", "八", "九" }
theme.numbers = { "壱", "弐", "参", "肆", "伍", "陸", "漆", "捌", "玖" }
-- clock
theme.clock_extra_fg = theme.standart_on
theme.clock_extra_bg = theme.eva_green

-- mystuff
theme.standart_on = "#c500f9"
theme.standart_off = "#000000"
theme.eva_green = "#00FF00" --"#A2DA5A" --"#AEF359"

theme.black = "#000000"
theme.white = "#FFFFFF"
theme.transp = "#00000000"

theme.bg_normal = "#FFFFFF"
theme.bg_focus = theme.eva_green --"#535d6c" -- Hintergrundfarbe des Desktops auf dem man gerade ist (壹,貳 usw)
theme.bg_urgent = "#ff0000" -- Wenn auf einem Desktop was urgentes aufkommt dann leuchtet das in der farbe
theme.bg_minimize = "#444444" -- Keine Ahnung lol

-- TODO REMOVE SYSTRAY or add toggle trick
theme.bg_systray = eva.reb_purple1

theme.wibar_bg = theme.transp

theme.fg_normal = theme.standart_on -- textfarbe von nicht focused desktops
theme.fg_focus = "#000000" -- Textfarbe von focued desktop "#A2DA5A"
theme.fg_urgent = "#ffffff" -- Textfarbe vom Urgent
theme.fg_minimize = "#ffffff" -- Keine Ahnung

theme.wibox = 30

theme.useless_gap = 5
theme.border_width = 3
theme.border_normal = "#00000000" -- normal state is purple
theme.border_focus = theme.eva_green --"#AEF359" focused window is green
theme.border_marked = "#91231c" -- Keine Ahnung

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Generate taglist squares
local taglist = {
    shape = gears.shape.circle,
    bg_occupied = theme.standart_on,
    fg_occupied = theme.standart_off,
    bg_focus = theme.eva_green,
    spacing = 1,
    forced_height = theme.wibox,
    --shape_border_width = 2,
    --shape_border_color = theme.standart_on,
    font = theme.font .. " 15"
}

for key, val in pairs(taglist) do
    theme["taglist_" .. key] = val
end

-- Hotkeys
local hotkeys = {
    bg = eva.alacbg,
    fg = eva.alacfg,
    border_width = 2,
    border_color = eva.reb_green,
    modifiers_fg = eva.reb_green,
    label_bg = eva2.reb_purp,
    group_margin = 50
}

for key, val in pairs(hotkeys) do
    theme["hotkeys_" .. key] = val
end



--[[
local taglist_square_size = 5 --die kleinen Squares in der Ecke der Tags
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.standart_on
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.standart_off
)
]]
--

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path .. "default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width = dpi(100)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
-- theme.titlebar_close_button_normal = themes_path .. "default/titlebar/close_normal.png"
-- theme.titlebar_close_button_focus = themes_path .. "default/titlebar/close_focus.png"
--
-- theme.titlebar_minimize_button_normal = themes_path .. "default/titlebar/minimize_normal.png"
-- theme.titlebar_minimize_button_focus = themes_path .. "default/titlebar/minimize_focus.png"
--
-- theme.titlebar_ontop_button_normal_inactive = themes_path .. "default/titlebar/ontop_normal_inactive.png"
-- theme.titlebar_ontop_button_focus_inactive = themes_path .. "default/titlebar/ontop_focus_inactive.png"
-- theme.titlebar_ontop_button_normal_active = themes_path .. "default/titlebar/ontop_normal_active.png"
-- theme.titlebar_ontop_button_focus_active = themes_path .. "default/titlebar/ontop_focus_active.png"
--
-- theme.titlebar_sticky_button_normal_inactive = themes_path .. "default/titlebar/sticky_normal_inactive.png"
-- theme.titlebar_sticky_button_focus_inactive = themes_path .. "default/titlebar/sticky_focus_inactive.png"
-- theme.titlebar_sticky_button_normal_active = themes_path .. "default/titlebar/sticky_normal_active.png"
-- theme.titlebar_sticky_button_focus_active = themes_path .. "default/titlebar/sticky_focus_active.png"
--
-- theme.titlebar_floating_button_normal_inactive = themes_path .. "default/titlebar/floating_normal_inactive.png"
-- theme.titlebar_floating_button_focus_inactive = themes_path .. "default/titlebar/floating_focus_inactive.png"
-- theme.titlebar_floating_button_normal_active = themes_path .. "default/titlebar/floating_normal_active.png"
-- theme.titlebar_floating_button_focus_active = themes_path .. "default/titlebar/floating_focus_active.png"
--
-- theme.titlebar_maximized_button_normal_inactive = themes_path .. "default/titlebar/maximized_normal_inactive.png"
-- theme.titlebar_maximized_button_focus_inactive = themes_path .. "default/titlebar/maximized_focus_inactive.png"
-- theme.titlebar_maximized_button_normal_active = themes_path .. "default/titlebar/maximized_normal_active.png"
-- theme.titlebar_maximized_button_focus_active = themes_path .. "default/titlebar/maximized_focus_active.png"
--
-- -- You can use your own layout icons like this:
-- theme.layout_fairh = themes_path .. "default/layouts/fairhw.png"
-- theme.layout_fairv = themes_path .. "default/layouts/fairvw.png"
-- theme.layout_floating = themes_path .. "default/layouts/floatingw.png"
-- theme.layout_magnifier = themes_path .. "default/layouts/magnifierw.png"
-- theme.layout_max = themes_path .. "default/layouts/maxw.png"
-- theme.layout_fullscreen = themes_path .. "default/layouts/fullscreenw.png"
-- theme.layout_tilebottom = themes_path .. "default/layouts/tilebottomw.png"
-- theme.layout_tileleft = themes_path .. "default/layouts/tileleftw.png"
-- theme.layout_tile = themes_path .. "default/layouts/tilew.png"
-- theme.layout_tiletop = themes_path .. "default/layouts/tiletopw.png"
-- theme.layout_spiral = themes_path .. "default/layouts/spiralw.png"
-- theme.layout_dwindle = themes_path .. "default/layouts/dwindlew.png"
-- theme.layout_cornernw = themes_path .. "default/layouts/cornernww.png"
-- theme.layout_cornerne = themes_path .. "default/layouts/cornernew.png"
-- theme.layout_cornersw = themes_path .. "default/layouts/cornersww.png"
-- theme.layout_cornerse = themes_path .. "default/layouts/cornersew.png"
--
-- -- Generate Awesome icon:
-- theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.bg_focus, theme.fg_focus)
--
-- -- Define the icon theme for application icons. If not set then the icons
-- -- from /usr/share/icons and /usr/share/icons/hicolor will be used.
-- theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

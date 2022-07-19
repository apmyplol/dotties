local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local adir = gears.filesystem.get_configuration_dir() -- awesome config dir
beautiful.init(adir .. "/evatheme/evatheme.lua")

local GET_VOL = require("mystuff.commands").GET_VOLUME
local progress_shape = require("evatheme.evashapes").eva_double_matrix_progress

local dpi = beautiful.xresources.apply_dpi

local popup_width = 50 --dpi(50)
local popup_margin = 5
local fscreen = screen.primary


local width_gaps = 10
local height_gaps = 0
local widget_height = 20
local widget_width = 30

-- ===================================================================
-- Appearance & Functionality
-- ===================================================================

local volume_text = wibox.widget({
	widget = wibox.widget.textbox,
	font = beautiful.font .. " 20",
	align = "center",

})

-- create the volume_adjust component
local volume_adjust = wibox({
	screen = fscreen,
	x = 0,
	y = 3/4 * fscreen.geometry.height,
	width = popup_width,
	height = fscreen.geometry.height * 1 / 2,
	bg = "#000000FF",
	shape = gears.shape.rectangle,
	valign = "center",
	visible = false,
	ontop = true,
})



local volume_bar = wibox.widget({
	widget = wibox.widget.progressbar,
	color = beautiful.eva.reb_green,
	max_value = 100,
	value = 0,
	background_color = beautiful.eva.reb_red,
	shape = function(cr, shape_width, shape_height)
		progress_shape(cr, shape_height, shape_width, popup_width - 2*popup_margin ,widget_height, widget_width, height_gaps, width_gaps, false)
	end,
	bar_shape = function(cr, shape_width, height)
		progress_shape(cr, height, shape_width,popup_width - 2*popup_margin, widget_height, widget_width, height_gaps, width_gaps, true)
	end,
	clip = false,
	paddings = 0,
	margins = {
		top = 0,
		bottom = 0,
	},
})

volume_adjust:setup({
	layout = wibox.layout.align.vertical,
	wibox.container.margin(volume_text, 0, 0, dpi(20), dpi(5)),
	wibox.container.margin(volume_bar, popup_margin, dpi(5), dpi(10), popup_margin),
})

-- create a timer to hide the volume adjust
-- component whenever the timer is started
local hide_volume_adjust = gears.timer({
	timeout = 1,
	autostart = true,
	callback = function()
		volume_adjust.visible = false
	end,
})

-- show volume-adjust when "volume_change" signal is emitted
awesome.connect_signal("volume_change_s", function()
	-- set new volume value and colors etc
	awful.spawn.easy_async_with_shell(GET_VOL, function(stdout)
		-- 27
		-- false
		local vol, status = stdout:match("([%d]+)\n([%a]*)")
		local vol = tonumber(vol)

		volume_bar.value = vol

		local text = function(tex, clr)
			return "<span color='" .. clr .. "'>" .. tex .. "</span>"
		end

		-- set colors and 漢字
		if status == "true" then -- if muted
			volume_bar.color = beautiful.eva.orange
			volume_text:set_markup_silently(text("無", beautiful.eva.orange))
		else
			volume_bar.color = beautiful.eva.reb_green
			if vol == 100 then
				volume_text:set_markup_silently(text("拾", beautiful.eva.green))
				return
			elseif vol == 0 then
				volume_text:set_markup_silently(text("〇", beautiful.eva.red))
				return
			elseif vol < 10 then
				volume_bar.color = beautiful.eva2.red
				volume_text:set_markup_silently(text("零", beautiful.eva2.red))
				return
			end
			local perc = math.floor(vol / 10)
			volume_text:set_markup_silently(text(beautiful.numbers[perc], beautiful.eva.green))
		end
	end)

	-- make volume_adjust component visible
	if volume_adjust.visible then
		hide_volume_adjust:again()
	else
		volume_adjust.visible = true
		hide_volume_adjust:start()
	end
end)

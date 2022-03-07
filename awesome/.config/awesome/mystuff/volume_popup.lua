-- ===================================================================
-- Initialization
-- ===================================================================

local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local GET_VOL = require("mystuff.commands").GET_VOLUME

local dpi = beautiful.xresources.apply_dpi

local offsetx = dpi(200)
local fscreen = awful.screen.focused()
beautiful.init(gears.filesystem.get_configuration_dir() .. "/evatheme/evatheme.lua")
local tick_size = 15
local gaps = 1

-- ===================================================================
-- Appearance & Functionality
-- ===================================================================

local volume_icon = wibox.widget({
	widget = wibox.widget.textbox,
	font = beautiful.font .. " 20",
})

-- create the volume_adjust component
local volume_adjust = wibox({
	screen = fscreen,
	x = offsetx, --screen.geometry.width,,
	y = fscreen.geometry.height,
	width = fscreen.geometry.width - 2 * offsetx,
	height = 50,
	bg = "#00000000",
	shape = gears.shape.rectangle,
	visible = false,
	ontop = true,
})

local volume_bar = wibox.widget({
	widget = wibox.widget.progressbar,
	color = beautiful.eva.reb_green,
	background_color = beautiful.eva.reb_purple1,
  shape = function(cr, width, height)
    beautiful.shapes.bar1(cr, width, height, gaps, tick_size)
    end,
  bar_shape = function(cr, width, height)
    beautiful.shapes.bar1(cr, width, height, gaps, tick_size)
    end,
	max_value = 100,
	value = 0,
})

volume_adjust:setup({
	layout = wibox.layout.align.horizontal,
    volume_icon,
	{
		wibox.container.margin(volume_bar, dpi(20), dpi(0), dpi(20), dpi(20)),
		layout = wibox.container.place,
	},
})

-- create a 4 second timer to hide the volume adjust
-- component whenever the timer is started
local hide_volume_adjust = gears.timer({
	timeout = 1,
	autostart = true,
	callback = function()
		volume_adjust.visible = false
	end,
})

-- show volume-adjust when "volume_change" signal is emitted
awesome.connect_signal("volume_change", function()
	-- adjust position and length if the focused screen changed

	local focused_screen = awful.screen.focused()
	if fscreen ~= focused_screen then
		fscreen = focused_screen
		volume_adjust.screen = focused_screen

		if focused_screen == screen.primary then
			volume_adjust.x = offsetx --screen.geometry.width,
			volume_adjust.y = fscreen.geometry.height
			volume_adjust.width = fscreen.geometry.width - 2 * offsetx
			volume_adjust.height = 50
		else
			volume_adjust.x = dpi(2080) --screen.geometry.width,
			volume_adjust.y = dpi(1000)
			volume_adjust.width = fscreen.geometry.width - 2 * offsetx
			volume_adjust.height = 50
		end
	end

	-- set new volume value and colors etc
	awful.spawn.easy_async_with_shell(
    GET_VOL,
		function(stdout)
      -- 27
      -- false
			local vol, status = stdout:match("([%d]+)\n([%a]*)")
			local vol = tonumber(vol)


			volume_bar.value = vol

      local text = function(tex, clr)
        return "<span color='" .. clr .."'>" .. tex .. "</span>"
      end

			-- set colors and 漢字
			if status == "true" then -- if muted
				volume_bar.color = beautiful.eva.orange
				volume_icon:set_markup_silently(text("無", beautiful.eva.orange))
			else
				volume_bar.color = beautiful.eva.reb_green
				if vol == 100 then
					volume_icon:set_markup_silently(text("拾", beautiful.eva.green))
					return
        elseif vol == 0 then
					volume_icon:set_markup_silently(text("〇", beautiful.eva.red))
					return
				elseif vol < 10 then
          volume_bar.color = beautiful.eva2.red
					volume_icon:set_markup_silently(text("零", beautiful.eva2.red))
					return
				end
				local perc = math.floor(vol / 10)
				volume_icon:set_markup_silently(text(beautiful.numbers[perc], beautiful.eva.green))
			end
		end
	)

	-- make volume_adjust component visible
	if volume_adjust.visible then
		hide_volume_adjust:again()
	else
		volume_adjust.visible = true
		hide_volume_adjust:start()
	end
end)

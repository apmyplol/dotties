pcall(require, "luarocks.loader")

local mystuff = require("mystuff")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local numbers = beautiful.numbers
local commands = require("mystuff.commands")

local adir = gears.filesystem.get_configuration_dir() -- awesome config dir
local cdir = gears.filesystem.get_xdg_config_home() -- .config dir
beautiful.init(adir .. "/evatheme/evatheme.lua")


-- TODO: edit popup to become eva thing
require("mystuff.volume_popup")

-- TODO: make cool switcher
-- local switcher = require("awesome-switcher")
-- switcher.settings.preview_box_bg = beautiful.reb_purple1 -- background color
-- switcher.settings.preview_box_border = beautiful.eva_green -- border-color
-- switcher.settings.cycle_raise_client = false
-- switcher.settings.preview_box_title_color = { 247 / 155, 186 / 255, 221 / 255, 1 }

local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")

-- set hotkey popup colors
hotkeys_popup.widget.add_group_rules("awesome", { color = beautiful.eva.reb_orange })
hotkeys_popup.widget.add_group_rules("client", { color = beautiful.eva.reb_orange })
hotkeys_popup.widget.add_group_rules("launcher", { color = beautiful.eva.reb_orange })
hotkeys_popup.widget.add_group_rules("media", { color = beautiful.eva.reb_orange })
hotkeys_popup.widget.add_group_rules("layout", { color = beautiful.eva.reb_orange })
hotkeys_popup.widget.add_group_rules("random", { color = beautiful.eva.reb_orange })
hotkeys_popup.widget.add_group_rules("screen", { color = beautiful.eva.reb_orange })
hotkeys_popup.widget.add_group_rules("tag", { color = beautiful.eva.reb_orange })

-- some widgets
local batteryarc = mystuff.battery_widget({
    show_current_level = true,
    arc_thickness = 2,
    size = beautiful.wibox,
    timeout = 10,
    --main stuff
    arc_main_color = beautiful.standart_on,
    main_background = beautiful.black,
    main_text = beautiful.white,
    -- chargin stuff
    charging_background = beautiful.black,
    charging_text = beautiful.white,
    arc_charging_color = beautiful.eva_green,
    get_bat_cmd = "cat /sys/class/power_supply/BAT1/capacity /sys/class/power_supply/BAT1/status"
  })

local bluetooth = wibox.widget {
    image  = beautiful.bluetooth_pic,
    widget = wibox.widget.imagebox
}
-- TODO: volumearc läuft die ganze Zeit im Hintergrund -> deswegen erstmal ausgemacht
-- local volumearc, volume_update = mystuff.volumearc({
-- 	main_color = beautiful.eva.reb_green,
-- 	mute_color = beautiful.eva.reb_orange,
-- 	get_volume_cmd = commands.GET_VOLUME,
-- 	inc_volume_cmd = commands.INC_VOLUME,
-- 	dec_volume_cmd = commands.DEC_VOLUME,
-- 	tog_volume_cmd = commands.TOG_VOLUME,
-- 	thickness = 12.5,
-- 	height = 25,
-- })


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

local terminal = "alacritty"
local editor = os.getenv("nvim") or "nvim"
-- local editor_cmd = terminal .. " -e " .. editor

local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.floating,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}

-- {{{ Wibar
-- Create a textclock widget
local mytextclock = wibox.widget.textclock(
	"<big>" .. mystuff.clock.get_current_day_of_week_in_kanji() .. "  %H時%M分</big>"
)

mytextclock:connect_signal("mouse::enter", function(self)
	self.format = "<big><span foreground='"
		.. beautiful.standart_on
		.. "' background='"
		.. beautiful.eva_green
		.. "'>"
		.. mystuff.clock.get_current_month_in_kanji()
		.. "%d日 </span>  "
		.. mystuff.clock.get_current_day_of_week_in_kanji()
		.. "  %H時%M分</big>"
end)

mytextclock:connect_signal("mouse::leave", function(self)
	self.format = "<big>" .. mystuff.clock.get_current_day_of_week_in_kanji() .. "  %H時%M分</big>"
end)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)


-- taglist
local tlist = function(s, styl)
	return awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
		style = styl,
		--- fontsize adden!!!
	})
end

-- normal wibar and
local sbar = function(s)
	return {
		layout = wibox.layout.align.horizontal,
		expand = "outside",
		nil,
		tlist(s, { spacing = 10 }),
	}
end

-- 集中 wibar
local nbar = function(s)
	return {
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			tlist(s),
		},
		mytextclock,
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
      -- TODO: volumearc fix
			-- volumearc,
			--mykeyboardlayout,
			-- TODO something with systray
			wibox.widget.systray(),
			batteryarc,
			--s.mylayoutbox,
		},
	}
end

local function set_wallpaper(s)
  -- if s == screen.primary then
    gears.wallpaper.fit(adir .. "evatheme/evaunit01.jpg", s)
  -- else
  --   gears.wallpaper.fit(adir .. "evatheme/eva_3.jpg", s)
  -- end
end

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag(numbers, s, awful.layout.layouts[1])

	-- Create the wibox
	s.mywibox = awful.wibar({
		position = "bottom",
		screen = s,
		visible = true,
		opacity = "1",
		height = beautiful.wibox,
	})
  -- s.mywibox:struts({bottom = 400})
	s.mywibox:setup(sbar(s))
end)



-- TODO: make cool pomodoro timer
-- local pom = require("mystuff.pomodoro")
--pomodoro wibox
-- local pomowibox = awful.wibox({ position = "top", screen = 1, height=4})
-- pomowibox.visible = false
-- local pomodoro = pom.new({
-- 	minutes 			= 2,
-- 	do_notify 			= true,
-- 	active_bg_color 	= beautiful.eva.eva_green,
-- 	paused_bg_color 	= beautiful.eva.reb_purple1,
-- 	fg_color			= {type = "linear", from = {0,0}, to = {pomowibox.width, 0}, stops = {{0, "#AECF96"},{0.5, "#88A175"},{1, "#FF5656"}}},
-- 	width 				= pomowibox.width,
-- 	height 				= pomowibox.height,
--
-- 	begin_callback = function()
--     awful.screen.connect_for_each_screen(function(s)
-- 			s.mywibox.visible = false
--     end)
-- 		pomowibox.visible = true
-- 	end,
--
-- 	finish_callback = function()
--     awful.screen.connect_for_each_screen(function(s)
-- 			s.mywibox.visible = true
--     end
--     )
-- 		pomowibox.visible = false
-- 	end})
-- pomowibox:set_widget(pomodoro)

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	-- TODO: add mymainmenu?
	-- awful.button({}, 3, function()
	-- 	mymainmenu:toggle()
	-- end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev),

	-- my mouse bindings
	awful.button({ modkey }, 4, awful.tag.viewnext),
	awful.button({ modkey }, 5, awful.tag.viewprev),
	awful.button({ modkey }, 2, function()
		awful.screen.focus_relative(1)
	end)
))
-- }}}

-- {{{ Key bindings
local globalkeys = gears.table.join(

  ------------------- AWESOMEWM BINDINGS --------------------------

	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),



  -------------------- TAG BINDINGS 1. ------------------------------

	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),



  -------------------- CLIENT BINDINGS ------------------------------

	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),
	awful.key({ "Mod1" }, "Tab", function()
		awful.util.spawn(cdir .. "/rofi/evaswitch/colorful_eva")
	end, { description = "change tabs", group = "client" }),



  ------------------ SCREEN BINDINGS -----------------------------------

	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),



  ---------------------- LAUNCHER BINDINGS ---------------------------

	awful.key({ modkey }, "c", function()
		awful.util.spawn("rofi -show run")
	end, { description = "run prompt", group = "launcher" }),
	awful.key({ modkey }, "d", function()
		awful.util.spawn(cdir .. "rofi/evaribbon/launcher.sh")
  end, { description = "run application prompt", group = "launcher" }),
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),



  ----------------------- LAYOUT BINDINGS -----------------------------

	awful.key({ modkey }, "i", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "u", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "u", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "i", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "u", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "i", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey, "Mod1" }, "i", function()
		awful.client.incwfact(0.05)
	end, { description = "increase client width factor", group = "layout" }),
	awful.key({ modkey, "Mod1" }, "u", function()
		awful.client.incwfact(-0.05)
	end, { description = "decrease client width factor", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),



	-- fancy keys for switching tags and monitors
	awful.key({ modkey }, "XF86AudioPlay", function()
		awful.screen.focus_relative(1)
	end, { description = "最高! focus next monitor", group = "layout" }),
	awful.key({ modkey }, "XF86AudioNext", function()
		awful.tag.viewnext()
	end, { description = "goto next tag", group = "layout" }),
	awful.key({ modkey }, "XF86AudioPrev", function()
		awful.tag.viewprev()
	end, { description = "goto previous tag", group = "layout" }),




	-------------------------------- MEDIA BINDINGS --------------------------
	awful.key({}, "Print", function()
		awful.util.spawn("flameshot gui")
	end, { description = "Screenshot", group = "media" }),
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn(commands.INC_VOLUME)

    -- emit signal for volume change
    -- make arcpopip if in normal mode and eva popup in 集中モード
    if screen.primary.mywibox.position == "bottom" then
      awesome.emit_signal("volume_change")
    else
      -- TODO: volumearc fix
      -- volume_update()
    end
	end, { description = "raise volume", group = "media" }),
	awful.key({}, "XF86AudioMute", function()
		awful.spawn(commands.TOG_VOLUME)
    if screen.primary.mywibox.position == "bottom" then
      awesome.emit_signal("volume_change")
    else
      -- volume_update()
    end
	end, { description = "mute", group = "media" }),
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn(commands.DEC_VOLUME)
    if screen.primary.mywibox.position == "bottom" then
      awesome.emit_signal("volume_change")
    else
		  -- volume_update()
    end
	end, { description = "lower volume", group = "media" }),
	awful.key({}, "XF86AudioPlay", function()
		awful.spawn(commands.TOG_PLAY)
	end, { description = "play/pause", group = "media" }),
	awful.key({}, "XF86AudioNext", function()
		awful.spawn(commands.MEDIA_NEXT)
	end, { description = "next", group = "media" }),
	awful.key({}, "XF86AudioPrev", function()
		awful.spawn(commands.MEDIA_PREV)
	end, { description = "previous", group = "media" }),
	awful.key({}, "XF86Tools", function()
		awful.spawn(commands.IDLE_MPV)
	end, { description = "run mpv", group = "media" }),
	awful.key({ modkey }, "XF86Tools", function()
		awful.spawn(commands.YT_MUSIC)
	end, { description = "run youtube music", group = "media" }),
  -- Brightness
   awful.key({ }, "XF86MonBrightnessDown", function ()
    awful.spawn.with_shell(commands.BRIGHT_DWN) end, {description="brightness down", group="media"}),
   awful.key({ }, "XF86MonBrightnessUp", function ()
    awful.spawn.with_shell(commands.BRIGHT_UP) end, {description="brightness up", group="media"}),




	----------------------------- RANDOM BINDINGS------------------------

	awful.key({ modkey, "Control" }, "s", function()
		awful.screen.connect_for_each_screen(function(s)
			if s.mywibox.position == "top" then
				s.mywibox.position = "bottom"
				beautiful.taglist_spacing = 10
				s.mywibox:setup(sbar(s))
			elseif s.mywibox.position == "bottom" then
				s.mywibox.position = "top"
				beautiful.taglist_spacing = 1
				s.mywibox:setup(nbar(s))
			end
		end)
	end, { description = "集中モード", group = "random" }),
	awful.key({ modkey, "Control" }, "c", function()
		awful.spawn(terminal .. " -e " .. editor .. " " .. awesome.conffile)
	end, { description = "edit rc.lua", group = "random" }),
	awful.key({ modkey}, "e", function()
		awful.spawn(terminal .. " -e ranger")
	end, { description = "edit rc.lua", group = "random" })
  -- TODO: Pomodoro timer
  -- awful.key({	modkey			}, "p", function () pomodoro:toggle() end),
  -- awful.key({	modkey, "Shift"	}, "p", function () pomodoro:finish() end)
)


local clientkeys = gears.table.join(
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey }, "q", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move client to other screen", group = "client" }),
	awful.key({ modkey }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
    if screen.primary.mywibox.position == "bottom" then
      c:struts({bottom = 40})
    end
		c:raise()
	end, { description = "(un)maximize", group = "client" }),
	awful.key({ modkey, "Control" }, "m", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = "(un)maximize vertically", group = "client" }),
	awful.key({ modkey, "Shift" }, "m", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = "(un)maximize horizontally", group = "client" })
)

-- create key bindings with numbers

for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end)
	)
end



----------------------- TAG HOTKEYS 2. ---------------------------------
hotkeys_popup.widget.add_hotkeys({ ["tag"] = { { modifiers = { modkey }, keys = { i = "focus tag i (0-9)" } } } })
hotkeys_popup.widget.add_hotkeys({
	["tag"] = { { modifiers = { modkey, "Control" }, keys = { i = "toggle tag i (0-9)" } } },
})
hotkeys_popup.widget.add_hotkeys({
	["tag"] = { { modifiers = { modkey, "Shift" }, keys = { i = "move client to tag i (0-9)" } } },
})
hotkeys_popup.widget.add_hotkeys({
	["tag"] = {
		{ modifiers = { modkey, "Control", "Shift" }, keys = { i = "toggle focused client on tag i (0-9)" } },
	},
})


------------- CLIENT MOUSE BUTTONS ------------------------

local clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end),

	-- my mouse bindings: modkey + wheel up/down changes tag and middle mouse click
	awful.button({ modkey }, 4, function(c)
		awful.tag.viewnext()
	end),
	awful.button({ modkey }, 5, function(c)
		awful.tag.viewprev()
	end),
	awful.button({ modkey }, 2, function(c)
		awful.screen.focus_relative(1)
	end)
)

root.keys(globalkeys)

awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"pavucontrol",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },

    -- Set Firefox to always map on the tag named "2" on screen 1.
     { rule = { name = "Google Podcasts - Brave" },
       properties = { screen = 1, tag = numbers[9], floating = false } },
     { rule = { class = "discord" },
       properties = { screen = 1, tag = numbers[9] } },
     { rule = { class = "obsidian" },
       properties = { screen = 1, tag = numbers[2] } },
     { rule = { name = "YouTube Music" },
       properties = { screen = 1, tag = numbers[8], floating = false } },
	{
		rule = { name = "YouTube" },
		except = { instance = "YouTube Music" },
		properties = { screen = 1, tag = numbers[8], floating = false },
	}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
-- }}}


-- autostart
awful.spawn.with_shell(
	'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;'
		.. 'xrdb -merge <<< "awesome.started:true";'
		-- list each of your autostart commands, followed by ; inside single quotes, followed by ..
		.. "dex --environment Awesome --autostart" -- hab das hier weggemacht, hat iwien icht geklappt --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
)

awful.spawn.with_shell(
	"pgrep -l picom || picom --experimental-backends --xrender-sync-fence --config " .. cdir .. "picom.conf"
) -- für logs --log-level info --log-file /home/afa/picom.log")



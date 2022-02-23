-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local mystuff = require("mystuff")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- TODO: replace path with relative path
beautiful.init("/home/afa/.config/awesome/evatheme/evatheme.lua")

local switcher = require("awesome-switcher")
switcher.settings.preview_box_bg = beautiful.reb_purple1 -- background color
switcher.settings.preview_box_border = beautiful.eva_green -- border-color
switcher.settings.cycle_raise_client = false
switcher.settings.preview_box_title_color = { 247 / 155, 186 / 255, 221 / 255, 1 }

-- Notification library
local naughty = require("naughty")
-- local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
hotkeys_popup.widget.add_group_rules("awesome", {color = beautiful.eva.reb_orange})
hotkeys_popup.widget.add_group_rules("client", {color = beautiful.eva.reb_orange})
hotkeys_popup.widget.add_group_rules("launcher", {color = beautiful.eva.reb_orange})
hotkeys_popup.widget.add_group_rules("media", {color = beautiful.eva.reb_orange})
hotkeys_popup.widget.add_group_rules("layout", {color = beautiful.eva.reb_orange})
hotkeys_popup.widget.add_group_rules("random", {color = beautiful.eva.reb_orange})
hotkeys_popup.widget.add_group_rules("screen", {color = beautiful.eva.reb_orange})
hotkeys_popup.widget.add_group_rules("tag", {color = beautiful.eva.reb_orange})
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
-- require("awful.hotkeys_popup.keys")

-- some widgets
local GET_VOLUME = "amixer -D default sget Master"
local INC_VOLUME = "amixer -q -D default sset Master 2%+"
local DEC_VOLUME = "amixer -q -D default sset Master 2%-"
local TOG_VOLUME = "amixer -q -D default sset Master toggle"
local volumearc, volume_update = mystuff.volumearc({
	main_color = beautiful.eva_green,
	mute_color = beautiful.standart_on,
	get_volume_cmd = GET_VOLUME,
	inc_volume_cmd = INC_VOLUME,
	dec_volume_cmd = DEC_VOLUME,
	tog_volume_cmd = TOG_VOLUME,
	thickness = 12.5,
	height = 25,
})

-- numbers for the taglist
--local numbers = { "壹", "貳", "參", "肆", "伍", "陸", "漆", "捌", "玖" }
-- local numbers = { "壱", "弐", "参", "四", "伍", "六", "七", "八", "九" }
local numbers = { "壱", "弐", "参", "肆", "伍", "陸", "漆", "捌", "玖" }

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

-- This is used later as the default terminal and editor to run.
local terminal = "alacritty"
local editor = os.getenv("nvim") or "nvim"
-- local editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
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
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
-- local myawesomemenu = {
-- 	{
-- 		"hotkeys",
-- 		function()
-- 			hotkeys_popup.show_help(nil, awful.screen.focused())
-- 		end,
-- 	},
-- 	{ "manual", terminal .. " -e man awesome" },
-- 	{ "edit config", editor_cmd .. " " .. awesome.conffile },
-- 	{ "restart", awesome.restart },
-- 	{
-- 		"quit",
-- 		function()
-- 			awesome.quit()
-- 		end,
-- 	},
-- }
--[[ was unused
local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
			     menu = mymainmenu })

-- Menubar configuration

menubar.utils.terminal = terminal -- Set the terminal for applications that require it

--]]
-- Keyboard map indicator and switcher
--mykeyboardlayout = awful.widget.keyboardlayout()

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

local tlist = function(s, styl)
	return 	-- Create a taglist widget
awful.widget.taglist({
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
			volumearc,
			--mykeyboardlayout,
			-- TODO something with systray
			wibox.widget.systray(),
			--s.mylayoutbox,
		},
	}
end

--[[local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

]]
--

local function set_wallpaper(s)
	-- TODO: copy images to awesome path and replace with relative path
	awful.spawn.with_shell(
		"feh --bg-fill $HOME/.config/awesome/evatheme/evaunit01.jpg --bg-max $HOME/SynologyDrive/BG/tate/eva_3.jpg"
	)
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
--screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag(numbers, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	--[[s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    --]]

	-- Create a tasklist widget
	--[[s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        opacity = 0.5
    }--]]

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s, visible = true, opacity = "1", height = beautiful.wibox })

	-- Add widgets to the wibox

	-- s.mywibox.visible = false

	s.mywibox:setup(nbar(s))
end)
-- }}}

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
	-- Random
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
	-- change clients with mod + mouse
	-- TODO: replace with relative path

	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	-- awful.key({ modkey }, "w", function()
	-- 	mymainmenu:show()
	-- end, { description = "show main menu", group = "awesome" }),
	--

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),

	-- Standard program
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	-- layout manipulation
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

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),
	--

	-- Tab switching

	awful.key({ "Mod1" }, "Tab", function()
		-- TODO: replace with relative path
		awful.util.spawn("/home/afa/.config/rofi/evaswitch/colorful_eva")
	end, { description = "change tabs", group = "client" }),

	-- awful.key({ "Mod1",           }, "Tab",
	--   function ()
	--       switcher.switch( 1, "Mod1", "Alt_L", "Shift", "Tab")
	--   end),
	--
	-- awful.key({ "Mod1", "Shift"   }, "Tab",
	--   function ()
	--       switcher.switch(-1, "Mod1", "Alt_L", "Shift", "Tab")
	--   end),

	-- Prompt

	awful.key({ modkey }, "c", function()
		awful.util.spawn("rofi -show run")
	end, { description = "run prompt", group = "launcher" }),

	-- TODO: replace with relative path
	awful.key({ modkey }, "d", function()
		awful.util.spawn("/home/afa/.config/rofi/evaribbon/launcher.sh")
	end, { description = "run application prompt", group = "launcher" }),

	awful.key({ modkey }, "x", function()
		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, { description = "lua execute prompt", group = "awesome" }),

	--[[ Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
    --]]

	-- Brightness
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn.with_shell("test $(xbacklight -get) -lt 10 && xbacklight -1 || xbacklight -5")
	end, { description = "brightness down", group = "media" }),
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn.with_shell("test $(xbacklight -get) -lt 10 && xbacklight +1 || xbacklight +5")
	end, { description = "brightness up", group = "media" }),

	-- Screenshot
	awful.key({}, "Print", function()
		awful.util.spawn("flameshot gui")
	end, { description = "Screenshot", group = "media" }),

	-- Volume
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.spawn(INC_VOLUME)
		volume_update()
	end, { description = "raise volume", group = "media" }),
	awful.key({}, "XF86AudioMute", function()
		awful.spawn(TOG_VOLUME)
		volume_update()
	end, { description = "mute", group = "media" }),
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.spawn(DEC_VOLUME)
		volume_update()
	end, { description = "lower volume", group = "media" }),

	-- music control
	awful.key({}, "XF86AudioPlay", function()
		awful.spawn("playerctl play-pause")
	end, { description = "play/pause", group = "media" }),
	awful.key({}, "XF86AudioNext", function()
		awful.spawn("playerctl next")
	end, { description = "next", group = "media" }),
	awful.key({}, "XF86AudioPrev", function()
		awful.spawn("playerctl previous")
	end, { description = "previous", group = "media" }),
	awful.key({}, "XF86Tools", function()
		awful.spawn("mpv --player-operation-mode=pseudo-gui")
	end, { description = "run mpv", group = "media" }),
	awful.key({ modkey }, "XF86Tools", function()
		awful.spawn("brave --profile-directory=Default --app-id=cinhimbnkkaeohfgghhklpknlkffjgod")
	end, { description = "run youtube music", group = "media" }),

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

	-- random stuff
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
	end, { description = "edit rc.lua", group = "random" })
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

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
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
hotkeys_popup.widget.add_hotkeys({["tag"] = {{modifiers = {modkey}, keys ={i = "focus tag i (0-9)"}}}})
hotkeys_popup.widget.add_hotkeys({["tag"] = {{modifiers = {modkey, "Control"}, keys ={i = "toggle tag i (0-9)"}}}})
hotkeys_popup.widget.add_hotkeys({["tag"] = {{modifiers = {modkey, "Shift"}, keys ={i = "move client to tag i (0-9)"}}}})
hotkeys_popup.widget.add_hotkeys({["tag"] = {{modifiers = {modkey, "Control", "Shift"}, keys ={i = "toggle focused client on tag i (0-9)"}}}})
-- hotkeys_popup.widget.add_group_rules("screem", {color = beautiful.eva.purple1})
-- , { description = "toggle focused client on tag i"  .. i, group = "tag" }

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
	-- changes screen focus
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

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
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
				"DTA", -- Firefox addon DownThemAll.
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
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },

	-- Set Firefox to always map on the tag named "2" on screen 1.
	{
		rule = { name = "Google Podcasts - Brave" },
		properties = { screen = 2, tag = numbers[9], floating = false },
	},
	{ rule = { class = "discord" }, properties = { screen = 1, tag = numbers[9] } },
	{ rule = { class = "obsidian" }, properties = { screen = 1, tag = numbers[2] } },
	{
		rule = { name = "YouTube" },
		except = { instance = "YouTube Music" },
		properties = { screen = 1, tag = numbers[8], floating = false },
	},
	{ rule = { name = "YouTube Music" }, properties = { screen = 2, tag = numbers[9], floating = false } },
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

awful.spawn.with_shell(
	'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;'
		.. 'xrdb -merge <<< "awesome.started:true";'
		-- list each of your autostart commands, followed by ; inside single quotes, followed by ..
		.. "dex --environment Awesome --autostart" -- hab das hier weggemacht, hat iwien icht geklappt --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
)

--autostart apps
-- awful.spawn.with_shell("pgrep -l cloud || synology-drive")
-- TODO: replace with relative path
awful.spawn.with_shell(
	"pgrep -l picom || picom --experimental-backends --xrender-sync-fence --config /home/afa/.config/picom.conf"
) -- für logs --log-level info --log-file /home/afa/picom.log")
--awful.spawn.with_shell("nitrogen --random /home/afa/BG")
--awful.spawn.with_shell("nm-applet")
--awful.spawn.with_shell("volumeicon")
--awful.spawn.with_shell("fcitx")

--awful.spawn.once("picom")
--awful.spawn.once("nitrogen --restore --random")
--awful.spawn.once("nm-applet")
--awful.spawn.once("volumeicon")
--awful.spawn.once("setxkbmap de -variant nodeadkeys")

-------------------------------------------------
-- Battery Arc Widget for Awesome Window Manager
-- Shows the battery level of the laptop
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/batteryarc-widget

-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

local HOME = os.getenv("HOME")
local WIDGET_DIR = HOME .. '/.config/awesome/mystuff'

local widget = {}

local function worker(user_args)

    local args = user_args or {}

    local font = args.font or beautiful.font
    local arc_thickness = args.arc_thickness or 2
    local show_current_level = args.show_current_level or false
    local size = args.size or beautiful.wibox
    local timeout = args.timeout or 5
    local show_notification_mode = args.show_notification_mode or 'on_hover' -- on_hover / on_click

    local main_background = args.main_background
    local main_text = args.main_text
    local arc_main_color = args.arc_main_color

    local update_script = args.update_script or HOME .. "/.config/awesome/myprogs/batupdate"
    local get_bat_cmd = args.get_bat_cmd or '/home/afa/.config/awesome/myprogs/batupdate'

    local charging_background = args.charging_background or '#43a047'
    local charging_text = args.charging_text or "#FFFFFF"
    local arc_charging_color = args.arc_charging_color or '#43a047'
    
    local bg_color = args.bg_color or '#ffffff11'
    local low_level_color = args.low_level_color or '#e53935'
    local medium_level_color = args.medium_level_color or '#c0ca33'

    local warning_msg_title = args.warning_msg_title or 'Houston, we have a problem'
    local warning_msg_text = args.warning_msg_text or 'Battery is dying'
    local warning_msg_position = args.warning_msg_position or 'bottom_right'
    local warning_msg_icon = args.warning_msg_icon or WIDGET_DIR .. '/spaceman.jpg'
    local enable_battery_warning = args.enable_battery_warning
    if enable_battery_warning == nil then
        enable_battery_warning = true
    end

    local text = wibox.widget {
        align = 'center',
        valign = 'center',
        widget = wibox.widget.textbox
    }

    local text_with_background = wibox.container.background(text)

    local batteryarc = wibox.widget {
        align = 'center',
        valign = 'center',
        text_with_background,
        max_value = 100,
        rounded_edge = true,
        thickness = arc_thickness,
        start_angle = 4.71238898, -- 2pi*3/4
        forced_height = size,
        forced_width = size,
        bg = bg_color,
        paddings = 1,
        widget = wibox.container.arcchart
    }

    local last_battery_check = os.time()

    --[[ Show warning notification ]]
    local function show_battery_warning()
        naughty.notify {
            icon = warning_msg_icon,
            icon_size = 100,
            text = warning_msg_text,
            title = warning_msg_title,
            timeout = 25, -- show the warning for a longer time
            hover_timeout = 0.5,
            position = warning_msg_position,
            bg = "#F06060",
            fg = "#EEE9EF",
            width = 300,
        }
    end

    function readfile(file)
        local f = assert(io.open(file, "rb"))
        local content = f:read()
        f:close()
        return content
    end

    local function kanji(charge)
        kans = {"零","壹", "貳", "參", "肆", "伍", "陸", "漆", "捌", "玖", "佰"}
        return kans[math.floor(charge / 10)]
    end

    local update_widget = function(widget, stdout, _, _, _)
        lines = {}
        for s in stdout:gmatch("[^\r\n]+") do
            table.insert(lines, s)
        end
        
        local charge = tonumber(lines[1])
        local status = lines[2]
        
        if charge == 100 then widget.value = 100 else widget.value =  (charge % 10) * 10 end

        if status == 'Charging' then
            text_with_background.bg = charging_background
            text_with_background.fg = charging_text
        else
            text_with_background.bg = main_background
            text_with_background.fg = main_text
        end
        
        if show_current_level == true then
            --- if battery is fully charged (100) there is not enough place for three digits, so we don't show any text
            text.font = beautiful.font .. " 12"
            text.text = kanji(charge+10)
        else
            text.text = ''
        end
        --naughty.notify({text = kanji(charge+10)})

        if status == 'Charging' then
            widget.colors = { arc_charging_color }
            return
        else 
            widget.colors = { arc_main_color }
            return
        end

        if charge < 25 then
            widget.colors = { low_level_color }
            if enable_battery_warning and status ~= 'Charging' and os.difftime(os.time(), last_battery_check) > 300 then
                -- if 5 minutes have elapsed since the last warning
                last_battery_check = os.time()

                show_battery_warning()
            end
        elseif charge > 25 and charge < 50 then
            widget.colors = { medium_level_color }
        end
    end

    
    -- Popup with battery info
    local notification
    local function show_battery_status()
		awful.spawn.easy_async([[bash -c '/home/afa/.config/awesome/myprogs/batupdate']],
        function(stdout, _, _, _)
            naughty.destroy(notification)
            notification = naughty.notify {
                text = stdout,
                title = "Battery ステータス",
                timeout = 5,
                width = 200,
            }
        end)
    end
    
    if show_notification_mode == 'on_hover' then
        batteryarc:connect_signal("mouse::enter", function() show_battery_status() end)
        batteryarc:connect_signal("mouse::leave", function() naughty.destroy(notification) end)
    elseif show_notification_mode == 'on_click' then
        batteryarc:connect_signal('button::press', function(_, _, _, button)
            if (button == 1) then show_battery_status() end
        end)
    end

    watch(get_bat_cmd, 1, update_widget, batteryarc)
    
    return batteryarc

end

return setmetatable(widget, { __call = function(_, ...) return worker(...) end })

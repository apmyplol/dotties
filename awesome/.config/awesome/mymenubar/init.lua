---------------------------------------------------------------------------
--- Menubar module, which aims to provide a freedesktop menu alternative
--
-- List of menubar keybindings:
-- ---
--
--  *  "Left"  | "C-j" select an item on the left
--  *  "Right" | "C-k" select an item on the right
--  *  "Backspace"     exit the current category if we are in any
--  *  "Escape"        exit the current directory or exit menubar
--  *  "Home"          select the first item
--  *  "End"           select the last
--  *  "Return"        execute the entry
--  *  "C-Return"      execute the command with awful.spawn
--  *  "C-M-Return"    execute the command in a terminal
--
-- @author Alexander Yakushev &lt;yakushev.alex@gmail.com&gt;
-- @copyright 2011-2012 Alexander Yakushev
-- @module menubar
---------------------------------------------------------------------------

-- Grab environment we need
local capi = {
    client = client,
    mouse = mouse,
    screen = screen,
}
local awful = require 'awful'
local gfs = require 'gears.filesystem'
local common = require 'awful.widget.common'
local theme = require 'beautiful'
local wibox = require 'wibox'
local gcolor = require 'gears.color'
local gstring = require 'gears.string'
local gdebug = require 'gears.debug'
local gears = require "gears"
local naughty = require"naughty"


local beautiful = require 'beautiful'
local dpi = beautiful.xresources.apply_dpi
local function get_screen(s)
    return s and capi.screen[s]
end

--- Menubar normal text color.
-- @beautiful beautiful.menubar_fg_normal

--- Menubar normal background color.
-- @beautiful beautiful.menubar_bg_normal

--- Menubar border width.
-- @beautiful beautiful.menubar_border_width
-- @tparam[opt=0] number menubar_border_width

--- Menubar border color.
-- @beautiful beautiful.menubar_border_color

--- Menubar selected item text color.
-- @beautiful beautiful.menubar_fg_normal

--- Menubar selected item background color.
-- @beautiful beautiful.menubar_bg_normal

-- menubar
local menubar = { menu_entries = {} }
menubar.menu_gen = require 'menubar.menu_gen'
menubar.utils = require 'menubar.utils'

-- Options section

--- When true the .desktop files will be reparsed only when the
-- extension is initialized. Use this if menubar takes much time to
-- open.
-- @tfield[opt=true] boolean cache_entries
menubar.cache_entries = true

--- When true the categories will be shown alongside application
-- entries.
-- @tfield[opt=true] boolean show_categories
menubar.show_categories = false

--- Specifies the geometry of the menubar. This is a table with the keys
-- x, y, width and height. Missing values are replaced via the screen's
-- geometry. However, missing height is replaced by the font size.
-- @table geometry
-- @tfield number geometry.x A forced horizontal position
-- @tfield number geometry.y A forced vertical position
-- @tfield number geometry.width A forced width
-- @tfield number geometry.height A forced height
menubar.geometry = { width = nil, height = nil, x = nil, y = nil }

--- Width of blank space left in the right side.
-- @tfield number right_margin
menubar.right_margin = theme.xresources.apply_dpi(8)

--- Label used for "Next page", default "▶▶".
-- @tfield[opt="▶▶"] string right_label
menubar.right_label = '▶▶'

--- Label used for "Previous page", default "◀◀".
-- @tfield[opt="◀◀"] string left_label
menubar.left_label = '◀◀'

-- awful.widget.common.list_update adds three times a margin of dpi(4)
-- for each item:
-- @tfield number list_interspace

--- Allows user to specify custom parameters for prompt.run function
-- (like colors).
-- @see awful.prompt

menubar.prompt_args = { bg_cursor = '#00FF00', prompt = '初号機🙆:' }
menubar.textargs = { forced_height = 20, align = 'center'}
menubar.bgargs = { bg = "#775899", fg = '#00FF00', border_width = 10, border_color = nil}

-- Private section
local current_item = 1
local previous_item = nil
local current_category = nil
local shownitems = nil
local instance = nil

menubar.grid = {
    rows = 5,
    columns = 4,
    height = dpi(600),
    hgap = dpi(10),
    width = dpi(800),
    offsetx = dpi(200),
}

local img_siz = math.min(menubar.grid.height / menubar.grid.rows / 2, menubar.grid.width / menubar.grid.columns / 2)
local marg_siz = (menubar.grid.width / menubar.grid.columns - img_siz) / 2


local my_widget_template = {
    {
        {
            {
                id = 'icon_role',
                widget = wibox.widget.imagebox,
                -- clip_shape = gears.shape.circle,
                forced_height = img_siz,
                forced_width = img_siz,
            },
            id = 'icon_margin_role',
            left = marg_siz,
            right = marg_siz,
            top = menubar.grid.hgap, --height / lines / 4,
            bottom = menubar.grid.hgap * 2,
            forced_height = img_siz + 3 * menubar.grid.hgap,
            widget = wibox.container.margin,
        },
        {
            {
                id = 'text_role',
                align = 'center',
                widget = wibox.widget.textbox,
            },
            id = 'text_margin_role',
            fill_space = false,
            layout = wibox.layout.fixed.vertical,
        },
        -- {
        --     widget = wibox.widget.separator,
        --     orientation = 'horizontal',
        --     thickness = 5,
        -- },
        layout = wibox.layout.fixed.vertical,
    },
    forced_height = menubar.grid.height / menubar.grid.rows,
    forced_width = menubar.grid.width / menubar.grid.columns,
    id = 'background_role',
    widget = wibox.container.background,
}

menubar.geometry = {
    x = dpi(500),
    y = dpi(900),
    height = menubar.grid.height + menubar.textargs.forced_height,
    width = menubar.grid.width,
}

local common_args = {
    w = wibox.widget {
        layout = wibox.layout.grid,
        orientation = 'horizontal',
        forced_num_cols = menubar.grid.columns,
        forced_num_rows = menubar.grid.rows,
        forced_height = menubar.grid.height,
        forced_width = menubar.grid.width,
        homogeneous = true,
        expand = false,
    },
    data = setmetatable({}, { __mode = 'kv' }),
}

--- Wrap the text with the color span tag.
-- @param s The text.
-- @param c The desired text color.
-- @return the text wrapped in a span tag.
local function colortext(s, c)
    return '<span color=\'' .. gcolor.ensure_pango_color(c) .. '\'>' .. s .. '</span>'
end

--- Get how the menu item should be displayed.
-- @param o The menu item.
-- @return item name, item background color, background image, item icon.
local function label(o)
    local fg_color = theme.menubar_fg_normal or theme.menu_fg_normal or theme.fg_normal
    local bg_color = theme.menubar_bg_normal or theme.menu_bg_normal or theme.bg_normal
    if o.focused then
        fg_color = theme.menubar_fg_focus or theme.menu_fg_focus or theme.fg_focus
        bg_color = theme.menubar_bg_focus or theme.menu_bg_focus or theme.bg_focus
    end
    return colortext(gstring.xml_escape(o.name), fg_color), bg_color, nil, o.icon
end

local function load_count_table()
    if instance.count_table then
        return instance.count_table
    end
    instance.count_table = {}
    local count_file_name = gfs.get_cache_dir() .. '/menu_count_file'
    local count_file = io.open(count_file_name, 'r')
    if count_file then
        for line in count_file:lines() do
            local name, count = string.match(line, '([^;]+);([^;]+)')
            if name ~= nil and count ~= nil then
                instance.count_table[name] = count
            end
        end
        count_file:close()
    end
    return instance.count_table
end

local function write_count_table(count_table)
    count_table = count_table or instance.count_table
    local count_file_name = gfs.get_cache_dir() .. '/menu_count_file'
    local count_file = assert(io.open(count_file_name, 'w'))
    for name, count in pairs(count_table) do
        local str = string.format('%s;%d\n', name, count)
        count_file:write(str)
    end
    count_file:close()
end

--- Perform an action for the given menu item.
-- @param o The menu item.
-- @return if the function processed the callback, new awful.prompt command, new awful.prompt prompt text.
local function perform_action(o)
    if not o then
        return
    end
    if o.key then
        current_category = o.key
        local new_prompt = shownitems[current_item].name .. ': '
        previous_item = current_item
        current_item = 1
        return true, '', new_prompt
    elseif shownitems[current_item].cmdline then
        awful.spawn(shownitems[current_item].cmdline)
        -- load count_table from cache file
        local count_table = load_count_table()
        -- increase count
        local curname = shownitems[current_item].name
        count_table[curname] = (count_table[curname] or 0) + 1
        -- write updated count table to cache file
        write_count_table(count_table)
        -- Let awful.prompt execute dummy exec_callback and
        -- done_callback to stop the keygrabber properly.
        return false
    end
end

-- Cut item list to return only current page.
-- @tparam table all_items All items list.
-- @tparam str query Search query.
-- @tparam number|screen scr Screen
-- @return table List of items for current page.
local function get_current_page(all_items, query, scr)
    local current_page = {}
    local first_page_len = menubar.grid.columns * menubar.grid.rows - 1
    local page_len = menubar.grid.columns * menubar.grid.rows - 2
    local pages = (#all_items - #all_items % page_len) / page_len
    local left_label = { name = menubar.left_label, icon = nil }
    local right_label = { name = menubar.right_label, icon = nil }
    -- if there are no items to display (i.e. search without results), return nothing
    if #all_items == 0 then
        return {}
    end


    -- current item is on first page
    if current_item <= first_page_len then
        current_page = table.move(all_items, 1, first_page_len, 1, {})
        if #all_items > first_page_len then
            table.insert(current_page, right_label)
        end

        -- current item is on last page
    elseif current_item >= page_len * (pages - 1) + first_page_len - 1 then
        current_page = table.move(all_items, page_len * (pages - 1) + first_page_len - 1, #all_items, 1, {})
        table.insert(current_page, 1, left_label)

        -- else current item is between first and last page
    else
        local curpage = ((current_item - first_page_len - 1) - ((current_item - first_page_len - 1) % page_len))
                / page_len
            + 1
        -- higher and lower bounds for the page to display
        local lower_b = first_page_len + (curpage - 1) * page_len + 1
        local higher_b = first_page_len + curpage * page_len
        current_page = table.move(all_items, lower_b, higher_b, 1, {})
        table.insert(current_page, 1, left_label)
        table.insert(current_page, #current_page + 1, right_label)
    end

    return current_page
end

--- Update the menubar according to the command entered by user.
-- @tparam number|screen scr Screen
local function menulist_update(scr)
    -- require("naughty").notify({text = gears.debug.dump_return(common_args.w:get_all_children())})
    local query = instance.query or ''
    shownitems = {}
    local pattern = gstring.query_to_pattern(query)

    -- All entries are added to a list that will be sorted
    -- according to the priority (first) and weight (second) of its
    -- entries.
    -- If categories are used in the menu, we add the entries matching
    -- the current query with high priority as to ensure they are
    -- displayed first. Afterwards the non-category entries are added.
    -- All entries are weighted according to the number of times they
    -- have been executed previously (stored in count_table).
    local count_table = load_count_table()
    local command_list = {}

    local PRIO_NONE = 0
    local PRIO_CATEGORY_MATCH = 2

    -- Add the categories
    if menubar.show_categories then
        for _, v in pairs(menubar.menu_gen.all_categories) do
            v.focused = false
            if not current_category and v.use then
                -- check if current query matches a category
                if string.match(v.name, pattern) then
                    v.weight = 0
                    v.prio = PRIO_CATEGORY_MATCH

                    -- get use count from count_table if present
                    -- and use it as weight
                    if string.len(pattern) > 0 and count_table[v.name] ~= nil then
                        v.weight = tonumber(count_table[v.name])
                    end

                    -- check for prefix match
                    if string.match(v.name, '^' .. pattern) then
                        -- increase default priority
                        v.prio = PRIO_CATEGORY_MATCH + 1
                    else
                        v.prio = PRIO_CATEGORY_MATCH
                    end

                    table.insert(command_list, v)
                end
            end
        end
    end

    -- Add the applications according to their name and cmdline
    for _, v in ipairs(menubar.menu_entries) do
        v.focused = false
        if not current_category or v.category == current_category then
            -- check if the query matches either the name or the commandline
            -- of some entry
            if string.match(v.name, pattern) or string.match(v.cmdline, pattern) then
                v.weight = 0
                v.prio = PRIO_NONE

                -- get use count from count_table if present
                -- and use it as weight
                if string.len(pattern) > 0 and count_table[v.name] ~= nil then
                    v.weight = tonumber(count_table[v.name])
                end

                -- check for prefix match
                if string.match(v.name, '^' .. pattern) or string.match(v.cmdline, '^' .. pattern) then
                    -- increase default priority
                    v.prio = PRIO_NONE + 1
                else
                    v.prio = PRIO_NONE
                end

                table.insert(command_list, v)
            end
        end
    end



    local function compare_counts(a, b)
        if a.prio == b.prio then
            return a.weight > b.weight
        end
        return a.prio > b.prio
    end

    -- sort command_list by weight (highest first)
    table.sort(command_list, compare_counts)
    -- copy into showitems
    shownitems = command_list

    if #shownitems > 0 then
        -- Insert a run item value as the last choice
        -- table.insert(shownitems, { name = "Exec: " .. query, cmdline = query, icon = nil })

        if current_item > #shownitems then
            current_item = #shownitems
        end
        shownitems[current_item].focused = true
    else
        table.insert(shownitems, { name = '', cmdline = query, icon = nil })
    end

    common.list_update(
        common_args.w,
        nil,
        label,
        common_args.data,
        get_current_page(shownitems, query, scr),
        { widget_template = my_widget_template }
    )
end

--- Refresh menubar's cache by reloading .desktop files.
-- @tparam[opt] screen scr Screen.
function menubar.refresh(scr)
    scr = get_screen(scr or awful.screen.focused() or 1)
    menubar.menu_gen.generate(function(entries)
        menubar.menu_entries = entries
        if instance then
            menulist_update(scr)
        end
    end)
end

--- Awful.prompt keypressed callback to be used when the user presses a key.
-- @param mod Table of key combination modifiers (Control, Shift).
-- @param key The key that was pressed.
-- @param comm The current command in the prompt.
-- @return if the function processed the callback, new awful.prompt command, new awful.prompt prompt text.
local function prompt_keypressed_callback(mod, key, comm)
    if key == 'Left' or (mod.Control and key == 'j') then
        current_item = math.max(current_item - 1, 1)
        return true
    elseif key == 'Right' or (mod.Control and key == 'k') then
        current_item = current_item + 1
        return true
    elseif key == 'BackSpace' then
        if comm == '' and current_category then
            current_category = nil
            current_item = previous_item
            return true, nil, 'Run: '
        end
    elseif key == 'Escape' then
        if current_category then
            current_category = nil
            current_item = previous_item
            return true, nil, 'Run: '
        end
    elseif key == 'Home' then
        current_item = 1
        return true
    elseif key == 'End' then
        current_item = #shownitems
        return true
    elseif key == 'Return' or key == 'KP_Enter' then
        if mod.Control then
            current_item = #shownitems
            if mod.Mod1 then
                -- add a terminal to the cmdline
                shownitems[current_item].cmdline = menubar.utils.terminal .. ' -e ' .. shownitems[current_item].cmdline
            end
        end
        return perform_action(shownitems[current_item])
    end
    return false
end

--- Show the menubar on the given screen.
-- @param[opt] scr Screen.
function menubar.show(scr)
    scr = get_screen(scr or awful.screen.focused() or 1)
    local fg_color = menubar.bgargs.fg
    local bg_color = menubar.bgargs.bg
    local border_width = menubar.bgargs.border_width
    local border_color = menubar.bgargs.border_color

    if not instance then
        -- Add to each category the name of its key in all_categories
        for k, v in pairs(menubar.menu_gen.all_categories) do
            v.key = k
        end

        if menubar.cache_entries then
            menubar.refresh(scr)
        end

        instance = {
            wibox = wibox {
                ontop = true,
                bg = bg_color,
                fg = fg_color,
                border_width = border_width,
                border_color = border_color,
                layout = wibox.layout.background,
            },
            widget = common_args.w,
            prompt = awful.widget.prompt { prompt = 'bla' },
            query = nil,
            count_table = nil,
        }
        local layout = wibox.layout.fixed.vertical()
        layout:add(instance.prompt)
        layout:add(instance.widget)
        -- layout:add(wibox.container.scroll.vertical(instance.widget))
        instance.wibox:set_widget(layout)
    end

    if instance.wibox.visible then -- Menu already shown, exit
        return
    elseif not menubar.cache_entries then
        menubar.refresh(scr)
    end

    -- set textbox properties
    for key, value in pairs(menubar.textargs) do
        instance.prompt.widget[key] = value
    end

    -- require("naughty").notify({text = gears.debug.dump_return(instance.prompt.widget)})

    instance.wibox:geometry(menubar.geometry)

    current_item = 1
    current_category = nil
    menulist_update(scr)

    local prompt_args = menubar.prompt_args or {}

    awful.prompt.run(setmetatable({
        textbox = instance.prompt.widget,
        completion_callback = awful.completion.shell,
        history_path = gfs.get_cache_dir() .. '/history_menu',
        done_callback = menubar.hide,
        changed_callback = function(query)
            instance.query = query
            menulist_update(scr)
        end,
        keypressed_callback = prompt_keypressed_callback,
    }, { __index = prompt_args }))

    instance.wibox.visible = true
end

--- Hide the menubar.
function menubar.hide()
    if instance then
        instance.wibox.visible = false
        instance.query = nil
    end
end

--- Get a menubar wibox.
-- @tparam[opt] screen scr Screen.
-- @return menubar wibox.
-- @deprecated get
function menubar.get(scr)
    gdebug.deprecate('Use menubar.show() instead', { deprecated_in = 5 })
    menubar.refresh(scr)
    -- Add to each category the name of its key in all_categories
    for k, v in pairs(menubar.menu_gen.all_categories) do
        v.key = k
    end
    return common_args.w
end


--[[ local applist = require("mystuff.applist_backend"){get_current_page = get_current_page, labelfunc = label,widget_container = common_args.w,widget_template = my_widget_template } ]]
--[[ naughty.notify({text = gears.debug.dump_return(applist)}) ]]

local mt = {}
function mt.__call(_, ...)
    return menubar.get(...)
end

return setmetatable(menubar, mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

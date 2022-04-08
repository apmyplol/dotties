local capi = {
    client = client,
    mouse = mouse,
    screen = screen,
}
local awful = require "awful"
local gstring = require "gears.string"
local gfs = require "gears.filesystem"
local common = require "awful.widget.common"
local wibox = require "wibox"

local function get_screen(s)
    return s and capi.screen[s]
end

local menubar = { menu_entries = {} }
local menubar_gen = require "menubar.menu_gen"

local privinstance = {
    current_category = nil,
    current_item = nil,
    count_table = nil,
}

menubar.instance = {
    widget_template = nil,
    get_current_page = nil,
    labelfunc = nil,
    widget_container = nil,
    data = setmetatable({}, { __mode = "kv" }),
}

-- function that loads the priority list for application that is based on how often
-- the application have been run
-- returns table
local function load_count_table()
    if privinstance.count_table then
        return privinstance.count_table
    end
    privinstance.count_table = {}
    local count_file_name = gfs.get_cache_dir() .. "/menu_count_file"
    local count_file = io.open(count_file_name, "r")
    if count_file then
        for line in count_file:lines() do
            local name, count = string.match(line, "([^;]+);([^;]+)")
            if name ~= nil and count ~= nil then
                privinstance.count_table[name] = count
            end
        end
        count_file:close()
    end
    return privinstance.count_table
end

-- function that updates the menubar depending on the query
-- `scr`: screen
-- `queryinp`: the query that is inputted
function menubar:update(scr, queryinp)
    -- require("naughty").notify({text = gears.debug.dump_return(common_args.w:get_all_children())})
    local query = queryinp or ""
    local shownitems = {}
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
    if self.show_categories then
        for _, v in pairs(menubar_gen.all_categories) do
            v.focused = false
            if not privinstance.current_category and v.use then
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
                    if string.match(v.name, "^" .. pattern) then
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
        if not privinstance.current_category or v.category == privinstance.current_category then
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
                if string.match(v.name, "^" .. pattern) or string.match(v.cmdline, "^" .. pattern) then
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

        if privinstance.current_item > #shownitems then
            privinstance.current_item = #shownitems
        end
        shownitems[privinstance.current_item].focused = true
    else
        table.insert(shownitems, { name = "", cmdline = query, icon = nil })
    end

    common.list_update(
        menubar.instance.widget_container,
        nil,
        menubar.instance.labelfunc,
        menubar.instance.data,
        menubar.instance.get_current_page(shownitems, query, scr),
        { widget_template = menubar.instance.widget_template }
    )
end

--- Refresh menubar's cache by reloading .desktop files.
-- @tparam[opt] screen scr Screen.
function menubar.refresh(scr)
    scr = get_screen(scr or awful.screen.focused() or 1)
    menubar_gen.generate(function(entries)
        menubar.menu_entries = entries
        if menubar.instance then
            menubar.update(scr)
        end
    end)
end

--- Get a menubar wibox.
-- @tparam[opt] screen scr Screen.
-- @return menubar wibox.
-- @deprecated get
function menubar.get(scr)
    menubar.refresh(scr)
    -- Add to each category the name of its key in all_categories
    for k, v in pairs(menubar.menu_gen.all_categories) do
        v.key = k
    end
    return menubar.instance.widget_container
end

applist.meta = {
  __index = {get_current_page = nil, labelfunc = nil, widget_container = nil, widget_template = nil}
}

return function(table)
  setmetatable(table, {
    -- function has the following arguments:
    -- `get_current_page`: function that returns a list of widgets that should be displayed,
    -- based on all items(widgets), a query and a screen (can use the global current_item)
    --
    -- stuff for awful.widget.common:list_update
    -- labelfunc: function for labeling the items in the list,
    -- widget_container: container, in which all the widgets are added,
    -- widget_template: widget template that is used to update the list
    __index = function(self, input)
        for key, value in ipairs(input) do
            self[key] = value
        end
      return self
    end})
  return table
end

local mp = require('mp')
local utils = require('mp.utils')
local msg = require('mp.msg')
local mpopt = require('mp.options')
--local dir = mp.get_script_directory()
--msg.error(dir)
local OSD = require("osd_styler")

num = 1
function test()
        --local len = binds:len()
    mp.osd_message(binds[num]["cmd"])
    num = num+1
    --mp.osd_message(len)
end

menu = {
    active = false,
    overlay = mp.create_osd_overlay and mp.create_osd_overlay('ass-events'),
}

menu.overlay_draw = function(text)
    menu.overlay.data = text
    menu.overlay:update()
end

menu.keybindings = mp.get_property_native("input-bindings")

menu.update = function()
    if menu.active == false then
        return
    end

    local osd = OSD:new():size(24):align(4)
    osd:submenu('Key bindings'):newline()
    osd:item("key"):tab():item("function"):tab():item("commend"):newline()
    for key in menu.keybindings do
        osd:item(key["key"]):tab():item(key["cmd"]):tab():item(key["comment"]):newline()
    end
    menu.overlay_draw(osd:get_text())
end


menu.open = function()
    if menu.active == true then
        menu.close()
        return
    end
    
    menu.active = true
    menu.update()
end

mp.add_forced_key_binding("U", "testfunc", menu.open)
--mp.add_key_binding(nil, "mpvacious-menu-open", menu.open)
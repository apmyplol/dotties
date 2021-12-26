local utils = require("mp.utils")
local msg = require 'mp.msg'
local mp = require "mp"
local active = false


function toggle()
	if not active then
		mp.set_property("sub-visibility", "no")
		mp.observe_property("pause", "bool", on_pause_change)
		mp.osd_message("hide subs enabled")
	end

	if active then
		mp.set_property("sub-visibility", "yes")
		mp.unobserve_property(on_pause_change)
		mp.osd_message("hide subs disabled")
	end

	active = not active
end


function on_pause_change(name, value)
    if value == true then
    	mp.osd_message(" ", 0.01)
        mp.set_property("sub-visibility", "yes")
	else
    	mp.set_property("sub-visibility", "no")
    end
end



mp.add_key_binding(nil, "toggle_hidesubs", toggle)
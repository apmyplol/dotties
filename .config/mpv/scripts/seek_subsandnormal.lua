local utils = require("mp.utils")
local msg = require 'mp.msg'
local mp = require "mp"

function seek_right()
	if mp.get_property_native("sub-text") == nil then
		mp.commandv("seek", 5)
	else
		mp.commandv("sub-seek", 1)
	end
end


function seek_left()
	print(mp.get_property_native("sub-text"))
	if mp.get_property_native("sub-text") == nil then
		mp.commandv("seek", -5)
	else
		mp.commandv("sub-seek", -1)
	end
end

mp.add_key_binding(nil, "seek_right", seek_right)
mp.add_key_binding(nil, "seek_left", seek_left)
local msg = require 'mp.msg'
local options = require 'mp.options'
local utils = require 'mp.utils'
local mp = require "mp"
local currentnum = nil
local registered = false
local registered_second = false

--1. check playlist name und nummer
local function getpath()
	currentnum = mp.get_property_number("playlist-playing-pos")
	local lastnumber = mp.get_property_number('playlist-count')
	local path = mp.get_property("playlist/" .. lastnumber-1 .. "/filename")
	return path
end


--2. geh in Ordner und finde richtige subs
function getsubfile()
	path = getpath()
	if path == nil then return nil end
	files = utils.readdir(path, "files")
	if files == nil then
        msg.verbose("no other files in directory")
        return
    end
  table.sort(files, function(a, b) return a < b end)
  relsubfile = files[currentnum+1]
  -- subfile = path .. "\\" .. relsubfile
  subfile = path .. "/" .. relsubfile
    return subfile
end


--3. lade die subs rein
function loadsubs()
	subfile = getsubfile()
	if subfile == nil then mp.osd_message("could not load sub file") return end
	-- subfile = string.gsub(subfile, "\\", "\\\\")
  print(subfile)
  print(currentnum)
	mp.commandv("sub-add", subfile, "select")
	mp.osd_message("autoloaded subs")
	if not registered then
		mp.register_event("start-file", loadsubs)
		registered = true
	end
end

function load_secondary()
	subfile = getsubfile()
	subfile = string.gsub(subfile, "\\", "\\\\")
	subsize = get_sub_amount()
	mp.commandv("sub-add", subfile, "auto")
	mp.set_property("secondary-sid", subsize+1)
	mp.osd_message("autoloaded secondary subs")
	mp.set_property("secondary-sub-visibility", "no")
	if not registered_second then 
		mp.register_event("start-file", load_secondary)
		registered_second = true
	end

end

function get_sub_amount()
	subsize = mp.get_property_native("track-list/count")
	amount = 0
	for i=1,subsize do
		if mp.get_property_native("track-list/".. i .. "/type") == "sub" then
			amount = amount +1
		end
	end
	return amount
end

mp.add_key_binding(nil, "autoload_subs", loadsubs)
mp.add_key_binding(nil, "autoload_secondary_subs", load_secondary)

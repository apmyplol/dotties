local utils = require 'mp.utils'
local msg = require 'mp.msg'
local mp = require "mp"


function sync_anki()
	mp.osd_message("syncing anki")
	local request = utils.format_json({action="sync", version=6})

	port = "8765"

   -- if on windows then this is executed
   if mp.get_property('options/vo-mmcss-profile') ~= nil then
      port = "8888"
   end

	local args = { 'curl', '-s', 'http://localhost:' .. port, '-X', 'POST', '-d', request}

	local result = utils.subprocess({ args = args, cancellable = true, capture_stderr = true })
  	if utils.parse_json(result.stdout) ~= nil then
  		mp.osd_message("anki synced")
  	else
  		mp.osd_message("could not sync anki")
  	end
end

function set_vorlesung()
	if mp.get_property_native("path"):find("Downloads\\00_vorlesung") then
		mp.set_property_native("title", "mpvvorlesung")
	else
		mp.set_property_native("media-title", mp.get_property_native("filename"))
	end
end

mp.register_event("start-file", set_vorlesung)
--mp.add_key_binding(nil, "title_vorlesung", set_vorlesung)

mp.add_key_binding(nil, "sub_background", function() mp.set_property_native("sub-ass-override", true) mp.set_property_native("sub-back-color", "0.0/0.0/0.0") end)

mp.add_key_binding(nil,"reset_sub_delay",function() mp.set_property_native("sub-delay", 0) mp.osd_message("Sub delay: 0ms") end)
mp.add_key_binding(nil, "sync_anki", sync_anki)

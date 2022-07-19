local utils = require 'mp.utils'
local msg = require 'mp.msg'
local mp = require "mp"


function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

--- Check if a directory exists in this path
function isdir(path)
   -- "/" works on both Unix and Windows
   return exists(path.."/")
end


function screenshot_timestamp()
  local pos = mp.get_property_native("time-pos")
  pos = math.floor(pos)
  local seconds = pos % 60
  local minutes = (pos - seconds)/60

  if minutes < 10 then
  	minutes = "0" .. minutes
  end

  if seconds < 10 then
  	seconds = "0" .. seconds
  end

  local episode = mp.get_property_native("playlist-pos")+1
  local pos = minutes .. "-" .. seconds

  pl_size = mp.get_property_native("playlist-count")

  if pl_size > 1 then
    anim = mp.get_property("playlist/" .. pl_size-1 .. "/title")
    --msg.error(anim)
    --local len = anim:len()
    --anim = anim:sub(3)
    screenshot_dir = "C:\\Users\\arthu\\SynologyDrive\\BG\\" .. anim .. "\\"
    msg.error(screenshot_dir)
    if not isdir(screenshot_dir) then
      os.execute("mkdir \"" .. screenshot_dir .. "\"")
    end

  else 
    anim = mp.get_property_native("playlist/1/title")
  	if anim == nil then
  		anim = mp.get_property_native("filename/no-ext")
  	end
  	screenshot_dir = "C:\\Users\\arthu\\SynologyDrive\\BG\\random\\"
  end
  

  filename = anim .. "_" .. episode .. "_" .. pos .. ".png"
  file = screenshot_dir .. filename


  mp.commandv("screenshot-to-file", file, "video")
  mp.osd_message("uploading")
  discord(file:gsub("\\", "\\\\"), anim, episode, pos:gsub("-", ":"))
end

function discord(file, name, ep, timestamp)
	script = "C:\\Users\\arthu\\AppData\\Roaming\\mpv\\scripts\\.webhook.py"
	mp.commandv("run", "python", script, file, name, ep, timestamp)
end


mp.add_key_binding(nil, "screenshot_discord", screenshot_timestamp)
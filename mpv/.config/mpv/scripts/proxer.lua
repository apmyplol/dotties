
local mp = require "mp"
local msg = require 'mp.msg'

-- user input imports!
package.path = mp.command_native({"expand-path", "~~/script-modules/?.lua;"})..package.path
local ui = require "user-input-module"

function split_str(delim, input)
  temp = {}
  for word in input:gmatch(delim) do table.insert(temp, word) end
  return temp
end

function get_input()
  local get_user_input = ui.get_user_input

  get_user_input(get_links, {
        text = "<url> <startep> <endep>: https://proxer.me/info/47145 1 3",
        replace = true
    })
end

function get_links(input)
  print(type(input))
  print(input)
  temp = {}
  if input == "" or input == nil then temp = {"https://proxer.me/info/47145",  "1", "3"} else temp = split_str("%S+", input) end

  script = "C:\\Users\\arthu\\AppData\\Roaming\\mpv\\scripts\\.getproxer.py"
  
  print(temp[1])


  

  link = temp[1]
  startep = temp[2]
  endep = temp[3]

    local command_table = {
      name = "subprocess",
      playback_only = false,
      capture_stdout = true,
      args = {"python", script, link, startep, endep}
  }

  mp.command_native_async(command_table, add_links)
end

function print_table(inp)
  for k,v in pairs(inp) do
    print(k)
    print(v)
  end
end

function add_links(one, result, two)

  local keyset={}
  local n=0
  --[[print("sucess ", one)
  print("error ", two)
  print("printing status: ", result["status"])
  print("printing sucess", result["success"])
  print("printing error", result["error"])
  print("printing result")
  print_table(result)
  print("printing result!!\n", result["stdout"])--]]

  if result["status"] == 0 then
    local lines = split_str("([^\n]*)\n?", result["stdout"])
    local orderedlines = {}

    for i = 1, #lines-1, 1 do -- something like https://s73.ps.proxer.me/files/9/nnh5lp62ftb7r8/video.mp4 Owarimonogatari_2nd_Season_Episode_3
      local line = lines[i]
      local line_split = split_str("%S+", line) -- split that line by " " (space)
      local episodepart = split_str("([^_]+)", line_split[2])  -- split the second part with the title and number by "_"
      local episodenum = tonumber(episodepart[#episodepart]) -- get the number from the string to put it in the right order
      orderedlines[episodenum] = line_split  -- add the line to the correct position
    end


    for i = 1, #lines-1, 1 do
      print("adding", orderedlines[i][2])
      mp.commandv("loadfile", orderedlines[i][1], "append-play", "force-media-title=" .. orderedlines[i][2])
      --mp.commandv("video-add", orderedlines[i][1], "auto", orderedlines[i][2]:gsub("_", " "))
    end
    mp.osd_message("added " .. #orderedlines .. " episodes")
  else
    msg.error("Error while loading proxer link")
    mp.osd_message("Error loading proxer link")
  end
end

mp.add_key_binding("Alt+w", "autoload_secondary_subs", get_input)
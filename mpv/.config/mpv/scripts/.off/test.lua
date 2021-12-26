local mp = require 'mp'
local msg = require 'mp.msg'
local http = require 'http'

function test()
	msg.error("Keypad 1 pressed")
end


mp.add_key_binding("KP1", "test", test)


local mp = require("mp")
M = {}

M.print_table = function(inp)
	for k, v in pairs(inp) do
		print(k)
		print(v)
	end
end

M.split_str = function(delim, input)
	local temp = {}
	for word in input:gmatch(delim) do
		table.insert(temp, word)
	end
	return temp
end

M.check_linux = function()
	return not mp.get_property("options/vo-mmcss-profile")
end

return M

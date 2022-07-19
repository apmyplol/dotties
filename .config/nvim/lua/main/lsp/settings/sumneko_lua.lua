return {
	settings = {

		Lua = {
			diagnostics = {
				globals = { "vim", "awesome", "client", "root", "mouse", "screen", "mp" },
			},
			runtime = {
				version = "Lua 5.3",
				path = {
					"?.lua",
					"?/init.lua",
					vim.fn.expand("~/.luarocks/share/lua/5.3/?.lua"),
					vim.fn.expand("~/.luarocks/share/lua/5.3/?/init.lua"),
					"/usr/share/5.3/?.lua",
					"/usr/share/lua/5.3/?/init.lua",
				},
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
					["/usr/share/awesome/lib"] = true,
				},
			},
		},
	},
}

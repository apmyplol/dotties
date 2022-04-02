return {
	settings = {

		Lua = {
			diagnostics = {
				globals = { "vim", "awesome", "client", "root", "mouse", "screen", "mp" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
					["/usr/share/awesome/lib"] = true
				},
			},
		},
	},
}

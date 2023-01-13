local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
	return
end

local hide_in_width = function()
	return vim.fn.winwidth(0) > 80
end

local diagnostics = {
	"diagnostics",
	sources = { "nvim_diagnostic" },
	sections = { "error", "warn" },
	symbols = { error = " ", warn = " " },
	colored = false,
	update_in_insert = false,
	always_visible = true,
}

local diff = {
	"diff",
	colored = false,
	symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
	cond = hide_in_width,
}

local mode = {
	"mode",
	fmt = function(str)
		return "-- " .. str .. " --"
	end,
}

local filetype = {
	"filetype",
	icons_enabled = false,
	icon = nil,
}

local branch = {
	"branch",
	icons_enabled = true,
	icon = "",
}

local location = {
	"location",
	padding = 0,
}

-- cool function for progress
local progress = function()
	local current_line = vim.fn.line(".")
	local total_lines = vim.fn.line("$")
	local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
	local line_ratio = current_line / total_lines
	local index = math.ceil(line_ratio * #chars)
	return chars[index]
end

local spaces = function()
	return "spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
end

local eva = require("colors.eva_colors")

local colors = {
	normal = {
		a = "LualineNormal",
		b = "LualineNormal",
		c = "LualineNormal",
		x = "LualineNormal",
		y = "LualineNormal",
		z = { bg = eva.reb_purple1, fg = eva.reb_green },
	},
	insert = {
		a = { bg = eva.reb_green, fg = eva.black},
		b = "LualineInsert",
		c = "LualineInsert",
		x = "LualineInsert",
		y = "LualineInsert",
		z = { bg = eva.reb_green, fg = eva.reb_purple1 },
	},
	visual = {
		a = { bg = eva.purple1, fg = eva.alacbg},
		b = "LualineVisual",
		c = "LualineVisual",
		x = "LualineVisual",
		y = "LualineVisual",
		z = { bg = eva.purple1, fg = eva.reb_green },
	},
	replace = {
		a = "LualineReplace",
		b = "LualineReplace",
		c = "LualineReplace",
		x = "LualineReplace",
		y = "LualineReplace",
		z = { bg = eva.reb_purple1, fg = eva.reb_green },
	},
	command = {
		a = "LualineCommand",
		b = "LualineCommand",
		c = "LualineCommand",
		x = "LualineCommand",
		y = "LualineCommand",
		z = { bg = eva.reb_orange, fg = eva.reb_green },
	},
	inactive = {
		-- a = { bg = eva.reb_purple2, fg = eva.alacfg, gui = "bold" },
    -- a = "LualineInactiveDiags",
		b = "LualineInactive",
		c = "LualineInactive",
		x = "LualineInactive",
		y = "LualineInactive",
		-- z = { bg = eva.reb_purple2, fg = eva.reb_green },
    -- z = "LualineInactiveProg"
	},
}

lualine.setup({
	options = {
		icons_enabled = true,
		theme = colors,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = { "dashboard" , "Outline" },
    ignore_focus = {"NvimTree"},
		always_divide_middle = true,
	},
	sections = {
		lualine_a = { branch, diagnostics },
		lualine_b = { mode },
		lualine_c = {},
		-- lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_x = { diff, spaces, "encoding", filetype },
		lualine_y = { location },
		lualine_z = { progress },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
})

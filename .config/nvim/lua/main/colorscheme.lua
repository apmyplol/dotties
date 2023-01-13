-- local colorscheme = "base16-eva"
-- 
-- local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
-- if not status_ok then
--   vim.notify("colorscheme " .. colorscheme .. " not found!")
--   return
-- end

local colors = require("colors.evatheme")

-- colorschemes generally want to do this
vim.cmd("highlight clear")
vim.cmd("set t_Co=256")
vim.cmd("let g:colors_name='evatheme'")

-- apply highlight groups
for group, attrs in pairs(colors) do
  vim.api.nvim_set_hl(0, group, attrs)
end

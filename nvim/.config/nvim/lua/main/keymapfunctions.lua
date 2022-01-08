local M = {}
M.latex = function()
  local file = vim.fn.expand("%")
  file = file:gsub("tex", "pdf")
  vim.cmd("! zathura " .. file .. " &")
end

M.luasnipchoose = function(i)
  local ls = require "luasnip"
  if ls.choice_active() then
    ls.change_choice(i)
  end
end

return M

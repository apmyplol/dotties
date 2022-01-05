local M = {}
M.latex = function()
  local file = vim.fn.expand("%")
  file = file:gsub("tex", "pdf")
  vim.cmd("! zathura " .. file)
end

return M

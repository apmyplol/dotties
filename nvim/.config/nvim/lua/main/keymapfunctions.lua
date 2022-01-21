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

function M.test_grep_filename()
local opts = {
  attach_mappings = function(_, map)
    map("i", "<CR>", function(prompt_bufnr)
      -- filename is available at entry[1]
      local entry = require("telescope.actions.state").get_selected_entry()
      require("telescope.actions").close(prompt_bufnr)
      local filename = entry[1]
      -- Insert filename in current cursor position
      vim.cmd('normal i [[' .. filename:match("([^/.]+)%..*$"))
    end)
    return true
  end,
}
require("telescope.builtin").find_files(opts)
end

M.comment = function()
  -- TODO: wait for support to get selection in new vim version and renew this function
  local top = vim.api.nvim_buf_get_mark(0, "<")[1]
  local bot = vim.api.nvim_buf_get_mark(0, ">")[1]
  if math.abs(top-bot)>0 then
    require("Comment.api").toggle_current_blockwise()
    return
  end
  require("Comment.api").toggle_current_linewise()
  return
end
return M

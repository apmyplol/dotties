local keymap = vim.keymap

local status_ok, fpreview = pcall(require, "fold-preview")
if not status_ok then
  return
end

local status_ok, kamend = pcall(require, "keymap-amend")
if not status_ok then
  return
end

local map = fpreview.mapping

keymap.amend = kamend

keymap.amend('n', '<CR>',  map.show_close_preview_open_fold)
keymap.amend('n', 'l',  map.close_preview_open_fold)
keymap.amend('n', 'ö', map.close_preview)
-- fpreview.setup({
--   default_keybindings = true
-- })

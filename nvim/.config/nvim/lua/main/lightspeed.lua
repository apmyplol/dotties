local status_ok, lightspeed = pcall(require, "lightspeed")
if not status_ok then
  return
end

vim.g.lightspeed_no_default_keymaps = 1
vim.cmd("let g:lightspeed_no_default_keymaps=1")


lightspeed.setup{
  ignore_case = true,
  exit_after_idle_msecs = { unlabeled = 1000, labeled = nil },
  disable_default_mappings = true
}

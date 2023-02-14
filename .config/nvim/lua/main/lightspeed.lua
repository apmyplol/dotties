local status_ok, lightspeed = pcall(require, "lightspeed")
if not status_ok then
  return
end

-- vim.g.lightspeed_no_default_keymaps = 1
-- vim.cmd("let g:lightspeed_no_default_keymaps=1")


lightspeed.setup{
  ignore_case = false,
  exit_after_idle_msecs = { unlabeled = nil, labeled = nil },
  jump_to_unique_chars = { safety_timeout = nil },
  -- disable_default_mappings = true
}

local status_ok, lightspeed = pcall(require, "lightspeed")
if not status_ok then
  return
end


lightspeed.setup{
  ignore_case = true,
  exit_after_idle_msecs = { unlabeled = 1000, labeled = nil },
}

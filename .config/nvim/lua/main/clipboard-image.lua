local status_ok, clipimage = pcall(require, "clipboard-image")
if not status_ok then
    return
end

clipimage.setup {
  -- Default configuration for all filetype
  default = {
    img_dir = "images",
    img_name = function() return os.date('%Y-%m-%d-%H-%M-%S') end, -- Example result: "2021-04-13-10-04-18"
    affix = "![](%s)"
  }
}

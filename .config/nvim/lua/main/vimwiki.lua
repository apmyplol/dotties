local opts = {
  hl_headers = 1,
  hl_cb_checked = 1,
  folding = "expr",
  auto_chdir = 1,
  key_mappings={
    global = 0,
    headers = 0,
    text_objs = 0,
    table_format = 0,
    table_mappings = 0,
    lists = 0,
    links = 0,
    html = 0,
    mouse = 0
  }
}

for index, value in pairs(opts) do
  vim.g["vimwiki_" .. index] = value
end

local status_ok, surround = pcall(require, "surround")
if not status_ok then
  return
end

surround.setup{
  context_offset = 100,
  load_autogroups = false,
  mappings_style = "sandwich",
  map_insert_mode = false,
  quotes = {"'", '"', "*"},
  brackets = {"(", '{', '['},
  -- space_on_closing_char = false,
  space_on_closing_char = true,
  pairs = {
    nestable = { b = { "(", ")" }, e = { "[", "]" }, g = { "{", "}" }, v = { "<", ">" }, l = {"\\{", "\\}"} },
    linear = { q = { "'", "'" }, t = { "`", "`" }, d = { '"', '"' }, m = {"$", "$"}, M = {"$$", "$$"}, s = {"*", "*"}, c = {"\\(", "\\)"}, C = {"\\[", "\\]"}
  },
  prefix = "s"
  }
}

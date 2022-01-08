local status_ok, ls = pcall(require, "luasnip")
if not status_ok then
  return
end

local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

-- helper functions for defining snippets
local h = {}
h.paren = function(str) return "{" .. str .. "}" end
ls.snippets = {
	-- When trying to expand a snippet, luasnip first searches the tables for
	-- each filetype specified in 'filetype' followed by 'all'.
	-- If ie. the filetype is 'lua.c'
	--     - luasnip.lua
	--     - luasnip.c
	--     - luasnip.all
	-- are searched in that order.
	all = {
        -- snippet to create snippets lol
       ls.parser.parse_snippet({trig="regsnippet"},
        [[
      s(
          { trig = "$1", regTrig = true },
          f(function(_, snip)
            return $2
          end, {})
      ),
      $0]]
      ),
        -- snippet for ^{} in latex.
      s(
          { trig = "(%S+)(%d%d)", regTrig = true },
          f(function(_, snip)
            return snip.captures[1] .. "^" .. h.paren(snip.captures[2])
          end, {})
      ),
      s(
          { trig = "(%S+)(%d)", regTrig = true },
          f(function(_, snip)
            return snip.captures[1] .. "^" .. snip.captures[2]
          end, {})
      ),      s(
          { trig = "(%S+)(%d%d)", regTrig = true },
          f(function(_, snip)
            return snip.captures[1] .. "_" .. h.paren(snip.captures[2])
          end, {})
      ),
      s(
          { trig = "(%S+)(%d)", regTrig = true },
          f(function(_, snip)
            return snip.captures[1] .. "_" .. snip.captures[2]
          end, {})
      ),
  }
}
-- 
-- Triggered with a3. 
-- Captured Text: 4.
-- Captured Text: 5.
-- Captured Text: 0.
-- Triggered with a5.
-- Captured Text: 4.
--


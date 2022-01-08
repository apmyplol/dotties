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

-- 'recursive' dynamic snippet. Expands to some text followed by itself.
local rec_ls
rec_ls = function()
	return sn(
		nil,
		c(1, {
			-- Order is important, sn(...) first would cause infinite loop of expansion.
			t(""),
			sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
		})
	)
end

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
       ls.parser.parse_snippet({trig="regsnippet", name="regex snippet", dscr="snippet to create regex snippets"},
        [[
      s(
          { trig = "$1", name = "$2", dscr = "$3", regTrig = true },
          f(function(_, snip)
            return $4
          end, {})
      ),
      $0]]
      ),
      s(
          { trig = "sc(%d)", name = "snippet capture regex", dscr = "snippet for creating regex snippets", regTrig = true },
          f(function(_, snip)
            return "snip.captures[" .. snip.captures[1] .. "]"
          end, {})
      ),
      s(
          { trig = "Bo([a-z])", name = "Bold math text", dscr = "Snippet for creating bold math text", regTrig = true },
          f(function(_, snip)
            return [[\mathbb{]] .. snip.captures[1]:upper() .. "}"
          end, {})
      ),
      s(
          { trig = "abs%s(%S+)%sabs", name = "absolute values", dscr ="replaces abs with |" , regTrig = true },
          f(function(_, snip)
            return "| " .. snip.captures[1] .. "|"
          end, {})
      ),
      s(
          { trig = "bi(g+)%s(.*)%sbi(g+)", name = "Bigg Thicc", dscr = "depending on how many g's, replaces the text with latex \\Big command, the more g's the bigger the text" ,regTrig = true },
          f(function(_, snip)
            local outs = { [1] = [[\big ]], [2] = [[\Big ]], [3] = [[\bigg ]], [4] = [[\Bigg ]] }
            local size = outs[snip.captures[1]:len()]
            return size .. snip.captures[2] .." " .. size
          end, {})
      ),
      s(
          { trig = "int%s(%S+)%s(.*)", name = "integral", dscr = "creates integral based on expression seperanted by spaces", regTrig = true },
          f(function(_, snip)
            return "\\int_" .. h.paren(snip.captures[1]) .. "^" .. h.paren(snip.captures[2])
          end, {})
      ),
      s(
          { trig = "lim%s(%S+)%s(%S+)", name = "limes", dscr = "creates limit sign based on expression seperated by spaces", regTrig = true },
          f(function(_, snip)
            return "\\lim_{" .. snip.captures[1] .. " \\rightarrow " .. snip.captures[2] .. "}"
          end, {})
      ),
      s(
          { trig = "(%d)r(%S+)", name = "n-th root", dscr = "creates n-th root based on expression seperated by the letter r",  regTrig = true },
          f(function(_, snip)
            return "\\sqrt[" .. snip.captures[1] .. "]{" .. snip.captures[2] .. "}"
          end, {})
      ),
        -- snippet for ^{} in latex.
      s(
        { trig = "(%S+)(%d%d?)", name = "subscript and superscript", dscr = "expands superscript or subscript numbers, depending on choice",  regTrig = true },
          c(1,{
            f(function(_, snip)
              return snip.captures[1] .. "^" .. h.paren(snip.captures[2])
            end, {}),
            f(function(_, snip)
              return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
            end, {})
        })
      ),
      s(
          { trig = "(%S+)(%d)", regTrig = true },
          f(function(_, snip)
            return snip.captures[1] .. "^" .. snip.captures[2]
          end, {})
      ),
      s("matrix", {
        t({ "\\begin{pmatrix}", " " }),
        i(1),
        d(2, rec_ls, {}),
        t({ "", "\\end{itemize}" }),
      }),
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


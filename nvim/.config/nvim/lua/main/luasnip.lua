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

-- helper functions for defining snippets
local h = {}
h.alignsnippet = function()
  if h.aligncount == nil then return t("hmm") end
  local args = {t("\t")}
  for k = 1, h.aligncount-1, 1 do
    args[#args+1] = i(k)
    args[#args+1] = t(" & ")
  end
  args[#args+1] = i(h.aligncount)
  args[#args+1] =t({"\\\\", ""})
  args[#args+1]=d(h.aligncount+1, h.alignsnippet, {})
	return sn(
		nil,
		c(1, {
			-- Order is important, sn(...) first would cause infinite loop of expansion.
			t(""),
			sn(nil, args),
		})
	)
end
h.rec_case = function()
	return sn(
		nil,
		c(1, {
			-- Order is important, sn(...) first would cause infinite loop of expansion.
			t(""),
			sn(nil, { t({"", "\t" }), i(1), t(" & "), i(2), t("\\\\"),  d(3, h.rec_case, {}) }),
		})
	)
end
local rec_ls
rec_ls = function()
	return sn(nil, {
		c(1, {
			-- important!! Having the sn(...) as the first choice will cause infinite recursion.
			t({""}),
			-- The same dynamicNode as in the snippet (also note: self reference).
			sn(nil, {t({"", "\t\\item "}), i(1), d(2, rec_ls, {})}),
		}),
	});
end
ls.snippets = {
    -- snippet to create snippets lol
   lua ={
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
  },

  -- tex snippets
	tex = {
      s(
          { trig = "--(%d)--", name = "& expandor", dscr = "create snippet that expands the right amount of & infinetely", regTrig = true },
      {f(function(_, snip)
            h.aligncount = tonumber(snip.captures[1])
           return ""
      end, {}),
     d(1, h.alignsnippet, {}), i(0)
    }),

      -- Snippets for math text
      s(
          { trig = "fancy([a-z])", name = "fancy math text", dscr = "expands 'fancy a' to \\mathcal{A}", regTrig = true },
          f(function(_, snip)
            return "\\mathcal{ "   .. snip.captures[1]:upper() .. "}"
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
            return "| " .. snip.captures[1] .. " |"
          end, {})
      ),
      s(
          { trig = "norm%s(%S+)%snorm", name = "norm", dscr ="replaces norm with |" , regTrig = true },
          f(function(_, snip)
            return "\\| " .. snip.captures[1] .. " \\|"
          end, {})
      ),     s(
          { trig = "bi(g+)%s(.*)%sbi(g+)", name = "Bigg Thicc", dscr = "depending on how many g's, replaces the text with latex \\Big command, the more g's the bigger the text" ,regTrig = true },
          f(function(_, snip)
            local outs = { [1] = [[\big ]], [2] = [[\Big ]], [3] = [[\bigg ]], [4] = [[\Bigg ]] }
            local size = outs[snip.captures[1]:len()]
            return size .. snip.captures[2] .." " .. size
          end, {})
      ),

      -- product, integral, limes
      s(
          { trig = "prod%s(%S+)%s(%S+)", name = "product", dscr = "Creates big product", regTrig = true },
          f(function(_, snip)
            return "\\prod_{" .. snip.captures[1] .. "}^{" .. snip.captures[2] .. "}"
          end, {})
      ),
      s(
          { trig = "int%s(%S+)%s(%S+)", name = "integral", dscr = "creates integral based on expression seperanted by spaces", regTrig = true },
          f(function(_, snip)
            return "\\int_{" .. snip.captures[1] .. "}^{" .. snip.captures[2] .. "}"
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

      -- Fraction snippets
      s(
          { trig = "(%S)/(%S)", name = "fraction easy mode", dscr = "expands (a/b) to a divided by b, a and b can both be numbers and letters", regTrig = true },
          f(function(_, snip)
            return "\\frac{" .. snip.captures[1] .. "}{" .. snip.captures[2] .. "}"
          end, {})
      ),
      s(
          { trig = "(%S)%s/%s(%S)", name = "fraction hard mode", dscr = "expands 'something / something' to according fraction", regTrig = true },
          f(function(_, snip)
            return "\\frac{" .. snip.captures[1] .. "}{" .. snip.captures[2] .. "}"
          end, {})
      ),

      -- snippets for sub and superscript for single letters and longer expressions
      s(
        { trig = "(%S+)%ss%s(%S+)", name = "sub/superscript in general", dscr = "expands superscript or subscript expressions",  regTrig = true },
          c(1,{
            f(function(_, snip)
              return snip.captures[1] .. "^{" .. snip.captures[2] .. "}"
            end, {}),
            f(function(_, snip)
              return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
            end, {})
        })
      ),
      s(
        { trig = "(%S+)([%dikn])", name = "subscript and superscript", dscr = "expands superscript or subscript numbers, depending on choice",  regTrig = true },
          c(1,{
            f(function(_, snip)
              return snip.captures[1] .. "^{" .. snip.captures[2] .. "}"
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

}
}
ls.filetype_set("latex", {"tex"})
ls.filetype_set("markdown", {"tex"})

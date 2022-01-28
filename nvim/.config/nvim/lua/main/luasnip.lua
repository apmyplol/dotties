local status_ok, ls = pcall(require, "luasnip")
if not status_ok then
  return
end

local status_ok, vsloader = pcall(require, "luasnip.loaders.from_vscode")
if not status_ok then
  return
end
vsloader.load({paths = "~/.config/nvim/snippets/"})
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

vim.api.nvim_command("hi LuasnipChoiceNodePassive cterm=italic")
ls.config.setup({
	ext_opts = {
		[types.insertNode] = {
			passive = {
				hl_group = "GruvboxRed"
			}
		},
		[types.choiceNode] = {
			active = {
				virt_text = {{"choiceNode", "GruvboxOrange"}}
			}
		},
		[types.textNode] = {
			snippet_passive = {
				hl_group = "GruvboxGreen"
			}
		},
	},
	ext_base_prio = 200,
	ext_prio_increase = 3,
})
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

h.bigsymbol = function(trig, tex, name, desc) -- creates big math symbol snippet, e.g. sum, integral,. etc
      return s(
          { trig = trig .. "%s(%S+)%s(.+)", name = name, dscr = desc, regTrig = true, hidden = true},
          f(function(_, snip)
						local out = "\\" .. tex .. "_{" .. snip.captures[1] .. "}"
						if snip.captures[2] ~= " " then
							out = out .. "^{" .. snip.captures[2] .. "}"
						end
						return out
          end, {})
      )
end

h.greek = {
	a = "alpha",
	b = "beta",
	c = "chi",
	d = "delta", "Delta",
	e = "varepsilon", E = "epsilon", ev = "epsilon",
	et = "eta",
	g = "gamma", G = "Gamma",
	-- h
	i = "iota",
	-- j
	k = "kappa",
	l = "lambda", "Lambda",
	m = "mu",
	n = "nu",
	o = "omega", O = "Omega",
	p = "phi", P = "Phi", pv = "varphi", ph = "phi", Ph = "Phi",
	ps = "psi", pS = "Psi", Ps = "Psi",
	pi = "pi", Pi = "Pi", pI = "Pi",
	q = "psi", "Psi",
	r = "rho", R = "varrho",
	s = "sigma", S = "Sigma",
	t = "theta", T = "Theta", tv = "vartheta",
	ta = "tau",
	u = "upsilon", U = "Uplislon",
	x = "xi", X = "Xi",
	z = "zeta",

}

ls.snippets = {
    -- snippet to create snippets lol


   lua ={
        ls.parser.parse_snippet({trig="regsnippet", name="regex snippet", dscr="snippet to create regex snippets"},
					[[
				s(
						{ trig = "$1", name = "$2", dscr = "$3", regTrig = true, hidden = true },
						f(function(_, snip)
							return $4
						end, {})
				),
				$0]]
      ),
      s(
				{ trig = "sc(%d)", name = "snippet capture regex", dscr = "snippet for creating regex snippets", regTrig = true, hidden = true },
          f(function(_, snip)
            return "snip.captures[" .. snip.captures[1] .. "]"
          end, {})
      ),
  },



  -- tex snippets
	tex = {
      s(
				{ trig = "%-%-(%d)%-%-", name = "& expandor", dscr = "create snippet that expands the right amount of & infinetely", regTrig = true, hidden = true },
					{f(function(_, snip)
								h.aligncount = tonumber(snip.captures[1])
							 return ""
					end, {}),
				 d(1, h.alignsnippet, {}), i(0)
			}),

      -- Snippets for math text
      s(
				{ trig = "fancy([a-z])", name = "fancy math text", dscr = "expands 'fancya' to \\mathcal{A}", regTrig = true, hidden = true },
          f(function(_, snip)
            return "\\mathcal{"   .. snip.captures[1]:upper() .. "}"
          end, {})
      ),
      s(
				{ trig = "calli([a-z])", name = "calligraphy math text", dscr = "expands 'callia' to \\mathcal{A}", regTrig = true, hidden = true },
          f(function(_, snip)
            return "\\mathscr{"   .. snip.captures[1]:upper() .. "}"
          end, {})
      ),
      s(
				{ trig = "bo([a-z])", name = "Bold math text", dscr = "Snippet for creating bold math text", regTrig = true, hidden = true },
          f(function(_, snip)
            return [[\mathbb{]] .. snip.captures[1]:upper() .. "}"
          end, {})
      ),
			-- TODO: maybe add .* before gr, so that 2grpi could also expand to 2\pi
      s(
				{ trig = "gr(%a%a?)", name = "greek math text", dscr = "Snippet for creating greek letters", regTrig = true, hidden = true },
          f(function(_, snip)
						print(snip.captures[1])
						local letter = h.greek[snip.captures[1]]
            return (letter ~= nil and "\\" .. letter .. " " or "rip")
          end, {})
      ),
      s( -- TODO: add (?s) too abs snippet to use \| as the abs
				{ trig = "abs%s%((.+)%)%sabs", name = "absolute values", dscr ="replaces abs with |" , regTrig = true, hidden = true },
          f(function(_, snip)
            return "| " .. snip.captures[1] .. " |"
          end, {})
      ),
      s(
				{ trig = "norm%s(%S+)%snorm", name = "norm", dscr ="replaces norm with |" , regTrig = true, hidden = true },
          f(function(_, snip)
            return "\\| " .. snip.captures[1] .. " \\|"
          end, {})
      ),
		s(
			{ trig = "bi(g+)%s(.+)%sbi(g+)", name = "Bigg Thicc", dscr = "depending on how many g's, replaces the text with latex \\Big command, the more g's the bigger the text", regTrig = true, hidden = true },
				f(function(_, snip)
					local outs = { [1] = [[\big ]], [2] = [[\Big ]], [3] = [[\bigg ]], [4] = [[\Bigg ]] }
					local size = outs[snip.captures[1]:len()]
					return size .. snip.captures[2] .." " .. size
				end, {})
		),

      -- product, integral, sum, infimum/minimum and supremum/maximum
			h.bigsymbol("prod",	"prod", "product",	"Creates product based on expression seperated by spaces"),
			h.bigsymbol("int", 	"int", 	"integral",	"creates integral based on expression seperanted by spaces"),
			h.bigsymbol("sum", 	"sum", 	"sum", 			"creates sum based on expression seperated by spaces"),
			h.bigsymbol("inf", 	"inf", 	"infimum", 	"creates infimum based on expression seperated by spaces"),
			h.bigsymbol("min", 	"min", 	"minimum", 	"creates minimum symbol based on expression seperated by spaces"),
			h.bigsymbol("max", 	"max", 	"maximum", 	"creates maximum symbol based on expression seperated by spaces"),
			h.bigsymbol("sup", 	"sup", 	"supremum", 	"creates supremum based on expression seperated by spaces"),

			-- limes
      s(
				{ trig = "lim%s(%S+)%s(%S+)", name = "limes", dscr = "creates limit sign based on expression seperated by spaces", regTrig = true, hidden = true},
          f(function(_, snip)
            return "\\lim_{" .. snip.captures[1] .. " \\rightarrow " .. snip.captures[2] .. "}"
          end, {})
      ),
      s(
				{ trig = "(%d)r(%S+)", name = "n-th root", dscr = "creates n-th root based on expression seperated by the letter r",  regTrig = true, hidden = true},
          f(function(_, snip)
            return "\\sqrt[" .. snip.captures[1] .. "]{" .. snip.captures[2] .. "}"
          end, {})
      ),

      -- Fraction snippets
      s(
				{ trig = "(%S)/(%S)", name = "fraction easy mode", dscr = "expands (a/b) to a divided by b, a and b can both be numbers and letters", regTrig = true, hidden = true },
          f(function(_, snip)
            return "\\frac{" .. snip.captures[1] .. "}{" .. snip.captures[2] .. "}"
          end, {})
      ),
      s(
				{ trig = "(%S+)%s/%s(%S+)", name = "fraction hard mode", dscr = "expands 'something / something' to according fraction", regTrig = true, hidden = true },
          f(function(_, snip)
            return "\\frac{" .. snip.captures[1] .. "}{" .. snip.captures[2] .. "}"
          end, {})
      ),

      -- snippets for sub and superscript for single letters and longer expressions
      s(
        { trig = "(%S+)%ss%s(%S+)", name = "sub/superscript in general", dscr = "expands superscript or subscript expressions",  regTrig = true, hidden = true },
          c(1,{
            f(function(_, snip)
              return snip.captures[1] .. "^{" .. snip.captures[2] .. "}"
            end, {}),
            f(function(_, snip)
              return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
            end, {})
        })
      ),

			-- TODO: remove "i, p" from here, instead change snippet priority
      s(
        { trig = "([^{%spi+]+)%s?([%dikn])", name = "subscript and superscript", dscr = "expands superscript or subscript numbers, depending on choice",  regTrig = true, hidden = true },
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
				{ trig = "i(o?)%s(%S+)%s(%S+)", name = "interval", dscr = "expands 'i bla bla' to '[bla,bla]' and 'io bla bla' to '(bla, bla)'", regTrig = true, hidden = true },
				f(function(_, snip)
					local mid = snip.captures[2] .. "," .. snip.captures[3]
					if snip.captures[1] == "o" then return "("  .. mid .. ")"
					else return "[" .. mid .. "]"
				end
				end, {})
      ),
      s(
        { trig = "ih%s(%S+)%s(%S+)", name = "half opened interval choice node", dscr = "expands 'ih bla bla' to choice node '(bla, bla] OR [bla, bla)'",  regTrig = true, hidden = true },
          c(1,{
            f(function(_, snip)
              return "(" .. snip.captures[1] .. "," .. snip.captures[2] .. "]"
            end, {}),
            f(function(_, snip)
              return "[" .. snip.captures[1] .. "," .. snip.captures[2] .. ")"
            end, {})
        })
      ),

			-- snippet for markdown comment
		s("ct", {
			t({"---",
				"tags: ana/complex",
				"date: " .. os.date("%d-%m-%Y"),
				"vorlesung: 11",
				"kapitel: "}), i(1),
			t({"", "aliases:"}), i(2),
			t({"", "---", "", "#"}), i(0)
		}),

}

}

ls.filetype_set("latex", {"tex"})
ls.filetype_set("markdown", {"tex"})
ls.filetype_set("vimwiki", {"tex"})

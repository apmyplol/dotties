local status_ok, ls = pcall(require, "luasnip")
if not status_ok then
    return
end


require "main.snippets.tex_snip"
require "main.snippets.obsidian_snip"

local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require "luasnip.util.events"
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require "luasnip.util.types"
local conds = require "luasnip.extras.expand_conditions"

ls.setup{
  enable_autosnippets = true
}


ls.add_snippets(
    -- snippet to create snippets lol

    "lua",
    {
        ls.parser.parse_snippet(
            { trig = "regsnippet", name = "regex snippet", dscr = "snippet to create regex snippets" },
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
            {
                trig = "sc(%d)",
                name = "snippet capture regex",
                dscr = "snippet for creating regex snippets",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                return "snip.captures[" .. snip.captures[1] .. "]"
            end, {})
        ),
    }
)


-- TODO: double snippets, add "\mathop{}\!\mathrm{d}" as snippet, vllt metrischer Raum snippet, \rightarrow

ls.filetype_extend("latex", { "tex", "obsidian" })
ls.filetype_extend("markdown", { "tex", "obsidian", "text" })
ls.filetype_extend("vimwiki", { "obsidian", "tex", "text" })
ls.filetype_extend("tex", { "obsidian" })
ls.filetype_extend("html", { "text", "tex" })

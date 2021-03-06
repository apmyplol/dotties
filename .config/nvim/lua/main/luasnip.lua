local status_ok, ls = pcall(require, "luasnip")
if not status_ok then
    return
end

local status_ok, vsloader = pcall(require, "luasnip.loaders.from_vscode")
if not status_ok then
    return
end

vsloader.load { paths = { "~/.config/nvim/snippets/" } }

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
local types = require "luasnip.util.types"
local conds = require "luasnip.extras.expand_conditions"

-- helper functions for defining snippets
local h = {}
h.alignsnippet = function()
    if h.aligncount == nil then
        return t "hmm"
    end
    local args = { t "\t" }
    for k = 1, h.aligncount - 1, 1 do
        args[#args + 1] = i(k)
        args[#args + 1] = t " & "
    end
    args[#args + 1] = i(h.aligncount)
    args[#args + 1] = t { "\\\\", "" }
    args[#args + 1] = d(h.aligncount + 1, h.alignsnippet, {})
    return sn(
        nil,
        c(1, {
            -- Order is important, sn(...) first would cause infinite loop of expansion.
            t "",
            sn(nil, args),
        })
    )
end

h.bigsymbol = function(trig, tex, name, desc) -- creates big math symbol snippet, e.g. sum, integral,. etc
    -- print("[^\\]" .. trig .. "%s%(?([^()]+)%)?%s?%s(.+)")
    return s(
        -- %s(%S+)%s(.+) ersetzt durch  %s%(?([^()]+)%)?%s(%S+)
        {
            trig = "[^\\]?" .. trig .. "%s%(?([^()]+)%)?%s?%s(.+)",
            name = name,
            dscr = desc,
            regTrig = true,
            hidden = true,
        },
        f(function(_, snip)
            local out = "\\" .. tex .. "_{" .. snip.captures[1] .. "}"
            if snip.captures[2] ~= " " then
                out = out .. "^{" .. snip.captures[2] .. "}"
            end
            return out
        end, {})
    )
end

h.double = function(trig, tex, op1, op2, desc)
    return s {
        trig = trig,
    }
end

h.temp = nil

h.returnfunc = function(bool, choice1, choice2)
    if bool then
        return sn(nil, { c(1, { t(choice1), t(choice2) }) })
    else
        return sn(nil, { c(1, { t(choice2), t(choice1) }) })
    end
end
h.greek = {
    a = "alpha",
    b = "beta",
    c = "chi",
    d = "delta",
    "Delta",
    e = "varepsilon",
    E = "epsilon",
    ev = "epsilon",
    et = "eta",
    g = "gamma",
    G = "Gamma",
    -- h
    i = "iota",
    -- j
    k = "kappa",
    l = "lambda",
    "Lambda",
    m = "mu",
    n = "nu",
    o = "omega",
    O = "Omega",
    p = "phi",
    P = "Phi",
    pv = "varphi",
    ph = "phi",
    Ph = "Phi",
    ps = "psi",
    pS = "Psi",
    Ps = "Psi",
    PS = "Psi",
    pi = "pi",
    Pi = "Pi",
    pI = "Pi",
    PI = "Pi",
    q = "psi",
    Q = "Psi",
    r = "rho",
    R = "varrho",
    s = "sigma",
    S = "Sigma",
    t = "theta",
    T = "Theta",
    tv = "vartheta",
    ta = "tau",
    u = "upsilon",
    U = "Uplislon",
    x = "xi",
    X = "Xi",
    z = "zeta",
}

h.triglist = "[%a|{}[]]"

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

ls.add_snippets(
    -- tex snippets
    "tex",
    {
        s({
            trig = "%-%-(%d)%-%-",
            name = "& expandor",
            dscr = "create snippet that expands the right amount of & infinetely",
            regTrig = true,
            hidden = true,
        }, {
            f(function(_, snip)
                h.aligncount = tonumber(snip.captures[1])
                return ""
            end, {}),
            d(1, h.alignsnippet, {}),
            i(0),
        }),

        -- Snippets for math text
        s(
            {
                trig = "fan([%a%d])",
                name = "fancy math text",
                dscr = "expands 'fancya' to \\mathcal{A}",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                return snip.captures[1]:lower() == snip.captures[1] and "\\mathcal{" .. snip.captures[1]:upper() .. "}"
                    or "\\mathcal{" .. snip.captures[1]:lower() .. "}"
            end, {})
        ),
        s(
            {
                trig = "calli([%a%d])",
                name = "calligraphy math text",
                dscr = "expands 'callia' to \\mathcal{A}",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                return snip.captures[1]:lower() == snip.captures[1] and "\\mathscr{" .. snip.captures[1]:upper() .. "}"
                    or "\\mathscr{" .. snip.captures[1]:lower() .. "}"
            end, {})
        ),
        s(
            {
                trig = "bo([%a%d])",
                name = "Bold math text",
                dscr = "Snippet for creating bold math text",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                return snip.captures[1]:lower() == snip.captures[1] and "\\mathbb{" .. snip.captures[1]:upper() .. "}"
                    or "\\mathbb{" .. snip.captures[1]:lower() .. "}"
            end, {})
        ),
        -- TODO: maybe add .* before gr, so that 2grpi could also expand to 2\pi
        s(
            {
                trig = "([gG][rR])(%a%a?)",
                name = "greek math text",
                dscr = "Snippet for creating greek letters",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                local letter = snip.captures[1]:lower() ~= snip.captures[1] and h.greek[snip.captures[2]:upper()]
                    or h.greek[snip.captures[2]]
                return (letter ~= nil and "\\" .. letter or "rip")
            end, {})
        ),
        s( -- TODO: add (?s) too abs snippet to use \| as the abs
            {
                trig = "abs(s?)%s(.+)%sabs",
                name = "absolute values",
                dscr = "replaces abs with |",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                abs = "|"
                if snip.captures[1] == "s" then
                    abs = "\\|"
                end
                return abs .. " " .. snip.captures[2] .. " " .. abs
            end, {})
        ),
        -- TODO: Add pnorm trig = "...norm[pi%d]"
        s(
            { trig = "norm%s(.+)%snorm", name = "norm", dscr = "replaces norm with |", regTrig = true, hidden = true },
            f(function(_, snip)
                return "\\| " .. snip.captures[1] .. " \\|"
            end, {})
        ),
        s(
            {
                trig = "[^\\]?bi(g+)%s(.+)%s[^\\]?bi(g+)",
                name = "Bigg Thicc",
                dscr = "depending on how many g's, replaces the text with latex \\Big command, the more g's the bigger the text",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                local outs = { [1] = [[\big ]], [2] = [[\Big ]], [3] = [[\bigg ]], [4] = [[\Bigg ]] }
                local size = outs[snip.captures[1]:len()]
                return size .. snip.captures[2] .. " " .. size
            end, {})
        ),

        -- product, integral, sum, infimum/minimum and supremum/maximum
        h.bigsymbol("prod", "prod", "product", "Creates product based on expression seperated by spaces"),
        h.bigsymbol("int", "int", "integral", "creates integral based on expression seperanted by spaces"),
        h.bigsymbol("sum", "sum", "sum", "creates sum based on expression seperated by spaces"),
        h.bigsymbol("inf", "inf", "infimum", "creates infimum based on expression seperated by spaces"),
        h.bigsymbol("min", "min", "minimum", "creates minimum symbol based on expression seperated by spaces"),
        h.bigsymbol("max", "max", "maximum", "creates maximum symbol based on expression seperated by spaces"),
        h.bigsymbol("sup", "sup", "supremum", "creates supremum based on expression seperated by spaces"),
        h.bigsymbol("cup", "cup", "??? symbol", "creates cup symbol based on expression seperated by spaces"),
        h.bigsymbol("cap", "cap", "??? symbol", "creates cap symbol based on expression seperated by spaces"),
        -- FIX: liminf und sup sind nicht ganz richtig, \rightarrow fehlt
        h.bigsymbol("liminf", "liminf", "??? symbol", "creates liminf symbol based on expression seperated by spaces"),
        h.bigsymbol("limsup", "limsup", "??? symbol", "creates limsup symbol based on expression seperated by spaces"),

        -- limes
        s(
            {
                trig = "lim%s(%S+)%s(%S+)",
                name = "limes",
                dscr = "creates limit sign based on expression seperated by spaces",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                return "\\lim_{" .. snip.captures[1] .. " \\rightarrow " .. snip.captures[2] .. "}"
            end, {})
        ),
        s(
            {
                trig = "(%d)r(%S+)",
                name = "n-th root",
                dscr = "creates n-th root based on expression seperated by the letter r",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                return "\\sqrt[" .. snip.captures[1] .. "]{" .. snip.captures[2] .. "}"
            end, {})
        ),

        -- Fraction snippets
        s(
            {
                trig = "(%S)/(%S)",
                name = "fraction easy mode",
                dscr = "expands (a/b) to a divided by b, a and b can both be numbers and letters",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                return "\\frac{" .. snip.captures[1] .. "}{" .. snip.captures[2] .. "}"
            end, {})
        ),
        s(
            {
                trig = "(%S+)%s/%s(%S+)",
                name = "fraction hard mode",
                dscr = "expands 'something / something' to according fraction",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                return "\\frac{" .. snip.captures[1] .. "}{" .. snip.captures[2] .. "}"
            end, {})
        ),
        s(
            {
                trig = "i(o?)(%-?[%a%d%.])(%-?[%a%d%.])",
                name = "interval",
                dscr = "expands 'iab' to open or closed interval from a to b",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                local mid = snip.captures[2]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                    .. ","
                    .. snip.captures[3]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                if snip.captures[1] == "o" then
                    return "(" .. mid .. ")"
                else
                    return "[" .. mid .. "]"
                end
            end, {})
        ),
        s(
            {
                trig = "i(o?)%s(%S+)%s(%S+)",
                name = "interval",
                dscr = "expands 'i bla bla' to '[bla,bla]' and 'io bla bla' to '(bla, bla)'",
                regTrig = true,
                hidden = true,
            },
            f(function(_, snip)
                local mid = snip.captures[2]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                    .. ","
                    .. snip.captures[3]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                if snip.captures[1] == "o" then
                    return "(" .. mid .. ")"
                else
                    return "[" .. mid .. "]"
                end
            end, {})
        ),
        s(
            {
                trig = "ih(%-?[%a%d%.])(%-?[%a%d%.])",
                name = "half opened interval choice node",
                dscr = "expands 'ihba' to choice node '(b, a] OR [b, a)'",
                regTrig = true,
                hidden = true,
            },
            c(1, {
                f(function(_, snip)
                    return "("
                        .. snip.captures[1]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                        .. ","
                        .. snip.captures[2]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                        .. "]"
                end, {}),
                f(function(_, snip)
                    return "["
                        .. snip.captures[1]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                        .. ","
                        .. snip.captures[2]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                        .. ")"
                end, {}),
            })
        ),
        s(
            {
                trig = "ih%s(%S+)%s(%S+)",
                name = "half opened interval choice node",
                dscr = "expands 'ih bla bla' to choice node '(bla, bla] OR [bla, bla)'",
                regTrig = true,
                hidden = true,
            },
            c(1, {
                f(function(_, snip)
                    return "("
                        .. snip.captures[1]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                        .. ","
                        .. snip.captures[2]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                        .. "]"
                end, {}),
                f(function(_, snip)
                    return "["
                        .. snip.captures[1]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                        .. ","
                        .. snip.captures[2]:gsub("inf", "\\infty"):gsub("%.", "\\infty")
                        .. ")"
                end, {}),
            })
        ),
        s(
            { trig = "(%a)x(%a)", name = "times", dscr = "expands dxd to d \times d", regTrig = true, hidden = true },
            f(function(_, snip)
                return snip.captures[1] .. "\\times " .. snip.captures[2]
            end, {})
        ),

        -- snippets for sub and superscript for single letters and longer expressions
        -- s(
        --   { trig = "(%S+)%ss%s(.+)", name = "sub/superscript in general", dscr = "expands superscript or subscript expressions",  regTrig = true, hidden = true },
        --     c(1,{
        --       f(function(_, snip)
        --         return snip.captures[1] .. "^{" .. snip.captures[2] .. "}"
        --       end, {}),
        --       f(function(_, snip)
        --         return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
        --       end, {})
        --   })
        -- ),
        s(
            {
                trig = "([^{%spi+:$%.-]+)%ss%s(.+)",
                name = "sub/superscript in general",
                dscr = "expands superscript or subscript expressions",
                regTrig = true,
                hidden = true,
            },
            c(1, {
                f(function(_, snip)
                    return snip.captures[1] .. "^{" .. snip.captures[2] .. "}"
                end, {}),
                f(function(_, snip)
                    return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
                end, {}),
            })
        ),

        -- TODO: remove "i, p" from here, instead change snippet priority
        s(
            {
                trig = "([^{%spi+:$%.]+)%s?([%diknd])",
                name = "subscript and superscript",
                dscr = "expands superscript or subscript numbers, depending on choice",
                regTrig = true,
                hidden = true,
            },
            c(1, {
                f(function(_, snip)
                    return snip.captures[1] .. "^{" .. snip.captures[2] .. "}"
                end, {}),
                f(function(_, snip)
                    return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
                end, {}),
            })
        ),
        s({
            trig = "([Nn][Aa][Cc][Hh])",
            name = "nach",
            dscr = "\\rightarrow or \\mapsto choicenode",
            regTrig = true,
            hidden = true,
        }, {
            f(function(_, snip)
                h.temp = (snip.captures[1]:lower() == snip.captures[1])
                return ""
            end, {}),
            d(1, function(_)
                return h.returnfunc(h.temp, "\\rightarrow", "\\mapsto")
            end, {}),
        }),
    }
)

ls.add_snippets("obsidian", {
    -- snippet for markdown comment
    s("inttheo", {
        t {
            "---",
            "tags: ana/inttheo",
            "date: " .. os.date "%d-%m-%Y",
            "vorlesung: ",
        },
        i(1, "23"),
        t { "", "kapitel: " },
        i(2, "7.0"),
        t { "", "aliases:" },
        i(3),
        t { "", "---", "" },
        i(0),
    }),
    s("stat", {
        t {
            "---",
            "tags: WS/EinfStochastik",
            "date: " .. os.date "%d-%m-%Y",
            "vorlesung: ",
        },
        i(1, "22"),
        t { "", "kapitel: " },
        i(2, "5.8"),
        t { "", "aliases:" },
        i(3),
        t { "", "---", "" },
        i(0),
    }),
})

-- TODO: double snippets, add "\mathop{}\!\mathrm{d}" as snippet, vllt metrischer Raum snippet, \rightarrow

ls.filetype_extend("latex", { "tex", "obsidian" })
ls.filetype_extend("markdown", { "tex", "obsidian", "text" })
ls.filetype_extend("vimwiki", { "obsidian", "tex", "text" })
ls.filetype_extend("tex", { "obsidian" })
ls.filetype_extend("html", { "text", "tex" })

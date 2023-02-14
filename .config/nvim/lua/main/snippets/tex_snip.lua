local status_ok, ls = pcall(require, "luasnip")
if not status_ok then
    return
end

local extras = require "luasnip.extras"

local h = require("main.snippets.helpers").tex

local s_mathonly = h.s_mathonly

local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local events = require "luasnip.util.events"

local complex = {
    -- shady stuff
    -- s_mathonly(
    --     {
    --         trig = "mathlink",
    --         dscr = "opens dialog to create mathlink",
    --     },
    --     t"", {callbacks = {[-1] = {[events.pre_expand] = function(snippet, event_args) print("test") require("main.obsidian").obsidian.mathlink() print("worked?") end}}}
    -- ),

    s_mathonly(
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
    s_mathonly({
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
    s_mathonly({
        trig = "vec(%d)(%d?)",
        name = "vector",
        dscr = "creates vector with length %d",
        regTrig = true,
        hidden = true,
    }, {
        t "\\begin{pmatrix}",
        d(1, function(_, snip)
            local out = {}
            -- print(snip.captures[2] == "" and "NIL" or snip.captures[2])
            local m = tonumber(snip.captures[1])
            local n = snip.captures[2] == "" and 1 or tonumber(snip.captures[2])
            -- if 1x1 matrix
            if n == 1 and m == 1 then
                return sn(nil, { i(1) })
            end
            -- create first row
            for j = 1, n - 1, 1 do
                out[#out + 1] = i(j)
                out[#out + 1] = t " & "
            end
            out[#out + 1] = i(n)

            -- create more rows if necessary
            -- for each remaining row
            for ii = 2, m do
                -- append \\ for another
                out[#out + 1] = t " \\\\ "
                -- and create another row
                for j = 1, n - 1, 1 do
                    out[#out + 1] = i((ii - 1) * n + j)
                    out[#out + 1] = t " & "
                end
                out[#out + 1] = i(ii * n)
            end
            return sn(nil, out)
        end, {}),
        t "\\end{pmatrix}",
        i(0),
    }),

    s_mathonly(
        {
            trig = "fan([%a%d])",
            name = "fancy math text",
            dscr = "expands 'fancya' to \\mathcal{A}",
            regTrig = true,
            hidden = true,
            snippetType = "autosnippet",
        },
        f(function(_, snip)
            return snip.captures[1]:lower() == snip.captures[1] and "\\mathcal{" .. snip.captures[1]:upper() .. "}"
                or "\\mathcal{" .. snip.captures[1]:lower() .. "}"
        end, {})
    ),
    s_mathonly(
        {
            trig = "calli([%a%d])",
            name = "calligraphy math text",
            dscr = "expands 'callia' to \\mathcal{A}",
            regTrig = true,
            hidden = true,
            snippetType = "autosnippet",
        },
        f(function(_, snip)
            return snip.captures[1]:lower() == snip.captures[1] and "\\mathscr{" .. snip.captures[1]:upper() .. "}"
                or "\\mathscr{" .. snip.captures[1]:lower() .. "}"
        end, {})
    ),
    s_mathonly(
        {
            trig = "bo([%a%d])",
            name = "Bold math text",
            dscr = "Snippet for creating bold math text",
            regTrig = true,
            hidden = true,
            snippetType = "autosnippet",
        },
        f(function(_, snip)
            return snip.captures[1]:lower() == snip.captures[1] and "\\mathbb{" .. snip.captures[1]:upper() .. "}"
                or "\\mathbb{" .. snip.captures[1]:lower() .. "}"
        end, {})
    ),
    s_mathonly(
        {
            trig = "fat([%a%d])",
            name = "fat/bold math text, not letters",
            dscr = "expands 'fata' to \\\boldsymbol{a}",
            regTrig = true,
            hidden = true,
            snippetType = "autosnippet",
        },
        f(function(_, snip)
            return "\\boldsymbol{" .. snip.captures[1] .. "}"
        end, {})
    ),
    s_mathonly(
        {
            trig = "(b?)v([%a%d])",
            name = "fat/bold math text with \\bar inside",
            dscr = "expands 'va' to \\\boldsymbol{a} and bva to \\boldsymbol{\\bar a}",
            regTrig = true,
            hidden = true,
            snippetType = "autosnippet",
        },
        f(function(_, snip)
            return snip.captures[1] == "b" and "\\boldsymbol{\\bar " .. snip.captures[2] .. "}"
                or "\\boldsymbol{" .. snip.captures[2] .. "}"
        end, {})
    ),
    -- TODO: maybe add .* before gr, so that 2grpi could also expand to 2\pi
    s_mathonly(
        {
            trig = "([gG][rR])(%a[%a%s])",
            name = "greek math text",
            dscr = "Snippet for creating greek letters",
            regTrig = true,
            hidden = true,
            snippetType = "autosnippet",
        },
        f(function(_, snip)
            local letter = snip.captures[1]:lower() ~= snip.captures[1] and h.greek[snip.captures[2]:upper():gsub("%s","")]
                or h.greek[snip.captures[2]:gsub("%s", "")]
            return (letter ~= nil and "\\" .. letter or "rip")
        end, {})
    ),
    s_mathonly(
        {
            trig = "abs(s?)%s([^$]+)%sabs",
            name = "absolute values",
            dscr = "replaces abs with |",
            regTrig = true,
            hidden = true,
        },
        f(function(_, snip)
            local abs = "|"
            if snip.captures[1] == "s" then
                abs = "\\|"
            end
            return abs .. " " .. snip.captures[2] .. " " .. abs
        end, {})
    ),
    -- TODO: Add pnorm trig = "...norm[pi%d]"
    s_mathonly(
        { trig = "norm%s(.+)%snorm", name = "norm", dscr = "replaces norm with |", regTrig = true, hidden = true },
        f(function(_, snip)
            return "\\| " .. snip.captures[1] .. " \\|"
        end, {})
    ),
    s_mathonly(
        {
            trig = "[^\\]?bi(g+)%s([^$]+)%s[^\\]?bi(g+)",
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
    h.bigsymbol("cup", "cup", "∪ symbol", "creates cup symbol based on expression seperated by spaces"),
    h.bigsymbol("cap", "cap", "∩ symbol", "creates cap symbol based on expression seperated by spaces"),
    h.bigsymbol("bcup", "bigcup", "big ∪ symbol", "creates cup symbol based on expression seperated by spaces"),
    h.bigsymbol("bcap", "bigcap", "big ∩ symbol", "creates cap symbol based on expression seperated by spaces"),
    -- FIX: liminf und sup sind nicht ganz richtig, \rightarrow fehlt
    h.bigsymbol("limf", "liminf", "limes inferior", "creates liminf symbol based on expression seperated by spaces"),
    h.bigsymbol("lsup", "limsup", "limes superior", "creates limsup symbol based on expression seperated by spaces"),

    -- limes
    s_mathonly(
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
    s_mathonly(
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
    s_mathonly(
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
    s_mathonly(
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
    s_mathonly(
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
    s_mathonly(
        {
            trig = "i(o?)%s([^%s\\]+)%s([^%s\\]+)",
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
    s_mathonly(
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
    s_mathonly(
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
    s_mathonly(
        { trig = "(%a)x(%a)", name = "times", dscr = "expands dxd to d \times d", regTrig = true, hidden = true },
        f(function(_, snip)
            return snip.captures[1] .. "\\times " .. snip.captures[2]
        end, {})
    ),

    -- snippets for sub and superscript for single letters and longer expressions
    -- s_mathonly(
    --   { trig = "(%S+)%ss%s_mathonly(.+)", name = "sub/superscript in general", dscr = "expands superscript or subscript expressions",  regTrig = true, hidden = true },
    --     c(1,{
    --       f(function(_, snip)
    --         return snip.captures[1] .. "^{" .. snip.captures[2] .. "}"
    --       end, {}),
    --       f(function(_, snip)
    --         return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
    --       end, {})
    --   })
    -- ),
    s_mathonly(
        {
            trig = "([^{%spi+:$%&.\\,%(%)-_=*<>]+)%ss%s([^$_%^]+)",
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
    s_mathonly(
        {
            trig = "([^{%spi+:$%.&+%(%)\\-,_=*<>]+)%s?([%diknd])",
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
    s_mathonly({
        trig = "([Nn][Aa][Cc][Hh])",
        name = "nach",
        dscr = "\\rightarrow or \\mapsto choicenode",
        regTrig = true,
        hidden = true,
    }, {
        d(1, function(_, snip)
            temp = (snip.captures[1]:lower() == snip.captures[1])
            return h.bool_choice(temp, "\\rightarrow", "\\mapsto")
        end, {}),
    }),
    -- s_mathonly("test", { i(1), t { "", "" }, rep(1) }),
    s_mathonly({
        trig = "([Tt][Ee][Ii][Ll])",
        name = "⊂ and ⊆",
        dscr = "\\subset or \\subseteq choicenode",
        regTrig = true,
        hidden = true,
    }, {
        d(1, function(_, snip)
            temp = (snip.captures[1]:lower() == snip.captures[1])
            return h.bool_choice(temp, "\\subset", "\\subseteq")
        end, {}),
    }),
    s_mathonly("begin", {
        t "\\begin{",
        i(1),
        t { "}", "" },
        i(0),
        t { "", "\\end{" },
        d(2, function(args)
            return sn(nil, { t(args[1]) })
        end, { 1 }),
        t "}",
    }),
}

local simple = {
    s_mathonly( "root", { t "\\sqrt[", i(1), t "]{", i(2), t "}", i(3), t "" } ),
    s_mathonly( "text", { t "\\text{", i(1), t "}", i(2), t "" } ),
    s_mathonly( "frac", { t "\\frac{", i(1), t "}{", i(2), t "}", i(3), t "" } ),
    s_mathonly( "sum", { t "\\sum_{", i(1), t "}^{", i(2), t "}", i(3), t "" } ),
    s_mathonly( "lim", { t "\\lim_{", i(1), t " \\rightarrow \\infty", i(2), t " } ", i(3), t "" } ),
    s_mathonly( "align", { t "\\begin{align*}", t "", i(1), t "", t "\\end{align*}", t "" } ),
}

local simple_autotrig = {
    { "cdot", { t "\\cdot " } },
    { "exi",   { t "\\exists " } },
    { "quad", { t "\\quad " } },
    { "bar", { t "\\bar " } },
    { "inn", { t "\\in " } },
    { "nin", { t "\\notin " } },
    { "inf", { t "\\infty" } },
    { "cup", { t "\\cup" } },
    { "cap", { t "\\cap" } },
    { "gleich", { t "\\Leftrightarrow " } },
    { "gdw", { t "\\iff " } },
    { "iff", { t "\\iff " } },
    { "lrarrow", { t "\\Leftrightarrow " } },
    { "partial", { t "\\partial " } },
    { "kl", { t "\\leq " } },
    { "ge", { t "\\geq " } },
    { "also", { t "\\Rightarrow " } },
    { "tilde", { t "\\tilde " } },
    { "sin", { t "\\sin " } },
    { "cos", { t "\\cos " } },
    { "tan", { t "\\tan " } },
    { "asin", { t "\\arcsin " } },
    { "acos", { t "\\arccos " } },
    { "atan", { t "\\arctan " } },
    { "cosh", { t "\\cosh " } },
    { "sinh", { t "\\sinh " } },
    { "tanh", { t "\\tanh " } },
    { "sm", { t "\\setminus " } },
    { "ohne", { t "\\setminus " } },
    { "fall", { t "\\forall " } },
    { "leer", { t "\\emptyset " } },
    { "neq", { t "\\neq " } },
    { "times", { t "\\times " } },
    { "choose", { t "{", i(1), t " \\choose ", i(2), t "}", i(3), t "" } },
    { "color", { t "\\textcolor{", i(1), t "}{", i(2), t "}", i(3), t "" } },
    { "overline", { t "\\overline{", i(1), t "}", i(2), t "" } },
    { "unten", { t "\\underset{", i(1), t "}{", i(2), t "}", i(3), t "" } },
    { "oben", { t "\\overset{", i(1), t "}{", i(2), t "}", i(3), t "" } },
    { "men", { t "\\{", i(1), t "\\}", i(2), t "" } },
    { "set", { t "\\{", i(1), t "\\}", i(2), t "" } },
    { "bul", { t "\\bullet " } },
}

local simple_autotrig_snips = {}

for _, s in pairs(simple_autotrig) do
  simple_autotrig_snips[#simple_autotrig_snips+1] = s_mathonly({trig = s[1], snippetType="autosnippet"}, s[2])
end

ls.add_snippets("tex", simple_autotrig_snips)
ls.add_snippets("tex", simple)
ls.add_snippets("tex", complex)

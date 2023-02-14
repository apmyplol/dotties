local status_ok, ls = pcall(require, "luasnip")
if not status_ok then
    return
end

local h = {}
h.tex = {}
h.obsidian = {}
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node

local inmath = require("main.helpers").inmath

local s = ls.snippet
h.tex.f = ls.function_node

h.tex.s_mathonly = ls.extend_decorator.apply(s, {}, { condition = inmath })
h.obsidian.s_nomath = ls.extend_decorator.apply(s, {}, {
    condition = function()
        return not inmath()
    end,
})

h.tex.bigsymbol = function(trig, tex, name, desc) -- creates big math symbol snippet, e.g. sum, integral,. etc
    -- print("[^\\]" .. trig .. "%s%(?([^()]+)%)?%s?%s(.+)")
    return h.tex.s_mathonly(
        -- %s(%S+)%s(.+) ersetzt durch  %s%(?([^()]+)%)?%s(%S+)
        {
            trig = "([^\\])" .. trig .. "%s%(?([^()]+)%)?%s?%s(.+)",
            name = name,
            dscr = desc,
            regTrig = true,
            hidden = true,
        },
        h.tex.f(function(_, snip)
            local out = snip.captures[1] .. "\\" .. tex .. "_{" .. snip.captures[2] .. "}"
            if snip.captures[3] ~= " " then
                out = out .. "^{" .. snip.captures[3] .. "}"
            end
            return out
        end, {})
    )
end

h.tex.temp = nil

-- if bool then return choice node with text nodes made out of `choice1` and `choice2` in the same order
-- else return choice node with textnodes in order `choisc2` `choice1`
h.tex.bool_choice = function(bool, choice1, choice2)
    local order = bool and { t(choice1), t(choice2) } or { t(choice2), t(choice1) }
    return sn(nil, { c(1, order) })
end

-- `choices`: list of possible snippets
-- `active`: the index of the snippet that should be selected as first element
-- **return**: choice node with order {active, ..., n, 1, ..., active-1} where n is the length if choices
h.tex.multiple_choice = function(active, choices)
    return sn(nil, { c(1, table.unpack(choices, active), table.unpack(choices, 1, active - 1)) })
end

h.tex.alignsnippet = function()
    if h.tex.aligncount == nil then
        return t "hmm"
    end
    local args = { t "\t" }
    for k = 1, h.tex.aligncount - 1, 1 do
        args[#args + 1] = i(k)
        args[#args + 1] = t " & "
    end
    args[#args + 1] = i(h.tex.aligncount)
    args[#args + 1] = t { "\\\\", "" }
    args[#args + 1] = d(h.tex.aligncount + 1, h.tex.alignsnippet, {})
    return sn(
        nil,
        c(1, {
            -- Order is important, sn(...) first would cause infinite loop of expansion.
            t "",
            sn(nil, args),
        })
    )
end

h.tex.greek = {
    a = "alpha",
    b = "beta",
    c = "chi",
    d = "delta",
    "Delta",
    e = "varepsilon",
    E = "epsilon",
    ve = "varepsilon",
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
    vp = "varphi",
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
    vr = "varrho",
    s = "sigma",
    S = "Sigma",
    t = "theta",
    T = "Theta",
    vt = "vartheta",
    ta = "tau",
    u = "upsilon",
    U = "Uplislon",
    x = "xi",
    X = "Xi",
    z = "zeta",
}

return h

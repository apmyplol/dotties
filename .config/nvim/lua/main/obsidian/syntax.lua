-- import tex stuff
vim.cmd("syntax include syntax/tex.vim")

vim.cmd("syntax cluster mathjax contains=texMathZoneTI,texMathZoneTD")

local simplematch = function(name, pattern)
  vim.cmd("syntax match " .. name .. " /" .. pattern .. "/")
end

-- YAML Frontmatter
vim.cmd([[syntax region ObsYamlFM start=/\%^---/ end=/---/ fold]])


-- Headers 1-6
for i = 1, 6, 1 do
  local pattern = "^" .. string.rep("#", i) .. "\\s.*"
  local name = "ObsH" .. i
  simplematch(name, pattern)
end


-- Textblock links
simplematch("ObsTextBlockRef", [[^\^.*$]])

-- callout header
simplematch("ObsCalloutHEAD", [[^>\s\[.*$]])

-- quotes
vim.cmd("syntax region ObsQuote start=/^>\\s[^[]/ end=/^>\\s[^[].*$\\n\\([^>]\\|\\n\\)/ fold contains=@ObsLink,@mathjax keepend nextgroup=ObsTextBlockRef skipempty")

-- callouts
vim.cmd([[syntax region ObsCallout start=/^>\s\[/ end=/^>\s[^[].*$\n[^>]/me=e-1 contains=ObsCalloutHEAD,@ObsLink,@mathjax keepend fold]])

-- links with rename thing
vim.cmd("syntax match ObsLinkRename /\\[\\[.\\{-1,}|.\\{-1,}\\]\\]/ contains=ObsLinkName,ObsLinkDest,ObsLinkConcealChars keepend")

-- the rename value
vim.cmd("syntax match ObsLinkName /|.\\{-1,}\\]\\]/ms=s+1,me=e-2")

-- link destination
vim.cmd("syntax match ObsLinkDest /\\[\\[.\\{-1,}|/ms=s+2 conceal")

-- links without rename
vim.cmd("syntax match ObsLinkNoRename /\\[\\[[^\\|]\\{-1,}\\]\\]/ keepend")


vim.cmd("syntax cluster ObsLink contains=ObsLinkName,ObsLinkDest,ObsLinkNoRename,ObsLinkRename")


-- vim.cmd([[
-- hi def link ObsLinkName Underlined
-- hi def link ObsLinkDest Underlined
-- hi def link ObsLinkNoRename Underlined
-- hi def link ObsLinkRename Underlined
-- hi def link ObsYamlFM StatusLine
-- hi def link ObsTextBlockRef StatusLine
-- " hi def link ObsCalloutHEAD PmenuThumb
-- " hi def link ObsCallout PmenuThumb
-- ]])


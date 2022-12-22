M = {}

M.visual_selection_range = function()
    local _, csrow, cscol, _ = unpack(vim.fn.getpos "'<")
    local _, cerow, cecol, _ = unpack(vim.fn.getpos "'>")
    if csrow < cerow or (csrow == cerow and cscol <= cecol) then
        return csrow - 1, cscol - 1, cerow - 1, cecol
    else
        return cerow - 1, cecol - 1, csrow - 1, cscol
    end
end

M.inmath = function()
    local pos =
        vim.api.nvim_command_output [[echo join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), ' > ')]]
    return pos:find "VimwikiEqIn"
        or pos:find "textSnipTEX"
        or pos:find "texMathDelimZimeTI"
        or pos:find "texMathZoneTI"
        or pos:find "texMathDelimZimeTD"
        or pos:find "texMathZoneTD"
end

return M

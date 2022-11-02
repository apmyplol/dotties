local status_ok, acmd = pcall(require, "autocmd-lua")
if not status_ok then
    return
end

acmd.augroup {
    "filetype_commands",
    {
        {
            "FileType",
            {
                vimwiki = function()
                    print "bla"
                    local path = vim.fn.stdpath "data" .. "/site/pack/packer/start"
                    vim.cmd([[function! Bla()
    setlocal matchpairs=(:),{:},[:],":"
    ]] .. "source " .. path .. [[/vim-matchup/after/ftplugin/tex_matchup.vim
    endfunction
    let g:matchup_hotfix = {'vimwiki': 'Bla'}
    ]])
                end,
            },
        },
    },
}
-- function! MDfix()
--       echo "MDfix
--       let g:vimtex_enabled = 1
-- endfunction
-- let g:matchup_hotfix = { 'vimwiki': 'MDfix' }

-- acmd.augroup{
--   group = "test_fold",
--   autocmds = {
--     {"BufWinEnter", "*", cmd = function()
--        if vim.opt["foldmethod"]["_value"] == "manual" then
--          if not pcall(vim.cmd("silent! loadview")) then print("loadview error") end
--        end
--     end},
--     {"BufWinLeave", "*", cmd = function()
--        if vim.opt["foldmethod"]["_value"] == "manual" then
--          if not pcall(vim.cmd("mkview")) then print("mkview error") end
--        end
--     end},
--   }
-- }
-- -- OR
-- require('autocmd-lua').augroup {
--   -- the keys `group` and `autocmds` are also optional
--   'filetype_commands',
--   {{
--     'FileType', {
--       lua = function() do_something end,
--       markdown = 'set sw=2',
--       -- these keys are passed as the pattern
--       ['help,man'] = 'nmap q :q<CR>',
--     }
--   }}
-- }

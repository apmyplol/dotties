vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = "*.md",
    callback = function()
        local status_ok, which_key = pcall(require, "which-key")
        if not status_ok then
            return
        end
        which_key.register {
                ["<leader>Ll"] = { "<plug>(vimtex-compile)", "Start latex compile" },
        }
    end,
})

local g = vim.g

g.tex_flavor='latex'
--g.vimtex_view_method='zathura'
g.vimtex_quickfix_mode=0
g.tex_conceal='abdmg'
vim.api.nvim_set_option("conceallevel", 1)

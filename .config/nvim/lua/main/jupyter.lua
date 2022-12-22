-- stuff to install:
-- pynvim
-- jupyter_client
-- ueberzug
-- cairosvg
-- pnglatex
-- plotly
-- kaleido

-- keymaps are set in which-key.lua

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = "*.ipynb",
    callback = function()
        local status_ok, which_key = pcall(require, "which-key")
        if not status_ok then
            return
        end
        vim.api.nvim_command "set filetype=ipynb"
        which_key.register {
            ["<leader>np"] = {
                "<cmd>call jukit#convert#notebook_convert('jupyter-notebook')<CR>",
                "start output split",
            },
        }
    end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = "*.py",
    callback = function()
        local status_ok, which_key = pcall(require, "which-key")
        if not status_ok then
            return
        end
        which_key.register (
            {
                ["["] = { "<cmd>call jukit#cells#jump_to_previous_cell()<cr>", "jump to cell above" },
                ["]"] = { "<cmd>call jukit#cells#jump_to_next_cell()<cr>", "jump to cell below" },
                ["<cr>"] = { "<cmd>call jukit#send#section(0)<cr>", "send cell to jupyter" },
                ["<leader>"] = {
                    ["<cr>"] = { "<cmd>call jukit#send#all()<cr>", "send all to jupyter" },
                },
                ["<leader>J"] = {
                    name = "Jupyter / python stuff",
                    S = { "<cmd>call jukit#splits#output()<cr>", "start output split" },
                    T = { "<cmd>call jukit#splits#term()<cr>", "start split without commands" },
                    d = { "<cmd>call jukit#cells#delete_outputs(0)<cr>", "delete output of current cell" },
                    D = { "<cmd>call jukit#cells#delete_outputs(1)<cr>", "delete output of all cells" },
                    ["c"] = {
                        name = "cell manipulation",
                        c = { "<cmd>call jukit#cells#create_below(0)<cr>", "code cell below" },
                        C = { "<cmd>call jukit#cells#create_above(0)<cr>", "code cell above" },
                        t = { "<cmd>call jukit#cells#create_below(1)<cr>", "text cell below" },
                        T = { "<cmd>call jukit#cells#create_above(1)<cr>", "text cell above" },
                        d = { "<cmd>call jukit#cells#delete()<cr>", "delete cell" },
                        s = { "<cmd>call jukit#cells#split()<cr>", "split cell" },
                        m = { "<cmd>call jukit#cells#merge_below()<cr>", "merge with below cell" },
                        M = { "<cmd>call jukit#cells#merge_above()<cr>", "merge with cell above" },
                        k = { "<cmd>call jukit#cells#move_up()<cr>", "move cell up" },
                        j = { "<cmd>call jukit#cells#move_down()<cr>", "move cell down" },
                        R = {
                            "<cmd>call jukit#convert#notebook_convert('jupyter-notebook')<CR>",
                            "convert back to notebook",
                        },
                        h = {"<cmd>call jukit#convert#save_nb_to_file(0,1,'html')<cr>", "convert to html"},
                    },
                    ["["] = { "<cmd>call jukit#cells#jump_to_previous_cell()<cr>", "jump to cell above" },
                    ["]"] = { "<cmd>call jukit#cells#jump_to_next_cell()<cr>", "jump to cell below" },
                    h = { "<cmd>call jukit#convert#save_nb_to_file(0,1,'html')<cr>", "convert to html" },
                },
            },
            {
                mode = "n", -- NORMAL mode
                buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
                silent = true, -- use `silent` when creating keymaps
                noremap = true, -- use `noremap` when creating keymaps
                nowait = true, -- use `nowait` when creating keymaps
            }
        )
        which_key.register({
            ["<cr>"] = { "<cmd>call jukit#send#section()<cr>", "send cell to jupyter" },
        }, { mode = "v" })
    end,
})

-- vim.cmd("let g:magma_automatically_open_output = v:false")
-- vim.cmd 'let g:magma_image_provider = "ueberzug"'
-- vim.cmd "let g:magma_wrap_output = v:true"
-- vim.g.magma_save_path = vim.fn.stdpath "data" .. "/magma"
-- vim.cmd("let g:magma_show_mimetype_debug = v:true")
-- vim.g.jupytext_fmt = "py"
vim.g.jukit_hist_use_ueberzug = 0
-- use which-key to make bindings myself
vim.g.jukit_mappings = 0
-- vim.g.jukit_ueberzug_use_cached = 1
vim.g.jukit_ueberzug_cutycapt_cmd = "/usr/bin/wkhtmltoimage"

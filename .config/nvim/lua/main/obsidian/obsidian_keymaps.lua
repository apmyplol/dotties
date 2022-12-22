O = {}

local status_ok, workspaces = pcall(require, "workspaces")
if not status_ok then
    return
end

local status_ok, helpers = pcall(require, "main.helpers")
if not status_ok then
    return
end

local init_autocmd = function()
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        pattern = "*.md",
        callback = function()
      --       vim.cmd [[
      --   unlet b:current_syntax
      --   runtime syntax/tex.vim
      -- ]]
        end,
    })
end

O.hook = function()
    if workspaces.name() == "wiki" then
        -- when going into workspace wiki then
        -- change clipiboard image path
        local status_ok, clipimage = pcall(require, "clipboard-image")
        if not status_ok then
            return
        end
        clipimage.setup {
            vimwiki = {
                img_dir = { "Bilder" },
                img_dir_txt = "",
                affix = "![[%s]]",
            },
        }

        -- activate autocommand for markdown files
        init_autocmd()

        -- add vimwiki hotkeys
        local status_ok, which_key = pcall(require, "which-key")
        if not status_ok then
            return
        end
        which_key.register {
            ["<CR>"] = { "<cmd>VimwikiFollowLink<cr>", "Vimwiki Follow Link" },
            ["<leader>W"] = {
                j = { "<cmd>VimwikiNextLink<cr>", "goto Next wiki link" },
                k = { "<cmd>VimwikiPrevLink<cr>", "goto prev wiki link" },
                c = { "<cmd>!xdg-open obsidian://open?vault=wiki\\&file=%<cr><cr>", "opens current file in obsidian" },
                p = { "<cmd>PasteImg<cr>", "paste image from clipboard" },
            },
            ["<leader>f"] = { "<cmd> lua require 'main.obsidian'.obsidian.findfile()<cr><Esc>", "find file in wiki" },
            ["<leader>F"] = {
                "<cmd> lua require 'main.obsidian'.obsidian.nonwiki()<cr><Esc>",
                "open non wiki file such as pdf",
            },
            ["<c-l>"] = { [[llvf|h"lxxvwh"nxhxx"nPla(<c-r>l)]], "change link format to [ref](link)" },
        }

        local opts = { noremap = true, silent = true }
        -- vim.api.nvim_set_keymap("v", "<C-b>", [[<cmd>lua require 'main.helpers'.visual_selection_range()<CR>]], opts)
        which_key.register({
            ["<C-i>"] = { [[c*<c-r>"*]], "surround with *" },
            ["<C-b>"] = { [[c**<c-r>"**]], "surround with **" },
        }, { mode = "v", noremap = true, silent = true, nowait = true })

        which_key.register({
            ["<c-u>"] = { [[<cmd>lua require 'main.obsidian'.obsidian.fileref_popup()<CR>]], "wikilink autocomplete" },
            ["<c-z>"] = { [[<cmd>lua require 'main.obsidian'.obsidian.mathlink()<CR>]], "mathlink autocomplete" },
        }, { mode = "i", noremap = true, silent = true, nowait = true })
    end
end

return O

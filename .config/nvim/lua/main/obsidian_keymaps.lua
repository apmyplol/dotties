
O = {}

local status_ok, workspaces = pcall(require, "workspaces")
if not status_ok then
    return
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
                c = { "<cmd>VimwikiGoto<cr>", "crates vimwiki link" },
                p = {"<cmd>PasteImg<cr>", "paste image from clipboard"}
            },
            ["<leader>f"] = {"<cmd> lua require 'main.obsidian'.findfile()<cr>", "find file in wiki"},
            ["<leader>F"] = {"<cmd> lua require 'main.obsidian'.nonwiki()<cr>", "open non wiki file such as pdf"}
        }
    end
end

return O

-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
--     pattern = "*.md",
--     callback = function()
--         local status_ok, which_key = pcall(require, "which-key")
--         if not status_ok then
--             return
--         end
--         which_key.register {
--             ["<CR>"] = {
--                 "<cmd>VimwikiFollowLink<CR>",
--                 "follow markdown link",
--             },
--             ["<leader>F"] = {}
--         }
--     end,
-- })

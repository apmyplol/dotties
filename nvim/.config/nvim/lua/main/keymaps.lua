local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- mapping "h" onto "ö" for better navigation

keymap("n", "ö", "h", opts)

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
-- moving between *windows* with arrow keys
keymap("n", "<Up>", "<C-w>k", opts)
keymap("n", "<Down>", "<C-w>j", opts)
keymap("n", "<Left>", "<C-w>h", opts)
keymap("n", "<Right>", "<C-w>l", opts)

keymap("n", "<leader>e", ":NvimTreeToggle<cr>", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers , someting like tabs in vim
keymap("n", "<S-k>", ":bnext<CR>", opts)
keymap("n", "<S-j>", ":bprevious<CR>", opts)
keymap("n", "<C-w>", ":Bdelete<CR>", opts)
-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)


-- W um word zurück zu springen
keymap("n", "W", "b", opts)
-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- map ö for selecting blocks
keymap("x", "ö", "h", opts)

-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

-- Telescope
keymap("n", "<leader>f", "<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown())<cr>", opts)
keymap("n", "<c-t>", "<cmd>Telescope live_grep<cr>", opts)

-- open current file latex preview
keymap("n", "<leader>l", "<cmd>lua require'main.keymapfunctions'.latex()<cr>", opts)

-- keymap for chose-nodes in luasnip
keymap("i", "<C-k>", "<cmd>lua require 'main.keymapfunctions'.luasnipchoose(-1)<cr>", opts)
keymap("i", "<C-j>", "<cmd>lua require 'main.keymapfunctions'.luasnipchoose(1)<cr>", opts)

-- vimtex
keymap("n", "<leader>ll", "<plug>(vimtex-compile)", opts)

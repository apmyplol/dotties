local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    }
    print "Installing packer close and reopen Neovim..."
    vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end,
    },
}

-- Install your plugins here e
return packer.startup(function(use)
    -- My plugins here

    use "lunarvim/colorschemes" -- fancy color schemes

    use "wbthomason/packer.nvim" -- Have packer manage itself
    use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
    use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins
    -- use "sheerun/vim-polyglot" -- better Syntax support
    use "windwp/nvim-autopairs" -- autocomplete for ( { [

    -- File explorer and telescope for search
    use "kyazdani42/nvim-web-devicons"
    use { "kyazdani42/nvim-tree.lua", requires = "nvim-web-devicons" }

    -- Telescope
    use "nvim-telescope/telescope.nvim"
    -- use "nvim-telescope/telescope-media-files.nvim"

    -- Bufferline to see which bufferes are opened
    use "akinsho/bufferline.nvim"

    use "moll/vim-bbye" -- for :Bdelete

    -- cmp plugins
    use "hrsh7th/nvim-cmp" -- The completion plugin
    use "hrsh7th/cmp-buffer" -- buffer completions
    use "hrsh7th/cmp-path" -- path completions
    use "hrsh7th/cmp-cmdline" -- cmdline completions
    use "hrsh7th/cmp-nvim-lsp" -- cmdline completions
    use "hrsh7th/cmp-nvim-lua" -- cmdline completions
    use "saadparwaiz1/cmp_luasnip" -- snippet completions

    -- snippets
    use "L3MON4D3/LuaSnip" --snippet engine
    -- use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

    use "benfowler/telescope-luasnip.nvim" -- Luasnip integration for telescope

    use "norcalli/nvim-colorizer.lua" -- Colorizer to see fancy colors when writing code

    use "ggandor/lightspeed.nvim" -- for quick jumping around files

    -- LSP for code completion and definitions etc
    use "neovim/nvim-lspconfig"
    use "williamboman/nvim-lsp-installer"
    use "jose-elias-alvarez/null-ls.nvim" -- for formatters and linters

    use "lewis6991/gitsigns.nvim" -- for git information, added/deleted stuff and see changes while file is opened

    use { "lervag/vimtex", ft = { "tex", "vimwiki" } } -- latex support

    -- never fotget keybindings again (hopefully)
    use "folke/which-key.nvim"

    use "akinsho/toggleterm.nvim" -- toggle terminal for nvim

    use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" } -- treeesitter for better syntax highlighting
    use "p00f/nvim-ts-rainbow" -- color for parenthesis
    use "nvim-treesitter/playground" -- for developing color scheeemeee yeee
    use "folke/tokyonight.nvim"

    -- aahh ich mag das plugin iwie nicht
    -- use {'iamcco/markdown-preview.nvim', run=":call mkdp#util#install()" , ft={'markdown'}}
    --use "plasticboy/vim-markdown"
    use { "vimwiki/vimwiki", ft = { "markdown" } }
    -- use "junegunn/goyo.vim"
    use "tanvirtin/vgit.nvim"

    -- Block and single line quotes
    use "numToStr/Comment.nvim"
    use "JoosepAlviste/nvim-ts-context-commentstring"

    -- Autocmd lua wrapper
    use "jakelinnzy/autocmd-lua"

    -- Statusline
    use "nvim-lualine/lualine.nvim"

<<<<<<< HEAD
  -- Plugin which extends vim's matchup, i.e. jumping to matching parenthesis
  use 'andymass/vim-matchup'
  -- for surrouding editing
  -- surround has been deleted...
  -- use 'blackcauldron7/surround.nvim'
  use "ur4ltz/surround.nvim"
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  --danymat/neogen, ekickx/clipboard-image.nvim

    -- to use neovim in browser
    -- use {
    --     'glacambre/firenvim',
    --     run = function() vim.fn['firenvim#install'](0) end
    -- }

    -- for nice folding
    use "anuvyklack/pretty-fold.nvim"

    -- workspaces
    use "natecraddock/workspaces.nvim"

    -- fancy todo highlights
    use { "folke/todo-comments.nvim", requires = "nvim-lua/plenary.nvim"}

    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)

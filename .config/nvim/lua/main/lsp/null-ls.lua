local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup {
    debug = false,
    sources = {
        formatting.black.with { extra_args = { "--fast" } },
        -- diagnostics.pylint,
        formatting.stylua.with {
            extra_args = {
                "--indent-width",
                "4",
                "--indent-type",
                "Spaces",
                "--quote-style",
                "AutoPreferDouble",
                "--call-parentheses",
                "None",
            },
            --formatting.prettier.with { extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } },
        },
        diagnostics.luacheck,
    },
}

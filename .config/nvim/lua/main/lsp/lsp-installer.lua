local status_ok, mason = pcall(require, "mason")
if not status_ok then
    return
end

mason.setup()

require("mason-lspconfig").setup()

local status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
    return
end

local on_attach = require("main.lsp.handlers").on_attach
local capabilities = require("main.lsp.handlers").capabilities


local sumneko_opts = require "main.lsp.settings.sumneko_lua"
local jsonls_opts = require "main.lsp.settings.jsonls"
local pyright_opts = require "main.lsp.settings.pyright"


lspconfig.lua_ls.setup{
      on_attach = on_attach,
      capabilities = capabilities,
      opts = sumneko_opts
}

lspconfig.jsonls.setup{
      on_attach = on_attach,
      capabilities = capabilities,
      opts = jsonls_opts
}

lspconfig.pyright.setup{
      on_attach = on_attach,
      capabilities = capabilities,
      opts = pyright_opts
}

local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
	return
end

require("main.lsp.lsp-installer")
require("main.lsp.handlers").setup()

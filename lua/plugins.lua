-- ============================================================
--  PACK (Nuevo en Neovim 0.11+)
-- ============================================================

vim.pack.add({
	{ src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
	-- { src = "https://github.com/nvim-mini/mini.statusline", name = "mini-status" },
	-- { src = "https://github.com/nvim-mini/mini.icons", name = "mini-icons" },
	{ src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim", name = "telescope" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "treesitter" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator", name = "tmux-navigator" },
	{ src = "https://github.com/windwp/nvim-autopairs", name = "autopairs" },
	-- LSP
	{ src = "https://github.com/williamboman/mason.nvim", name = "mason" },
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim", name = "mason-lspconfig" },
	{ src = "https://github.com/neovim/nvim-lspconfig", name = "lspconfig" },
	-- nvim-cmp (autocompletado)
	{ src = "https://github.com/hrsh7th/nvim-cmp", name = "cmp" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp", name = "cmp-nvim-lsp" },
	{ src = "https://github.com/hrsh7th/cmp-buffer", name = "cmp-buffer" },
	{ src = "https://github.com/hrsh7th/cmp-path", name = "cmp-path" },
})

require("rose-pine").setup({
	styles = {
		bold = false,
		italic = true,
		transparency = false,
	},
})

vim.cmd("colorscheme rose-pine")

-- require("mini.statusline").setup()
-- require("mini.icons").setup()

require("nvim-autopairs").setup({})

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"lua",
		"vim",
		"bash",
		"javascript",
		"json",
		"python",
		"go",
		"c",
		"cpp",
	},
	highlight = { enable = true },
	indent = { enable = true },
})

require("telescope").setup({})

--  AUTOCOMPLETADO (nvim-cmp)
local cmp = require("cmp")
local cmp_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_lsp.default_capabilities()

cmp.setup({
	mapping = {
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "buffer" },
		{ name = "path" },
	},
})

--  LSP NATIVO (Neovim 0.11+)
-- Declaración de servidores nativos
vim.lsp.config.pyright = {
	cmd = { "pyright-langserver", "--stdio" },
}

vim.lsp.config.gopls = {
	cmd = { "gopls" },
}

vim.lsp.config.clangd = {
	cmd = { "clangd" },
}

-- Auto-inicio del LSP por tipo de archivo
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function(ev)
		local client = vim.lsp.start(vim.lsp.config.pyright)
		vim.lsp.buf_attach_client(ev.buf, client)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function(ev)
		local client = vim.lsp.start(vim.lsp.config.gopls)
		vim.lsp.buf_attach_client(ev.buf, client)
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "c", "cpp" },
	callback = function(ev)
		local client = vim.lsp.start(vim.lsp.config.clangd)
		vim.lsp.buf_attach_client(ev.buf, client)
	end,
})

-- Capabilities extendidas para LSP
local cmp_cap = require("cmp_nvim_lsp").default_capabilities()

-- Formateo automático si el servidor lo soporta
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(ev)
		vim.lsp.buf.format({
			bufnr = ev.buf,
			timeout_ms = 2000,
		})
	end,
})

--  Mason
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"pyright",
		"gopls",
		"clangd",
	},
})

-- Config general de diagnósticos
vim.diagnostic.config({
	signs = true,
	virtual_text = false,
	update_in_insert = false,
})

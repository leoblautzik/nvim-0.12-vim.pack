-- ============================================================
--  plugins.lua - Neovim 0.12 (sin lazy)
-- ============================================================

-- =========================
-- PACK
-- =========================
vim.pack.add({

	-- Tema
	{ src = "https://github.com/rose-pine/neovim", name = "rose-pine" },

	-- Utilities
	{ src = "https://github.com/nvim-lua/plenary.nvim", name = "plenary" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim", name = "telescope" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "treesitter" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator", name = "tmux-navigator" },
	{ src = "https://github.com/windwp/nvim-autopairs", name = "autopairs" },
	-- LSP & Autocompletado
	{ src = "https://github.com/williamboman/mason.nvim", name = "mason" },
	{ src = "https://github.com/williamboman/mason-lspconfig.nvim", name = "mason-lspconfig" },
	{ src = "https://github.com/neovim/nvim-lspconfig", name = "lspconfig" },
	{ src = "https://github.com/hrsh7th/nvim-cmp", name = "cmp" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp", name = "cmp-nvim-lsp" },
	{ src = "https://github.com/hrsh7th/cmp-buffer", name = "cmp-buffer" },
	{ src = "https://github.com/hrsh7th/cmp-path", name = "cmp-path" },
})

-- =========================
-- THEME
-- =========================
require("rose-pine").setup({
	styles = { bold = false, italic = true, transparency = false },
})
vim.cmd("colorscheme rose-pine")

-- =========================
-- TREESITTER
-- =========================
require("nvim-treesitter.configs").setup({
	ensure_installed = { "lua", "vim", "bash", "json", "python", "go", "c", "cpp", "markdown" },
	highlight = { enable = true },
	indent = { enable = true },
	modules = {},
	sync_install = false,
	ignore_install = {},
	auto_install = true,
})

-- =========================
-- TELESCOPE
-- =========================
require("telescope").setup({})

-- =========================
-- AUTOPAIRS
-- =========================
require("nvim-autopairs").setup({})

-- =========================
-- MASON
-- =========================
require("mason").setup()
require("mason-lspconfig").setup({
	ensre_installed = { "pyright", "ruff", "gopls", "clangd", "lua_ls", "stylua" },
})

-- =========================
-- CMP (autocompletado)
-- =========================
local cmp = require("cmp")
local cmp_lsp = require("cmp_nvim_lsp")
local npairs = require("nvim-autopairs")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
npairs.setup({})
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
local capabilities = cmp_lsp.default_capabilities()

cmp.setup({
	completion = { completeopt = "menu,menuone,noinsert" },
	mapping = {
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
		["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
		["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
		["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
	},
	sources = { { name = "nvim_lsp" }, { name = "buffer" }, { name = "path" } },
})

-- Definición de LSPs (usando vim.lsp.config)
vim.lsp.config.lua_ls = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}
vim.lsp.config.pyright = {
	cmd = {
		"pyright-langserver",
		"--stdio",
	},
	filetypes = {
		"python",
	},
	capabilities = capabilities,
}

vim.lsp.config.ruff = {
	init_options = { settings = { args = {} } },
	capabilities = capabilities,
}

vim.lsp.config.gopls = {
	cmd = {
		"gopls",
	},
	filetypes = {
		"go",
	},
	capabilities = capabilities,
}

vim.lsp.config.clangd = {
	cmd = {
		"clangd",
	},
	filetypes = {
		"c",
		"cpp",
	},
	capabilities = capabilities,
}

-- Habilitarlos
vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("gopls")
vim.lsp.enable("clangd")
vim.lsp.enable("ruff")

-- Autocmd para formateo automático si el servidor lo soporta
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.server_capabilities.documentFormattingProvider then
			vim.api.nvim_buf_create_user_command(args.buf, "Format", function()
				vim.lsp.buf.format({
					bufnr = args.buf,
					timeout_ms = 2000,
				})
			end, {})
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = args.buf,
				callback = function()
					vim.lsp.buf.format({
						bufnr = args.buf,
						timeout_ms = 2000,
					})
				end,
			})
		end
	end,
})

-- =========================
-- DIAGNÓSTICOS
-- =========================
vim.diagnostic.config({
	signs = true,
	-- virtual_text = true,
	update_in_insert = false,
	virtual_lines = {
		current_line = true,
	},
})

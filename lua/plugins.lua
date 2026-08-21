-- ============================================================
--  plugins.lua - Neovim 0.12 o superior (sin lazy)
-- ============================================================

-- PACK
vim.pack.add({

  -- Tema
  { src = "https://github.com/catppuccin/nvim",                     name = "catppuccin" },

  -- Utilities
  { src = "https://github.com/mbbill/undotree",                     name = "undotree" },
  { src = "https://github.com/nvim-lua/plenary.nvim",               name = "plenary" },
  { src = "https://github.com/ibhagwan/fzf-lua",                    name = "fzf-lua" },
  { src = "https://github.com/romus204/tree-sitter-manager.nvim",   name = "tree-sitter-manager" },
  { src = "https://github.com/christoomey/vim-tmux-navigator",      name = "tmux-navigator" },
  { src = "https://github.com/windwp/nvim-autopairs",               name = "autopairs" },
  { src = "https://github.com/lukas-reineke/indent-blankline.nvim", name = "ibl" },
  { src = "https://github.com/nvim-neotest/neotest",                name = "neotest" },
  { src = "https://github.com/nvim-neotest/nvim-nio",               name = "nvim-nio" },
  { src = "https://github.com/nvim-neotest/neotest-python",         name = "neotest-python" },
  { src = "https://github.com/nvim-neotest/neotest-go",             name = "neotest-go" },
  { src = "https://github.com/antoinemadec/FixCursorHold.nvim",     name = "fix-cursor-hold" },
  { src = "https://github.com/mfussenegger/nvim-jdtls",             name = "jdtls" },

  -- LSP & Autocompletado
  { src = "https://github.com/neovim/nvim-lspconfig",               name = "lspconfig" },
  { src = "https://github.com/hrsh7th/nvim-cmp",                    name = "cmp" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp",                name = "cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer",                  name = "cmp-buffer" },
  { src = "https://github.com/hrsh7th/cmp-path",                    name = "cmp-path" },
  { src = "https://github.com/lewis6991/gitsigns.nvim",             name = "gitsigns" },
})

-- THEME
require("catppuccin").setup({
  transparent_background = false,
  integrations = {
    cmp = true,
    native_lsp = { enabled = true },
    treesitter = true,
    indent_blankline = { enabled = true },
  },
})
vim.cmd("colorscheme catppuccin-mocha")

-- TREE-SITTER
require("tree-sitter-manager").setup({
  ensure_installed = {
    "lua",
    "zsh",
    "java",
    "markdown",
    "csv",
    "kitty",
    "tsv",
    "toml",
    "gitcommit",
    "c",
    "cpp",
    "python",
    "go",
    "gitignore",
    "diff",
    "markdown_inline"
  },
  auto_install = true,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function(args)
    local ok, parser = pcall(vim.treesitter.get_parser, args.buf)
    if ok and parser then
      parser:parse()
    end
  end,
})

-- FZF-LUA
require("fzf-lua").setup({})

require("gitsigns").setup({
  signs = {
    add          = { text = "│" },
    change       = { text = "│" },
    delete       = { text = "_" },
    topdelete    = { text = "‾" },
    changedelete = { text = "~" },
  },
})

-- AUTOPAIRS
require("nvim-autopairs").setup({})

require("neotest").setup({
  adapters = {
    require("neotest-python")({}),
    require("neotest-go")({}),
  }
})

require("ibl").setup({
  indent = {
    char = "▏", -- más fino que "│"
  },
})
vim.api.nvim_set_hl(0, "IblIndent", { fg = "#313244" })

-- CMP (autocompletado)
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
  cmd = { "lua-language-server",
    '--logpath=' .. vim.fn.stdpath('cache') .. '/lua-ls-log', },
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
-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     -- Pyright NO formatea
--     if client and client.name == "pyright" and client.server_capabilities then
--       client.server_capabilities.documentFormattingProvider = false
--     end
--     if client and client.server_capabilities.documentFormattingProvider then
--       vim.api.nvim_buf_create_user_command(args.buf, "Format", function()
--         vim.lsp.buf.format({
--           bufnr = args.buf,
--           timeout_ms = 2000,
--         })
--       end, {})
--       vim.api.nvim_create_autocmd("BufWritePre", {
--         buffer = args.buf,
--         callback = function()
--           vim.lsp.buf.format({
--             bufnr = args.buf,
--             timeout_ms = 2000,
--           })
--         end,
--       })
--     end
--   end,
-- })
-- Formateo al guardar (evita duplicar el autocmd por buffer)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    if vim.b[bufnr].format_on_save_configured then return end

    local function has_formatter()
      for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if c.name ~= "pyright" and c:supports_method("textDocument/formatting") then
          return true
        end
      end
      return false
    end

    if has_formatter() then
      vim.b[bufnr].format_on_save_configured = true

      local function do_format()
        vim.lsp.buf.format({
          bufnr = bufnr,
          timeout_ms = 2000,
          filter = function(c) return c.name ~= "pyright" end,
        })
      end

      vim.api.nvim_buf_create_user_command(bufnr, "Format", do_format, {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = do_format,
      })
    end
  end,
})
-- DIAGNÓSTICOS
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "󰋼",
      [vim.diagnostic.severity.HINT] = "󰌵",
    },
  },
  underline = true,
  update_in_insert = false,
  virtual_lines = {
    current_line = true,
  },
})

-- JDTLS (Java)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local jdtls = require("jdtls")

    -- Workspace único por proyecto (evita conflictos entre proyectos)
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

    jdtls.start_or_attach({
      cmd = { "jdtls", "-data", workspace_dir },
      root_dir = vim.fs.root(0, { "pom.xml", "build.gradle", ".git", "mvnw" }),
      capabilities = capabilities,
      settings = {
        java = {
          format = { enabled = true },
          saveActions = { organizeImports = true },
          completion = { favoriteStaticMembers = {} },
        },
      },
    })
  end,
})

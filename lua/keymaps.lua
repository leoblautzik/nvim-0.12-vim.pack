local utils = require("utils")
local map = vim.keymap.set

vim.g.mapleader = " " -- Leader key
vim.g.maplocalleader = " " -- Set local leader key (NEW)

map("n", "<leader>zz", ":wqa<CR>", { silent = true })
--
map("i", "jj", "<Esc>", { noremap = true, silent = true })

-------------------------------------------------------------------------------
-- Deshabilitar PgUp y PgDn en todos los modos
-------------------------------------------------------------------------------
-- local modes = { 'n', 'i', 'v', 'x', 's', 'o', 'c' }
--
-- for _, key in ipairs { '<PageUp>', '<PageDown>', '<Home>', '<Del>', '<Delete>' } do
--   for _, mode in ipairs(modes) do
--     map(mode, key, '<Nop>', { noremap = true, silent = true })
--   end
-- end

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-------------------------------------------------------------------------------
-- Habilitar la tecla Del para cerrar el buffer actual
-------------------------------------------------------------------------------
map("n", "<C-x>", function()
	local choice = vim.fn.confirm("¿Cerrar el buffer actual?", "&Sí\n&No", 2)
	if choice == 1 then
		vim.cmd("bdelete")
	end
end, { noremap = true, silent = true, desc = "Cerrar buffer con confirmación" })

-------------------------------------------------------------------------------
-- Deshabilitar flechas en modo normal
-------------------------------------------------------------------------------
-- map("n", "<Up>", "<Nop>", { noremap = true, silent = true })
-- map("n", "<Down>", "<Nop>", { noremap = true, silent = true })
-- map("n", "<Left>", "<Nop>", { noremap = true, silent = true })
-- map("n", "<Right>", "<Nop>", { noremap = true, silent = true })

-------------------------------------------------------------------------------
-- Copiar selección visual al portapapeles con Ctrl-C
-------------------------------------------------------------------------------
map("v", "<C-c>", '"+y', { noremap = true, silent = true })

-------------------------------------------------------------------------------
-- Copia todo el contenido del archivo al portapapeles del sistema sin mover
-- el cursor
map("n", "<C-a>", function()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd('normal! ggVG"+y')
	vim.api.nvim_win_set_cursor(0, pos)
end, { desc = "Copiar todo sin mover cursor" })

-------------------------------------------------------------------------------
-- Navegación con netrw
-------------------------------------------------------------------------------
-- Toggle netrw con \
map("n", "<leader>\\", function()
	if vim.bo.filetype == "netrw" then
		vim.cmd("bd")
	else
		vim.cmd("Explore")
	end
end, { desc = "Toggle netrw" })

-- Toggle netrw con leader n
map("n", "<C-n>", function()
	if vim.bo.filetype == "netrw" then
		vim.cmd("bd")
	else
		vim.cmd("Explore")
	end
end, { desc = "Toggle netrw" })
-------------------------------------------------------------------------------

-- Navegación insert mode
map("i", "<C-h>", "<Left>", { noremap = true })
map("i", "<C-l>", "<Right>", { noremap = true })
map("i", "<C-j>", "<Down>", { noremap = true })
map("i", "<C-k>", "<Up>", { noremap = true })

-- Cambiar buffers
map("n", "<Tab>", "<cmd>bn<CR>", { noremap = true })
map("n", "<S-Tab>", "<cmd>bp<CR>", { noremap = true })

-- Splits
map("n", "<leader>sh", "<C-w>s", { noremap = true })
map("n", "<leader>sv", "<C-w>v", { noremap = true })
map("n", "<leader>se", "<C-w>=", { noremap = true })
map("n", "<leader>sx", "<cmd>close<CR>", { noremap = true })

map("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Yank to EOL
map("n", "Y", "y$", { desc = "Yank to end of line" })

-- Diagnóstico y quickfix
map("n", "<leader>q", function()
	local winid = vim.fn.getqflist({ winid = 0 }).winid
	if winid ~= 0 then
		vim.cmd.cclose()
	else
		vim.diagnostic.setqflist()
		vim.cmd.copen()
	end
end, { desc = "Toggle Quickfix con diagnósticos" })

-------------------------------------------------------------------------------
-- Copy Full File-Path
-------------------------------------------------------------------------------
map("n", "<leader>pp", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file-path" })

-------------------------------------------------------------------------------
-- Lanzar Terminal flotante y small proporcional
-------------------------------------------------------------------------------
map("n", "<space>ft", utils.open_floating, { desc = "Open floating terminal" })
map("n", "<space>st", utils.open_small, { desc = "Open small terminal (30%)" })

-------------------------------------------------------------------------------
-- Ejecutar archivo actual (C, Python, Go, Lua)
-------------------------------------------------------------------------------
map("n", "<leader>ex", utils.run_file, { desc = "Ejecutar archivo actual" })

-- Go Test
map("n", "<leader>tgn", utils.run_test_under_cursor, { desc = "Go: test bajo cursor" })
-- map('n', '<leader>tga', utils.run_tests_in_file, { desc = 'Go: todos los tests del archivo' })
map("n", "<leader>tga", function()
	utils.run_tests_in_file(true)
end, { desc = "Go: tests archivo (verbose)" })

-- Python Test
map("n", "<leader>tpn", utils.run_pytest_under_cursor, { desc = "Py: test bajo cursor" })
map("n", "<leader>tpa", utils.run_pytests_in_file, { desc = "Py: todos los tests del archivo" })

-- Cerrar panel de ejecución
map("n", "<leader>ec", function()
	if vim.g.runner_win and vim.api.nvim_win_is_valid(vim.g.runner_win) then
		vim.api.nvim_win_close(vim.g.runner_win, true)
		vim.g.runner_win = nil
	else
		print("No hay panel de ejecución activo")
	end
end, { desc = "Cerrar panel runner" })

--------------------------------------------------------------------------------
--- Telescope keymaps
--------------------------------------------------------------------------------
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Buscar archivos" })
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>", { desc = "Buscar texto" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Buscar grep" })
map("n", "<leader><leader>", "<cmd>Telescope buffers<CR>", { desc = "Buffers abiertos" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Ayuda" })
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Search keymaps" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Archivos recientes" })
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Buscar diagnósticos" })
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "Commits" })
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Cambios sin commit" })
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", { desc = "Ramas" })
--------------------------------------------------------------------------------
-- Alternar tema claro/orcuro
--
vim.keymap.set("n", "<leader>t", function()
	local cs = vim.g.colors_name or ""

	if cs:match("^catppuccin") then
		vim.cmd("colorscheme delek")
		vim.o.background = "light"
	else
		vim.cmd("colorscheme catppuccin-mocha")
		vim.o.background = "dark"
	end
end, { desc = "Toggle theme (catppuccin ↔ delek)" })
--------------------------------------------------------------------------------

local utils = require("utils")

vim.g.mapleader = " " -- Leader key
vim.g.maplocalleader = " " -- Set local leader key (NEW)

vim.keymap.set("n", "<leader>zz", ":wqa<CR>", { silent = true })
--
vim.keymap.set("i", "jj", "<Esc>", { noremap = true, silent = true })

-------------------------------------------------------------------------------
-- Deshabilitar PgUp y PgDn en todos los modos
-------------------------------------------------------------------------------
-- local modes = { 'n', 'i', 'v', 'x', 's', 'o', 'c' }
--
-- for _, key in ipairs { '<PageUp>', '<PageDown>', '<Home>', '<Del>', '<Delete>' } do
--   for _, mode in ipairs(modes) do
--     vim.keymap.set(mode, key, '<Nop>', { noremap = true, silent = true })
--   end
-- end

-------------------------------------------------------------------------------
-- Habilitar la tecla Del para cerrar el buffer actual
-------------------------------------------------------------------------------
vim.keymap.set("n", "<Del>", function()
	local choice = vim.fn.confirm("¿Cerrar el buffer actual?", "&Sí\n&No", 2)
	if choice == 1 then
		vim.cmd("bdelete")
	end
end, { noremap = true, silent = true, desc = "Cerrar buffer con confirmación" })

-------------------------------------------------------------------------------
-- Deshabilitar flechas en modo normal
-------------------------------------------------------------------------------
-- vim.keymap.set("n", "<Up>", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<Down>", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<Left>", "<Nop>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<Right>", "<Nop>", { noremap = true, silent = true })

-------------------------------------------------------------------------------
-- Copiar selección visual al portapapeles con Ctrl-C
-------------------------------------------------------------------------------
vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true })

-------------------------------------------------------------------------------
-- Copia todo el contenido del archivo al portapapeles del sistema sin mover
-- el cursor
vim.keymap.set("n", "<C-a>", function()
	local pos = vim.api.nvim_win_get_cursor(0)
	vim.cmd('normal! ggVG"+y')
	vim.api.nvim_win_set_cursor(0, pos)
end, { desc = "Copiar todo sin mover cursor" })

-------------------------------------------------------------------------------
-- Navegación con netrw
-------------------------------------------------------------------------------
-- Toggle netrw con \
vim.keymap.set("n", "<leader>\\", function()
	if vim.bo.filetype == "netrw" then
		vim.cmd("bd")
	else
		vim.cmd("Explore")
	end
end, { desc = "Toggle netrw" })

-- Toggle netrw con leader n
vim.keymap.set("n", "<C-n>", function()
	if vim.bo.filetype == "netrw" then
		vim.cmd("bd")
	else
		vim.cmd("Explore")
	end
end, { desc = "Toggle netrw" })
-------------------------------------------------------------------------------

-- Navegación insert mode
vim.keymap.set("i", "<C-h>", "<Left>", { noremap = true })
vim.keymap.set("i", "<C-l>", "<Right>", { noremap = true })
vim.keymap.set("i", "<C-j>", "<Down>", { noremap = true })
vim.keymap.set("i", "<C-k>", "<Up>", { noremap = true })

-- Cambiar buffers
vim.keymap.set("n", "<Tab>", "<cmd>bn<CR>", { noremap = true })
vim.keymap.set("n", "<S-Tab>", "<cmd>bp<CR>", { noremap = true })

-- Splits
vim.keymap.set("n", "<leader>sh", "<C-w>s", { noremap = true })
vim.keymap.set("n", "<leader>sv", "<C-w>v", { noremap = true })
vim.keymap.set("n", "<leader>se", "<C-w>=", { noremap = true })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { noremap = true })

vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Yank to EOL
vim.keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })

-- Diagnóstico y quickfix
vim.keymap.set("n", "<leader>q", function()
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
vim.keymap.set("n", "<leader>pp", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Toggle Quickfix con diagnósticos" })

-------------------------------------------------------------------------------
-- Lanzar Terminal flotante y small proporcional
-------------------------------------------------------------------------------
vim.keymap.set("n", "<space>ft", utils.open_floating, { desc = "Open floating terminal" })
vim.keymap.set("n", "<space>st", utils.open_small, { desc = "Open small terminal (30%)" })

-------------------------------------------------------------------------------
-- Ejecutar archivo actual (C, Python, Go, Lua)
-------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>ex", utils.run_file, { desc = "Ejecutar archivo actual" })

-- Go Test
vim.keymap.set("n", "<leader>tgn", utils.run_test_under_cursor, { desc = "Go: test bajo cursor" })
-- vim.keymap.set('n', '<leader>tga', utils.run_tests_in_file, { desc = 'Go: todos los tests del archivo' })
vim.keymap.set("n", "<leader>tga", function()
	runner.run_tests_in_file(true)
end, { desc = "Go: tests archivo (verbose)" })

-- Python Test
vim.keymap.set("n", "<leader>tpn", utils.run_pytest_under_cursor, { desc = "Py: test bajo cursor" })
vim.keymap.set("n", "<leader>tpa", utils.run_pytests_in_file, { desc = "Py: todos los tests del archivo" })

-- Cerrar panel de ejecución
vim.keymap.set("n", "<leader>ec", function()
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
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Buscar archivos" })
vim.keymap.set("n", "<leader>fw", "<cmd>Telescope grep_string<CR>", { desc = "Buscar texto" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Buscar grep" })
vim.keymap.set("n", "<leader><leader>", "<cmd>Telescope buffers<CR>", { desc = "Buffers abiertos" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Ayuda" })
vim.keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Search keymaps" })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Archivos recientes" })
vim.keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Buscar diagnósticos" })
vim.keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "Commits" })
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Cambios sin commit" })
vim.keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", { desc = "Ramas" })

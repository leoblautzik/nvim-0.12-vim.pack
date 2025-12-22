-- options.lua

local o = vim.opt

-- Basic settings
o.number = true -- Line numbers
o.relativenumber = true -- Relative line numbers
o.cursorline = true -- Highlight current line
o.wrap = false -- Don't wrap lines
o.scrolloff = 2 -- Keep 2 lines above/below cursor
o.sidescrolloff = 2 -- Keep 2 columns left/right of cursor

-- Indentation
o.tabstop = 4 -- Tab width
o.shiftwidth = 4 -- Indent width
o.softtabstop = 4 -- Soft tab stop
o.expandtab = true -- Use spaces instead of tabs
o.smartindent = true -- Smart auto-indenting
o.autoindent = true -- Copy indent from current line
o.backspace = { "indent", "eol", "start" }

-- Search settings
o.ignorecase = true -- Case insensitive search
o.smartcase = true -- Case sensitive if uppercase in search
o.hlsearch = true -- false Don't highlight search results
o.incsearch = true -- Show matches as you type

-- Visual settings
o.termguicolors = true -- Enable 24-bit colors
o.signcolumn = "yes" -- Always show sign column
--o.colorcolumn = '100' -- Show column at 100 characters
o.showmatch = true -- Highlight matching brackets
o.matchtime = 2 -- How long to show matching bracket
o.cmdheight = 1 -- Command line height
o.completeopt = "menuone,menu,noselect" -- Completion options
o.showmode = true -- Don't show mode in command line
o.pumheight = 10 -- Popup menu height
o.pumblend = 0 -- Popup menu transparency
o.winblend = 0 -- Floating window transparency
o.conceallevel = 0 -- Don't hide markup
o.concealcursor = "" -- Don't hide cursor line markup
o.synmaxcol = 300 -- Syntax highlighting limit
o.winborder = "rounded"
o.fillchars:append({ eob = " " })
--
-- File handling
o.backup = false -- Don't create backup files
o.writebackup = false -- Don't create backup before writing
o.swapfile = false -- Don't create swap files
o.undofile = true -- Persistent undo
o.updatetime = 300 -- Faster completion
o.timeoutlen = 800 -- Key timeout duration
o.ttimeoutlen = 0 -- Key code timeout
o.autoread = true -- Auto reload files changed outside vim
o.autowrite = false -- Don't auto save
-- Directorio de undo específico del entorno NVIM_APPNAME
o.undodir = vim.fn.stdpath("state") .. "/undo"

-- Split behavior
o.splitbelow = true -- Horizontal splits go below
o.splitright = true -- Vertical splits go right

-- Cursor setting
o.guicursor = {
	"n-v-c:block", -- bloque en normal, visual y command
	"i-ci-ve:ver30", -- palito en insert, command-insert, visual-ex
	"r-cr:hor20", -- guion bajo en replace
	"o:hor50", -- guion bajo en operator-pending
	"a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor", -- parpadeo y resalte
	"sm:block-blinkwait175-blinkoff150-blinkon175",
}

o.laststatus = 1

-- vim.g.netrw_liststyle = 3

local M = {}

-- Floating terminal
M.open_floating = function()
  local buf = vim.api.nvim_create_buf(false, true)

  local function open_win()
    local width = math.floor(vim.o.columns * 0.85)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    return vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
    })
  end

  local win = open_win()
  vim.fn.termopen(vim.o.shell)
  vim.cmd.startinsert()

  vim.keymap.set('t', '<C-q>', '<C-\\><C-n>:q<CR>', { buffer = buf })

  -- Auto-resize
  vim.api.nvim_create_autocmd('VimResized', {
    buffer = buf,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      win = open_win()
      vim.cmd.startinsert()
    end,
  })
end

-- Small terminal (split inferior 30% con resize automático)
M.open_small = function()
  local function total_tab_height()
    local total = 0
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      total = total + vim.api.nvim_win_get_height(w)
    end
    return total
  end

  local total_before = total_tab_height()
  local term_h = math.max(3, math.floor(total_before * 0.3))

  vim.cmd(string.format('belowright %d split', term_h))
  vim.cmd.term(vim.o.shell)
  local term_win = vim.api.nvim_get_current_win()
  local term_buf = vim.api.nvim_get_current_buf()
  vim.cmd.startinsert()

  vim.keymap.set('t', '<C-q>', '<C-\\><C-n>:close<CR>', { buffer = term_buf })

  local group_name = 'SmallTerm_' .. tostring(term_buf)
  vim.api.nvim_create_augroup(group_name, { clear = true })

  vim.api.nvim_create_autocmd({ 'VimResized', 'WinResized' }, {
    group = group_name,
    callback = function()
      if not vim.api.nvim_win_is_valid(term_win) then
        pcall(vim.api.nvim_del_augroup_by_name, group_name)
        return
      end
      local total = total_tab_height()
      local new_h = math.max(3, math.floor(total * 0.3))
      if vim.api.nvim_win_is_valid(term_win) then
        pcall(vim.api.nvim_win_set_height, term_win, new_h)
      end
    end,
  })
end

-- Crear terminal temporal en split inferior y ejecutar comando
local function run_cmd_output(cmd, cwd)
  if vim.g.runner_win and vim.api.nvim_win_is_valid(vim.g.runner_win) then
    vim.api.nvim_win_close(vim.g.runner_win, true)
  end
  local buf = vim.api.nvim_create_buf(false, true)
  local win_height = 12
  vim.cmd('botright ' .. win_height .. 'split')
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.g.runner_win = win
  vim.fn.termopen(cmd, {
    cwd = cwd,
    on_exit = function()
      vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    end,
  })
end

----------------------------------------------------------------------
-- Ejecutar archivo actual según su tipo
----------------------------------------------------------------------
function M.run_file()
  if vim.bo.modified then
    vim.cmd 'write'
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  local file_type = vim.bo.filetype

  if file_type == 'lua' then
    run_cmd_output({ 'lua', file_name }, vim.fn.expand '%:p:h')
  elseif file_type == 'c' then
    local out = '/tmp/a.out'
    local compile_cmd = { 'gcc', file_name, '-o', out }
    local compile_result = vim.fn.system(compile_cmd)
    if vim.v.shell_error ~= 0 then
      print('Error de compilación:\n' .. compile_result)
    else
      run_cmd_output({ out }, vim.fn.expand '%:p:h')
    end
  elseif file_type == 'python' then
    run_cmd_output({ 'python3', file_name }, vim.fn.expand '%:p:h')
  elseif file_type == 'go' then
    local file_dir = vim.fn.expand '%:p:h'
    local gomod = vim.fn.findfile('go.mod', file_dir .. ';')
    local dir = gomod ~= '' and vim.fn.fnamemodify(gomod, ':h') or file_dir

    if file_name:match '_test%.go$' then
      run_cmd_output({ 'go', 'test' }, file_dir) -- todos los tests del paquete
    else
      run_cmd_output({ 'go', 'run', file_name }, dir)
    end
  else
    print 'Formato no soportado'
  end
end

----------------------------------------------------------------------
-- GO: Ejecutar test bajo el cursor
----------------------------------------------------------------------
function M.run_test_under_cursor()
  if vim.bo.modified then
    vim.cmd 'write'
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  if not file_name:match '_test%.go$' then
    print 'Este comando solo funciona en archivos *_test.go'
    return
  end

  local ts_utils = require 'nvim-treesitter.ts_utils'
  local node = ts_utils.get_node_at_cursor()
  local test_name = nil

  while node do
    if node:type() == 'function_declaration' then
      local id = node:field('name')[1]
      if id then
        test_name = vim.treesitter.get_node_text(id, 0)
      end
      break
    end
    node = node:parent()
  end

  if not test_name or not test_name:match '^Test' then
    print 'No se detectó una función de test aquí'
    return
  end

  local file_dir = vim.fn.expand '%:p:h'
  run_cmd_output({ 'go', 'test', '-run', test_name }, file_dir)
end

----------------------------------------------------------------------
-- GO: Ejecutar todos los tests del archivo actual
----------------------------------------------------------------------
function M.run_tests_in_file(verbose)
  if vim.bo.modified then
    vim.cmd 'write'
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  if not file_name:match '_test%.go$' then
    print 'Este comando solo funciona en archivos *_test.go'
    return
  end

  -- Extraer nombres de test (func TestXxx)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local tests = {}
  for _, line in ipairs(lines) do
    local name = line:match '^func%s+(Test%w+)'
    if name then
      table.insert(tests, name)
    end
  end

  if #tests == 0 then
    print 'No se encontraron tests en este archivo'
    return
  end

  -- Construir regex para go test -run
  local pattern = '^(' .. table.concat(tests, '|') .. ')$'
  local file_dir = vim.fn.expand '%:p:h'

  local cmd = { 'go', 'test', '-run', pattern }
  if verbose then
    table.insert(cmd, '-v')
  end

  run_cmd_output(cmd, file_dir)
end

----------------------------------------------------------------------
-- PYTHON: Ejecutar test bajo el cursor (pytest)
----------------------------------------------------------------------
function M.run_pytest_under_cursor()
  if vim.bo.modified then
    vim.cmd 'write'
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  if not file_name:match '_test%.py$' then
    print 'Este comando solo funciona en archivos *_test.py'
    return
  end

  local ts_utils = require 'nvim-treesitter.ts_utils'
  local node = ts_utils.get_node_at_cursor()
  local test_name = nil
  local class_name = nil

  while node do
    if node:type() == 'function_definition' then
      local id = node:field('name')[1]
      if id then
        test_name = vim.treesitter.get_node_text(id, 0):gsub('%s+', '')
      end
    elseif node:type() == 'class_definition' then
      local id = node:field('name')[1]
      if id then
        class_name = vim.treesitter.get_node_text(id, 0):gsub('%s+', '')
      end
    end
    node = node:parent()
  end

  if not test_name or not test_name:match '^test' then
    print 'No se detectó una función de test aquí'
    return
  end

  local target = file_name
  if class_name then
    target = target .. '::' .. class_name
  end
  target = target .. '::' .. test_name

  local file_dir = vim.fn.expand '%:p:h'
  run_cmd_output({ 'pytest', '-v', target }, file_dir)
end
----------------------------------------------------------------------
-- PYTHON: Ejecutar todos los tests del archivo actual
----------------------------------------------------------------------
function M.run_pytests_in_file()
  if vim.bo.modified then
    vim.cmd 'write'
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  if not file_name:match '_test%.py$' then
    print 'Este comando solo funciona en archivos *_test.py'
    return
  end

  local file_dir = vim.fn.expand '%:p:h'
  run_cmd_output({ 'pytest', '-v', file_name }, file_dir)
end



return M


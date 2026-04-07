vim.api.nvim_create_autocmd("FileType", {
  pattern = "c",
  callback = function()
    -- Esto limpia cualquier expresión de indentación previa
    vim.opt_local.indentexpr = ""
    -- Activa el motor de indentación específico para C
    vim.opt_local.cindent = true
    -- Configuración tipica de 4 espacios
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

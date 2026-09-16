-- en tu init.lua, o en after/ftplugin/go.lua
vim.schedule(function()
  vim.bo[0].tabstop = 4
  vim.bo[0].shiftwidth = 4
  vim.bo[0].softtabstop = -1
end)

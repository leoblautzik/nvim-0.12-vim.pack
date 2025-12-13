-- init.lua con solo requires
require("options") -- Primero: opciones básicas
require("plugins") -- Segundo: instalar y configurar plugins
require("keymaps") -- Después de plugins si usan funciones de plugins
require("autocmds") -- Al final, si dependen de LSP o plugins

vim.pack.add({ 'https://github.com/RRethy/base16-nvim' })

local ok, matugen = pcall(require, 'matugen')
if ok then matugen.setup() end

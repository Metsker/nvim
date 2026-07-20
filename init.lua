vim.pack.add({ "https://github.com/RRethy/base16-nvim" })

local ok, matugen = pcall(require, "matugen")
if ok then
	matugen.setup()
end

-- transparent bg
for _, g in ipairs({ "Normal", "NormalNC", "SignColumn", "LineNr", "EndOfBuffer", "FoldColumn" }) do
	local hl = vim.api.nvim_get_hl(0, { name = g })
	hl.bg, hl.ctermbg = nil, nil
	vim.api.nvim_set_hl(0, g, hl)
end

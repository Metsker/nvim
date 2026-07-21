vim.pack.add({ "https://github.com/RRethy/base16-nvim" })

-- Keep the background transparent across every theme (re)apply.
local base16 = require("base16-colorscheme")
if not base16._transparent_bg_wrapped then
	base16._transparent_bg_wrapped = true
	local orig = base16.setup
	base16.setup = function(...)
		orig(...)
		for _, g in ipairs({ "Normal", "NormalNC", "SignColumn", "LineNr", "EndOfBuffer", "FoldColumn" }) do
			local hl = vim.api.nvim_get_hl(0, { name = g })
			hl.bg, hl.ctermbg = nil, nil
			vim.api.nvim_set_hl(0, g, hl)
		end
	end
end

local ok, matugen = pcall(require, 'matugen')
if ok then matugen.setup() end

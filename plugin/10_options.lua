vim.g.mapleader = " "

vim.o.relativenumber = false
vim.o.number = true
vim.o.signcolumn = "yes:1"
vim.o.mousescroll = "ver:2,hor:6"
vim.o.wrap = false

vim.o.clipboard = "unnamedplus"
vim.o.confirm = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.smoothscroll = true
vim.o.linebreak = true
vim.o.undofile = true
vim.o.swapfile = false
vim.o.iskeyword = "@,48-57,_,192-255,-"
vim.o.winborder = "single"
vim.o.ruler = false
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.splitright = true
vim.o.virtualedit = "block"

vim.o.autoindent = true
vim.o.smartindent = true

vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.smartcase = true
vim.o.spelloptions = "camel"

vim.o.pumborder = "single"

vim.o.showmode = false

vim.o.shada = "'100,<50,s10,:1000,/100,@100,h"

vim.cmd("filetype plugin indent on")
if vim.fn.exists("syntax_on") ~= 1 then
	vim.cmd("syntax enable")
end


-- Diagnostics
local diagnostic_opts = {
	signs = { priority = 9999, severity = { min = "WARN", max = "ERROR" } },
	underline = { severity = { min = "HINT", max = "ERROR" } },
	virtual_lines = false,
	virtual_text = {
		current_line = true,
		severity = { min = "WARN", max = "ERROR" },
	},
}
vim.diagnostic.config(diagnostic_opts)

-- LSP
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})
vim.lsp.enable({ "lua_ls", "rust_analyzer" })

-- Autocommands
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 150,
			on_visual = true,
		})
	end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
	callback = function()
		vim.cmd("setlocal formatoptions-=c formatoptions-=o")
	end,
})

-- Colors
vim.api.nvim_set_hl(0, "FloatBorder", { link = "TelescopeBorder" })
vim.api.nvim_set_hl(0, "NormalFloat", { link = "TelescopeNormal" })

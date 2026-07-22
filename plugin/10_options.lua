vim.g.mapleader = " "

vim.o.relativenumber = true
vim.o.number = true
vim.o.signcolumn = "yes:1"
vim.o.mousescroll = "ver:2,hor:6"
-- vim.o.wrap = false
vim.o.wrap = true

vim.o.spell = true
vim.o.spelllang = "en_us"

vim.o.clipboard = "unnamedplus"
vim.o.confirm = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.smoothscroll = true
vim.o.linebreak = true
vim.o.undofile = true
vim.o.swapfile = false
vim.o.iskeyword = "@,48-57,_,192-255,-" -- word-word is one word
vim.o.winborder = "single"
vim.o.ruler = false
vim.o.splitbelow = true
vim.o.splitkeep = "screen"
vim.o.splitright = true
vim.o.virtualedit = "block"
vim.o.cursorline = true
vim.o.cursorlineopt = "number"

vim.o.autoindent = true
vim.o.smartindent = true

vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.smartcase = true
vim.o.spelloptions = "camel"

vim.o.pumborder = "single"

vim.o.showmode = false
vim.o.showtabline = 0

vim.o.shada = "'100,<50,s10,:1000,/100,@100,h"

vim.o.whichwrap = "b,s,h,l"

vim.cmd("filetype plugin indent on")
if vim.fn.exists("syntax_on") ~= 1 then
	vim.cmd("syntax enable")
end

-- FileTypes
vim.filetype.add({ pattern = { [".*%.conf"] = "dosini" } })

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
	cmd = { "lua-language-server" },
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
		telemetry = {
			enable = false,
		},
	},
})
vim.lsp.config("nil_ls", {
	settings = {
		["nil"] = {
			nix = {
				flake = {
					autoArchive = true,
				},
			},
		},
	},
})
vim.lsp.enable({ "lua_ls", "rust_analyzer", "nil_ls" })

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

-- IDE-like: highlight LSP symbol references under cursor
local lsp_ref_hl = vim.api.nvim_create_augroup("LspReferenceHighlight", { clear = true })
vim.api.nvim_create_autocmd("CursorMoved", {
	group = lsp_ref_hl,
	desc = "Highlight references under cursor",
	callback = function()
		if vim.fn.mode() ~= "i" then
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			local supports_highlight = false
			for _, client in ipairs(clients) do
				if client.server_capabilities.documentHighlightProvider then
					supports_highlight = true
					break
				end
			end
			if supports_highlight then
				vim.lsp.buf.clear_references()
				vim.lsp.buf.document_highlight()
			end
		end
	end,
})

vim.api.nvim_create_autocmd("CursorMovedI", {
	group = lsp_ref_hl,
	desc = "Clear highlights when entering insert mode",
	callback = function()
		vim.lsp.buf.clear_references()
	end,
})

local add = vim.pack.add

local function gh(str)
	return "https://github.com/" .. str
end
add({
	gh("neovim/nvim-lspconfig"),
	gh("stevearc/conform.nvim"),
	gh("nvim-treesitter/nvim-treesitter"),
	gh("nvim-treesitter/nvim-treesitter-textobjects"),
	gh("rafamadriz/friendly-snippets"),
	{
		src = gh("saghen/blink.cmp.git"),
		version = "v1.10.2",
	},
	gh("nvim-lualine/lualine.nvim"),
	gh("windwp/nvim-autopairs"),
	gh("karb94/neoscroll.nvim"),

	gh("folke/snacks.nvim"),
	gh("diogo464/hotreload.nvim"),

	gh("nvim-mini/mini.icons"),
	gh("nvim-mini/mini.files"),
	gh("nvim-mini/mini.operators"),
	gh("nvim-mini/mini.surround"),
	gh("nvim-mini/mini.move"),
	gh("nvim-mini/mini.ai"),
	gh("nvim-mini/mini.clue"),
	gh("nvim-mini/mini.jump"),

	gh("lewis6991/gitsigns.nvim"),

	gh("mrsobakin/multilayout.nvim"),
})

local ts_parsers = {
	-- languages
	"rust",
	"python",
	"go",
	"lua",
	"gdscript",
	"javascript",
	"typescript",
	"tsx",
	"svelte",
	"c",
	"cpp",
	"nix",
	-- config / dotfile formats
	"bash",
	"json",
	"toml",
	"yaml",
	"css",
	"html",
	"markdown",
}
require("nvim-treesitter").install(ts_parsers)

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ts_start", { clear = true }),
	callback = function(ev)
		if not vim.treesitter.highlighter.active[ev.buf] then
			pcall(vim.treesitter.start, ev.buf)
		end
	end,
})

require("nvim-autopairs").setup()
require("lualine").setup({
	options = {
		globalstatus = true,
		section_separators = "",
		component_separators = "",
	},
	sections = {
		lualine_b = { { "filename", path = 1 } },
		lualine_c = {},
		lualine_x = { "progress" },
		lualine_y = { "branch", "diff", "diagnostics" },
		lualine_z = { "lsp_status" },
	},
})

---@diagnostic disable-next-line
require("hotreload").setup()
require("gitsigns").setup()

require("neoscroll").setup({
	duration_multiplier = 0.5,
})
require("snacks").setup({
	statuscolumn = { enabled = true },
	indent = { enabled = true },
	quickfile = { enabled = true },
	image = { enabled = true },
	picker = {
		enabled = true,
		win = {
			input = {
				keys = {
					-- single <Esc> closes the picker instead of dropping to normal mode first
					["<Esc>"] = { "close", mode = { "n", "i" } },
				},
			},
		},
	},
})

require("mini.icons").setup()
require("mini.files").setup({
	windows = {
		preview = true,
		width_focus = 30,
		width_preview = 50,
	},
	options = {
		use_as_default_explorer = true,
		permanent_delete = true,
	},
	mappings = {
		go_in_plus = "l",
		close = "<Esc>",
	},
})

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		local MiniFiles = require("mini.files")
		vim.keymap.set("n", "<CR>", function()
			MiniFiles.go_in({ close_on_file = true })
		end, { buffer = buf })
		vim.keymap.set("n", "q", function()
			MiniFiles.close()
		end, { buffer = buf })

		local buf = args.data.buf_id
		vim.keymap.set("n", "j", function()
			local last = vim.fn.line("$")
			vim.cmd(vim.fn.line(".") == last and "normal! gg" or "normal! j")
		end, { buffer = buf })
		vim.keymap.set("n", "k", function()
			vim.cmd(vim.fn.line(".") == 1 and "normal! G" or "normal! k")
		end, { buffer = buf })
	end,
})

require("mini.operators").setup()
require("mini.surround").setup()
require("mini.move").setup()
require("mini.jump").setup()
require("mini.ai").setup({
	custom_textobjects = {
		B = function()
			local from = { line = 1, col = 1 }
			local to = {
				line = vim.fn.line("$"),
				col = math.max(vim.fn.getline("$"):len(), 1),
			}
			return { from = from, to = to }
		end,
	},
})

require("blink.cmp").setup({
	keymap = { preset = "enter", ["<Tab>"] = { "accept", "fallback" } },
	cmdline = {
		keymap = {
			preset = "inherit",
			["<Tab>"] = { "accept" },
			["<CR>"] = { "accept_and_enter", "fallback" },
		},
		completion = {
			menu = { auto_show = true },
		},
	},
	completion = {
		documentation = {
			auto_show = true,
		},
	},
	sources = {
		providers = {
			cmdline = {
				min_keyword_length = function(ctx)
					if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
						return 3
					end
					return 0
				end,
			},
		},
	},
})

require("conform").setup({
	default_format_opts = {
		lsp_format = "fallback",
	},
	-- format_on_save = {},
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixpkgs_fmt" },
	},
})

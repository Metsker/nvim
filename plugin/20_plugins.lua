local add = vim.pack.add

local function gh(str)
	return "https://github.com/" .. str
end
add({
	gh("neovim/nvim-lspconfig"),
	gh("stevearc/oil.nvim.git"),
	gh("mason-org/mason.nvim"),
	gh("stevearc/conform.nvim"),
	gh("nvim-treesitter/nvim-treesitter"),
	gh("nvim-treesitter/nvim-treesitter-textobjects"),
	gh("rafamadriz/friendly-snippets"),
	{
		src = gh("saghen/blink.cmp.git"),
		version = "v1.10.2",
	},
	gh("nvim-lua/plenary.nvim"),
	gh("nvim-telescope/telescope.nvim"),
	gh("nvim-telescope/telescope-fzy-native.nvim"),
	gh("nvim-lualine/lualine.nvim"),
	gh("windwp/nvim-autopairs"),
	gh("karb94/neoscroll.nvim"),
	gh("aserowy/tmux.nvim"),

	gh("folke/snacks.nvim"),
	gh("diogo464/hotreload.nvim"),

	gh("nvim-mini/mini.icons"),
	gh("nvim-mini/mini.operators"),
	gh("nvim-mini/mini.surround"),
	gh("nvim-mini/mini.move"),
	gh("nvim-mini/mini.ai"),
	gh("nvim-mini/mini.clue"),
	gh("nvim-mini/mini.jump"),

	gh("Metsker/sixelvim"),

	gh("lewis6991/gitsigns.nvim"),

	gh("mrsobakin/multilayout.nvim"),
	-- gh("Wansmer/langmapper.nvim"),
})

require("sixel-preview").setup({
	sixel = {
		chafa_colors = "full",
		max_width = 800,
    max_height = 600,
	},
	converters = {
		image = "chafa",
	},
})

---@diagnostic disable-next-line
require("tmux").setup({
	copy_sync = {
		enable = false,
	},
	resize = {
		enable_default_keybindings = false,
		resize_step_x = 5,
		resize_step_y = 5,
	},
	swap = {
		enable_default_keybindings = false,
	},
})

require("mason").setup()
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
	-- image = {enabled = true },
	indent = { enabled = true },
	quickfile = { enabled = true },
})

require("mini.icons").setup()
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
	formatters_by_ft = { lua = { "stylua" } },
})

require("oil").setup({
	default_file_explorer = true,
	delete_to_trash = true,
	skip_confirm_for_simple_edits = true,
	win_options = {
		wrap = true,
	},
	float = {
		preview_split = "right",
		padding = 2,
		max_width = 0.79,
		max_height = 0.79,
		border = "single",
	},
	keymaps = {
		["<Esc>"] = { "actions.close", mode = "n" },
		["<C-p>"] = false,
	},
})

require("telescope").setup({
	defaults = {
		borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		buffer_previewer_maker = require("sixel-preview.telescope").previewer_maker,
	},
	extensions = {
		fzy_native = {
			override_generic_sorter = false,
			override_file_sorter = true,
		},
	},
})
require("telescope").load_extension("fzy_native")

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
	gh("nvim-mini/mini.files"),
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
		permanent_delete = false,
	},
	mappings = {
		go_in_plus = "<CR>",
	},
})
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		vim.keymap.set("n", "<Esc>", require("mini.files").close, { buffer = args.data.buf_id })
	end,
})
local sixel_render_timer = nil
local function pad_buffer_for_image(buf)
	-- Mini.files sizes the preview window height to buf_line_count. The
	-- "-Non-text-file---" placeholder is one line, leaving the window too
	-- short for a real image. Fill the buffer with empty lines so the
	-- subsequent height calc gives us a tall preview pane.
	local target_lines = math.max(20, vim.o.lines - 6)
	pcall(function()
		vim.bo[buf].modifiable = true
		local empty = {}
		for i = 1, target_lines do
			empty[i] = ""
		end
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, empty)
	end)
end
local function sixel_render_mini_preview(buf, path)
	if sixel_render_timer then
		pcall(function()
			sixel_render_timer:stop()
			sixel_render_timer:close()
		end)
	end
	sixel_render_timer = vim.defer_fn(function()
		sixel_render_timer = nil
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		pcall(vim.cmd, "mode")
		require("sixel-preview.preview").open_in_buf(buf, path)
	end, 30)
end
local function expand_preview_window(win_id)
	if not (win_id and vim.api.nvim_win_is_valid(win_id)) then
		return
	end
	pcall(function()
		local cfg = vim.api.nvim_win_get_config(win_id)
		cfg.height = math.max(20, vim.o.lines - 6)
		vim.api.nvim_win_set_config(win_id, cfg)
	end)
end
vim.api.nvim_create_autocmd("User", {
	pattern = { "MiniFilesBufferUpdate", "MiniFilesWindowUpdate" },
	callback = function(args)
		local buf = args.data.buf_id
		local path = vim.api.nvim_buf_get_name(buf):match("^minifiles://%d+/(.*)$")
		if not path or vim.fn.filereadable(path) ~= 1 then
			return
		end
		if not require("sixel-preview.converters").detect(path) then
			return
		end
		pad_buffer_for_image(buf)
		expand_preview_window(args.data.win_id)
		sixel_render_mini_preview(buf, path)
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
	format_on_save = {},
	formatters_by_ft = { lua = { "stylua" } },
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

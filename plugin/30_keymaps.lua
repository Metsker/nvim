local set = vim.keymap.set

-- Run a shell command in a small split. Closes the window when the process exits.
-- Uses jobstart(…, { term = true, on_exit }) (replaces termopen) because an interactive
-- :term + chansend only ends the child process; the shell keeps running, so TermClose
-- never fires.
local function run_in_terminal(cmd)
	vim.cmd.vnew()
	local win = vim.api.nvim_get_current_win()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, 10)
	vim.fn.jobstart({ "sh", "-c", cmd }, {
		term = true,
		on_exit = function()
			vim.schedule(function()
				if vim.api.nvim_win_is_valid(win) then
					pcall(vim.api.nvim_win_close, win, true)
				end
			end)
		end,
	})
end

local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		{ mode = { "n", "x" }, keys = "<Leader>" },
		{ mode = { "n", "x" }, keys = "[" },
		{ mode = { "n", "x" }, keys = "]" },
		{ mode = { "n", "x" }, keys = "g" },
		{ mode = { "n", "x" }, keys = "'" },
		{ mode = { "n", "x" }, keys = "`" },
		{ mode = { "n", "x" }, keys = '"' },
		{ mode = { "i", "c" }, keys = "<C-r>" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = { "n", "x" }, keys = "s" },
		{ mode = { "n", "x" }, keys = "z" },
		{ mode = { "n", "x" }, keys = "m" },
	},
	clues = {
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.square_brackets(),
		miniclue.gen_clues.windows({ submode_resize = true }),
		miniclue.gen_clues.z(),
		{ mode = "n", keys = "<Leader>f", desc = "+Find" },
		{ mode = { "n", "x" }, keys = "<Leader>l", desc = "+LSP" },
		{ mode = { "n" }, keys = "<Leader>e", desc = "+Edit/Explore" },
		{ mode = { "n" }, keys = "<Leader>r", desc = "+Run" },
	},
	window = {
		delay = 500,
		config = {
			border = "single",
			width = "40",
		},
	},
})

-- Files
set("n", "<C-s>", ":w<CR>") local builtin = require("telescope.builtin")
set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
set("n", "<leader>fd", builtin.builtin, { desc = "Builtins" })
set("n", "<leader>?", builtin.keymaps, { desc = "Keymaps" })

-- Tmux
set("", "<C-S-h>", '<cmd>lua require("tmux").resize_to("left", step)<cr>')
set("", "<C-S-j>", '<cmd>lua require("tmux").resize_to("bottom", step)<cr>')
set("", "<C-S-k>", '<cmd>lua require("tmux").resize_to("top", step)<cr>')
set("", "<C-S-l>", '<cmd>lua require("tmux").resize_to("right", step)<cr>')

set("", "<C-M-S-h>", '<cmd>lua require("tmux").swap_to("left")<cr>')
set("", "<C-M-S-j>", '<cmd>lua require("tmux").swap_to("bottom")<cr>')
set("", "<C-M-S-k>", '<cmd>lua require("tmux").swap_to("top")<cr>')
set("", "<C-M-S-l>", '<cmd>lua require("tmux").swap_to("right")<cr>')

-- Unbinds
set("", "<C- >", function() end)
set("", " ", function() end)
set({ "n", "o" }, "<CR>", function()
	require("flash").jump({
		remote_op = {
			restore = true,
			motion = nil,
		},
	})
end)
set("n", "<Leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
set({ "n", "x", "o" }, "<Tab>", function()
	require("flash").treesitter({
		actions = {
			["<Tab>"] = "next",
			["<S-Tab>"] = "prev",
		},
	})
end, { desc = "Treesitter incremental selection" })

set("x", "/", "<Esc>/\\%V")
set("x", "ms", [[:l/\%V]], { desc = "Replace inside selection" })

set("n", "<leader>la", "<Cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Actions" })
set("n", "<leader>ld", "<Cmd>lua vim.diagnostic.open_float()<CR>", { desc = "Diagnostic popup" })
set({ "n", "x" }, "<leader>lf", '<Cmd>lua require("conform").format()<CR>', { desc = "Format" })
set("n", "<leader>li", "<Cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "Implementation" })
set("n", "<leader>lh", "<Cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Hover" })
set("n", "<leader>ll", "<Cmd>lua vim.lsp.codelens.run()<CR>", { desc = "Lens" })
set("n", "<leader>lr", "<Cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })
set("n", "<leader>lR", "<Cmd>lua vim.lsp.buf.references()<CR>", { desc = "References" })
set("n", "<leader>ls", "<Cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Source definition" })
set("n", "<leader>lt", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", { desc = "Type definition" })

set("n", "[p", '<Cmd>exe "iput! " . v:register<CR>', { desc = "Paste Above" })
set("n", "]p", '<Cmd>exe "iput "  . v:register<CR>', { desc = "Paste Below" })

local edit_plugin_file = function(filename)
	return string.format("<Cmd>edit %s/plugin/%s<CR>", vim.fn.stdpath("config"), filename)
end
local explore_quickfix = function()
	vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and "cclose" or "copen")
end
local explore_locations = function()
	vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and "lclose" or "lopen")
end

set("n", "<Leader>ef", function()
	require("oil").open_float(nil, { preview = {} })
end, { desc = "Explore files" })
set("n", "<Leader>ei", "<Cmd>edit $MYVIMRC<CR>", { desc = "init.lua" })
set("n", "<Leader>eo", edit_plugin_file("10_options.lua"), { desc = "Options config" })
set("n", "<Leader>ep", edit_plugin_file("20_plugins.lua"), { desc = "Plugins config" })
set("n", "<Leader>ek", edit_plugin_file("30_keymaps.lua"), { desc = "Keymaps config" })
set("n", "<Leader>eq", explore_quickfix, { desc = "Quickfix list" })
set("n", "<Leader>eQ", explore_locations, { desc = "Location list" })

-- set("n", "<leader>rl", function()
-- 	vim.fn.system("love .")
-- end, { desc = "Run LÖVE game from current directory" })

set("n", "<Leader>rl", function()
	run_in_terminal("love .")
end, { desc = "Run LÖVE with terminal attached" })

---
require("multilayout").setup({
	layouts = {
		ru = "ru",
	},
	use_libukb = false,
})
require("langmapper").setup()

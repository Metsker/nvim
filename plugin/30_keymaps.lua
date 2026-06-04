local set = vim.keymap.set

-- Bottom split stays open so crash output remains visible; next run enews + drops old term buffer.
local RUN_TERM_HEIGHT = 10
local RUN_TERM_SHRINK_HEIGHT = 1
local run_in_terminal_state = { win = nil, buf = nil, is_shrunk = false }

-- shrink_on_close: if true, window height is reduced on exit; next run expands again.
-- on_exit always: if the run terminal is still the active window, focus the previous (last) window.
local function run_in_terminal(cmd, shrink_on_close)
	local s = run_in_terminal_state
	local function after_term()
		local buf = vim.api.nvim_get_current_buf()
		vim.bo[buf].bufhidden = "wipe"
		vim.bo[buf].buflisted = false
		return buf
	end
	local function start_job()
		local run_win = s.win
		local function focus_previous_if_terminal_active()
			if not vim.api.nvim_win_is_valid(run_win) or vim.api.nvim_get_current_win() ~= run_win then
				return
			end
			local prev_id = vim.fn.win_getid(vim.fn.winnr("#"))
			if prev_id > 0 and prev_id ~= run_win then
				pcall(vim.api.nvim_set_current_win, prev_id)
			end
		end
		vim.fn.jobstart({ "sh", "-c", cmd }, {
			term = true,
			on_exit = function()
				vim.schedule(function()
					if not vim.api.nvim_win_is_valid(run_win) then
						return
					end
					if shrink_on_close then
						pcall(vim.api.nvim_win_set_height, run_win, RUN_TERM_SHRINK_HEIGHT)
						s.is_shrunk = true
					end
					focus_previous_if_terminal_active()
				end)
			end,
		})
		s.buf = after_term()
	end

	if s.win and vim.api.nvim_win_is_valid(s.win) then
		vim.api.nvim_set_current_win(s.win)
		if s.is_shrunk then
			pcall(vim.api.nvim_win_set_height, s.win, RUN_TERM_HEIGHT)
			s.is_shrunk = false
		end
		local old_buf = s.buf
		vim.cmd("enew!")
		if old_buf and vim.api.nvim_buf_is_valid(old_buf) then
			pcall(vim.api.nvim_buf_delete, old_buf, { force = true })
		end
		start_job()
		return
	end

	s.win, s.buf, s.is_shrunk = nil, nil, false
	vim.cmd.vnew()
	s.win = vim.api.nvim_get_current_win()
	vim.cmd.wincmd("J")
	vim.api.nvim_win_set_height(0, RUN_TERM_HEIGHT)
	start_job()
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
		{ mode = { "n" }, keys = "<Leader>t", desc = "+Tabs" },
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
set("n", "<C-s>", ":w<CR>")
local picker = require("snacks").picker
set("n", "<leader><leader>", function() picker.smart() end, { desc = "Smart picker" })
set("n", "<leader>ff", function() picker.files() end, { desc = "Find files" })
set("n", "<leader>fg", function() picker.grep() end, { desc = "Live grep" })
set("n", "<leader>fb", function() picker.buffers() end, { desc = "Buffers" })
set("n", "<leader>fd", function() picker.pickers() end, { desc = "All pickers" })
set("n", "<leader>?", function() picker.keymaps() end, { desc = "Keymaps" })

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

-- Move by display lines (wrapped lines act as separate lines), but keep
-- count-prefixed motions (e.g. 5j) on real lines so relative jumps still work.
set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down (display line)" })
set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up (display line)" })

set("n", "<Leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
set({ "n", "x", "o" }, "mi", function()
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

set("n", "<leader>a", "<C-6>", { desc = "Go to last file" }) -- test

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
	local path = vim.api.nvim_buf_get_name(0)
	require("mini.files").open(path ~= "" and path or nil, true)
end, { desc = "Explore files" })
set("n", "<Leader>ei", "<Cmd>edit $MYVIMRC<CR>", { desc = "init.lua" })
set("n", "<Leader>eo", edit_plugin_file("10_options.lua"), { desc = "Options config" })
set("n", "<Leader>ep", edit_plugin_file("20_plugins.lua"), { desc = "Plugins config" })
set("n", "<Leader>ek", edit_plugin_file("30_keymaps.lua"), { desc = "Keymaps config" })
set("n", "<Leader>eq", explore_quickfix, { desc = "Quickfix list" })
set("n", "<Leader>eQ", explore_locations, { desc = "Location list" })

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
-- vim.keymap.del("n", "C-i", { silent = true }) Tab is sending C-i

set("n", "<Leader>rll", function()
	run_in_terminal("love .", true)
end, { desc = "Run LÖVE with terminal attached" })

for i = 1, 6 do
	set("n", "<Leader>rl"..i, function()
		run_in_terminal("love . slot_"..i, true)
	end, { desc = "Run LÖVE with terminal attached" })
end

for i = 1, 6 do
	set("n", "<Leader>rle"..i, function()
		run_in_terminal("love editor_help slot_"..i, true)
	end, { desc = "Run LÖVE help editor with terminal attached" })
end

vim.api.nvim_set_keymap("n", "<leader>tn", ":tabnew<CR>", { desc = "Create new tab", noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>tq",
	":tabclose<CR>",
	{ desc = "Close current tab", noremap = true, silent = true }
)

vim.api.nvim_set_keymap("n", "<leader>tl", ":tabnext<CR>", { desc = "Select next tab" })
vim.api.nvim_set_keymap("n", "<leader>th", ":tabprevious<CR>", { desc = "Select previous tab" })

---
require("multilayout").setup({
	layouts = {
		ru = "ru",
	},
	use_libukb = false,
})
-- require("langmapper").setup()

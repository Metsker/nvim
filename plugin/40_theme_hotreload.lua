local theme_file = vim.env.HOME .. "/.config/nvim/theme.lua"
local watch_dir = vim.env.HOME .. "/.config/omarchy/current"

local function read_theme_spec()
	local chunk = loadfile(theme_file)
	if not chunk then
		return nil
	end
	local ok, res = pcall(chunk)
	if not ok or type(res) ~= "table" then
		return nil
	end
	local src = res[1] and res[1][1]
	local name = res[2] and res[2].opts and res[2].opts.colorscheme
	if type(src) ~= "string" or type(name) ~= "string" then
		return nil
	end
	return { src = src, name = name }
end

local function unload_plugin_modules(src)
	local repo = src:match("/([^/]+)$") or src
	repo = repo:gsub("%.git$", "")
	local base = repo:gsub("%.n?vim$", "")
	for mod in pairs(package.loaded) do
		if mod == base or mod:sub(1, #base + 1) == base .. "." then
			package.loaded[mod] = nil
		end
	end
end

local function apply_theme()
	local spec = read_theme_spec()
	if not spec then
		return
	end

	pcall(vim.pack.add, { "https://github.com/" .. spec.src }, { confirm = false })

	unload_plugin_modules(spec.src)

	vim.cmd("highlight clear")
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.o.background = "dark"

	pcall(vim.cmd.colorscheme, spec.name)
	vim.api.nvim_exec_autocmds("ColorScheme", { modeline = false })
	vim.cmd("redraw!")
end

apply_theme()

local w = vim.uv.new_fs_event()
if w then
	local pending = false
	pcall(function()
		w:start(watch_dir, {}, vim.schedule_wrap(function(err, fname)
			if err or fname ~= "theme" or pending then
				return
			end
			pending = true
			vim.defer_fn(function()
				pending = false
				apply_theme()
			end, 150)
		end))
	end)
end

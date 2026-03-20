-- custom_fonts.lua
local M = {}

-- State for debouncing
local timer = (vim.uv or vim.loop).new_timer()

-- Default configuration
M.config = {
	ghostty_path = vim.fn.expand("~/.config/ghostty/config"),
	name = "JetBrainsMono Nerd Font",
	size = 12,
}

-- Check if telescope is available
local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
	-- If telescope is missing, we don't crash, just return a dummy setup
	function M.setup()
		print("Telescope not found. Please install 'nvim-telescope/telescope.nvim'")
	end

	return M
end

-- Telescope modules
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values

-- Apply changes to Ghostty config
local function apply_to_ghostty(font_name)
	local path = M.config.ghostty_path
	if vim.fn.filereadable(path) ~= 1 then return end

	local lines = vim.fn.readfile(path)
	local found = false
	for i, line in ipairs(lines) do
		if line:match("^font%-family%s*=") then
			lines[i] = 'font-family = "' .. font_name .. '"'
			found = true
		end
	end
	if not found then table.insert(lines, 'font-family = "' .. font_name .. '"') end

	vim.fn.writefile(lines, path)
	-- Reload Ghostty
	vim.fn.system("killall -SIGUSR2 ghostty")
end

-- Main Picker function
function M.picker()
	local fonts = {}
	-- Load fonts from system
	local handle = io.popen("fc-list :spacing=mono family")
	if handle then
		for line in handle:lines() do
			local name = line:match("([^,]+)")
			if name and not name:find(":") then table.insert(fonts, name) end
		end
		handle:close()
	end
	table.sort(fonts)

	pickers.new({}, {
		prompt_title = "Ghostty Font Preview",
		finder = finders.new_table { results = fonts },
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			-- Debounced preview function
			local function update_font()
				timer:stop()
				timer:start(150, 0, vim.schedule_wrap(function()
					local selection = action_state.get_selected_entry()
					if selection then apply_to_ghostty(selection[1]) end
				end))
			end

			-- Live preview on Tab/Arrows
			map("i", "<Tab>", function()
				actions.move_selection_next(prompt_bufnr)
				update_font()
			end)
			map("i", "<S-Tab>", function()
				actions.move_selection_previous(prompt_bufnr)
				update_font()
			end)
			map("i", "<Down>", function()
				actions.move_selection_next(prompt_bufnr)
				update_font()
			end)
			map("i", "<Up>", function()
				actions.move_selection_previous(prompt_bufnr)
				update_font()
			end)

			-- Confirm selection
			actions.select_default:replace(function()
				timer:stop() -- Prevent pending updates after closing
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				if selection then
					apply_to_ghostty(selection[1])
					print("Font applied: " .. selection[1])
				end
			end)

			return true
		end,
	}):find()
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	-- Create command to launch the picker
	vim.api.nvim_create_user_command("GhosttyFonts", function()
		M.picker()
	end, {})
end

return M

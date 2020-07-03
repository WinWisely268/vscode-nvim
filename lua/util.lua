--- Mities
-- @module core.M

-- local modes = require("core.modes")
local M = {}

-- Create augroup
function M.create_augroups(definitions)
	for group_name, definition in pairs(definitions) do
		vim.cmd("augroup " .. group_name)
		vim.cmd("autocmd!")
		for _, def in ipairs(definition) do
			local command = table.concat(vim.tbl_flatten{"autocmd", def}, " ")
			vim.cmd(command)
		end
		vim.cmd("augroup END")
	end
end

-- Bind key
local function escape_keymap(key)
	-- Prepend with a letter so it can be used as a dictionary key
	return 'k'..key:gsub('.', string.byte)
end


local modes = {
	c = "c",
	i = "i",
	n = "n",
	o = "o",
	t = "t",
	v = "v",
	x = "x"
}

BIND_FUNC = {}

function M.bind_key(map)
	for key, value in pairs(map) do
		local mode, lhs = key:match("^(.)(.+)$")
		local rhs = value[1]
		local default_opts = {}

		if not modes[mode] then
			assert(false, "Not a valid mode " .. mode)
		end
		mode = modes[mode]

		if #value > 1 then
			default_opts = vim.tbl_extend("force", default_opts, value[2])
		else
			default_opts = { noremap = true, silent = true }
		end

		if type(rhs) == "function" then
			local escaped = escape_keymap(key)
			BIND_FUNC[escaped] = rhs
			rhs = (":lua BIND_FUNC.%s()<CR>"):format(escaped)
		end

		vim.api.nvim_set_keymap(mode, lhs, rhs, default_opts)
	end
end

function M.noremap_key(map)
	for key, value in pairs(map) do
		local lhs = key
		local rhs = value[1]
		local default_opts = {}

		if #value > 1 then
			default_opts = vim.tbl_extend("force", default_opts, value[2])
		else
			default_opts = { noremap = true, silent = true }
		end

		if type(rhs) == "function" then
			local escaped = escape_keymap(key)
			BIND_FUNC[escaped] = rhs
			rhs = (":lua BIND_FUNC.%s()<CR>"):format(escaped)
		end

		vim.api.nvim_set_keymap(modes['n'], lhs, rhs, default_opts)
		vim.api.nvim_set_keymap(modes['v'], lhs, rhs, default_opts)
		vim.api.nvim_set_keymap(modes['o'], lhs, rhs, default_opts)
	end
end

-- from https://github.com/neovim/nvim-lsp/blob/master/lua/nvim_lsp/M.lua

local is_windows = vim.loop.os_uname().version:match("Windows")
local path_sep = is_windows and "\\" or "/"
local strip_dir_pat = path_sep.."([^"..path_sep.."]+)$"
local strip_sep_pat = path_sep.."$"

local is_fs_root

if is_windows then
	is_fs_root = function(path)
		return path:match("^%a:$")
	end
else
	is_fs_root = function(path)
		return path == "/"
	end
end


function M.jump_to_buf(buf, range)
	vim.api.nvim_set_current_buf(buf)
	local row = range.start.line
	local col = range.start.character
	local line = vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
	col = vim.str_byteindex(line, col)
	vim.api.nvim_win_set_cursor(0, { row + 1, col })
end


function M.err_message(...)
	vim.api.nvim_err_writeln(table.concat(vim.tbl_flatten{...}))
	vim.api.nvim_command("redraw")
end


function M.exists(filename)
	local stat = vim.loop.fs_stat(filename)
	return stat and stat.type or false
end

local function dirname(path)
	if not path then return end
	local result = path:gsub(strip_sep_pat, ""):gsub(strip_dir_pat, "")
	if #result == 0 then
		return "/"
	end
	return result
end

local function path_join(...)
	local result = table.concat(vim.tbl_flatten {...}, path_sep):gsub(path_sep.."+", path_sep)
	return result
end

local function iterate_parents(path)
	path = vim.loop.fs_realpath(path)
	local function it(_, v)
		if not v then return end
		if is_fs_root(v) then return end
		return dirname(v), path
	end
	return it, path, path
end

local function search_ancestors(startpath, fn)
	if fn(startpath) then return startpath end
	for path in iterate_parents(startpath) do
		if fn(path) then return path end
	end
end


function M.root_pattern(bufnr, patterns)
	local function matcher(path)
		for _, pattern in ipairs(patterns) do
			if M.exists(path_join(path, pattern)) then
				return path
			end
		end
	end

	local filepath = vim.api.nvim_buf_get_name(bufnr)
	local path = dirname(filepath)
	return search_ancestors(path, matcher)
end

function M.list_buffers()
	local bufs = vim.api.nvim_list_bufs()
	return table.concat(bufs, "\n")
end

function M.exists(file)
	local ok, err, code = os.rename(file, file)

	if not ok then
		if code == 13 then return true end
	end

	return ok, err
end

function M.isdir(path)
	local stat = vim.loop.fs_stat(path)
	return stat ~= nil and stat.type == "directory"
end

function M.exec(prog)
	local i = 0
	local result = {}

	local pfile = io.popen(prog)

	for filename in pfile:lines() do
		i = i + 1
		result[i] = filename
	end

	pfile:close()

	return result
end

function M.readdir(path)
	return M.exec('ls -a "' .. path .. '"')
end

function M.scandir(path)
	local i, t, popen = 0, {}, io.popen
	local pfile = popen('ls -a "'..path..'"')
	for filename in pfile:lines() do
		i = i + 1
		t[i] = filename
	end
	pfile:close()
	return t
end

function M.check_create_dir(path)
	return M.isdir(path) or os.execute('mkdir -p '..path)
end

return M

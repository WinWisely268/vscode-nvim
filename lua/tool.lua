local M = {}
local jobby = require('luajob')
local api = vim.api

local function endswith(str, ending)
	return ending == "" or str:sub(-(#ending)) == ending
end

local function close_git_status()
	local wins = api.nvim_list_wins()
	for _, w in ipairs(wins) do
		local buf = vim.api.nvim_win_get_buf(w)
		local buf_name = vim.api.nvim_buf_get_name(buf)
		if endswith(buf_name, ".git/index") then
			vim.api.nvim_win_close(w, false)
		end
	end
end

local function async_on_stdout(err, data)
	if err then
		vim.cmd.echoerr("error: ", err)
	elseif data then
		local lines = vim.fn.split(data, "\n")
		for _, line in ipairs(lines) do
			print(line)
		end
	end
end

M = {}

function M.async_run(cmd)
	vim.g.last_execution = cmd
	local output = ""
	local on_output = function(err, data)
		if err then
			print(err)
		end
		if data then
			local lines = vim.fn.split(data, "\n")
			for _, line in ipairs(lines) do
				print(line)
				output = output ..'\n'.. line
			end
		end
	end
	local job =
	jobby:new(
	{
		cmd = cmd,
		on_stdout = on_output,
		on_stderr = on_output,
		on_exit = function(code, _)
			if code ~= 0 then
				print('"' .. cmd .. '" failed!')
				local win = vim.api.nvim_get_current_win()
				vim.cmd("vert new")
				vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, false, vim.split(output, "\n"))
				vim.bo.bufhidden = "wipe"
				vim.bo.modified = false
				vim.api.nvim_set_current_win(win)
			else
				print('"' .. cmd .. '" finished!')
			end
		end
	}
	)
	job:start()
end

function M.async_git_push(force)
	local git_push =
	jobby:new(
	{
		cmd = "git push" .. (force and " -f" or ""),
		on_stdout = async_on_stdout,
		on_stderr = async_on_stdout,
		on_exit = function(code, _)
			if code == 0 then
				print("Git push succeeded!")
			end
		end
	}
	)
	git_push:start()
	close_git_status()
end

function M.async_custom_cmd(cmd)
	local job = jobby:new({
		cmd = cmd,
		on_stdout = async_on_stdout,
		on_exit = function(code, _)
			if code == 0 then
				print('"'..cmd..'" done, succeeded')
			end
		end
	})
	job:start()
end

return M

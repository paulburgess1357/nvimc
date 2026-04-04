local plugins = require("config.plugins")
local cfg = plugins.dap or {}
if cfg.enabled == false then return end

-----------------------------------------------------------
-- DAP Core
-----------------------------------------------------------
local dap = require("dap")
local mason_path = vim.fn.stdpath("data") .. "/mason/packages"

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "Visual", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticError", linehl = "", numhl = "" })

-- C/C++ (cpptools/GDB)
dap.adapters.cppdbg = {
	id = "cppdbg",
	type = "executable",
	command = mason_path .. "/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
}
dap.configurations.cpp = {
	{
		name = "Launch file",
		type = "cppdbg",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopAtEntry = false,
		MIMode = "gdb",
		miDebuggerPath = "/usr/bin/gdb",
	},
}
dap.configurations.c = dap.configurations.cpp

-- Python (debugpy)
dap.adapters.python = {
	type = "executable",
	command = mason_path .. "/debugpy/venv/bin/python",
	args = { "-m", "debugpy.adapter" },
}
dap.configurations.python = {
	{
		name = "Launch file",
		type = "python",
		request = "launch",
		program = "${file}",
		cwd = "${workspaceFolder}",
	},
}

-- Go (delve)
dap.adapters.delve = {
	type = "server",
	port = "${port}",
	executable = {
		command = mason_path .. "/delve/dlv",
		args = { "dap", "-l", "127.0.0.1:${port}" },
	},
}
dap.configurations.go = {
	{
		name = "Launch file",
		type = "delve",
		request = "launch",
		program = "${file}",
	},
	{
		name = "Launch package",
		type = "delve",
		request = "launch",
		program = "${workspaceFolder}",
	},
}

-- JavaScript/Node (js-debug-adapter)
dap.adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = mason_path .. "/js-debug-adapter/js-debug-adapter",
		args = { "${port}" },
	},
}
dap.configurations.javascript = {
	{
		name = "Launch file",
		type = "pwa-node",
		request = "launch",
		program = "${file}",
		cwd = "${workspaceFolder}",
	},
}
dap.configurations.typescript = dap.configurations.javascript

-- Bash (bash-debug-adapter)
dap.adapters.bashdb = {
	type = "executable",
	command = mason_path .. "/bash-debug-adapter/bash-debug-adapter",
}
dap.configurations.sh = {
	{
		name = "Launch file",
		type = "bashdb",
		request = "launch",
		program = "${file}",
		cwd = "${workspaceFolder}",
		pathBashdb = mason_path .. "/bash-debug-adapter/extension/bashdb_dir/bashdb",
		pathBashdbLib = mason_path .. "/bash-debug-adapter/extension/bashdb_dir",
		pathBash = "/bin/bash",
		pathCat = "/bin/cat",
		pathMkfifo = "/usr/bin/mkfifo",
		pathPkill = "/usr/bin/pkill",
		env = {},
	},
}
dap.configurations.bash = dap.configurations.sh

-----------------------------------------------------------
-- DAP UI
-----------------------------------------------------------
local dapui = require("dapui")
dapui.setup({
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.25 },
				{ id = "breakpoints", size = 0.25 },
				{ id = "stacks", size = 0.25 },
				{ id = "watches", size = 0.25 },
			},
			position = "left",
			size = 40,
		},
		{
			elements = {
				{ id = "repl", size = 0.5 },
				{ id = "console", size = 0.5 },
			},
			position = "bottom",
			size = 10,
		},
	},
})

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close({})
end

-----------------------------------------------------------
-- DAP Virtual Text
-----------------------------------------------------------
require("nvim-dap-virtual-text").setup({
	enabled = true,
	enabled_commands = true,
	highlight_changed_variables = true,
	highlight_new_as_changed = false,
	show_stop_reason = true,
	commented = false,
	virt_text_pos = "eol",
})

-----------------------------------------------------------
-- Persistent Breakpoints
-----------------------------------------------------------
require("persistent-breakpoints").setup({
	load_breakpoints_event = { "BufReadPost" },
})

-----------------------------------------------------------
-- Keymaps
-----------------------------------------------------------
local pb = require("persistent-breakpoints.api")

-- Breakpoints
vim.keymap.set("n", "<leader>db", pb.toggle_breakpoint, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Condition: ")) end, { desc = "Conditional Breakpoint" })
-- Execution
vim.keymap.set("n", "<leader>dc", "<cmd>DapContinue<cr>", { desc = "Continue / Start" })
vim.keymap.set("n", "<leader>dC", function() dap.run_to_cursor() end, { desc = "Run to Cursor" })
vim.keymap.set("n", "<leader>dl", function() dap.run_last() end, { desc = "Run Last" })
vim.keymap.set("n", "<leader>dp", function() dap.pause() end, { desc = "Pause" })
vim.keymap.set("n", "<leader>dt", function() dap.terminate() end, { desc = "Terminate" })
-- Stepping
vim.keymap.set("n", "<leader>di", "<cmd>DapStepInto<cr>", { desc = "Step Into" })
vim.keymap.set("n", "<leader>do", "<cmd>DapStepOver<cr>", { desc = "Step Over" })
vim.keymap.set("n", "<leader>dO", function() dap.step_out() end, { desc = "Step Out" })
-- Navigation
vim.keymap.set("n", "<leader>dj", function() dap.down() end, { desc = "Down Stack" })
vim.keymap.set("n", "<leader>dk", function() dap.up() end, { desc = "Up Stack" })
-- Tools
vim.keymap.set("n", "<leader>dr", function() dap.repl.toggle() end, { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>ds", function() dap.session() end, { desc = "Session" })
vim.keymap.set("n", "<leader>dL", function() dap.set_breakpoint(nil, nil, vim.fn.input("Log message: ")) end, { desc = "Log Point" })
vim.keymap.set("n", "<leader>dE", function()
	vim.ui.select({ "all", "uncaught", "none" }, { prompt = "Exception breakpoints:" }, function(choice)
		if choice then
			local filters = choice == "none" and {} or { choice }
			dap.set_exception_breakpoints(filters)
			vim.notify("Exception breakpoints: " .. choice, vim.log.levels.INFO)
		end
	end)
end, { desc = "Exception Breakpoints" })
vim.keymap.set("n", "<leader>da", function() dapui.elements.watches.add(vim.fn.expand("<cword>")) end, { desc = "Add Watch" })
-- DAP UI
vim.keymap.set("n", "<leader>du", function() dapui.toggle({}) end, { desc = "DAP UI" })
vim.keymap.set({ "n", "v" }, "<leader>de", function() dapui.eval() end, { desc = "Eval" })
-- F-key bindings
vim.keymap.set("n", "<F5>", "<cmd>DapContinue<cr>", { desc = "Continue" })
vim.keymap.set("n", "<F9>", pb.toggle_breakpoint, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<F10>", "<cmd>DapStepOver<cr>", { desc = "Step Over" })
vim.keymap.set("n", "<F11>", "<cmd>DapStepInto<cr>", { desc = "Step Into" })
vim.keymap.set("n", "<S-F11>", function() dap.step_out() end, { desc = "Step Out" })

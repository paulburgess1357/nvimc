local plugins = require("config.plugins")
local cfg = plugins.dap or {}
if cfg.enabled == false then return end

local mason_path = vim.fn.stdpath("data") .. "/mason/packages"

-----------------------------------------------------------
-- Persistent Breakpoints
-----------------------------------------------------------
-- Reloads a file's breakpoints on BufReadPost, so it is set up before any
-- file is read (one named on the command line is read before VimEnter).
-- Loads no dap code until a file is read.
require("persistent-breakpoints").setup({
	load_breakpoints_event = { "BufReadPost" },
})

-----------------------------------------------------------
-- DAP core, UI and virtual text: needed when a debug session starts, not
-- for the first frame, so set up once that is drawn (utils.startup).
-----------------------------------------------------------
require("utils.startup").after(function()
	local dap = require("dap")

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

	-- DAP UI
	local dapui = require("dapui")
	dapui.setup({
		floating = { border = require("utils.ui").border }, -- <leader>de eval float, the shared border
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

	-- DAP Virtual Text
	require("nvim-dap-virtual-text").setup({
		enabled = true,
		enabled_commands = true,
		highlight_changed_variables = true,
		highlight_new_as_changed = false,
		show_stop_reason = true,
		commented = false,
		virt_text_pos = "eol",
	})
end)

-----------------------------------------------------------
-- Keymaps. The modules are required at the keypress, so none of them
-- loads before the first frame.
-----------------------------------------------------------
local function dap_call(name, ...)
	local args = { ... }
	return function() require("dap")[name](unpack(args)) end
end
local function pb_toggle() require("persistent-breakpoints.api").toggle_breakpoint() end

-- Breakpoints
vim.keymap.set("n", "<leader>db", pb_toggle, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, { desc = "Conditional breakpoint" })
-- Execution
vim.keymap.set("n", "<leader>dc", "<cmd>DapContinue<cr>", { desc = "Continue / start" })
vim.keymap.set("n", "<leader>dC", dap_call("run_to_cursor"), { desc = "Run to cursor" })
vim.keymap.set("n", "<leader>dl", dap_call("run_last"), { desc = "Run last" })
vim.keymap.set("n", "<leader>dp", dap_call("pause"), { desc = "Pause" })
vim.keymap.set("n", "<leader>dt", dap_call("terminate"), { desc = "Terminate" })
-- Stepping
vim.keymap.set("n", "<leader>di", "<cmd>DapStepInto<cr>", { desc = "Step into" })
vim.keymap.set("n", "<leader>do", "<cmd>DapStepOver<cr>", { desc = "Step over" })
vim.keymap.set("n", "<leader>dO", dap_call("step_out"), { desc = "Step out" })
-- Navigation
vim.keymap.set("n", "<leader>dj", dap_call("down"), { desc = "Down stack" })
vim.keymap.set("n", "<leader>dk", dap_call("up"), { desc = "Up stack" })
-- Tools
vim.keymap.set("n", "<leader>dr", function() require("dap").repl.toggle() end, { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>ds", dap_call("session"), { desc = "Session" })
vim.keymap.set("n", "<leader>dL", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: ")) end, { desc = "Log point" })
vim.keymap.set("n", "<leader>dE", function()
	vim.ui.select({ "all", "uncaught", "none" }, { prompt = "Exception breakpoints:" }, function(choice)
		if choice then
			local filters = choice == "none" and {} or { choice }
			require("dap").set_exception_breakpoints(filters)
			vim.notify("Exception breakpoints: " .. choice, vim.log.levels.INFO, { title = "Debug" })
		end
	end)
end, { desc = "Exception breakpoints" })
vim.keymap.set("n", "<leader>da", function() require("dapui").elements.watches.add(vim.fn.expand("<cword>")) end, { desc = "Add watch" })
-- DAP UI
vim.keymap.set("n", "<leader>du", function() require("dapui").toggle({}) end, { desc = "Debug UI" })
vim.keymap.set({ "n", "v" }, "<leader>de", function() require("dapui").eval() end, { desc = "Eval" })
-- F-key bindings
vim.keymap.set("n", "<F5>", "<cmd>DapContinue<cr>", { desc = "Continue" })
vim.keymap.set("n", "<F8>", pb_toggle, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<F10>", "<cmd>DapStepOver<cr>", { desc = "Step over" })
vim.keymap.set("n", "<F11>", "<cmd>DapStepInto<cr>", { desc = "Step into" })
vim.keymap.set("n", "<S-F11>", dap_call("step_out"), { desc = "Step out" })

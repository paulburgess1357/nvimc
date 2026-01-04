-- DAP: Debug Adapter Protocol support for debugging.
-- Provides breakpoints, stepping, variable inspection, and more.
local plugins = require("config.plugins")
local cfg = plugins.dap or {}

return {
	-- Core DAP client
	{
		"mfussenegger/nvim-dap",
		enabled = cfg.enabled ~= false,
		dependencies = {
			"mason-org/mason.nvim",
		},
		event = "VeryLazy",
		keys = {
			-- Breakpoints
			{ "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle Breakpoint" },
			{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional Breakpoint" },
			-- Execution
			{ "<leader>dc", "<cmd>DapContinue<cr>", desc = "Continue / Start" },
			{ "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
			{ "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
			{ "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
			-- Stepping
			{ "<leader>di", "<cmd>DapStepInto<cr>", desc = "Step Into" },
			{ "<leader>do", "<cmd>DapStepOver<cr>", desc = "Step Over" },
			{ "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
			-- Navigation
			{ "<leader>dj", function() require("dap").down() end, desc = "Down Stack" },
			{ "<leader>dk", function() require("dap").up() end, desc = "Up Stack" },
			-- Tools
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
			{ "<leader>ds", function() require("dap").session() end, desc = "Session" },
			{ "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
			{ "<leader>dL", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: ")) end, desc = "Log Point" },
			{ "<leader>dE", function()
				vim.ui.select({ "all", "uncaught", "none" }, { prompt = "Exception breakpoints:" }, function(choice)
					if choice then
						local filters = choice == "none" and {} or { choice }
						require("dap").set_exception_breakpoints(filters)
						vim.notify("Exception breakpoints: " .. choice, vim.log.levels.INFO)
					end
				end)
			end, desc = "Exception Breakpoints" },
		},
		config = function()
			-- Set breakpoint signs
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
			vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "Visual", numhl = "" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticError", linehl = "", numhl = "" })

			local dap = require("dap")
			local mason_path = vim.fn.stdpath("data") .. "/mason/packages"

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

			-- Ruby (rdbg)
			dap.adapters.ruby = function(callback, config)
				callback({
					type = "server",
					host = "127.0.0.1",
					port = "${port}",
					executable = {
						command = "rdbg",
						args = { "-n", "--open", "--port", "${port}", "-c", "--", config.command or "ruby", config.script },
					},
				})
			end
			dap.configurations.ruby = {
				{
					name = "Launch file",
					type = "ruby",
					request = "launch",
					script = "${file}",
				},
			}
		end,
	},

	-- DAP UI: Visual debugging interface
	{
		"rcarriga/nvim-dap-ui",
		enabled = cfg.enabled ~= false,
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		keys = {
			{ "<leader>du", function() require("dapui").toggle({}) end, desc = "DAP UI" },
			{ "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = { "n", "v" } },
		},
		opts = {
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
		},
		config = function(_, opts)
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup(opts)

			-- Auto open/close UI
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({})
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close({})
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close({})
			end
		end,
	},

	-- DAP Virtual Text: Show variable values inline
	{
		"theHamsta/nvim-dap-virtual-text",
		enabled = cfg.enabled ~= false,
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			enabled = true,
			enabled_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = false,
			show_stop_reason = true,
			commented = false,
			virt_text_pos = "eol",
		},
	},
}

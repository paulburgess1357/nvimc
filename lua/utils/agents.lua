-- Agents running in Term slots (utils.terms) brought back by a session
-- restore (utils.session): settings.restore_agents in config/plugins.lua.
--
-- A session respawns fresh shells, so an agent that was running in a slot
-- is gone. With restore_agents on, the snapshot taken on quit notes which
-- agent each shell was running and which conversation it had open, and the
-- restore types the agent's resume command into the respawned shell, so the
-- slot comes back with the same conversation on screen. Off, a slot comes
-- back as a plain shell, as before.
--
-- Each conversation is found by its id, never by "the most recent one in
-- this directory", so several copies of the same agent in the same
-- directory each come back to their own conversation. Where the id comes
-- from differs per agent (M.agents):
--
--   claude  Takes an id at launch (--session-id). The Term shells start
--           with a bash rcfile Neovim writes (M.rcfile): it sources
--           ~/.bashrc, then defines a `claude` function that adds
--           --session-id <fresh uuid> when the command line carries no
--           session flag of its own. On quit the id is read back off the
--           process's command line. `claude -c` / `--resume` typed by hand
--           are passed through unchanged.
--   codex   Has no launch flag, but writes each session's transcript to
--           ~/.codex/sessions/<y>/<m>/<d>/rollout-<local start time>-<id>.jsonl
--           whose first line names the session's cwd. A running codex is
--           matched to the file written at its start time in its cwd, or
--           its id is read from `codex resume <id>` when launched that way.
--
-- Nothing outside Neovim changes: ~/.bashrc is untouched and shells not
-- spawned by the Term system never see the wrapper.

local M = {}

local UUID = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"

-- argv (a list) -> id, from the value after any of `flags`.
local function flag_value(argv, flags)
	for i, a in ipairs(argv) do
		for _, f in ipairs(flags) do
			if a == f and argv[i + 1] and argv[i + 1]:match("^" .. UUID .. "$") then return argv[i + 1] end
			local v = a:match("^" .. vim.pesc(f) .. "=(.+)$")
			if v and v:match("^" .. UUID .. "$") then return v end
		end
	end
end

-- Per agent:
--   wrapper(name)        bash function text added to the rcfile, or nil
--   id(argv, proc)       conversation id of a running process, or nil
--   resume(id)           shell command that reopens conversation `id`
-- No id (claude started by hand with -c, a codex whose rollout file was not
-- found): the slot comes back as a plain shell with a warning, never as a
-- guess at "the most recent conversation".
M.agents = {
	claude = {
		wrapper = function(name)
			return ([[
%s() {
	local a
	for a in "$@"; do
		case "$a" in --session-id|--session-id=*|--resume|--resume=*|-r|--continue|-c) command %s "$@"; return;; esac
	done
	command %s --session-id "$(cat /proc/sys/kernel/random/uuid)" "$@"
}]]):format(name, name, name)
		end,
		id = function(argv)
			return flag_value(argv, { "--session-id", "--resume", "-r" })
		end,
		resume = function(id)
			return "claude --resume " .. id
		end,
	},
	codex = {
		id = function(argv, proc)
			-- `codex resume <id>`: the id is on the command line.
			for i, a in ipairs(argv) do
				if a == "resume" and argv[i + 1] and argv[i + 1]:match("^" .. UUID .. "$") then return argv[i + 1] end
			end
			-- Otherwise the rollout file written at the process's start time,
			-- in its cwd. The name carries the local start time to the
			-- second; allow a few seconds either way.
			local start = proc.start_time
			if not start then return nil end
			local best, best_diff
			-- glob() expands the ~ itself; expand() would also expand the
			-- wildcards and hand back a newline-joined list.
			for _, file in ipairs(vim.fn.glob("~/.codex/sessions/*/*/*/rollout-*.jsonl", false, true)) do
				local y, mo, d, h, mi, s, id = vim.fn.fnamemodify(file, ":t"):match("^rollout%-(%d+)%-(%d+)%-(%d+)T(%d+)%-(%d+)%-(%d+)%-(" .. UUID .. ")%.jsonl$")
				if id then
					local t = os.time({ year = tonumber(y), month = tonumber(mo), day = tonumber(d), hour = tonumber(h), min = tonumber(mi), sec = tonumber(s) })
					local diff = math.abs(t - start)
					if diff <= 5 and (not best_diff or diff < best_diff) then
						local head = vim.fn.readfile(file, "", 1)[1] or ""
						local cwd = head:match('"cwd":"([^"]*)"')
						if not cwd or not proc.cwd or cwd == proc.cwd then best, best_diff = id, diff end
					end
				end
			end
			return best
		end,
		resume = function(id)
			return "codex resume " .. id
		end,
	},
}

local function enabled()
	return (require("config.plugins").settings or {}).restore_agents == true
end
M.enabled = enabled

-----------------------------------------------------------
-- The shell the Term slots run
-----------------------------------------------------------
local rcfile_path = vim.fn.stdpath("state") .. "/term-rc.bash"

-- Write the rcfile: ~/.bashrc, then every agent's wrapper. Returns its path.
function M.rcfile()
	local lines = {
		"# Written by Neovim (lua/utils/agents.lua) for the Term slots. Do not edit.",
		"[ -f ~/.bashrc ] && . ~/.bashrc",
	}
	local names = vim.tbl_keys(M.agents)
	table.sort(names)
	for _, name in ipairs(names) do
		local agent = M.agents[name]
		if agent.wrapper then
			lines[#lines + 1] = ""
			vim.list_extend(lines, vim.split(agent.wrapper(name), "\n"))
		end
	end
	vim.fn.mkdir(vim.fn.fnamemodify(rcfile_path, ":h"), "p")
	vim.fn.writefile(lines, rcfile_path)
	return rcfile_path
end

-- The command a Term shell is spawned with: 'shell' as always, through the
-- rcfile when restore_agents is on and the shell is bash (the wrappers are
-- bash functions; another shell gets no wrappers and so no claude ids).
function M.shell_cmd()
	local shell = vim.o.shell
	if enabled() and vim.fn.fnamemodify(shell, ":t") == "bash" then
		return { shell, "--rcfile", M.rcfile() }
	end
	return shell
end

-----------------------------------------------------------
-- Finding the agent a shell is running
-----------------------------------------------------------
local function read(path)
	local f = io.open(path, "r")
	if not f then return nil end
	local s = f:read("*a")
	f:close()
	return s
end

-- Descendant pids of `pid`, nearest first. An agent may sit under a
-- launcher (codex: node -> the codex binary), so the whole tree is walked.
local function descendants(pid)
	local out, queue = {}, { pid }
	while #queue > 0 do
		local p = table.remove(queue, 1)
		local kids = read(("/proc/%d/task/%d/children"):format(p, p)) or ""
		for k in kids:gmatch("%d+") do
			k = tonumber(k)
			out[#out + 1] = k
			queue[#queue + 1] = k
		end
	end
	return out
end

local function argv_of(pid)
	local raw = read("/proc/" .. pid .. "/cmdline")
	if not raw or raw == "" then return nil end
	return vim.split(raw, "\0", { trimempty = true })
end

-- The agent name a process is, judged by the command it was started as:
-- the basename of argv[1] or argv[2] without extension ("claude",
-- "codex.js" under node, the codex binary under that).
local function agent_of(argv)
	for i = 1, math.min(2, #argv) do
		local name = vim.fn.fnamemodify(argv[i], ":t:r")
		if M.agents[name] then return name end
	end
end

-- Epoch seconds the process started at, from /proc (field 22 of stat is
-- clock ticks after boot; btime in /proc/stat is the boot time).
local function start_time(pid)
	local stat = read("/proc/" .. pid .. "/stat")
	local btime = (read("/proc/stat") or ""):match("btime (%d+)")
	if not (stat and btime) then return nil end
	-- Fields after the parenthesised comm, which may contain spaces.
	local rest = stat:match("%) (.*)$")
	if not rest then return nil end
	local fields = vim.split(rest, " ", { trimempty = true })
	local ticks = tonumber(fields[20]) -- field 22 overall: 2 (pid, comm) precede `rest`
	if not ticks then return nil end
	local hz = 100
	local ok, out = pcall(vim.fn.system, { "getconf", "CLK_TCK" })
	if ok and tonumber(vim.trim(out)) then hz = tonumber(vim.trim(out)) end
	return tonumber(btime) + math.floor(ticks / hz)
end

-- What the shell with pid `shell_pid` is running: { name, id } for the
-- first agent found in its process tree (id nil when it could not be
-- learned), or nil for no agent.
function M.detect(shell_pid)
	for _, pid in ipairs(descendants(shell_pid)) do
		local argv = argv_of(pid)
		local name = argv and agent_of(argv)
		if name then
			local proc = {
				pid = pid,
				cwd = vim.uv.fs_readlink("/proc/" .. pid .. "/cwd"),
				start_time = start_time(pid),
			}
			local ok, id = pcall(M.agents[name].id, argv, proc)
			return { name = name, id = ok and id or nil }
		end
	end
end

-- The command that reopens a snapshot's agent, or nil (unknown agent, no id).
function M.resume_cmd(agent)
	local spec = type(agent) == "table" and M.agents[agent.name]
	if spec and type(agent.id) == "string" and agent.id:match("^" .. UUID .. "$") then
		return spec.resume(agent.id)
	end
end

return M

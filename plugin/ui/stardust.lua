local cfg = require("config.plugins").stardust or {}
if cfg.enabled == false then
	return
end

vim.opt.runtimepath:prepend(vim.fn.expand("~/Repos/Stardust"))
require("stardust").setup({
	fps = 60,
	stars = 24,
	shower_interval = 600, -- Seconds: random showers every 5–15 minutes; 0 disables automatic showers.

	enabled = {
		stars = true,
		meteors = true,
		moons = true,
		planets = true,
		comets = true,
		ships = true,
		ship_enemies = true,
	},

	-- Add or edit ships here. Each string is one row; spaces are transparent.
	-- stylua: ignore
	ships = {
		{ right = "╞═◉═╡", left = "╞═◉═╡" },
		{
			right = {
				"  ▄  ",
				"╰─○─╯",
			},
			left = {
				"  ▄  ",
				"╰─○─╯",
			},
		},
	},
})

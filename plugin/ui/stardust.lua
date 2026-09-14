local cfg = require("config.plugins").stardust or {}
if cfg.enabled == false then
	return
end

require("stardust").setup({
	fps = 60,
	floating_windows = false, -- Also animate popups, pickers, and hover docs.

	-- Every category is a level from 0 (off) to 10 (constant).
	-- Frequency: 1 is about hourly, each level doubles; 7 is about every minute, 10 every 7s.
	stars = 3, -- Density: about one star per 100 empty cells at 3, one per 30 at 10.
	meteors = 7,
	showers = 3,
	moons = 5,
	planets = 5, -- Spinning ring.
	orbits = 4, -- Planet with a circling moon.
	pulsars = 4,
	nebulas = 3,
	supernovas = 2,
	comets = 6,
	satellites = 1,
	ufos = 0,
	ships = 0,
	battles = 0, -- Share of ship flybys that become a chase: 3 is about 30%.

	-- Optional #RRGGBB foreground overrides; omit to keep the defaults.
	-- Stars take 1-8 colors; every other key is one color (meteors plus each kind above).
	-- colors = {
	-- 	stars = { "#f4f1de", "#ffe6a3" },
	-- 	meteors = "#e9c889",
	-- 	ships = "#c5d6ed",
	-- },

	-- Add or edit ships here. Each string is one row; spaces are transparent.
	-- stylua: ignore
	fleet = {
		-- Dart
		{ right = "╺══◈══►", left = "◄══◈══╸" },
		-- Comet Runner
		{ right = "·∘○╡═◉═╞▶", left = "◀╡═◉═╞○∘·" },
		-- Needle
		{ right = "─═◆═▶", left = "◀═◆═─" },
		-- Lancer
		{ right = "╾──◈──╼▶", left = "◀╾──◈──╼" },
		-- Scout
		{
			right = {
				"  ▄▖",
				"╾═◉▐▶",
			},
			left = {
				" ▗▄",
				"◀▌◉═╼",
			},
		},
		-- Wedge
		{ right = "◖◉▶", left = "◀◉◗" },
		-- Pin
		{ right = "·─◆▶", left = "◀◆─·" },
		-- Bolt
		{ right = "∘═◉═▶", left = "◀═◉═∘" },
		-- Sprite
		{
			right = {
				"▗▖",
				"▐◉▶",
			},
			left = {
				" ▗▖",
				"◀◉▌",
			},
		},
		-- Beetle
		{
			right = {
				" ▄▄",
				"╾◉◉▶",
			},
			left = {
				" ▄▄",
				"◀◉◉╼",
			},
		},
	},
})

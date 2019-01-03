script_name("debug1")
script_author("Mavl Pond")

require "lib.moonloader"
local TARDIS_API = import('DW/TARDIS/TARDIS_main')
local T_ext_fade_mode = require("DW/sys/labels").TARDIS_ext_fade_mode
local ext_fade = import('DW/TARDIS/misc/TARDIS_ext_fade.lua')

local enabled = false
local color_r = 236
local color_g = 240
local color_b = 241

function EXPORTS.enable()
	enabled = true
end

function EXPORTS.enable_normal()
	color_r = 236
	color_g = 240
	color_b = 241
	enabled = true
end

function EXPORTS.disable()
	enabled = false
end

function EXPORTS.set_red()
	color_r = 236
	color_g = 0
	color_b = 0
end

function EXPORTS.set_normal()
	color_r = 236
	color_g = 240
	color_b = 241
end

function EXPORTS.set_color(r, g, b)
	color_r = r
	color_g = g
	color_b = b
end

function main()
	local TARDIS = TARDIS_API.TARDIS_ext_handle()
	local X, Y, Z

	while true do

		while not enabled do
			wait(0)
		end

		-- Bright side
		start = os.clock() * 1000
		while true do
			if not enabled then break end
			wait(0)
			X, Y, Z = getOffsetFromCarInWorldCoords(TARDIS, 0.0, 0.0, 2.15)
			drawLightWithRange(X, Y, Z, color_r, color_g, color_b, 5.0)
			drawWeaponshopCorona(X, Y, Z, 0.65, 0, true, color_r, color_g, color_b)
			drawCorona(X, Y, Z+0.2, 0.01, 0, true, color_r, color_g, color_b) -- Lens flares
			time = os.clock() * 1000 - start

			if ext_fade.get_mode() ~= T_ext_fade_mode.IDLE then
				if not ext_fade.get_ext_top_light_flag() then break end
			else
				if time > 1500 then break end
			end
		end

		-- Dark side
		start = os.clock() * 1000
		while true do
			if not enabled then break end
			wait(0)
			time = os.clock() * 1000 - start
			if ext_fade.get_mode() ~= T_ext_fade_mode.IDLE then
				if ext_fade.get_ext_top_light_flag() then break end
			else
				if time > 1000 then break end
			end
		end
	end
end

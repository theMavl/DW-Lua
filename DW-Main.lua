script_name("DW/TARDIS/DW-Main")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("Launcher of Doctor Who: Daleks Invasion mod")

function main()
	fxt = script.load("DW/sys/fxt_emu.lua")
	dwg = script.load("DW/sys/globals.lua")
	wait(0)
	spawner = script.load("DW/TARDIS/TARDIS Spawner.lua")
	sonic = script.load("DW/props/SonicScrewdriver_v2.lua")
	shades = script.load("DW/props/SonicShades.lua")
	sonicHUD = script.load("DW/props/SonicHUD.lua")

	script.load("DW/debug/debug.lua")
end

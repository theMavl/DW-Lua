script_name("DW/TARDIS/DW-Main")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("Launcher of Doctor Who: Daleks Invasion mod")

function main()
	spawner = script.load("DW/TARDIS/TARDIS Spawner.lua")
	sonic = script.load("DW/misc/SonicScrewdriver_v2.lua")

	script.load("DW/debug/debug1.lua")
end

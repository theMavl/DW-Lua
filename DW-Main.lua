script_name("DW/TARDIS/DW-Main")
script_author("Mavl Pond")
script_version("1.0")
script_description("Launcher of Doctor Who: Daleks Invasion mod")

function main()
	if script.find("TARDIS Spawner") ~= nil then
    spawner = script.load("DW/TARDIS/TARDIS Spawner.lua")
	else
		printStringNow("Spawner not found!", 1000)
  end

end

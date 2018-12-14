script_name("TARDIS Summoner")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("Summoner for TARDIS")

require "lib.moonloader"

local TARDIS_API = import('DW/TARDIS/TARDIS_main')
local TARDIS_engine = import('DW/TARDIS/TARDIS_engine')

function main()
	while true do
		wait(0)
		if testCheat("TARS") then
			printHelp('CHEAT1')
			local X, Y, Z = getOffsetFromCharInWorldCoords(PLAYER_PED, 0.0, 2.5, offsetZ)
			TARDIS_engine.move_TARDIS_instantly(X, Y, Z, getActiveInterior(), nil, true)
		end
	end
end

function summonTARDIS()
	giveWeaponToChar(PLAYER_PED, 1, 1E38)
	key = createObject(models.BRASSKNUCKLE, 0.0, 0.0, 0.0)
	setObjectProofs(key, true, true, true, true, true)
	taskPickUpObject(PLAYER_PED, key, 0.0, 0.0, 0.0, 6, 16, nil, nil, -1)
	taskPlayAnim(PLAYER_PED, "KEY", "DW", 4.0, 0, 0, 0, 0, -1)

	tX, tY, tZ = getOffsetFromCharInWorldCoords(PLAYER_PED, 0.0, 9.8, 0.0)
	closeAllCarDoors(TARDIS)
	sfx_landing = load3load3dAudioStream("dws/LND1.MP3")
	setPlay3setPlay3dAudioStreamAtCoordinates(sfx_landing, tX, tY, tZ)
	setAudioStreamVolume(sfx_landing, 5.0)
	wait(200)
	setAudioStreamState(sfx_landing, as_action.PLAY)
	wait(5750)
	setObjectVisible(TARDIS_ext_objs[0], false)
	setObjectVisible(TARDIS_ext_objs[1], false)
	setObjectVisible(TARDIS_ext_objs[3], false)
	setCarCoordinates(TARDIS, tX, tY, tZ)
	setVehicleInterior(TARDIS, globals.Active_Interior)
	-- setCarVisible(TARDIS, false)
	-- TODO: Finish summoning sequence
end

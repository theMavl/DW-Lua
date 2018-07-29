script_name("TARDIS Spawner")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("The main script in TARDIS systems")

require "lib.moonloader"
local as_action = require('moonloader').audiostream_state
local mad = require 'MoonAdditions'

local models = require "lib.game.models"
local globals = require "lib.game.globals"

EXPORTS = {
  api_version = 1.0
}

local TARDIS
local TARDIS_ext
local is_ready

function EXPORTS.TARDIS()
	return TARDIS
end

function EXPORTS.TARDIS_ext()
	return TARDIS_ext
end

function EXPORTS.is_ready()
	return is_ready
end


function main()
	printStringNow("Hello!!", 1000)
	requestAnimation("DW")
	requestModel(models.SPARROW)
	requestModel(18631)
	requestModel(models.BRASSKNUCKLE)
	requestModel(18667)
	requestModel(18668)
	requestModel(18669)
	requestModel(18670)
	requestModel(18675)
	loadAllModelsNow()

	while true do
		wait(0)
		if (hasModelLoaded(models.SPARROW) and
		hasModelLoaded(18631) and
		hasModelLoaded(models.BRASSKNUCKLE) and
		hasModelLoaded(18667) and
		hasModelLoaded(18668) and
		hasModelLoaded(18669) and
		hasModelLoaded(18670) and
		hasModelLoaded(18675) and
		hasAnimationLoaded("DW")) then
			break
		end
	end

	TARDIS = createCar(models.SPARROW, 0.0, 0.0, 1.0)
	setCarHealth(TARDIS, 2000)
	freezeCarPositionAndDontLoadCollision(TARDIS, true)
	setCarCanBeVisiblyDamaged(TARDIS, false)

	TARDIS_ext = {}
	--[[
		0 - doorl
		1 - doorr
		2 - doors
		3 - main
		4 - interior texture
		5 - tfade
	]]
	for i = 0, 4 do
		TARDIS_ext[i] = createObject(18667 + i, 2.0, 0.0, 0.0)
		setObjectProofs(TARDIS_ext[i], 1, 1, 1, 1, 1)
		setObjectCollision(TARDIS_ext[i], false)
	end
	setObjectVisible(TARDIS_ext[2], false)

	TARDIS_ext[5] = createObject(18631, 3.0, 0.0, 2.0)
	setObjectVisible(TARDIS_ext[5], false)
	setObjectProofs(TARDIS_ext[5], 1, 1, 1, 1, 1)

	attachObjectToCar(TARDIS_ext[5], TARDIS, 0.0, 0.0, -0.030, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[0], TARDIS, 0.566, -0.698, 0.314, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[1], TARDIS, -0.566, -0.698, 0.314, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[2], TARDIS, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[3], TARDIS, 0.0, 0.0, 0.651, 0.0, 0.0, 90.0)
	attachObjectToCar(TARDIS_ext[4], TARDIS, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

	markModelAsNoLongerNeeded(models.SPARROW)
	markModelAsNoLongerNeeded(18631)
	markModelAsNoLongerNeeded(18667)
	markModelAsNoLongerNeeded(18668)
	markModelAsNoLongerNeeded(18669)
	markModelAsNoLongerNeeded(18670)
	markModelAsNoLongerNeeded(18675)

	is_ready = true
	while true do
		wait(0)
		if isKeyDown(57) then
			setCharCoordinates(PLAYER_PED, 1.0, 1.0, 1.0)
		end
	end
end

function summonTARDIS()
	giveWeaponToChar(PLAYER_HANDLE, 1, 1E38)
	key = createObject(models.BRASSKNUCKLE, 0.0, 0.0, 0.0)
	setObjectProofs(key, 1, 1, 1, 1, 1)
	taskPickUpObject(PLAYER_HANDLE, key, 0.0, 0.0, 0.0, 6, 16, nil, nil, -1)
	taskPlayAnim(PLAYER_HANDLE, "KEY", "DW", 4.0, 0, 0, 0, 0, -1)

	tX, tY, tZ = getOffsetFromCharInWorldCoords(PLAYER_PED, 0.0, 9.8, 0.0)
	closeAllCarDoors(TARDIS)
	sfx_landing = load3load3dAudioStream("dws/LND1.MP3")
	setPlay3setPlay3dAudioStreamAtCoordinates(sfx_landing, tX, tY, tZ)
	setAudioStreamVolume(sfx_landing, 5.0)
	wait(200)
	setAudioStreamState(sfx_landing, as_action.PLAY)
	wait(5750)
	setObjectVisible(TARDIS_ext[0], false)
	setObjectVisible(TARDIS_ext[1], false)
	setObjectVisible(TARDIS_ext[3], false)
	setCarCoordinates(TARDIS, tX, tY, tZ)
	setVehicleInterior(TARDIS, globals.Active_Interior)
	setCarVisible(TARDIS, false)
	-- TODO: Finish summoning sequence
end

function onScriptTerminate()
	if doesVehicleExist(TARDIS)
	then
		deleteCar(TARDIS)
	end

	if TARDIS_ext ~= nil then
		for i = 0, 5 do
			if doesObjectExist(TARDIS_ext[i]) then
				deleteObject(TARDIS_ext[i])
			end
		end
	end


end

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
	requestModel(models.TFADE)
	requestModel(models.BRASSKNUCKLE)
	requestModel(models.NVC_TDOORL)
	requestModel(models.NVC_TDOORR)
	requestModel(models.NVC_TDOORS)
	requestModel(models.NVC_TMAIN)
	requestModel(models.TWALLPAPER)
	loadAllModelsNow()

	while true do
		wait(0)
		if (hasModelLoaded(models.SPARROW) and
		hasModelLoaded(models.TFADE) and
		hasModelLoaded(models.BRASSKNUCKLE) and
		hasModelLoaded(models.NVC_TDOORL) and
		hasModelLoaded(models.NVC_TDOORR) and
		hasModelLoaded(models.NVC_TDOORS) and
		hasModelLoaded(models.NVC_TMAIN) and
		hasModelLoaded(models.TWALLPAPER) and
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
		TARDIS_ext[i] = createObject(models.NVC_TDOORL + i, 2.0, 0.0, 0.0)
		setObjectProofs(TARDIS_ext[i], true, true, true, true, true)
		setObjectCollision(TARDIS_ext[i], false)
	end
	setObjectVisible(TARDIS_ext[2], false)

	TARDIS_ext[5] = createObject(models.TFADE, 3.0, 0.0, 2.0)
	setObjectVisible(TARDIS_ext[5], false)
	setObjectProofs(TARDIS_ext[5], true, true, true, true, true)

	attachObjectToCar(TARDIS_ext[5], TARDIS, 0.0, 0.0, -0.030, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[0], TARDIS, 0.566, -0.698, 0.314, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[1], TARDIS, -0.566, -0.698, 0.314, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[2], TARDIS, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[3], TARDIS, 0.0, 0.0, 0.651, 0.0, 0.0, 90.0)
	attachObjectToCar(TARDIS_ext[4], TARDIS, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

	markModelAsNoLongerNeeded(models.SPARROW)
	markModelAsNoLongerNeeded(models.TFADE)
	markModelAsNoLongerNeeded(models.NVC_TDOORL)
	markModelAsNoLongerNeeded(models.NVC_TDOORR)
	markModelAsNoLongerNeeded(models.NVC_TDOORS)
	markModelAsNoLongerNeeded(models.NVC_TMAIN)
	markModelAsNoLongerNeeded(models.TWALLPAPER)

	is_ready = true
	while true do
		wait(0)

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
	setObjectVisible(TARDIS_ext[0], false)
	setObjectVisible(TARDIS_ext[1], false)
	setObjectVisible(TARDIS_ext[3], false)
	setCarCoordinates(TARDIS, tX, tY, tZ)
	setVehicleInterior(TARDIS, globals.Active_Interior)
	setCarVisible(TARDIS, false)
	-- TODO: Finish summoning sequence
end

function onScriptTerminate(script, quitGame)
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

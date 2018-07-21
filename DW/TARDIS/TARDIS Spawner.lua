script_name("TARDIS Spawner")
script_author("Mavl Pond")
script_version("1.0")
script_description("The main script in TARDIS systems")

require "lib.moonloader"
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

	TARDIS_ext[5] = createObject(18631, 2.0, 0.0, 0.0)
	setObjectVisible(TARDIS_ext[5], false)
	setObjectProofs(TARDIS_ext[5], 1, 1, 1, 1, 1)

	attachObjectToCar(TARDIS_ext[5], TARDIS, 0.0, 0.0, -0.030, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[0], TARDIS, 0.566, -0.698, 0.314, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[1], TARDIS, -0.566, -0.698, 0.314, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[2], TARDIS, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext[3], TARDIS, 0.0, 0.0, 0.651, 0.0, 0.0, 90.0)
	attachObjectToCar(TARDIS_ext[4], TARDIS, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

	markModelAsNoLongerNeeded(models.SPARROW)

	while true do
		wait(0)
		if isKeyDown(57) then
			printStringNow("Hello!!", 1000)
			setCharCoordinates(PLAYER_PED, 1.0, 1.0, 1.0)
		end
	end
end

function onScriptTerminate()

end

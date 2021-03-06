script_name("TARDIS Main")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("The main script in TARDIS systems")
--[[
	This is the script that creates all the exteior objects as well as the SPARROW
	itself, and stores all TARDIS's variables and flags. Script also provides with
	some of the exterior controlling procedures (closing doors for instance).

	On exiting the script, it cleans up all the created entities.

	Preferred usage in scripts:
	local TARDIS_API = import('DW/TARDIS/TARDIS_main')
]]

require "lib.moonloader"
local as_action = require('moonloader').audiostream_state
local mad = require 'MoonAdditions'

local models = require "lib.game.models"
local globals = require "lib.game.globals"
local labels = require("DW/sys/labels")

local new_game = false

local T_doors_action = labels.TARDIS_doors_action
local T_mode = labels.TARDIS_mode
local T_flight_mode = labels.TARDIS_flight_mode
local T_flight_status = labels.TARDIS_flight_status
local T_player_status = labels.TARDIS_player_status

EXPORTS = {
  api_version = 1.0
}

local TARDIS
local TARDIS_ext_objs
local is_ready
local doors_action = T_doors_action.IDLE
local cloaked = false
local mode = T_mode.NORMAL
local flight_mode = T_flight_mode.IDLE
local flight_status = T_flight_status.IDLE
local player_status = T_player_status.OUTSIDE
local energy = 100
local health = 2000
local summon_blocked = false

local ext_pos = {
  X = 0.0,
  Y = 0.0,
  Z = 0.0,
	interior = 0,
	angle = 0.0,
	time = os.time{year=1991, month = 1, day = 1, hour = 0, minute = 0, sec = 1}
}

local last_ext_pos = {
  X = 0.0,
  Y = 0.0,
  Z = 0.0,
	interior = 0,
	angle = 0.0,
	time = os.time{year=1991, month = 1, day = 1, hour = 0, minute = 0, sec = 1}
}

local dest_pos = {
  X = 0.0,
  Y = 0.0,
  Z = 0.0,
	interior = 0,
	angle = 0.0,
	time = os.time{year=1991, month = 1, day = 1, hour = 0, minute = 0, sec = 1}
}


-- Handles block
function EXPORTS.TARDIS_ext_handle()
	return TARDIS
end

function EXPORTS.TARDIS_ext_objs()
	return TARDIS_ext_objs
end

-- Properties block

function EXPORTS.get_ext_pos()
	return ext_pos
end

function EXPORTS.get_destination()
	return dest_pos
end

function EXPORTS.is_ready()
	return is_ready
end

function EXPORTS.get_doors_action()
	return doors_action
end

function EXPORTS.is_IDLE()
	return flight_mode == T_flight_mode.IDLE and mode == T_mode.NORMAL
end

function EXPORTS.is_summon_blocked()
	return summon_blocked
end

function EXPORTS.set_summon_blocked(status)
	summon_blocked = status
end

function EXPORTS.is_cloaked()
	return cloaked
end

function EXPORTS.get_mode()
	return mode
end

function EXPORTS.set_mode(new_mode)
	mode = new_mode
end

function EXPORTS.get_flight_status()
	return flight_status
end

function EXPORTS.set_flight_status(new_status)
	flight_status = new_status
end

function EXPORTS.get_flight_mode()
	return flight_mode
end

function EXPORTS.set_flight_mode(new_mode)
	flight_mode = new_mode
end

function EXPORTS.get_player_status()
	return player_status
end

function EXPORTS.set_player_status(new_status)
	player_status = new_status
end

function EXPORTS.get_energy()
	return energy
end

function EXPORTS.set_energy(energy_level)
	energy = energy_level
end

function EXPORTS.set_destination(X, Y, Z, interior, angle, time)
	dest_pos.X = X
	dest_pos.Y = Y
	dest_pos.Z = Z
	dest_pos.interior = interior
	if angle ~= nil then dest_pos.angle = angle end
	if time ~= nil then dest_pos.time = time end
end

function EXPORTS.set_ext_pos(X, Y, Z, interior, angle, time)
	ext_pos.X = X
	ext_pos.Y = Y
	ext_pos.Z = Z
	ext_pos.interior = interior
	if angle ~= nil then ext_pos.angle = angle end
	if time ~= nil then ext_pos.time = time end
end

-- Procedures block
function EXPORTS.check_close_ext_doors()
	-- return true if doors are closed, false otherwise and close them.
	if check_doors_closed() then
		return true
	else
		if doors_action ~= T_doors_action.CLOSING then
			lua_thread.create(ext_doors_controller, 0, nil)
			return false
		end
	end
end

function EXPORTS.are_doors_closed()
	return check_doors_closed()
end

function EXPORTS.set_tfade_visible()
	-- Special cases
	setCarVisible(TARDIS, false)
	setObjectVisible(TARDIS_ext_objs[5], true)
end

function EXPORTS.set_sparrow_visible()
	-- Special cases
	setCarVisible(TARDIS, true)
	setObjectVisible(TARDIS_ext_objs[5], false)
end

function EXPORTS.set_TARDIS_invisible()
	setCarVisible(TARDIS, false)
	setObjectVisible(TARDIS_ext_objs[0], false)
	setObjectVisible(TARDIS_ext_objs[1], false)
	setObjectVisible(TARDIS_ext_objs[2], false)
	setObjectVisible(TARDIS_ext_objs[3], false)
	setObjectVisible(TARDIS_ext_objs[5], false)
end

function EXPORTS.close_ext_doors(time_limit)
	if doors_action == T_doors_action.IDLE then
		lua_thread.create(ext_doors_controller, 0, time_limit)
	end
end

function EXPORTS.open_ext_doors(time_limit)
	if doors_action == T_doors_action.IDLE then
		lua_thread.create(ext_doors_controller, 1, time_limit)
	end
end

function main()
	printStringNow("Oh brilliant!!", 500)
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

	TARDIS_ext_objs = {}
	--[[
		0 - doorl
		1 - doorr
		2 - doors
		3 - main
		4 - interior texture
		5 - tfade
	]]
	for i = 0, 3 do
		TARDIS_ext_objs[i] = createObject(models.NVC_TDOORL + i, 2.0, 0.0, 0.0)
		setObjectProofs(TARDIS_ext_objs[i], true, true, true, true, true)
		-- setObjectCollision(TARDIS_ext_objs[i], false)
	end
	setObjectVisible(TARDIS_ext_objs[2], false)
	setObjectCollision(TARDIS_ext_objs[2], false)
	setObjectCollision(TARDIS_ext_objs[3], false)

	TARDIS_ext_objs[4] = createObject(models.TWALLPAPER, 3.0, 0.0, 2.0)
	-- setObjectVisible(TARDIS_ext_objs[4], false)
	setObjectProofs(TARDIS_ext_objs[4], true, true, true, true, true)
	setObjectCollision(TARDIS_ext_objs[4], false)

	TARDIS_ext_objs[5] = createObject(models.TFADE, 3.0, 0.0, 2.0)
	setObjectVisible(TARDIS_ext_objs[5], false)
	setObjectProofs(TARDIS_ext_objs[5], true, true, true, true, true)
	setObjectCollision(TARDIS_ext_objs[5], false)


	attachObjectToCar(TARDIS_ext_objs[0], TARDIS, 0.566, -0.698, 0.314, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext_objs[1], TARDIS, -0.566, -0.698, 0.314, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext_objs[2], TARDIS, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
	attachObjectToCar(TARDIS_ext_objs[3], TARDIS, 0.0, 0.0, 0.651, 0.0, 0.0, 90.0)
	attachObjectToCar(TARDIS_ext_objs[4], TARDIS, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

	markModelAsNoLongerNeeded(models.SPARROW)
	markModelAsNoLongerNeeded(models.TFADE)
	markModelAsNoLongerNeeded(models.NVC_TDOORL)
	markModelAsNoLongerNeeded(models.NVC_TDOORR)
	markModelAsNoLongerNeeded(models.NVC_TDOORS)
	markModelAsNoLongerNeeded(models.NVC_TMAIN)
	markModelAsNoLongerNeeded(models.TWALLPAPER)

	if new_game then
		repeat
			wait(0)
			if isPlayerPlaying(PLAYER_HANDLE) and isPlayerControllable(PLAYER_HANDLE) and locateCharAnyMeans3d(PLAYER_PED,  2239.3425, -1261.9398, 23.9375, 1.0, 1.0, 1.0, false) then
				while getFadingStatus() do
					wait(0)
				end
				wait(5000)
				break
			end
		until false
	end

	loadTextureDictionary('DWLOAD')
	local load_screen_sprite = loadSprite('loadsc1')
	displayHud(false)
	displayRadar(false)
	--setSpritesDrawBeforeFade(true)
	setObjectVisible(TARDIS_ext_objs[5], true)
	--useRenderCommands(false)
	--drawSprite(load_screen_sprite, 320.0, 220.0, 640.0, 480.0, 255, 255, 255, 255)
	setPlayerControl(PLAYER_HANDLE, false)
	freezeCharPosition(PLAYER_PED, true)
	local X, Y, Z = getOffsetFromCharInWorldCoords(PLAYER_PED, 0.0, 0.0, 0.0)
	setObjectCoordinates(TARDIS_ext_objs[5], X, Y, Z)

	wait(1500)
	while getFadingStatus() do
		wait(0)
	end
	local start = os.clock()*1000
	repeat
		wait(0)
		--drawSprite(load_screen_sprite, 320.0, 220.0, 640.0, 480.0, 255, 255, 255, 255)
		printStringNow("Loading...", 1)
		local time = os.clock()*1000 - start
	until time > 1000

	attachObjectToCar(TARDIS_ext_objs[5], TARDIS, 0.0, 0.0, -0.030, 0.0, 0.0, 0.0)
	setObjectVisible(TARDIS_ext_objs[5], false)
	setPlayerControl(PLAYER_HANDLE, true)
	freezeCharPosition(PLAYER_PED, false)
	useRenderCommands(false)
	removeTextureDictionary()
	displayRadar(true)
	displayHud(true)

	is_ready = true

	-- Load TARDIS systems
	script.load("DW/TARDIS/TARDIS_energy.lua")
	script.load("DW/TARDIS/TARDIS_defences.lua")
	script.load("DW/TARDIS/TARDIS_engine.lua")
	script.load("DW/TARDIS/TARDIS_interior_ambience.lua")

	-- Load misc scripts
	script.load("DW/TARDIS/misc/finger_snap.lua")
	script.load("DW/TARDIS/misc/back_int_texture.lua")
	script.load("DW/TARDIS/misc/TARDIS_summoner.lua")

	wait(-1)
	while true do
		wait(0)
	end
end

function ext_doors_controller(action, time_limit)
	-- Action: open(1), close(0)
	local time_limit_defined = not (time_limit == nil)
	local doors_sfx
	if action == T_doors_action.OPENING then
		doors_sfx = load3dAudioStream("DWS/DO.mp3")
		doors_action = 1
		openCarDoorABit(TARDIS, 2, 0.01)
		openCarDoorABit(TARDIS, 3, 0.01)
		angle = 0.01
		angle_time_rel = function (time) return -(0.0008*time + 0.01) end
		if not time_limit_defined then
			time_limit = 1223
		end
	else
		doors_sfx = load3dAudioStream("DWS/DC.mp3")
		doors_action = -1
		angle_time_rel = function (time) return 0.00126*time - 0.99 end
		if not time_limit_defined then
			time_limit = 784
		end
	end

	if not time_limit_defined then
		setPlay3dAudioStreamAtCar(doors_sfx, TARDIS)
		setAudioStreamState(doors_sfx, as_action.PLAY)
	end
	start = os.clock()*1000
	repeat
		wait(0)
		time = os.clock()*1000 - start
		angle = angle_time_rel(time)
		openCarDoorABit(TARDIS, 2, angle)
		openCarDoorABit(TARDIS, 3, angle)

		-- Sync tdoor objects with doors
		local angle_left = math.abs(getDoorAngleRatio(TARDIS, 3))
		local angle_right = math.abs(getDoorAngleRatio(TARDIS, 2))
		angle_left = angle_left * 72.0 / 1.26
		angle_right = angle_right * 72.0 / 1.26
		attachObjectToCar(TARDIS_ext_objs[0], TARDIS, 0.566, -0.698, 0.314, 0.0, 0.0, -angle_left)
		attachObjectToCar(TARDIS_ext_objs[1], TARDIS, -0.566, -0.698, 0.314, 0.0, 0.0, angle_right)

	until time >= time_limit
	if action == 0 then
		closeAllCarDoors(TARDIS)
		attachObjectToCar(TARDIS_ext_objs[0], TARDIS, 0.566, -0.698, 0.314, 0.0, 0.0, 0.0)
		attachObjectToCar(TARDIS_ext_objs[1], TARDIS, -0.566, -0.698, 0.314, 0.0, 0.0, 0.0)
		wait(400) -- Let SFX play fully
	end
	if not time_limit_defined then
		releaseAudioStream(doors_sfx)
	end
	doors_action = 0
end

function check_doors_closed()
	local angle_left = math.abs(getDoorAngleRatio(TARDIS, 3))
	local angle_right = math.abs(getDoorAngleRatio(TARDIS, 2))
	if angle_left == 0.0 and angle_right == 0.0 then
		return true
	else
		return false
	end
end

function onScriptTerminate(s, quitGame)
	if s == script.this then
		if doesVehicleExist(TARDIS)
		then
			deleteCar(TARDIS)
		end

		if TARDIS_ext_objs ~= nil then
			for i = 0, 5 do
				if doesObjectExist(TARDIS_ext_objs[i]) then
					deleteObject(TARDIS_ext_objs[i])
				end
			end
		end
	end
end

function onStartNewGame(missionPackNumber)
	new_game = true
end

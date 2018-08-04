script_name("SonicShades")
script_authors("Mavl Pond", "Tommy LU")
script_version("2.0")
script_version_number(2)
script_description("Sonic Shades script For Doctor Who: Dalek invasion mod")

require "lib.moonloader"
local as_action = require('moonloader').audiostream_state
local mad = require 'MoonAdditions'
local models = require "lib.game.models"
local globals = require "lib.game.globals"
local dwg = import('DW/sys/globals.lua')
local weapons = require "lib.game.weapons"
local keys = require "lib.game.keys"
local vkeys = require "lib.vkeys"

local obj_shades
local status = 0 -- 0 = disabled, 1 - enabled, 2 - performing action

function EXPORTS.putOn()
	on()
end

function EXPORTS.takeOff()
	off()
end

function EXPORTS.isShadesOn()
	if status == 1 then return true else return false end
end

function EXPORTS.status()
	return status
end

function main()
	requestAnimation("DW")
	requestModel(models.WEARABLETECH)
	loadAllModelsNow()
	while true do
		wait(0)
		if doesCharExist(PLAYER_PED) and isPlayerControllable(PLAYER_HANDLE) and dwg.get("IS_TIMELORD") then
			if isKeyDown(vkeys.VK_5) and isCurrentCharWeapon(PLAYER_PED, weapons.FIST) and not isCharPlayingAnim(PLAYER_PED, "Wearable_Tech") and getGameGlobal(globals.ONMISSION) == 0 then
				if doesObjectExist(obj_shades) then
					off()
				else
					on()
				end
			end
		end
	end
end

function off()
	print(string.format("Attempt to off. Current status: %d", status))
	if status == 1 and doesObjectExist(obj_shades) then
		status = 2 -- Secure shades
		local sfx_off = loadAudioStream("DWS/sgl_off.mp3")
		setAudioStreamState(sfx_off, as_action.PLAY)
		taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, false, false, false, false, -1)
		wait(800)
		deleteObject(obj_shades)
		setPlayerWeaponsScrollable(PLAYER_HANDLE, true)
		releaseAudioStream(sfx_off)
		status = 0
	elseif status == 1 and not doesObjectExist(obj_shades) then
		status = 0
	end
end

function on()
	print(string.format("Attempt to on. Current status: %d", status))
	if status == 0 and not doesObjectExist(obj_shades) then
		status = 2 -- Secure shades
		obj_shades = createObject(models.WEARABLETECH, 0.0, 0.0, -100.0)
		setObjectCollision(obj_shades, false)
		taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, false, false, false, false, -1)
		wait(250)
		taskPickUpObject(PLAYER_PED, obj_shades, 0.0, 0.0, 0.0, 2, 16, "NULL", "NULL", -1)
		setCurrentCharWeapon(PLAYER_PED, weapons.FIST)
		setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
		status = 1
	elseif status == 0 and doesObjectExist(obj_shades) then
		status = 1
	end
end

function onScriptTerminate(script, quitGame)
	if doesObjectExist(obj_shades) then
		deleteObject(obj_shades)
	end
end

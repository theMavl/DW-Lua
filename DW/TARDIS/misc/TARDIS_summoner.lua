script_name("TARDIS Summoner")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("Summoner for TARDIS")

require "lib.moonloader"

local TARDIS_API = import('DW/TARDIS/TARDIS_main')
local TARDIS_engine = import('DW/TARDIS/TARDIS_engine')
local vkeys = require "lib.vkeys"
local keys = require "lib.game.keys"
local labels = require("DW/sys/labels")
local models = require "lib.game.models"
local T_mode = labels.TARDIS_mode
local T_flight_mode = labels.TARDIS_flight_mode
local shades = import('DW/props/SonicShades')
local mad = require 'MoonAdditions'

function main()
	requestModel(models.BRASSKNUCKLE)
	loadAllModelsNow()

	while true do
		wait(0)
		if testCheat("TARS") then
			printHelp('CHEAT1')
			local X, Y, Z = getOffsetFromCharInWorldCoords(PLAYER_PED, 0.0, 2.5, offsetZ)
			TARDIS_engine.move_TARDIS_instantly(X, Y, Z, getActiveInterior(), nil, true)
		end
		-- TODO: Check if going in/out sequence performing
		if isButtonPressed(PLAYER_HANDLE, keys.player.LOCKTARGET) and not isCharInAnyCar(PLAYER_PED) and isCurrentCharWeapon(PLAYER_PED, 0) and TARDIS_API.is_IDLE() and not TARDIS_API.is_summon_blocked() then
			summonTARDIS()
		end
	end
end

function summonTARDIS()
	local key = nil
	if shades.isShadesOn() then -- Handle both cases here
		if locateCharAnyMeansCar3d(PLAYER_PED, TARDIS_API.TARDIS_ext_handle(), 90.0, 90.0, 90.0, false) then
			shades.activate(false)
		else
			shades.activate(true)
		end
	else
		giveWeaponToChar(PLAYER_PED, 1, 1E38)
		key = createObject(models.BRASSKNUCKLE, 0.0, 0.0, 0.0)
		setObjectProofs(key, true, true, true, true, true)
		taskPickUpObject(PLAYER_PED, key, 0.0, 0.0, 0.0, 6, 16, "NULL", "NULL", -1)
		taskPlayAnim(PLAYER_PED, "KEY", "DW", 4.0, false, false, false, false, -1)
		repeat
			wait(0)
			taskPlayAnim(PLAYER_PED, "KEY", "DW", 4.0, false, false, false, false, -1)
		until isCharPlayingAnim(PLAYER_PED, "KEY")
		wait(1000)
	end
	if locateCharAnyMeansCar3d(PLAYER_PED, TARDIS_API.TARDIS_ext_handle(), 9.0, 9.0, 9.0, false) then
		local marker = addBlipForCar(TARDIS_API.TARDIS_ext_handle())
		changeBlipColour(marker, 2)
		--wait(700)
		if shades.isShadesOn() then
			wait(2000)
			removeBlip(marker)
			wait(1000)
			return
		else
			--wait(150)
			lua_thread.create(keylight, 700)
			while isCharPlayingAnim(PLAYER_PED, "KEY") do
				wait(0)
			end
			giveWeaponToChar(PLAYER_PED, 0, 1E38)
			setCurrentCharWeapon(PLAYER_PED, 0)
			removeWeaponFromChar(PLAYER_PED, 1)
			deleteObject(key)
			wait(3450)
			removeBlip(marker)
			return
		end
	else
		lua_thread.create(keylight, 9490)
		TARDIS_engine.summon()
		wait(350)
		setCharAnimPlayingFlag(PLAYER_PED, "KEY", false)
		wait(9500)
		setCharAnimPlayingFlag(PLAYER_PED, "KEY", true)
		wait(1000)
	end
	if doesObjectExist(key) then
		print("Key exists, destroy")
		giveWeaponToChar(PLAYER_PED, 0, 1E38)
		setCurrentCharWeapon(PLAYER_PED, 0)
		removeWeaponFromChar(PLAYER_PED, 1)
		deleteObject(key)
	end
	if marker ~= nil and doesBlipExist(marker) then
		removeBlip(marker)
	end
end

function onScriptTerminate(s, quitGame)
	if s == script.this then
		giveWeaponToChar(PLAYER_PED, 0, 1E38)
		setCurrentCharWeapon(PLAYER_PED, 0)
		removeWeaponFromChar(PLAYER_PED, 1)
	end
end

function keylight(time_limit)
	-- 800 or 9490
	local start = os.clock() * 1000
	local time
	local X, Y, Z
	repeat
		wait(0)
		time = os.clock() * 1000 - start
		X, Y, Z = getOffsetFromCharInWorldCoords(PLAYER_PED, 0.165, 0.56, 0.78)
		drawLightWithRange(X, Y, Z, 242, 196, 15, 0.1)
		drawWeaponshopCorona(X, Y, Z, 0.1, 3, false, 242, 196, 15)
		if not isCharPlayingAnim(PLAYER_PED, "KEY") then
			return
		end
	until time >= time_limit
end

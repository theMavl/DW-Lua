script_name("SonicHUD")
script_authors("Mavl Pond", "Tommy LU")
script_version("2.0")
script_version_number(2)
script_description("Sonic Screwdriver script For Doctor Who: Dalek invasion mod")

require "lib.moonloader"
local as_action = require('moonloader').audiostream_state
local mad = require 'MoonAdditions'
local models = require "lib.game.models"
local globals = require "lib.game.globals"
local dwg = import('DW/sys/globals.lua')
local shades = import('DW/props/SonicShades.lua')
local weapons = require "lib.game.weapons"
local keys = require "lib.game.keys"
local vkeys = require "lib.vkeys"
local inicfg = require 'inicfg'

local mode = 0 -- 0 = off, 1 = vehicle seeeker, 2 = crosshair

function EXPORTS.setMode(new_mode)
	mode = new_mode
end

function main()
	loadTextureDictionary("CROSS")
	cross = loadSprite("CEL1")
	sprite_target = loadSprite("sonic_target")
	while true do
		wait(0)
		if mode == 1 then
			if (shades.isShadesOn() or isCurrentCharWeapon(PLAYER_PED, weapons.GOLFCLUB) or isCurrentCharWeapon(PLAYER_PED, weapons.POOLCUE)) and not isCharInAnyCar(PLAYER_PED) then
				if isButtonPressed(PLAYER_HANDLE, keys.player.LOCKTARGET) then
          long_wave_mode = true
        else
          long_wave_mode = false
        end
				target = get_target()
				if target ~= nil and doesVehicleExist(target) then
					local x, y, z = getCarCoordinates(target)
					setSpritesDrawBeforeFade(true)
					useRenderCommands(true)
					local result, wposX, wposY = convert3Dto2D(x, y, z)
					if result then
						drawSprite(sprite_target, wposX, wposY, 25.0, 25.0, 255, 255, 255, 255)
						--printStringNow(string.format("%s %f %f", result, wposX, wposY), 100)
					end
				end
			end
		elseif mode == 2 then
			setSpritesDrawBeforeFade(true)
			useRenderCommands(true)
			while mode == 2 do
				wait(0)
				drawSprite(cross, 339.1, 179.1, 25.0, 25.0, 255, 255, 255, 255)
			end
		end
	end
end

function convert3Dto2D(x, y, z)
	local result, wposX, wposY, wposZ, w, h = convert3DCoordsToScreenEx(x, y, z, true, true)
	local fullX = readMemory(0xC17044, 4, false)
	local fullY = readMemory(0xC17048, 4, false)
	wposX = wposX * (640.0 / fullX)
	wposY = wposY * (448.0 / fullY)
	return result, wposX, wposY
end

function get_target()
  local x, y, z = getCharCoordinates(PLAYER_PED)
  local settings = inicfg.load(nil, "DW_CUSTOM_SETTINGS")
  local len = settings.SONIC.LEN
  local found, target = findAllRandomVehiclesInSphere(x, y, z, len, false, true)
  if not found then
    return nil
  end
  if not long_wave_mode
  then
    target, null = storeClosestEntities(PLAYER_PED)
  end
  if isCarDead(target) or isCarModel(target, models.SPARROW) or isCarModel(target, models.RCCAM) or isCarModel(target, models.RHINO)
  then
    return nil
  end
  return target
end

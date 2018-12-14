script_name("Finger snap")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("Flick the fingers to open the TARDIS doors")

require "lib.moonloader"
local TARDIS_API = import('DW/TARDIS/TARDIS_main.lua')
local vkeys = require "lib.vkeys"
local globals = require "lib.game.globals"
local weapons = require "lib.game.weapons"
local shades = import('DW/props/SonicShades.lua')
local as_action = require('moonloader').audiostream_state

function main()
  TARDIS = TARDIS_API.TARDIS_ext_handle()
  while true do
    wait(0)
    if isKeyDown(vkeys.VK_G) and locateCharAnyMeansCar3d(PLAYER_PED, TARDIS, 20.0, 20.0, 20.0, false) and not isCharInCar(PLAYER_PED, TARDIS) then
			requestAnimation("DW")
			local click_sfx = loadAudioStream("DWS/FS.MP3")
			took_weapon = false

			if getGameGlobal(globals.ONMISSION) == 0 and isCharOnAnyBike(PLAYER_PED) then
				-- Remove weapons that CJ can hold on a bike
				if hasCharGotWeapon(PLAYER_PED, weapons.UZI) or hasCharGotWeapon(PLAYER_PED, weapons.MP5) or hasCharGotWeapon(PLAYER_PED, weapons.TEC9) then
					took_weapon = true
					weapon, ammo, modelId = getCharWeaponInSlot(PLAYER_PED, 5)
					removeWeaponFromChar(PLAYER_PED, weapon)
					requestModel(modelId)
					loadAllModelsNow()
				end
			end

			setCurrentCharWeapon(PLAYER_PED, weapons.FIST)
			if isCharInAnyCar(PLAYER_PED) then
				taskPlayAnim(PLAYER_PED, "bike_CLICK", "DW", 4.0, false, false, false, false, -1)
				wait(800)
			else
				if shades.isShadesOn() then
					taskPlayAnim(PLAYER_PED, "CLICK", "DW", 4.0, false, false, false, false, -1)
				else
					taskPlayAnimSecondary(PLAYER_PED, "CLICK", "DW", 4.0, false, false, false, false, -1)
				end
				wait(1250)
			end

			-- TODO: Goind in/out sequence check (if true -> exit sequence)
			if false then
				removeAnimation("DW")
				releaseAudioStream(click_sfx)
				-- goto beginning
			end

			setAudioStreamState(click_sfx, as_action.PLAY)
			wait(250)

      local angle_left = math.abs(getDoorAngleRatio(TARDIS, 3))
      local angle_right = math.abs(getDoorAngleRatio(TARDIS, 2))

			if angle_left == 0.0 or angle_right == 0.0 then
				TARDIS_API.open_ext_doors()
			else
				TARDIS_API.close_ext_doors()
			end
			wait(1200)
			removeAnimation("DW")
			releaseAudioStream(click_sfx)
			setPlayerWeaponsScrollable(PLAYER_HANDLE, true)

			if took_weapon then
				giveWeaponToChar(PLAYER_PED, weapon, ammo)
				setCurrentCharWeapon(PLAYER_PED, weapons.FIST)
				markModelAsNoLongerNeeded(modelId)
			end

    end
  end
end

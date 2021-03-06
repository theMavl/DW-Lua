script_name("SonicScrewdriver")
script_authors("Mavl Pond", "Tommy LU")
script_version("2.0")
script_version_number(2)
script_description("Sonic Screwdriver script For Doctor Who: Dalek invasion mod")

require "lib.moonloader"
local as_action = require('moonloader').audiostream_state
--local mad = require 'MoonAdditions'
local models = require "lib.game.models"
local globals = require "lib.game.globals"
local dwg = import('DW/sys/globals.lua')
local shades = import('DW/props/SonicShades.lua')
local sonicHUD = import('DW/props/SonicHUD.lua')
local weapons = require "lib.game.weapons"
local keys = require "lib.game.keys"
local vkeys = require "lib.vkeys"
local inicfg = require 'inicfg'
local HUD_mode = require("DW/sys/labels").Sonic_HUD_mode
local S_device = require("DW/sys/labels").Sonic_device

used_models = {
  models.SHOVEL,
  models.POOLCUE,
  models.GUN_VIBE1,
  models.GUN_VIBE2,
  models.GUN_DILDO2,
  models.SONICCL,
  models.SONICOL,
	models.GOLFCLUB,
	models.FLOWERA,
	models.GUN_DILDO2
}
local is_shades_on
local long_wave_mode = false
non_explicable_vehicles = {
  nil,
  models.SPARROW,
  models.RHINO,
  models.RCCAM,
  models.BMX,
  models.BIKE,
  models.RCGOBLIN
}

no_engine_vehicles = {
  nil, models.BMX, models.BIKE, models.MTBIKE, models.FCR900, models.BF400, models.FAGGIO, models.FREEWAY, models.NRG500, models.PCJ600, models.PIZZABOY, models.SANCHEZ, models.WAYFARER, models.COPBIKE, models.SPARROW, models.RCCAM
}

cant_accelerate_vehicles = {
  nil, models.SPARROW, models.RHINO, models.RCCAM, models.BMX, models.BIKE, models.MTBIKE
}

-- Sonic Device onfoot apps on target vehicle
local APP_EXP = 1
local APP_DEFL = 2
local APP_ONFOOT_ACC = 3
local APP_ONFOOT_LOCK = 4
local APP_ENG = 5
-- Sonic Device special onfoot app (id > 8)
local APP_DISARM = 9
local APP_SCAN_PHOTON = 10
local APP_SCAN_THERMAL = 11
-- Sonic Device incar apps (id > 16)
local APP_INCAR_ACC = 17
local APP_INCAR_LOCK = 18

local sonic_device
local device_in_hand

local sonic_spin_mode = 0 -- 0 = off, 1 = onfoot, 2 = driveby

function onScriptLoad(script)
  requestAnimation("DW")
  for i, model in ipairs(used_models) do
    requestModel(model)
  end
  loadAllModelsNow()
end

function onScriptTerminate(script, quitGame)
  for i, model in ipairs(used_models) do
    markModelAsNoLongerNeeded(model)
  end
  removeAnimation("DW")
end

function main()
  wait(0)
  giveWeaponToChar(PLAYER_PED, weapons.GOLFCLUB, 1)
	sonicHUD.setMode(HUD_mode.VEHICLE_SEEKER)
  while true do
    --::continue::
    wait(0)
    is_in_interior = dwg.get("IN_TINTERIOR")
    if is_in_interior then
      --goto continue
    end

    is_shades_on = shades.isShadesOn()
    sonic_device, device_in_hand = get_current_sonic_device()
    sonic_app = nil

    if sonic_device > S_device.NONE then
      if isCharInAnyCar(PLAYER_PED) then
        if isKeyDown(vkeys.VK_Z) then
          sonic_app = APP_INCAR_LOCK
        elseif isKeyDown(vkeys.VK_X) then
          sonic_app = APP_INCAR_ACC
        end
      else
        if isButtonPressed(PLAYER_HANDLE, keys.player.LOCKTARGET) then
          long_wave_mode = true
        else
          long_wave_mode = false
        end

        if isKeyDown(vkeys.VK_U) then
          sonic_app = APP_EXP
        elseif isKeyDown(vkeys.VK_K) then
          sonic_app = APP_ENG
        elseif isKeyDown(vkeys.VK_J) then
          sonic_app = APP_ONFOOT_ACC
        elseif (device_in_hand or sonic_device == S_device.SHADES) and isKeyDown(vkeys.VK_Z) and long_wave_mode then
          sonic_app = APP_DISARM
        elseif isKeyDown(vkeys.VK_2) then
          sonic_app = APP_ONFOOT_LOCK
        elseif isKeyDown(vkeys.VK_H) then
          sonic_app = APP_DEFL
        elseif isKeyDown(vkeys.VK_1) then
          sonic_app = APP_SCAN_PHOTON
        elseif isKeyDown(vkeys.VK_3) then
          sonic_app = APP_SCAN_THERMAL
        end
      end
      if sonic_app ~= nil then
        activate()
      end
    end
  end
end

function activate()
	has_purpledildo = hasCharGotWeapon(PLAYER_PED, weapons.PURPLEDILDO)
  if sonic_app <= 8 then
		-----------------------------------
    -- Onfoot apps on target vehicle --
		-----------------------------------
    setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
    target = get_target()
    if target == nil or not is_target_compatible(target, sonic_app) then
      setPlayerWeaponsScrollable(PLAYER_HANDLE, true)
      return
    end
    local marker = addBlipForCar(target)
    x, y, z = getCarCoordinates(target)
    taskTurnCharToFaceCoord(PLAYER_PED, x, y, z)
    wait(1000)
    local sfx_loop
    if device_in_hand then
      if long_wave_mode then
        flick2()
      else
        noflick2()
      end
			if sonic_device == S_device.ELEVENTH then
      	sfx_loop = loadAudioStream("dws/ssd_loop.wav")
			elseif sonic_device == S_device.TWELFTH then
				sfx_loop = loadAudioStream("dws/ssd_new.wav")
			end
    else
      if sonic_device == S_device.SHADES then
        taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, false, false, false, false, -1)
        wait(250)
        sfx_loop = loadAudioStream("dws/sgl_loop.mp3")
      else
        if long_wave_mode then
          flick()
        else
          noflick()
        end
				if sonic_device == S_device.ELEVENTH then
	      	sfx_loop = loadAudioStream("dws/ssd_loop.wav")
				elseif sonic_device == S_device.TWELFTH then
					sfx_loop = loadAudioStream("dws/ssd_new.wav")
				end
      end
    end
    setAudioStreamLooped(sfx_loop, true)
    setAudioStreamState(sfx_loop, as_action.PLAY)
		if sonic_device == S_device.SHADES then
			wait(500)
		end
    ssd_setlight()
    wait(800)
    sonic_app_activate(sonic_app, target, marker)
		wait(500)
		setAudioStreamState(sfx_loop, as_action.STOP)
    if doesBlipExist(marker) then
      removeBlip(marker)
    end
		ssd_removelight()
    releaseAudioStream(sfx_loop)
    if device_in_hand then
      wait(2000)
      restore_sonic()
      wait(400)
      restoreCamera()
    else
      wait(800)
      restore_sonic()
      wait(500)
      setCurrentCharWeapon(PLAYER_PED, weapons.FIST)
    end
    --clearCharTasks(PLAYER_PED)
    restoreCamera()
    setPlayerControl(PLAYER_HANDLE, true)
    wait(100)
    setPlayerWeaponsScrollable(PLAYER_HANDLE, true)
		sonicHUD.setMode(HUD_mode.VEHICLE_SEEKER) -- Vehicle seeker ON
  elseif sonic_app > 8 and sonic_app <= 16 then
		-------------------------
    -- Special onfoot apps --
		-------------------------
		if sonic_app == APP_SCAN_PHOTON or sonic_app == APP_SCAN_THERMAL then
			----------
			-- Scan --
			----------
			setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
		  wait(100)
		  sonicHUD.setMode(HUD_mode.OFF) -- Vehicle seeker OFF
			if device_in_hand then
				scan_11th()
			else
				scan_12th()
			end
			if sonic_app == APP_SCAN_PHOTON then
				setNightVision(true)
			else
				setInfraredVision(true)
			end
			wait(0)
			if device_in_hand then
				wait(1875)
				ssd_removelight()
				setCharAnimPlayingFlag(PLAYER_PED, "Sonic_nine", false)
				wait(0)
			else
				if sonic_device == S_device.SHADES then
					print("FR")
					setCharAnimPlayingFlag(PLAYER_PED, "Wearable_Tech", false)
				else
					wait(1750)
					ssd_removelight()
					setCharAnimPlayingFlag(PLAYER_PED, "Sonic_eight", false)
				end
				wait(0)
			end
			if sonic_app == APP_SCAN_PHOTON then
				printHelp('SONICN')
			else
				printHelp('SONICT')
			end
			wait(0)
			setTimeScale(0.0)
			drifted = false -- TODO: Global variable
			if drifted then
				-- TODO: Mark drifted TARDIS on map
			end
			repeat
				wait(0)
			until isKeyDown(vkeys.VK_X) or getCharHealth(PLAYER_PED) < 15

			clearHelp()

			wait(0)
			setTimeScale(1.0)
			if sonic_app == APP_SCAN_PHOTON then
				setNightVision(false)
			else
				setInfraredVision(false)
			end
			wait(0)
			if device_in_hand then
				setCharAnimPlayingFlag(PLAYER_PED, "Sonic_nine", true)
				wait(1750)
				if sonic_device == S_device.ELEVENTH then
					taskPlayAnimSecondary(PLAYER_PED, "Sonic_seven", "DW", 4.0, false, false, false, false, -1)
					wait(650)
					restore_sonic()
					wait(1500)
				elseif sonic_device == S_device.TWELFTH then
					wait(1000)
				end
			else
				if sonic_device == S_device.SHADES then
					setCharAnimPlayingFlag(PLAYER_PED, "Wearable_Tech", true)
					wait(0)
				elseif sonic_device == S_device.ELEVENTH or sonic_device == S_device.TWELFTH then
					setCharAnimPlayingFlag(PLAYER_PED, "Sonic_eight", true)
					wait(850)
					giveWeaponToChar(PLAYER_PED, weapons.FIST, 1)
					wait(750)
				end
			end
			wait(0)
			setPlayerWeaponsScrollable(PLAYER_HANDLE, true)
			--clearCharTasks(PLAYER_PED)
			sonicHUD.setMode(HUD_mode.VEHICLE_SEEKER) -- Vehicle seeker ON
			--removeAnimation("DW")
		elseif sonic_app == APP_DISARM then
			------------
			-- Disarm --
			------------
			setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
			sonicHUD.setMode(HUD_mode.OFF) -- Vehicle seeker OFF
			local sfx_act
			if sonic_device == S_device.SHADES then
				taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, false, false, false, false, -1)
		    wait(250)
		    sfx_act = loadAudioStream("DWS/sgl_act.mp3")
			else
				taskPlayAnimSecondary(PLAYER_PED, "Sonic_six", "DW", 4.0, false, false, false, false, -1)
				wait(620)
				if sonic_device == S_device.ELEVENTH then
					giveWeaponToChar(PLAYER_PED, weapons.SHOVEL, 1)
				end
				sfx_act = loadAudioStream("DWS/ssd_act.wav")
			end
			setAudioStreamState(sfx_act, as_action.PLAY)
			long_wave_mode = true
			ssd_setlight()
			printStringNow("Disarmament Mode ~g~Activated", 3000)
			wait(700)
			ssd_removelight()
			releaseAudioStream(sfx_act)
			local sfx_dloop = loadAudioStream("DWS/ssd_disarmloop.wav")
			setAudioStreamLooped(sfx_dloop, true)
			setAudioStreamState(sfx_dloop, as_action.PLAY)
			ssd_setlight()
			sonicHUD.setMode(HUD_mode.CROSSHAIR) -- Crosshair ON
			wait(1300)
			if sonic_device == S_device.ELEVENTH then
				setPlayerWeaponsScrollable(PLAYER_HANDLE, true)
			end
			--removeAnimation("DW")
			--clearCharTasksImmediately(PLAYER_PED)
			local sfx_disarm = loadAudioStream("DWS/ssd_disarm.wav")
			repeat
				wait(0)
				is_regenerating = false -- TODO: Global var
				if (not isCurrentCharWeapon(PLAYER_PED, weapons.SILVERVIBRATOR) and sonic_device == S_device.ELEVENTH) or is_regenerating then
					wait(100)
					local c_weap = getCurrentCharWeapon(PLAYER_PED)
					local c_ammo = getAmmoInCharWeapon(PLAYER_PED, weap)
					local weapon, null, null = getCharWeaponInSlot(PLAYER_PED, 11)
					removeWeaponFromChar(PLAYER_PED, weapon)
					if has_purpledildo then
						giveWeaponToChar(PLAYER_PED, weapons.PURPLEDILDO, 1)
					end
					releaseAudioStream(sfx_dloop)
					printStringNow("Program 'Disarmament' ~r~Terminated", 3000)
					ssd_removelight()
					if is_regenerating then
						restore_sonic()
						giveWeaponToChar(PLAYER_PED, weapons.FIST, 1)
					else
						giveWeaponToChar(PLAYER_PED, c_weap, c_ammo)
						restore_sonic()
					end

					sonicHUD.setMode(HUD_mode.VEHICLE_SEEKER) -- Vehicle seeker ON
					return
				end
				if testCheat("LIZARD") then
					result = false
					repeat
						local x, y, z = getCharCoordinates(PLAYER_PED)
						result, target = findAllRandomCharsInSphere(x, y, z, 20.0, true, true)
						if result and doesCharExist(target) then
							if getCurrentCharWeapon(target) > 15 then
								setAudioStreamState(sfx_dloop, as_action.PAUSE)
								setAudioStreamState(sfx_disarm, as_action.PLAY)
								disarm(target)
								--wait(250)
								setAudioStreamState(sfx_disarm, as_action.STOP)
								setAudioStreamState(sfx_dloop, as_action.PLAY)
							end
						end
						wait(0)
					until not result
					printStringNow("DONE", 1000)
				end

				if isKeyDown(vkeys.VK_Z) then
					local result, target = getCharPlayerIsTargeting(PLAYER_HANDLE)
					if result and doesCharExist(target) then
						setAudioStreamState(sfx_dloop, as_action.PAUSE)
						setAudioStreamState(sfx_disarm, as_action.PLAY)
						disarm(target)
						--wait(250)
						setAudioStreamState(sfx_disarm, as_action.STOP)
						setAudioStreamState(sfx_dloop, as_action.PLAY)
					else
						wait(250)
					end
					--removeAnimation("DW")
				end
			until isKeyDown(vkeys.VK_X)
			releaseAudioStream(sfx_disarm)
			sonicHUD.setMode(HUD_mode.VEHICLE_SEEKER) -- Vehicle seeker ON
			setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
			if sonic_device == S_device.SHADES then
				taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, false, false, false, false, -1)
				wait(250)
			else
				taskPlayAnimSecondary(PLAYER_PED, "Sonic_seven", "DW", 4.0, false, false, false, false, -1)
				wait(650)
				ssd_removelight()
				restore_sonic()
			end
			releaseAudioStream(sfx_dloop)
			printStringNow("Program 'Disarmament' ~r~Deactivated", 3000)
			clearHelp()
			if sonic_device == S_device.SHADES then
				local sfx_sgl_off = loadAudioStream("DWS/sgl_off.mp3")
				setAudioStreamState(sfx_sgl_off, as_action.PLAY)
				wait(1500)
				releaseAudioStream(sfx_sgl_off)
			else
				wait(1500)
			end
			setPlayerWeaponsScrollable(PLAYER_HANDLE, true)
		end
  elseif sonic_app > 16 then
		----------------
    -- Incar apps --
		----------------
		if sonic_app == APP_INCAR_LOCK then
			----------
			-- Lock --
			----------
			if is_driving_forbidden_vehicle({models.BIKE, models.BMX, 510}) or isCharOnAnyBike(PLAYER_PED) then return end
			wait(100)
			local weapon, ammo, modelId = removeuzi()
			if sonic_device == S_device.SHADES then
				sfx_loop = loadAudioStream("dws/sgl_loop.mp3")
			elseif sonic_device == S_device.ELEVENTH then
				sfx_loop = loadAudioStream("dws/ssd_loop.wav")
			elseif sonic_device == S_device.TWELFTH then
				sfx_loop = loadAudioStream("dws/ssd_new.wav")
			end
			setAudioStreamState(sfx_loop, as_action.PLAY)
			if sonic_device == S_device.SHADES then
				wait(500)
			else
				wait(100)
			end
			ssd_setlight_incar()
			wait(1250)
			local sfx_lock = loadAudioStream("dws/ssd_lock.wav")
			setAudioStreamState(sfx_lock, as_action.PLAY)
			local target = storeCarCharIsInNoSave(PLAYER_PED)
	    if getCarDoorLockStatus(target) > 1 then
	      lockCarDoors(target, 0)
	      printBig('UNLOCK', 2000, 2)
	    else
	      lockCarDoors(target, 2)
	      printBig('LOCK', 2000, 2)
	    end
			wait(500)
			ssd_removelight_incar()
		  releaseAudioStream(sfx_loop)
		  if sonic_device == S_device.SHADES then
		    local sfx_off = loadAudioStream("dws/sgl_off.mp3")
		    setAudioStreamState(sfx_off, as_action.PLAY)
		    wait(900)
		    releaseAudioStream(sfx_off)
		  end
			if modelId ~= nil and weapon~= nil and ammo ~= nil and getGameGlobal(globals.ONMISSION) == 0 then
		    repeat
		      wait(100)
		    until isModelAvailable(modelId)
		    giveWeaponToChar(PLAYER_PED, weapon, ammo)
		    setCurrentCharWeapon(PLAYER_PED, weapon)
		    markModelAsNoLongerNeeded(modelId)
		  end

		elseif sonic_app == APP_INCAR_ACC then
			----------------
			-- Accelerate --
			----------------
			if is_driving_forbidden_vehicle({models.BIKE, models.SPARROW, models.BMX, 510}) or (isCharInAnyBoat(PLAYER_PED) and not is_driving_forbidden_vehicle({models.VORTEX})) then return end
			wait(100)
		  local weapon, ammo, modelId = removeuzi()
			if sonic_device == S_device.SHADES then
		    local sfx_act = loadAudioStream("dws/sgl_act.mp3")
		    setAudioStreamState(sfx_act, as_action.PLAY)
		    wait(700)
		    releaseAudioStream(sfx_act)
		  end
			if sonic_device == S_device.TWELFTH then
				sfx_loop = loadAudioStream("dws/ssd_new.wav")
			else
				sfx_loop = loadAudioStream("dws/ssd_loop.wav")
			end
		  setAudioStreamState(sfx_loop, as_action.PLAY)
		  ssd_setlight_incar()
		  setAudioStreamLooped(sfx_loop, true)
		  wait(1150)
		  setPlayerEnterCarButton(PLAYER_HANDLE, false)
		  while isKeyDown(vkeys.VK_X) do
		    wait(100)
		    if isCharInAnyCar(PLAYER_PED) then
		      target = storeCarCharIsInNoSave(PLAYER_PED)
		    else
		      break
		    end
		    if not isCarInAirProper(target) then
		      setCarCruiseSpeed(target, 300.0)
		      setCarForwardSpeed(target, getCarSpeed(target) + 10.0)
		    end
		  end
			print(string.format("%s, %s, %s", modelId, weapon, ammo))
		  if modelId ~= nil and weapon ~= nil and ammo ~= nil and getGameGlobal(globals.ONMISSION) == 0 then
		    repeat
		      wait(100)
		    until isModelAvailable(modelId)
		    giveWeaponToChar(PLAYER_PED, weapon, ammo)
		    setCurrentCharWeapon(PLAYER_PED, weapon)
		    markModelAsNoLongerNeeded(modelId)
		  end
		  setAudioStreamState(sfx_loop, as_action.STOP)
		  ssd_removelight_incar()
		  setPlayerEnterCarButton(PLAYER_HANDLE, true)
		  releaseAudioStream(sfx_loop)
		  if sonic_device == S_device.SHADES then
		    local sfx_off = loadAudioStream("dws/sgl_off.mp3")
		    setAudioStreamState(sfx_loop, as_action.PLAY)
		    wait(900)
		    releaseAudioStream(sfx_off)
		  end
		end
  end
end

------------------------
-- Additional functions
------------------------

function load_sfx_loop()
  if sonic_device == S_device.ELEVENTH then
    sfx_loop = loadAudioStream("dws/ssd_loop.wav")
    setAudioStreamLooped(sfx_loop, true)
  elseif sonic_device == S_device.SHADES then
    sfx_loop = loadAudioStream("dws/sgl_loop.mp3")
    setAudioStreamLooped(sfx_loop, true)
    wait(500)
  end
  return sfx_loop
end

function is_driving_forbidden_vehicle(models)
  if isCharInAnyCar(PLAYER_PED) then
    for i, model in ipairs(models) do
      if isCharInModel(PLAYER_PED, model) then
        return true
      end
    end
  end
  return false
end

function is_forbidden_model(model, forbidden_models)
  for i, m in ipairs(forbidden_models) do
    wait(1000)
    if m == model then return true end
  end
  return false
end

function flick()
  sonicHUD.setMode(HUD_mode.OFF) -- Vehicle seeker OFF
  taskPlayAnimSecondary(PLAYER_PED, "Sonic_three", "DW", 4.0, false, false, false, false, -1)
  setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
  wait(550)
  giveWeaponToChar(PLAYER_PED, weapons.POOLCUE, 1)
  wait(550)
  giveWeaponToChar(PLAYER_PED, weapons.SHOVEL, 1)
  sfx_act = loadAudioStream("DWS/ssd_act.wav")
  setAudioStreamState(sfx_act, as_action.PLAY)
  ssd_setlight()
  wait(700)
  ssd_removelight()
  releaseAudioStream(sfx_act)
end

function noflick()
  wait(0)
  --taskPlayAnimSecondary(ped, animation, IFP, framedelta, loopA, lockX, lockY, lockF, time)
  taskPlayAnimSecondary(PLAYER_PED, "Sonic_two", "DW", 4.0, false, false, false, false, -1)
  setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
  wait(550)
  restore_sonic()
  wait(1250)
end

function flick2()
 	sonicHUD.setMode(HUD_mode.OFF) -- Vehicle seeker OFF
  taskPlayAnimSecondary(PLAYER_PED, "Sonic_five", "DW", 4.0, false, false, false, false, -1)
  setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
  wait(1000)
	if sonic_device == S_device.ELEVENTH then
	  giveWeaponToChar(PLAYER_PED, weapons.SHOVEL, 1)
	  sfx_act = loadAudioStream("DWS/ssd_act.wav")
	  setAudioStreamState(sfx_act, as_action.PLAY)
	  ssd_setlight()
	  wait(700)
	  ssd_removelight()
	  releaseAudioStream(sfx_act)
	elseif sonic_device == S_device.TWELFTH then
		ssd_setlight()
		wait(700)
		ssd_removelight()
	end
  wait(500)
end

function noflick2()
  wait(0)
  sonicHUD.setMode(HUD_mode.OFF) -- Vehicle seeker OFF
	if sonic_device == S_device.SHADES then
		taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, false, false, false, false, -1)
		wait(250)
	else
	  taskPlayAnimSecondary(PLAYER_PED, "Sonic_one", "DW", 4.0, false, false, false, false, -1)
	  setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
	  wait(750)
	end
end

function scan_12th()
  wait(100)
  sonicHUD.setMode(HUD_mode.OFF) -- Vehicle seeker OFF
  if sonic_device == S_device.SHADES then
		taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, false, false, false, false, -1)
    wait(300)
    local sfx_loop = loadAudioStream("DWS/sgl_loop.mp3")
    setAudioStreamState(sfx_loop, as_action.PLAY)
    setCharAnimPlayingFlag(PLAYER_PED, "Wearable_Tech", false)
    wait(2975)
    setAudioStreamState(sfx_loop, as_action.STOP)
    releaseAudioStream(sfx_loop)
  else
		taskPlayAnimSecondary(PLAYER_PED, "Sonic_eight", "DW", 4.0, false, false, false, false, -1)
		wait(950)
		restore_sonic()
		local sfx_loop
		if sonic_device == S_device.ELEVENTH then
			sfx_loop = loadAudioStream("DWS/ssd_loop.wav")
		elseif sonic_device == S_device.TWELFTH then
			sfx_loop = loadAudioStream("DWS/ssd_new.wav")
		end
		setPlayerWeaponsScrollable(PLAYER_PED, false)
		wait(600)
		setAudioStreamState(sfx_loop, as_action.PLAY)
		long_wave_mode = 0 -- For ssd_setlight
		ssd_setlight()
		wait(2675)
		setAudioStreamState(sfx_loop, as_action.STOP)
		releaseAudioStream(sfx_loop)
  end
  wait(0)
end

function scan_11th()
  wait(100)
  sonicHUD.setMode(HUD_mode.OFF) -- Vehicle seeker OFF
	local sfx, sonic_weap
	if sonic_device == S_device.ELEVENTH then
		sfx = "DWS/ssd_loop.wav"
		sonic_weap = weapons.SHOVEL
	elseif sonic_device == S_device.TWELFTH then
		sfx = "DWS/ssd_new.wav"
		sonic_weap = weapons.GOLFCLUB
	end
  taskPlayAnimSecondary(PLAYER_PED, "Sonic_nine", "DW", 4.0, false, false, false, false, -1)
  wait(750)
  local sfx_loop = loadAudioStream(sfx)
  setAudioStreamState(sfx_loop, as_action.PLAY)
	long_wave_mode = 0 -- For ssd_setlight
  ssd_setlight()
  wait(2250)
  setAudioStreamState(sfx_loop, as_action.STOP)
  ssd_removelight()
  releaseAudioStream(sfx_loop)
  wait(550)
  giveWeaponToChar(PLAYER_PED, sonic_weap, 1)
	long_wave_mode = true -- For ssd_setlight
  ssd_setlight()
  sfx_act = loadAudioStream("DWS/ssd_act.wav")
  setAudioStreamState(sfx_act, as_action.PLAY)
  wait(200)
  releaseAudioStream(sfx_act)
end

function disarm(target)
	local marker = addBlipForChar(target)
	local particle = createFxSystemOnChar("prt_spark", target, 0.05, 0.12, 0.01, 1)
	rotateToCharInstantly(target)
  wait(0)
  if sonic_device == S_device.ELEVENTH or sonic_device == S_device.TWELFTH then
    taskPlayAnimSecondary(PLAYER_PED, "Sonic_four", "DW", 4.0, false, false, false, false, -1)
		local time = 0
		repeat
			wait(0)
			time = getCharAnimCurrentTime(PLAYER_PED, "Sonic_four")
		until time >= 0.2
  elseif sonic_device == S_device.SHADES then
    taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, false, false, false, false, -1)
		wait(400)
  end


	if getCurrentCharWeapon(target) < 16 then -- melee weapons can't be broken
		wait(200)
		removeBlip(marker)
		wait(400)
	else
		playFxSystem(particle)
		wait(200)
		killFxSystem(particle)
		removeAllCharWeapons(target)
		removeBlip(marker)
		wait(400)
	end
	repeat
		wait(0)
	until not isCharPlayingAnim(PLAYER_PED, "Sonic_four") and not isCharPlayingAnim(PLAYER_PED, "Wearable_Tech")
end

function restore_sonic() -- old ssd_stuff
  if sonic_device == S_device.ELEVENTH then
    giveWeaponToChar(PLAYER_PED, weapons.POOLCUE, 1)
  elseif sonic_device == S_device.TWELFTH then
    giveWeaponToChar(PLAYER_PED, weapons.GOLFCLUB, 1)
  end
end

function removeuzi()
  wait(0)
  if getGameGlobal(globals.ONMISSION) == 0 then
    if hasCharGotWeapon(PLAYER_PED, weapons.UZI) or
    hasCharGotWeapon(PLAYER_PED, weapons.MP5) or
    hasCharGotWeapon(PLAYER_PED, weapons.TEC5)
    then
      weapon, ammo, modelId = getCharWeaponInSlot(PLAYER_PED, 5)
      removeWeaponFromChar(PLAYER_PED, weapon)
      setCurrentCharWeapon(PLAYER_PED, weapons.FIST)
      requestModel(modelId)
      loadAllModelsNow()
			if weapon == -1 or ammo == 0 or modelId == 0 then
				return nil, nil, nil
			else
      	return weapon, ammo, modelId
			end
    end
  end
	print("NIL")
	return nil, nil, nil
end

function ssd_setlight_incar()
  if sonic_device == S_device.ELEVENTH then
    if long_wave_mode then
      obj_sonic = createObject(models.SONICOL, 0.0, 0.0, -100.0)
    else
      obj_sonic = createObject(models.SONICCL, 0.0, 0.0, -100.0)
    end
    wait(0)
    setObjectCollision(obj_sonic, false)
    setObjectProofs(obj_sonic, true, true, true, true, true)
    taskPickUpObject(PLAYER_PED, obj_sonic, 0.0, 0.0, 0.0, 6, 16, "NULL", "NULL", -1)
	elseif sonic_device == S_device.TWELFTH then
		sonic_spin_mode = 2
		lua_thread.create(sonic_spin)
	end
end

function ssd_removelight_incar()
  wait(0)
	if sonic_device == S_device.ELEVENTH then
	  if doesObjectExist(obj_sonic) then
	    deleteObject(obj_sonic)
	    --markObjectAsNoLongerNeeded(obj_sonic)
	  end
	elseif sonic_device == S_device.TWELFTH then
		sonic_spin_mode = 0
	end
end

function ssd_setlight()
  wait(0)
  if sonic_device == S_device.ELEVENTH then
    if long_wave_mode then
      giveWeaponToChar(PLAYER_PED, weapons.SILVERVIBRATOR, 1)
    else
      giveWeaponToChar(PLAYER_PED, weapons.WHITEVIBRATOR, 1)
    end
  elseif sonic_device == S_device.TWELFTH then
		sonic_spin_mode = 1
		lua_thread.create(sonic_spin)
  end
end

function ssd_removelight()
  if sonic_device == S_device.ELEVENTH then
    local weapon, ammo, modelId = getCharWeaponInSlot(PLAYER_PED, 11)
    removeWeaponFromChar(PLAYER_PED, weapon)
    if has_purpledildo then
      giveWeaponToChar(PLAYER_PED, weapons.PURPLEDILDO, 1)
    end
    if long_wave_mode then
      giveWeaponToChar(PLAYER_PED, weapons.SHOVEL, 1)
    else
      giveWeaponToChar(PLAYER_PED, weapons.POOLCUE, 1)
    end
	elseif sonic_device == S_device.TWELFTH then
		sonic_spin_mode = 0
  end
  wait(0)
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
  if isCarDead(target)
  then
    return nil
  end
  return target
end

function get_current_sonic_device()
  in_hands = false
	if is_shades_on == nil then is_shades_on = false end
  if is_shades_on then
    return S_device.SHADES, false
  elseif hasCharGotWeapon(PLAYER_PED, weapons.POOLCUE) then
    if isCurrentCharWeapon(PLAYER_PED, weapons.POOLCUE) then
      in_hands = true
    end
    return S_device.ELEVENTH, in_hands
  elseif hasCharGotWeapon(PLAYER_PED, weapons.GOLFCLUB) then
    if isCurrentCharWeapon(PLAYER_PED, weapons.GOLFCLUB) then
      in_hands = true
    end
    return S_device.TWELFTH, in_hands
  else
    return S_device.NONE, false
  end
end

function is_target_compatible(target, sonic_app)
  bad_list = {}
  if sonic_app == APP_EXP then
    bad_list = non_explicable_vehicles
  elseif sonic_app == APP_DEFL then

  elseif sonic_app == APP_ENG then
    bad_list = no_engine_vehicles
  elseif sonic_app == APP_ONFOOT_ACC then
    bad_list = cant_accelerate_vehicles
  end
  return not is_forbidden_model(getCarModel(target), bad_list)
end

function sonic_app_activate(sonic_app, target, marker)
  if sonic_app == APP_EXP then
    explodeCar(target)
  elseif sonic_app == APP_DEFL then
    burstCarTire(target, 0)
    burstCarTire(target, 1)
    burstCarTire(target, 2)
    burstCarTire(target, 3)
  elseif sonic_app == APP_ENG then
    lua_thread.create(ssd_eng_async_task, target, marker)
  elseif sonic_app == APP_ONFOOT_ACC then
    lua_thread.create(ssd_onfoot_acc_async_task, target)
  elseif sonic_app == APP_ONFOOT_LOCK then
    local doorStatus = getCarDoorLockStatus(target)
    if doorStatus > 1 then
      lockCarDoors(target, 0)
      printBig('UNLOCK', 2000, 2)
    else
      lockCarDoors(target, 2)
      printBig('LOCK', 2000, 2)
    end
    local sfx_lock = load3dAudioStream("DWS/ssd_lock.mp3")
    setPlay3dAudioStreamAtCar(sfx_lock, target)
    setAudioStreamState(sfx_lock, as_action.PLAY)
    wait(500)
    setAudioStreamState(sfx_lock, as_action.STOP)
    releaseAudioStream(sfx_lock)
  end
end

function ssd_onfoot_acc_async_task(target_car)
  carGotoCoordinates(target, 0.0, 0.0, 0.0)
  wait(100)
  setCarForwardSpeed(target, 10.0)
  wait(1)
  setCarForwardSpeed(target, 30.0)
  wait(100)
  setCarForwardSpeed(target, 50.0)
  wait(100)
  setCarForwardSpeed(target, 70.0)
  wait(100)
  setCarForwardSpeed(target, 100.0)
end

function ssd_eng_async_task(target_car, marker)
  setCarEngineBroken(target_car, true)
  switchCarEngine(target_car, false)
  setCarHealth(target_car, 400)
  removeBlip(marker)
  wait(400)
  local ped = getDriverOfCar(target)
  if doesCharExist(ped) then
    taskLeaveAnyCar(ped)
    wait(500)
    local x, y, z = getCarCoordinates(target)
    local rnd = math.random(0, 10)
    printStringNow(rnd, 1000)
    if rnd > 5 then
      taskKillCharOnFootTimed(ped, PLAYER_PED, 15000)
    else
      taskFleePoint(ped, x, y, z, 100.0, 60000)
    end
  end
end

function rotateToCharInstantly(target)
	local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
	local tX, tY, tZ = getCharCoordinates(target)
	local x = tX - pX
	local y = tY - pY
	local c = math.atan2(x, y)
	setCharHeading(PLAYER_PED, math.deg(-c))
end

function sonic_spin()
	if sonic_spin_mode == 1 then
		while sonic_spin_mode == 1 do
			giveWeaponToChar(PLAYER_PED, weapons.WHITEDILDO, 1)
			wait(150)
			giveWeaponToChar(PLAYER_PED, weapons.FLOWERS, 1)
			wait(150)
		end
		local weapon, ammo, modelId = getCharWeaponInSlot(PLAYER_PED, 11)
		removeWeaponFromChar(PLAYER_PED, weapon)
		if has_purpledildo then
			giveWeaponToChar(PLAYER_PED, weapons.PURPLEDILDO, 1)
		end
		giveWeaponToChar(PLAYER_PED, weapons.GOLFCLUB, 1)
	elseif sonic_spin_mode == 2 then
			while sonic_spin_mode == 2 do
				local spin_a = createObject(models.FLOWERA, 0.0, 0.0, -100.0)
				local spin_b = createObject(models.GUN_DILDO2, 0.0, 0.0, -100.0)
				taskPickUpObject(PLAYER_PED, spin_a, 0.0, 0.0, 0.0, 6, 16, "NULL", "NULL", -1)
				wait(150)
				taskPickUpObject(PLAYER_PED, spin_b, 0.0, 0.0, 0.0, 6, 16, "NULL", "NULL", -1)
				wait(150)
				deleteObject(spin_a)
				deleteObject(spin_b)
			end

	end
end

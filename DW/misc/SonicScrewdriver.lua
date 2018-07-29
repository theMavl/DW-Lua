script_name("Sonic")
script_authors("Mavl Pond", "Tommy LU")
script_version("1.0")
script_version_number(1)
script_description("Sonic Screwdriver script For Doctor Who: Dalek invasion mod")

require "lib.moonloader"
local as_action = require('moonloader').audiostream_state
local mad = require 'MoonAdditions'
local models = require "lib.game.models"
local globals = require "lib.game.globals"
local weapons = require "lib.game.weapons"
local keys = require "lib.game.keys"
local vkeys = require "lib.vkeys"
local inicfg = require 'inicfg'

local used_models = {
	models.SHOVEL,
	models.POOLCUE,
	models.GUN_VIBE1,
	models.GUN_VIBE2,
	models.GUN_DILDO2,
	models.SONICCL,
	models.SONICOL
}
local is_shades_on
local sonic_wave_mode
non_explicable_vehicles = {
	nil,
	models.SPARROW,
	models.RHINO,
	models.RCCAM,
	models.BMX,
	models.BIKE,
	models.RCGOBLIN
}

local no_engine_vehicles = {
	nil, models.BMX, models.BIKE, models.MTBIKE, models.FCR900, models.BF400, models.FAGGIO, models.FREEWAY, models.NRG500, models.PCJ600, models.PIZZABOY, models.SANCHEZ, models.WAYFARER, models.COPBIKE, models.SPARROW, models.RCCAM
}

local cant_accelerate_vehicles = {
	nil, models.SPARROW, models.RHINO, models.RCCAM, models.BMX, models.BIKE, models.MTBIKE
}

function onScriptLoad(script)
  requestAnimation("DW")
  for i, model in ipairs(used_models) do
    requestModel(model)
  end
  loadAllModelsNow()
end

function main()
	wait(1)
	giveWeaponToChar(PLAYER_PED, weapons.POOLCUE, 1)
  while true do
    --::continue::
    wait(0)
    is_in_interior = false -- GET GLOBAL
    if is_in_interior then
      --goto continue
    end
    has_purpledildo = hasCharGotWeapon(PLAYER_PED, weapons.PURPLEDILDO)
    is_shades_on = false -- GET GLOBAL

    if is_shades_on then
      setCurrentCharWeapon(PLAYER_PED, weapons.FIST)
      setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
    end

    if isCharInAnyCar(PLAYER_PED) then
      ssd_incar()
    else
      if hasCharGotWeapon(PLAYER_PED, weapons.POOLCUE) or is_shades_on then
        ssd_onfoot()
      end
    end
  end
end

function ssd_onfoot()
  if not is_shades_on and not isCurrentCharWeapon(PLAYER_PED, weapons.FIST) and not isCurrentCharWeapon(PLAYER_PED, weapons.POOLCUE) then
    return
  end

  if isButtonPressed(PLAYER_HANDLE, keys.player.LOCKTARGET) then
    sonic_wave_mode = 1
  else
    sonic_wave_mode = 0
  end

  if isKeyDown(vkeys.VK_U) then
						printStringNow("GO", 100)
    ssd_exp()
  elseif isKeyDown(vkeys.VK_K) then
    ssd_eng()
  elseif isKeyDown(vkeys.VK_J) then
    ssd_acc()
  elseif isKeyDown(vkeys.VK_Z) then
    ssd_dsr()
  elseif isKeyDown(vkeys.VK_2) then
    ssd_lock()
  elseif isKeyDown(vkeys.VK_H) then
    ssd_defl()
  elseif isKeyDown(vkeys.VK_1) or isKeyDown(vkeys.VK_3) then
    ssd_scan()
  end
end

function ssd_incar()
  if isKeyDown(vkeys.VK_Z) and isCharInAnyCar(PLAYER_PED) and not isCharInModel(PLAYER_PED, models.SPARROW) then
    if hasCharGotWeapon(PLAYER_PED, weapons.POOLCUE) or is_shades_on then
      wait(800)
      ssd_lock_inc()
      return
    end
  elseif isKeyDown(vkeys.VK_X) and not is_driving_forbidden_vehicle({models.BIKE, models.SPARROW, models.BMX, models.MTBIKE}) then
    if hasCharGotWeapon(PLAYER_PED, weapons.POOLCUE) or is_shades_on then
      if isCharInAnyBoat(PLAYER_PED) and not isCharInModel(PLAYER_PED, models.VORTEX) then
        return
      end
      wait(800)
      ssd_acc_inc()
    end
  end
end

function ssd_exp()
	target = get_target()
	if target == nil then return end

	if is_forbidden_model(getCarModel(target), non_explicable_vehicles) then
		return
	end

  local marker = addBlipForCar(target)
  x, y, z = getCarCoordinates(target)
  taskTurnCharToFaceCoord(PLAYER_PED, x, y, z)
  wait(1000)
  if isCurrentCharWeapon(PLAYER_PED, weapons.POOLCUE) then
    if sonic_wave_mode == 1 then
      flick2()
    else
      noflick2()
    end
    local sfx_loop = loadAudioStream("dws/ssd_loop.wav")
    setAudioStreamLooped(sfx_loop, true)
    setAudioStreamState(sfx_loop, as_action.PLAY)
    ssd_setlight()
    wait(1100)
    setAudioStreamState(sfx_loop, as_action.STOP)
    ssd_removelight()
    releaseAudioStream(sfx_loop)
    explodeCar(target)
    removeBlip(marker)
    wait(2000)
    give_poolcue_ifno_shades()
    wait(400)
    restoreCamera()
  else
		if sonic_wave_mode == 1 then
      flick()
    else
      noflick()
    end
		local sfx_loop = load_sfx_loop()
		ssd_setlight()
		wait(1100)
		setAudioStreamLooped(sfx_loop, false)
		ssd_removelight()
		explodeCar(target)
		removeBlip(marker)
		releaseAudioStream(sfx_loop)
		wait(800)
		give_poolcue_ifno_shades()
		wait(500)
		setCurrentCharWeapon(PLAYER_PED, weapons.FIST)
  end
	clearCharTasks(PLAYER_PED)
	restoreCamera()
	setPlayerControl(PLAYER_HANDLE, true)
	wait(100)
	setPlayerWeaponsScrollable(PLAYER_HANDLE, true)
	-- TODO: Sonic GUI
end

function ssd_eng()
	target = get_target()
	if target == nil then return end
	if is_forbidden_model(getCarModel(target), no_engine_vehicles) then return end
  local marker = addBlipForCar(target)
  x, y, z = getCarCoordinates(target)
  taskTurnCharToFaceCoord(PLAYER_PED, x, y, z)
  wait(1000)
  if isCurrentCharWeapon(PLAYER_PED, weapons.POOLCUE) then
    if sonic_wave_mode == 1 then
      flick2()
    else
      noflick2()
    end
    local sfx_loop = loadAudioStream("dws/ssd_loop.wav")
    setAudioStreamLooped(sfx_loop, true)
    setAudioStreamState(sfx_loop, as_action.PLAY)
    ssd_setlight()
    wait(1100)
    setAudioStreamState(sfx_loop, as_action.STOP)
    ssd_removelight()
    releaseAudioStream(sfx_loop)
    setCarEngineBroken(target, true)
		switchCarEngine(target, false)
		setCarHealth(target, 400)
    removeBlip(marker)
		wait(400)
		local ped = getDriverOfCar(target)
		if doesCharExist(ped) then
			taskLeaveAnyCar(ped)
			wait(500)
			local x, y, z = getCarCoordinates(target)
			local rnd = math.random(0, 10)
			printStringNow(rnd, 1000)
			if  rnd > 5 then
				taskKillCharOnFootTimed(ped, PLAYER_PED, 15000)
			else
				taskFleePoint(ped, x, y, z, 100.0, 60000)
			end
		end
    wait(1600)
    give_poolcue_ifno_shades()
    wait(400)
    restoreCamera()
  else
		if sonic_wave_mode == 1 then
      flick()
    else
      noflick()
    end
		local sfx_loop = load_sfx_loop()
		ssd_setlight()
		wait(1100)
		setAudioStreamLooped(sfx_loop, false)
		ssd_removelight()
		setCarEngineBroken(target, true)
		switchCarEngine(target, false)
		setCarHealth(target, 400)
		removeBlip(marker)
		releaseAudioStream(sfx_loop)
		wait(400)
		local ped = getDriverOfCar(target)
		if doesCharExist(ped) then
			taskLeaveAnyCar(ped)
			wait(500)
			local x, y, z = getCarCoordinates(target)
			if math.random(9) > 5 then
				taskKillCharOnFootTimed(ped, PLAYER_PED, 15000)
			else
				taskFleePoint(ped, x, y, z, 100.0, 60000)
			end
		end
		give_poolcue_ifno_shades()
		wait(500)
		setCurrentCharWeapon(PLAYER_PED, weapons.FIST)
  end
	clearCharTasks(PLAYER_PED)
	restoreCamera()
	setPlayerControl(PLAYER_HANDLE, true)
	wait(100)
	setPlayerWeaponsScrollable(PLAYER_HANDLE, true)
	-- TODO: Sonic GUI turn on
end

function ssd_acc()
	target = get_target()
	if target == nil then return end
	local model = getCarModel(target)
	if is_forbidden_model(model, cant_accelerate_vehicles) or (isThisModelABoat(model) and not model == models.VORTEX) then return end

  local marker = addBlipForCar(target)
  x, y, z = getCarCoordinates(target)
  taskTurnCharToFaceCoord(PLAYER_PED, x, y, z)
  wait(1000)
  if isCurrentCharWeapon(PLAYER_PED, weapons.POOLCUE) then
    if sonic_wave_mode == 1 then
      flick2()
    else
      noflick2()
    end
    local sfx_loop = loadAudioStream("dws/ssd_loop.wav")
    setAudioStreamLooped(sfx_loop, true)
    setAudioStreamState(sfx_loop, as_action.PLAY)
    ssd_setlight()
    wait(1000)
		carGotoCoordinates(target, 0.0, 0.0, 0.0)
		wait(100)
		setCarForwardSpeed(target, 10.0)
    setAudioStreamState(sfx_loop, as_action.STOP)
    ssd_removelight()
    releaseAudioStream(sfx_loop)
    setCarForwardSpeed(target, 30.0)
		wait(100)
		setCarForwardSpeed(target, 50.0)
		wait(100)
		setCarForwardSpeed(target, 70.0)
		wait(100)
		setCarForwardSpeed(target, 100.0)
    removeBlip(marker)
    wait(1600)
    give_poolcue_ifno_shades()
    wait(400)
    restoreCamera()
  else
		if sonic_wave_mode == 1 then
      flick()
    else
      noflick()
    end
		local sfx_loop = load_sfx_loop()
		ssd_setlight()
		wait(1100)
		carGotoCoordinates(target, 0.0, 0.0, 0.0)
		wait(100)
		setCarForwardSpeed(target, 10.0)
		wait(100)
		setAudioStreamLooped(sfx_loop, false)
		ssd_removelight()
		releaseAudioStream(sfx_loop)
		setCarForwardSpeed(target, 30.0)
		wait(100)
		setCarForwardSpeed(target, 50.0)
		wait(100)
		setCarForwardSpeed(target, 70.0)
		wait(100)
		setCarForwardSpeed(target, 100.0)
		removeBlip(marker)
		wait(0)
		give_poolcue_ifno_shades()
		wait(800)
		setCurrentCharWeapon(PLAYER_PED, weapons.FIST)
  end
	clearCharTasks(PLAYER_PED)
	restoreCamera()
	setPlayerControl(PLAYER_HANDLE, true)
	wait(100)
	setPlayerWeaponsScrollable(PLAYER_HANDLE, true)
	-- TODO: Sonic GUI enable
end

function ssd_acc_inc()
	wait(100)
	local weapon, ammo, modelId = removeuzi()
	if is_shades_on then
		local sfx_act = loadAudioStream("dws/sgl_act.mp3")
		setAudioStreamState(sfx_loop, as_action.PLAY)
		wait(700)
		releaseAudioStream(sfx_act)
	end
	local sfx_loop = loadAudioStream("dws/ssd_loop.wav")
	setAudioStreamState(sfx_loop, as_action.PLAY)
	ssd_setlight_inc()
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
	if globals.ONMISSION == 0 then
		repeat
			wait(100)
		until isModelAvailable(modelId)
		giveWeaponToChar(PLAYER_PED, weapon, ammo)
		setCurrentCharWeapon(PLAYER_PED, weapon)
		markModelAsNoLongerNeeded(modelId)
	end
	setAudioStreamState(sfx_loop, as_action.STOP)
	ssd_removelight_inc()
	setPlayerEnterCarButton(PLAYER_HANDLE, true)
	releaseAudioStream(sfx_loop)
	if is_shades_on then
		local sfx_off = loadAudioStream("dws/sgl_off.mp3")
		setAudioStreamState(sfx_loop, as_action.PLAY)
		wait(900)
		releaseAudioStream(sfx_off)
	end
end

function ssd_scan()
	local smode
	if isKeyDown(vkeys.VK_1) then smode = 0
	elseif isKeyDown(vkeys.VK_3) then smode = 1
	else return end
	if isCurrentCharWeapon(PLAYER_PED, weapons.POOLCUE) then
		scan_11th()
	elseif isCurrentCharWeapon(PLAYER_PED, weapons.FIST) then
		scan_12th()
	else return end
	wait(0)
	if smode == 0 then
		setNightVision(true)
	else
		setInfraredVision(true)
	end
	wait(0)
	if sonic_wave_mode == 1 then
		wait(1875)
		ssd_removelight()
		setCharAnimPlayingFlag(PLAYER_PED, "Sonic_nine", 0)
		wait(0)

	else
		if is_shades_on then
			setCharAnimPlayingFlag(PLAYER_PED, "Wearable_Tech", 0)
		else
			wait(1750)
			ssd_removelight()
			setCharAnimPlayingFlag(PLAYER_PED, "Sonic_eight", 0)
		end
		wait(0)
	end
	-- TODO: GXT Strings!
	if smode == 0 then
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
	until isKeyDown(vkeys.VK_X)

	clearHelp()

	wait(0)
	setTimeScale(1.0)
	if smode == 0
	then
		setNightVision(false)
	else
		setInfraredVision(false)
	end

	wait(0)

	if sonic_wave_mode == 1 then
		setCharAnimPlayingFlag(PLAYER_PED, "Sonic_nine", 1)
		wait(1750)
		requestAnimation("DW")
		repeat
			wait(10)
		until hasAnimationLoaded("DW")
		taskPlayAnimSecondary(PLAYER_PED, "Sonic_seven", "DW", 4.0, 0, 0, 0, 0, -1)
		wait(650)
		give_poolcue_ifno_shades()
		wait(1500)
	else
		if is_shades_on then
			setCharAnimPlayingFlag(PLAYER_PED, "Wearable_Tech", 1)
			wait(0)
		else
			setCharAnimPlayingFlag(PLAYER_PED, "Sonic_eight", 1)
			wait(850)
			giveWeaponToChar(PLAYER_PED, weapons.FIST, 1)
			wait(750)
		end
	end
	wait(0)
	setPlayerWeaponsScrollable(PLAYER_HANDLE, true)
	-- TODO: Sonic GUI enable
	removeAnimation("DW")
end

function scan_12th()
	requestAnimation("DW")
	repeat
		wait(10)
	until hasAnimationLoaded("DW")
	wait(100)
	-- TODO: Sonic GUI STOP
	if not is_shades_on then
		taskPlayAnimSecondary(PLAYER_PED, "Sonic_eight", "DW", 4.0, 0, 0, 0, 0, -1)
		wait(950)
		giveWeaponToChar(PLAYER_PED, weapons.POOLCUE, 1)
		setPlayerWeaponsScrollable(PLAYER_PED, false)
		sonic_wave_mode = 0
		wait(600)
		local sfx_loop = loadAudioStream("DWS/ssd_loop.wav")
		setAudioStreamState(sfx_loop, as_action.PLAY)
		ssd_setlight()
		wait(2675)
		setAudioStreamState(sfx_loop, as_action.STOP)
		releaseAudioStream(sfx_loop)
	else
		taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, 0, 0, 0, 0, -1)
		wait(300)
		sonic_wave_mode = 0
		local sfx_loop = loadAudioStream("DWS/sgl_loop.mp3")
		setAudioStreamState(sfx_loop, as_action.PLAY)
		setCharAnimPlayingFlag(PLAYER_PED, "Wearable_Tech", 0)
		wait(2975)
		setAudioStreamState(sfx_loop, as_action.STOP)
		releaseAudioStream(sfx_loop)
	end
wait(0)
end

function scan_11th()
	requestAnimation("DW")
	repeat
		wait(10)
	until hasAnimationLoaded("DW")
	wait(100)
	-- TODO: Sonic GUI STOP
	taskPlayAnimSecondary(PLAYER_PED, "Sonic_nine", "DW", 4.0, 0, 0, 0, 0, -1)
	sonic_wave_mode = 0
	wait(750)
	local sfx_loop = loadAudioStream("DWS/ssd_loop.wav")
	setAudioStreamState(sfx_loop, as_action.PLAY)
	ssd_setlight()
	wait(2250)
	setAudioStreamState(sfx_loop, as_action.STOP)
	ssd_removelight()
	releaseAudioStream(sfx_loop)
	wait(550)
	sonic_wave_mode = 1
	giveWeaponToChar(PLAYER_PED, weapons.SHOVEL, 1)
	ssd_setlight()
	sfx_act = loadAudioStream("DWS/ssd_act.wav")
	setAudioStreamState(sfx_act, as_action.PLAY)
	wait(200)
	releaseAudioStream(sfx_act)
end

function ssd_dsr()
	wait(100)
	if not isCurrentCharWeapon(PLAYER_PED, weapons.POOLCUE) and not is_shades_on then return end
	requestAnimation("DW")
	-- TODO: Sonuc GUI STOP
	setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
	local sfx_act
	if not is_shades_on then
		taskPlayAnimSecondary(PLAYER_PED, "Sonic_six", "DW", 4.0, 0, 0, 0, 0, -1)
		wait(650)
		giveWeaponToChar(PLAYER_PED, weapons.SHOVEL, 1)
		sfx_act = loadAudioStream("DWS/ssd_act.wav")
	else
		taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, 0, 0, 0, 0, -1)
		wait(250)
		sfx_act = loadAudioStream("DWS/sgl_act.mp3")
	end
	sonic_wave_mode = 1
	setAudioStreamState(sfx_act, as_action.PLAY)
	ssd_setlight()
	printStringNow("Disarmament Mode ~g~Activated", 3000)
	wait(700)
	ssd_removelight()
	releaseAudioStream(sfx_act)
	local sfx_loop = loadAudioStream("DWS/ssd_disarmloop.wav")
	setAudioStreamState(sfx_loop, as_action.PLAY)
	ssd_setlight()
	setAudioStreamLooped(sfx_loop, true)
	-- TODO: Sonuc GUI Start Crosshair MODE
	if not is_shades_on then
		setPlayerWeaponsScrollable(PLAYER_HANDLE, true)
	end
	removeAnimation("DW")
	wait(1300)

end

function onScriptTerminate(script, quitGame)
  for i, model in ipairs(used_models) do
    markModelAsNoLongerNeeded(model)
  end
	removeAnimation("DW")
end

------------------------
-- Additional functions
------------------------

function load_sfx_loop()
		if is_shades_on then
			sfx_loop = loadAudioStream("dws/ssd_loop.wav")
			setAudioStreamLooped(sfx_loop, true)
		else
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
	-- TODO: END GUI THREAD
	if not is_shades_on then
		taskPlayAnimSecondary(PLAYER_PED, "Sonic_three", "DW", 4.0, 0, 0, 0, 0, -1)
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
	else
		taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, 0, 0, 0, 0, -1)
		wait(250)
	end
end

function noflick()
	wait(0)
	if not is_shades_on then
		--taskPlayAnimSecondary(ped, animation, IFP, framedelta, loopA, lockX, lockY, lockF, time)
		printStringNow("SOSI", 1000)
		taskPlayAnimSecondary(PLAYER_PED, "Sonic_two", "DW", 4.0, 0, 0, 0, 0, -1)
		setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
		wait(550)
		giveWeaponToChar(PLAYER_PED, weapons.POOLCUE, 1)
		wait(1250)
	else
		taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, 0, 0, 0, 0, -1)
		wait(250)
	end
end

function flick2()
	-- TODO: END GUI THREAD
	if not is_shades_on then
		taskPlayAnimSecondary(PLAYER_PED, "Sonic_five", "DW", 4.0, 0, 0, 0, 0, -1)
		setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
		wait(1000)
		giveWeaponToChar(PLAYER_PED, weapons.SHOVEL, 1)
		sfx_act = loadAudioStream("DWS/ssd_act.wav")
		setAudioStreamState(sfx_act, as_action.PLAY)
		ssd_setlight()
		wait(700)
		ssd_removelight()
		releaseAudioStream(sfx_act)
		wait(500)
	else
		taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, 0, 0, 0, 0, -1)
		wait(250)
	end
end

function noflick2()
	wait(0)
	-- TODO: END GUI THREAD
	if not is_shades_on then
		printStringNow("TESfT", 1000)
		taskPlayAnimSecondary(PLAYER_PED, "Sonic_one", "DW", 4.0, 0, 0, 0, 1, -1)
		setPlayerWeaponsScrollable(PLAYER_HANDLE, false)
		wait(750)
	else
		taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, 0, 0, 0, 0, -1)
		wait(250)
	end
end

function disarm()
	repeat
		wait(0)
	until hasAnimationLoaded("DW")
	wait(0)
	if not is_shades_on then
		taskPlayAnimSecondary(PLAYER_PED, "Sonic_four", "DW", 4.0, 0, 0, 0, 0, -1)
	else
		taskPlayAnimNonInterruptable(PLAYER_PED, "Wearable_Tech", "DW", 4.0, 0, 0, 0, 0, -1)
	end
	wait(0)
end

function give_poolcue_ifno_shades() -- old ssd_stuff
	if not is_shades_on then
		giveWeaponToChar(PLAYER_PED, weapons.POOLCUE, 1)
	end
end

function removeuzi()
	wait(0)
	if globals.ONMISSION == 0 then
		if 	hasCharGotWeapon(PLAYER_PED, weapons.UZI) or
				hasCharGotWeapon(PLAYER_PED, weapons.MP5) or
				hasCharGotWeapon(PLAYER_PED, weapons.TEC5)
		then
			weapon, ammo, modelId = getCharWeaponInSlot(PLAYER_PED, 5)
			removeWeaponFromChar(PLAYER_PED, weapon)
			setCurrentCharWeapon(PLAYER_PED, weapons.FIST)
			requestModel(modelId)
			loadAllModelsNow()
			return weapon, ammo, modelId
		end
	end
end

function ssd_setlight_incar()
	if not is_shades_on then
		if sonic_wave_mode == 1 then
			obj_sonic = createObject(models.SONICOL, 0.0, 0.0, -100.0)
		else
			obj_sonic = createObject(models.SONICCL, 0.0, 0.0, -100.0)
		end
		wait(0)
		setObjectCollision(obj_sonic, false)
		setObjectProofs(obj_sonic, 1, 1, 1, 1, 1)
		taskPickUpObject(PLAYER_PED, obj_sonic, 0.0, 0.0, 0.0, 6, 16, nil, nil, -1)
	end
end

function ssd_removelight_incar()
	wait(0)
	if doesObjectExist(obj_sonic) then
		deleteObject(obj_sonic)
		--markObjectAsNoLongerNeeded(obj_sonic)
	end
end

function ssd_setlight()
	wait(0)
	if not is_shades_on then
		if sonic_wave_mode == 1 then
			giveWeaponToChar(PLAYER_PED, weapons.SILVERVIBRATOR, 1)
		else
			giveWeaponToChar(PLAYER_PED, weapons.WHITEVIBRATOR, 1)
		end
	end
end

function ssd_removelight()
	is_shades_on = false -- TODO: GET GLOBAL VAR
	if not is_shades_on then
		local weapon, ammo, modelId = getCharWeaponInSlot(PLAYER_PED, 11)
		removeWeaponFromChar(PLAYER_PED, weapon)
		if has_purpledildo then
			giveWeaponToChar(PLAYER_PED, weapons.PURPLEDILDO, 1)
		end
		if sonic_wave_mode == 1 then
			giveWeaponToChar(PLAYER_PED, weapons.SHOVEL, 1)
		else
			giveWeaponToChar(PLAYER_PED, weapons.POOLCUE, 1)
		end
	end
	wait(0)
end

function get_target()
	local x, y, z = getCharCoordinates(PLAYER_PED)
	local settings = inicfg.load(nil, "DW_CUSTOM_SETTINGS")
	local len = settings.SONIC.LEN
	local found, target = findAllRandomVehiclesInSphere(x, y, z, len, 0, 1)
	if not found then
		return nil
	end
	if sonic_wave_mode == 0
	then
		target, null = storeClosestEntities(PLAYER_PED)
	end
	if isCarDead(target)
	then
		return nil
	end
	return target
end

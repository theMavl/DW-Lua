script_name("TARDIS Interior Ambience")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("TARDIS Interior ambience")

require "lib.moonloader"

local TARDIS_API = import('DW/TARDIS/TARDIS_main')
local labels = require("DW/sys/labels")
local models = require "lib.game.models"
local mad = require 'MoonAdditions'
local T_mode = labels.TARDIS_mode

local models_to_load = {
  models.LIG_BAR,
  models.LIG_ROUNDELS_P1,
  models.LIG_ROUNDELS_P2,
  models.LIG_SPOT,
  models.LIG_CORONAW,
	models.LIG_ROTATE7,

	models.LIG_ROTATE4,
	models.LIG_ROTATE4_2,
	models.LIG_ROTATE5,
	models.LIG_ROTATE4_2_D,

	models.TAR_ROTORB,
	models.TAR_ROTORM,
	models.TAR_ROTORT,
	models.LIG_ROTORB,
	models.LIG_ROTORM,
	models.LIG_ROTORT,

	models.LIG_HOLES,
	models.LIG_ROTATE6,
	models.LIG_ROTATE6_2,

	models.LIG_FLASH1, --18748
	models.LIG_FLASH2, --18749
	models.LIG_FLASH3, --18750
	models.LIG_FLASH4, --18751
	models.LIG_FLASH5, --18752
	models.LIG_ON, --18754
	models.LIG_OFF_S,
	models.LIG_ON_S,

	LIG_FLASH_SL, --18765
	LIG_FLASH_L1, --18746
	LIG_FLASH_L2, --18747

	LIG_FLASH_S1, --18766
	LIG_FLASH_S2, --18767
	LIG_FLASH_S3, --18768
}

local lig_bar = {}
local lig_roundels = {}
local lig_spot = nil
local lig_coronaW = nil
local cleanup_list = {}
local r_light_static = {}
local r_light = {}
local rotors = {}
local lig_rotors = {}
local lig_floor = {}
local lig_flash = {}
local lig_On_Off_S = {}
local lig_flash_SL = {}
local lig_flash_L = {}
local lig_flash_S = {}

function main()
  wait(0)

	for i, m in ipairs(models_to_load) do
		wait(0)
		requestModel(m)
	end

	loadAllModelsNow()
	table.insert(lig_bar, create_scripted_object(models.LIG_BAR, 0.0, 0.0, 1024.0, true, 3, true, false))
	table.insert(lig_bar, create_scripted_object(models.LIG_ROTATE7, 0.0, 0.0, 1024.0, true, 3, false, false))
	table.insert(lig_bar, create_scripted_object(models.LIG_ROTATE7, 0.0, 0.0, 1024.0, true, 3, false, false))

	table.insert(lig_roundels, create_scripted_object(models.LIG_ROUNDELS_P1, 0.0, 0.0, 1024.0, true, 3, true, false))
	table.insert(lig_roundels, create_scripted_object(models.LIG_ROUNDELS_P2, 0.0, 0.0, 1024.0, true, 3, true, false))
	setObjectQuaternion(lig_roundels[1], 0.0, 0.0, 0.0, 1.0)
	setObjectQuaternion(lig_roundels[2], 0.0, 0.0, 0.0, 1.0)

	lig_spot = create_scripted_object(models.LIG_SPOT, 0.0, 0.0, 1024.0, true, 3, true, false)
	lig_coronaW = create_scripted_object(models.LIG_CORONAW, 0.0, 0.0, 1024.0, true, 3, false, false)

	table.insert(r_light_static, create_scripted_object(models.LIG_ROTATE4, 0.0, 0.0, 1024.0, true, 3, false, false))
	table.insert(r_light_static, create_scripted_object(models.LIG_ROTATE5, 0.0, 0.0, 1024.0, true, 3, true, false))

	table.insert(r_light, create_scripted_object(models.LIG_ROTATE4_2, 0.0, 0.0, 1023.99, true, 3, false, false))
	table.insert(r_light, create_scripted_object(models.LIG_ROTATE4_2, 0.0, 0.0, 1023.99, true, 3, false, false))
	for i = 1, 4 do
		table.insert(r_light, create_scripted_object(models.LIG_ROTATE4_2_D, 0.0, 0.0, 1023.99, true, 3, false, false))
	end

	local from_model_1 = models.TAR_ROTORB
	local from_model_2 = models.LIG_ROTORB
	for i = 0, 2 do
		table.insert(rotors, create_scripted_object(from_model_1 + i, 0.0, 0.0, 1024.0, true, 3, true, false))
		table.insert(lig_rotors, create_scripted_object(from_model_2 + i, 0.0, 0.0, 1024.0, true, 3, true, false))
	end

	table.insert(lig_floor, create_scripted_object(models.LIG_HOLES, 0.0, 0.0, 1024.0, true, 3, true, false))
	table.insert(lig_floor, create_scripted_object(models.LIG_ROTATE6, 0.0, 0.0, 1024.0, true, 3, false, false))
	table.insert(lig_floor, create_scripted_object(models.LIG_ROTATE6_2, 0.0, 0.0, 1024.0, true, 3, false, false))
	table.insert(lig_floor, create_scripted_object(models.LIG_ROTATE6, 0.0, 0.0, 1024.0, true, 3, false, false))
	table.insert(lig_floor, create_scripted_object(models.LIG_ROTATE6_2, 0.0, 0.0, 1024.0, true, 3, false, false))
	setObjectHeading(lig_floor[3], -40.0)
	setObjectHeading(lig_floor[4], 200.0)
	setObjectHeading(lig_floor[5], 160.0)

	from_model_1 = models.LIG_FLASH1
	local tmp_obj
	for i = 0, 4 do
		tmp_obj = create_scripted_object(from_model_1 + i, 0.0, 0.0, 1024.0, true, 3, true, false)
		table.insert(lig_flash, tmp_obj)
		mad.set_object_model_alpha(tmp_obj, 50)
	end

	table.insert(lig_On_Off_S, create_scripted_object(models.LIG_ON_S, 0.0, 0.0, 1024.0, true, 3, true, false))
	table.insert(lig_On_Off_S, create_scripted_object(models.LIG_ON_S, 0.0, 0.0, 1024.0, true, 3, true, false))
	table.insert(lig_On_Off_S, create_scripted_object(models.LIG_OFF_S, 0.0, 0.0, 1024.0, true, 3, true, false))
	table.insert(lig_On_Off_S, create_scripted_object(models.LIG_OFF_S, 0.0, 0.0, 1024.0, true, 3, true, false))
	setObjectHeading(lig_On_Off_S[2], 160.0)
	setObjectHeading(lig_On_Off_S[4], 160.0)

	table.insert(lig_flash_SL, create_scripted_object(models.LIG_FLASH_SL, 0.0, 0.0, 1024.0, true, 3, true, false))
	table.insert(lig_flash_SL, create_scripted_object(models.LIG_FLASH_SL, 0.0, 0.0, 1024.0, true, 3, true, false))
	table.insert(lig_flash_L, create_scripted_object(models.LIG_FLASH_L1, 0.0, 0.0, 1024.0, true, 3, true, false))
	tmp_obj = create_scripted_object(models.LIG_FLASH_L2, 0.0, 0.0, 1024.0, true, 3, true, false)
	table.insert(lig_flash_L, tmp_obj)
	setObjectHeading(lig_flash_SL[2], 160.0)
	mad.set_object_model_alpha(tmp_obj, 50)

	from_model_1 = models.LIG_FLASH_S1
	for i = 0, 2 do
		tmp_obj = create_scripted_object(from_model_1 + i, 0.0, 0.0, 1024.0, true, 3, true, false)
		table.insert(lig_flash_S, tmp_obj)
		mad.set_object_model_alpha(tmp_obj, 50)
	end
	for i = 0, 2 do
		tmp_obj = create_scripted_object(models.LIG_FLASH_S1, 0.0, 0.0, 1024.0, true, 3, true, false)
		setObjectHeading(tmp_obj, 160.0)
		table.insert(lig_flash_S, tmp_obj)
	end


	for i, m in ipairs(models_to_load) do
		wait(0)
		markModelAsNoLongerNeeded(m)
	end


	lua_thread.create(lig_flash_blinking)
	lua_thread.create(lig_flash_SL_L_blinking)
	lua_thread.create(lig_flash_S_blinking)

	wait(-1)
  while true do
    wait(0)
  end
end

function lig_flash_blinking()
	math.randomseed(os.time())
	local lig_flash_n = table.getn(lig_flash)
	local prev1 = 1
	local prev2 = 1

	while true do
		if doesObjectExist(lig_flash[prev1]) then
			mad.set_object_model_alpha(lig_flash[prev1], 50)
		end
		if doesObjectExist(lig_flash[prev2]) then
			mad.set_object_model_alpha(lig_flash[prev2], 50)
		end
		n = math.random(1, lig_flash_n)
		mad.set_object_model_alpha(lig_flash[n], 255)
		prev1 = n
		n = math.random(1, lig_flash_n)
		mad.set_object_model_alpha(lig_flash[n], 255)
		prev2 = n
		wait(500)
	end
end

function lig_flash_SL_L_blinking()
	local counter = 0
	local flag = 3

	while true do
		wait(0)
			mad.set_object_model_alpha(lig_flash_SL[1], 255)
			mad.set_object_model_alpha(lig_flash_SL[2], 50)
			wait(10000)
			counter = counter + 1
			mad.set_object_model_alpha(lig_flash_SL[1], 50)
			mad.set_object_model_alpha(lig_flash_SL[2], 255)
			wait(10000)
			counter = counter + 1
			if counter >= 6 then
				counter = 0
				if flag == 4 then
					mad.set_object_model_alpha(lig_flash_L[1], 255)
					mad.set_object_model_alpha(lig_flash_L[1], 255)
					flag = 43
				elseif flag == 43 then
					mad.set_object_model_alpha(lig_flash_L[1], 255)
					mad.set_object_model_alpha(lig_flash_L[1], 50)
					flag = 3
				else
					mad.set_object_model_alpha(lig_flash_L[1], 50)
					mad.set_object_model_alpha(lig_flash_L[1], 255)
					flag = 4
				end
			end
	end
end

function lig_flash_S_blinking()
	math.randomseed(os.time())
	local lig_flash_S_n = table.getn(lig_flash_S)
	local prev = 0
	local n = 0

	while true do
		wait(0)
		while n == prev do
			wait(0)
			n = math.random(1, 3)
		end
		mad.set_object_model_alpha(lig_flash_S[n], 255)
		wait(100)
		mad.set_object_model_alpha(lig_flash_S[n], 50)
		prev = n
	end
end

function create_scripted_object(modelId, atX, atY, atZ, invulnerable, interior, visibility, collision)
  object = createObject(modelId, atX, atY, atZ)
  setObjectCoordinates(object, atX, atY, atZ)
  if invulnerable then setObjectProofs(object, true, true, true, true, true) end
  if interior ~= nil then linkObjectToInterior(object, interior) end
	if visibility == false or visibility == true then
		setObjectVisible(object, visibility)
	end
	if collision == false or collision == true then
		setObjectCollision(object, collision)
	end
	table.insert(cleanup_list, object)
  return object
end

function onScriptTerminate(s, quitGame)
	if s == script.this then
		printHelpString(string.format("Script '~p~%s~w~' crashed", script.this.name))
		print("Crash caught. Safely exiting...")
		onExitScript()
	end
end

function onExitScript(quitGame)
	for i, obj in ipairs(cleanup_list) do
		if doesObjectExist(obj) then
			deleteObject(obj)
		end
	end
end

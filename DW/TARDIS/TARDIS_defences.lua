script_name("TARDIS Defences")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("TARDIS Defences systems (Shield and HADS)")

require "lib.moonloader"

local TARDIS_API = import('DW/TARDIS/TARDIS_main')
local labels = require("DW/sys/labels")
local T_mode = labels.TARDIS_mode

local max_health = 2000
local shield_threshold = 1500
local health
local instant_inc = 10
local TARDIS
local shield_generator_enabled = true

function EXPORTS.set_shield_generator_enabled(status)
  shield_generator_enabled = status
end

function main()
  wait(0)
  repeat
    wait(0)
    TARDIS = TARDIS_API.TARDIS_ext_handle()
  until doesVehicleExist(TARDIS)
  setCarHealth(TARDIS, max_health)

  while true do
    wait(200)
    if shield_generator_enabled then
      TARDIS = TARDIS_API.TARDIS_ext_handle()
      health = getCarHealth(TARDIS)
      if getCarHealth(TARDIS) > shield_threshold then
        health = health + instant_inc
        if health > max_health then
          health = max_health
        end
				setCarHealth(TARDIS, health)
      end
    end
  end
end

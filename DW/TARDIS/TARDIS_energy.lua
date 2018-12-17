script_name("TARDIS Energy")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("TARDIS Energy system")
--[[
	This script is for TARDIS energy management.

	Usage:
	Energy consumption can be controlled by procedures provided by the interface.
	change_const_consumption(int delta) changes how much energy will be consumed constantly,
	in other words, changes the amount of maximum available energy.
	consume_once(nat energy) is to be used for actions like teleport/timetravel.
	set_generator_enabled(bool status) enables or disables the energy generator.

	TODO: Energy consumption for basic flight.

	Signals:
	Script sends energy level to the main TARDIS script. This script should not
	return it to other scripts in order to keep everything clear and consistent.
]]

require "lib.moonloader"

local TARDIS_API = import('DW/TARDIS/TARDIS_main')
local labels = require("DW/sys/labels")
local T_mode = labels.TARDIS_mode
local T_flight_mode = labels.TARDIS_flight_mode

local max_energy = 100
local energy_level
local instant_dec = 0
local instant_inc = 3
local const_dec = 0
local consume_once = 0

-- Change how much energy is consumed all the time (delta)
function EXPORTS.change_const_consumption(c_dec_delta)
  if const_dec + c_dec_delta < max_energy then
    const_dec = const_dec + c_dec_delta
  end
  if const_dec < 0 then
    const_dec = 0
  end
end

function EXPORTS.consume_once(energy)
  if energy > 0 then
    consume_once = consume_once + energy
  end
end

function EXPORTS.set_generator_enabled(status)
	if status then
		instant_inc = 3
	else
		instant_inc = 0
	end
end

function main()
  wait(0)
  while true do
    wait(1000)
		-- Basic flight consumption
		if TARDIS_API.get_flight_mode() == T_flight_mode.BASIC_FLIGHT then
			consume_once = consume_once + 4
		end
		
    energy_level = TARDIS_API.get_energy()
    energy_level = energy_level + instant_inc - instant_dec - consume_once

    consume_once = 0
    if energy_level < 0 then
      energy_level = 0
    end
    if energy_level > max_energy - const_dec then
      energy_level = max_energy - const_dec
    end
    TARDIS_API.set_energy(energy_level)
  end
end

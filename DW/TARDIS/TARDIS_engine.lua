script_name("TARDIS Engine")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("The TARDIS engine")

require "lib.moonloader"
local as_action = require('moonloader').audiostream_state
local mad = require 'MoonAdditions'

local models = require "lib.game.models"
local globals = require "lib.game.globals"
local labels = require("DW/sys/labels")

local TARDIS_API = import('DW/TARDIS/TARDIS_main.lua')

local T_mode = labels.TARDIS_mode
local T_flight_mode = labels.TARDIS_flight_mode
local T_flight_status = labels.TARDIS_flight_status
local T_player_status = labels.TARDIS_player_status

EXPORTS = {
  api_version = 1.0
}

function EXPORTS.move_TARDIS_instantly(X, Y, Z, interior, angle, lock_on_space)
	move_instantly(X, Y, Z, interior, angle, lock_on_space)
end

local TARDIS = TARDIS_API.TARDIS_ext_handle()
local TARDIS_ext_objs = TARDIS_API.TARDIS_ext_objs()

function main()
	wait(-1)
end

function move_instantly(X, Y, Z, interior, angle, lock_on_space)
	TARDIS = TARDIS_API.TARDIS_ext_handle()
	ext_pos = TARDIS_API.TARDIS_ext_pos()
	setVehicleInterior(TARDIS, interior)
	disableHeliAudio(TARDIS, false)
	setCarCoordinates(TARDIS, X, Y, Z)
	if angle ~= nil then
		setCarHeading(TARDIS, angle)
		ext_pos.angle = angle
	end
	freezeCarPositionAndDontLoadCollision(TARDIS, lock_on_space)
	ext_pos.X = X
	ext_pos.Y = Y
	ext_pos.Z = Z
	ext_pos.inte = interior
end

function dematerialize()
end

function materialize()
end

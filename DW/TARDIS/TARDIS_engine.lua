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

local TARDIS_API = import('DW/TARDIS/TARDIS_main')

local ext_fade = import('DW/TARDIS/misc/TARDIS_ext_fade')

local T_mode = labels.TARDIS_mode
local T_flight_mode = labels.TARDIS_flight_mode
local T_flight_status = labels.TARDIS_flight_status
local T_player_status = labels.TARDIS_player_status
local engine_command = nil
local demat_break = false

EXPORTS = {
  api_version = 1.0
}

function EXPORTS.move_TARDIS_instantly(X, Y, Z, interior, angle, lock_on_space)
	move_instantly(X, Y, Z, interior, angle, lock_on_space)
end

function EXPORTS.teleport()
	engine_command = 1
end

local TARDIS = TARDIS_API.TARDIS_ext_handle()
local TARDIS_ext_objs = TARDIS_API.TARDIS_ext_objs()

function main()
	while true do
		wait(0)
		if engine_command == 1 then
			TARDIS_API.set_flight_mode = T_flight_mode.NORMAL_FLIGHT
			TARDIS_API.set_flight_status = T_flight_status.DEMATERIALISING
			destination = TARDIS_API.get_destination()
			dX = destination.X
			dY = destination.Y
			dZ = destination.Z
			dInt = destination.interior
			dAng = destination.angle

			-- X, Y, Z = getOffsetFromCharInWorldCoords(PLAYER_PED, 0.0, 9.8, 0.0)
			local mat_sfx = load3dAudioStream("DWS/out_mat.mp3")

			setPlay3dAudioStreamAtCoordinates(mat_sfx, dX, dY, dZ)
			local demat_sfx = load3dAudioStream("DWS/out_demat.mp3")
			setPlay3dAudioStreamAtCar(demat_sfx, TARDIS_API.TARDIS_ext_handle())

			setAudioStreamState(mat_sfx, as_action.PLAY)
			setAudioStreamState(demat_sfx, as_action.PLAY)
			wait(3500)

			perform_dematerialization()

			local posX, posY, posZ = getCarCoordinates(TARDIS_API.TARDIS_ext_handle())
			setPlay3dAudioStreamAtCoordinates(demat_sfx, posX, posY, posZ)

			move_instantly(dX, dY, dZ, dInt, dAng, true)

			setPlay3dAudioStreamAtCar(mat_sfx, TARDIS_API.TARDIS_ext_handle())

			TARDIS_API.set_flight_status = T_flight_status.MATERIALISING
			perform_materialization()

			TARDIS_API.set_flight_mode = T_flight_mode.IDLE
			TARDIS_API.set_flight_status = T_flight_status.IDLE
			engine_command = 0

			repeat
				wait(0)
			until getAudioStreamState(mat_sfx) == -1 and getAudioStreamState(demat_sfx) == -1
			releaseAudioStream(mat_sfx)
			releaseAudioStream(demat_sfx)			
		end
	end
end

function move_instantly(X, Y, Z, interior, angle, lock_on_space)
	TARDIS = TARDIS_API.TARDIS_ext_handle()
	setVehicleInterior(TARDIS, interior)
	disableHeliAudio(TARDIS, false)
	setCarCoordinates(TARDIS, X, Y, Z)
	if angle ~= nil then
		setCarHeading(TARDIS, angle)
	end
	freezeCarPositionAndDontLoadCollision(TARDIS, lock_on_space)
	TARDIS_API.set_ext_pos(X, Y, Z, interior, angle, nil)
end

function perform_dematerialization()
	ext_fade.demat()
	repeat
		wait(0)
		stage, total = ext_fade.get_progress()
	until stage == -1
	print("Demat done!")
end

function perform_materialization()
	ext_fade.mat()
	repeat
		wait(0)
		stage, total = ext_fade.get_progress()
	until stage == -1
	print("Mat done!")
end

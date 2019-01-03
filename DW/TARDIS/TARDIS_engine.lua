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
local ext_toplight = import('DW/TARDIS/misc/TARDIS_ext_toplight')

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

function EXPORTS.summon()
	engine_command = 2
end

local TARDIS = TARDIS_API.TARDIS_ext_handle()
local TARDIS_ext_objs = TARDIS_API.TARDIS_ext_objs()

function main()
	while true do
		wait(0)
		if engine_command == 1 or engine_command == 2 then
			-- Normal teleport or summoning
			if not TARDIS_API.check_close_ext_doors() then
				while not TARDIS_API.are_doors_closed() do
					wait(0)
				end
			end
			if engine_command == 2 then
				local tX, tY, tZ = getOffsetFromCharInWorldCoords(PLAYER_PED, 0.0, 9.8, 0.0)
				TARDIS_API.set_destination(tX, tY, tZ, getActiveInterior(), nil, nil)
				dX = tX
				dY = tY
				dZ = tZ
				dInt = getActiveInterior()
				dAng = nil
				TARDIS_API.set_flight_mode(T_flight_mode.NORMAL_FLIGHT)
				TARDIS_API.set_mode(T_mode.SUMMONING)
				TARDIS_API.set_flight_status(T_flight_status.MATERIALISING)
			else
				destination = TARDIS_API.get_destination()
				dX = destination.X
				dY = destination.Y
				dZ = destination.Z
				dInt = destination.interior
				dAng = destination.angle
				TARDIS_API.set_flight_mode(T_flight_mode.NORMAL_FLIGHT)
				TARDIS_API.set_flight_status(T_flight_status.DEMATERIALISING)
			end

			-- X, Y, Z = getOffsetFromCharInWorldCoords(PLAYER_PED, 0.0, 9.8, 0.0)
			local mat_sfx = load3dAudioStream("DWS/out_mat.mp3")
			setPlay3dAudioStreamAtCoordinates(mat_sfx, dX, dY, dZ)
			setAudioStreamState(mat_sfx, as_action.PLAY)

			local demat_sfx
			if engine_command ~= 2 then
				demat_sfx = load3dAudioStream("DWS/out_demat.mp3")
				setPlay3dAudioStreamAtCar(demat_sfx, TARDIS_API.TARDIS_ext_handle())
				setAudioStreamState(demat_sfx, as_action.PLAY)
			end

			if engine_command ~= 2 then
				ext_toplight.enable_normal()
				wait(3500)
				perform_dematerialization()
				local posX, posY, posZ = getCarCoordinates(TARDIS_API.TARDIS_ext_handle())
				setPlay3dAudioStreamAtCoordinates(demat_sfx, posX, posY, posZ)
				move_instantly(dX, dY, dZ, dInt, dAng, true)
			elseif engine_command == 2 then
				--[[
				If summoning, we skip dematerialisation and move TARDIS to landing spot
				instantly, in order to show ext_toplight floating in the sky.
				For that purpose, we need to hide all TARDIS's objects by
				set_TARDIS_invisible()
				]]
				wait(7500)
				TARDIS_API.set_TARDIS_invisible()
				ext_toplight.enable_normal()
				move_instantly(dX, dY, dZ, dInt, dAng, true)
				wait(2700)
			end

			setPlay3dAudioStreamAtCar(mat_sfx, TARDIS_API.TARDIS_ext_handle())

			TARDIS_API.set_flight_status(T_flight_status.MATERIALISING)
			perform_materialization()

			TARDIS_API.set_flight_mode(T_flight_mode.IDLE)
			TARDIS_API.set_flight_status(T_flight_status.IDLE)
			if engine_command == 2 then
				TARDIS_API.set_mode(T_mode.NORMAL)
			end

			if engine_command == 2 then
				repeat
					wait(0)
				until getAudioStreamState(mat_sfx) == -1
				releaseAudioStream(mat_sfx)
			else
				repeat
					wait(0)
				until getAudioStreamState(mat_sfx) == -1 and getAudioStreamState(demat_sfx) == -1
				releaseAudioStream(mat_sfx)
				releaseAudioStream(demat_sfx)
			end

			engine_command = 0
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
	if TARDIS_API.get_player_status() == T_player_status.OUTSIDE then
		setCarCollision(TARDIS_API.TARDIS_ext_handle(), false)
	end
	repeat
		wait(0)
		stage, total = ext_fade.get_progress()
	until stage == -1
	setCarCollision(TARDIS_API.TARDIS_ext_handle(), true)
	ext_toplight.disable()
	print("Mat done!")
end

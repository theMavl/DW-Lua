-------------- TARDIS labels --------------
local TARDIS_doors_action = {
	CLOSING = -1,
	IDLE = 0,
	OPENING = 1
}

local TARDIS_mode = {
	NORMAL = 0,
	SUMMONING = 1,
	SHUTDOWN = 2,
	EMERGENCY = 3,
	DRIFTED = 4
}

local TARDIS_flight_mode = {
	IDLE = 0,
	BASIC_FLIGHT = 1,
	FAST_FLIGHT = 2,
	NORMAL_FLIGHT = 3,
	LONG_FLIGHT = 4
}

local TARDIS_flight_status = {
	IDLE = 0,
	LAUNCHING = 1,
	DEMATERIALISING = 2,
	IN_FLIGHT = 3,
	IN_VORTEX = 4,
	MATERIALISING = 5,
	FAIL_LAUNCH = 6
}

local TARDIS_player_status = {
	OUTSIDE = 0,
	IN_INTERIOR = 1,
	EXTERIOR_VIEW = 2
}

local TARDIS_ext_fade_mode = {
	IDLE = 0,
	DEMATERIALISING = 1,
	MATERIALISING = 2
}

-------------- Sonic labels --------------
local Sonic_HUD_mode = {
	OFF = 0,
	VEHICLE_SEEKER = 1,
	CROSSHAIR = 2
}

local Sonic_device = {
	NONE = 0,
	SHADES = 1,
	ELEVENTH = 11,
	TWELFTH = 12
}


return {
	TARDIS_doors_action = TARDIS_doors_action,
	TARDIS_mode = TARDIS_mode,
	TARDIS_flight_mode = TARDIS_flight_mode,
	TARDIS_flight_status = TARDIS_flight_status,
	TARDIS_player_status = TARDIS_player_status,
	TARDIS_ext_fade_mode = TARDIS_ext_fade_mode,

	Sonic_HUD_mode = Sonic_HUD_mode,
	Sonic_device = Sonic_device
}

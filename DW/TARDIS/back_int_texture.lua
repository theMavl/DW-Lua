script_name("Interior Texture")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("Show the interior texture on TARDIS shell if doors are opened")

require "lib.moonloader"
local TARDIS_API = import('DW/TARDIS/TARDIS_main')
local hide_always = false
local texture_visible = false

function EXPORTS.set_hide_always(status)
	hide_always = status
end

function main()
  TARDIS = TARDIS_API.TARDIS_ext_handle()
	back_texture = TARDIS_API.TARDIS_ext_objs()[4]

	local light = lua_thread.create_suspended(int_light)

	while (true) do
		wait(0)
		if not hide_always then
			local angle_left = math.abs(getDoorAngleRatio(TARDIS, 3))
			local angle_right = math.abs(getDoorAngleRatio(TARDIS, 2))
			if angle_left ~= 0.0 or angle_right ~= 0.0 then
				if not texture_visible then
					setObjectVisible(back_texture, true)
					texture_visible = true
					light:run()
				end
			else
				if texture_visible then
					setObjectVisible(back_texture, false)
					texture_visible = false
					light:terminate()
				end
			end
		else
			if texture_visible then
				setObjectVisible(back_texture, false)
				texture_visible = false
				light:terminate()
			end
		end
	end
end

function int_light()
	local X, Y, Z
	while true do
		wait(0)
		 X, Y, Z = getCarCoordinates(TARDIS)
		drawLightWithRange(X, Y, Z, 205, 55, 0, 2.0)
	end
end

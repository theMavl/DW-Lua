script_name("console_teleporter")
script_author("Mavl Pond")

require "lib.moonloader"
local vkeys = require "lib.vkeys"

function main()
	while true do
	  wait(0)
	  if wasKeyPressed(vkeys.VK_TAB) then
			setCurrentCharWeapon(PLAYER_PED, 0)
			setInteriorVisible(3)
			setCharInterior(PLAYER_PED, 3)
			setCharCoordinatesDontWarpGangNoOffset(PLAYER_PED, 1.2393, 1.929, 1023.8347)
			setExtraColours(11, false)
		end
	end
end

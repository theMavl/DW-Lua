script_name("debug_main")
script_author("Mavl Pond")

require "lib.moonloader"

function main()
	while true do
		wait(0)
 		if testCheat("do1") then
			script.load("DW/debug/debug1.lua")
		elseif testCheat("doo2") then
			script.load("DW/debug/debug2.lua")
		end
	end
end

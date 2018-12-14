script_name("TARDIS Ext Fade")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("TARDIS Exterior fade effects")

require "lib.moonloader"
local mad = require 'MoonAdditions'

local TARDIS_API = import('DW/TARDIS/TARDIS_main')
local labels = require("DW/sys/labels")
local T_mode = labels.TARDIS_mode

local fade_sequences = {
  mat = {
    {1, 50, 1383},
    {50, 10, 774},
    {10, 60, 1097},
    {60, 30, 678},
    {30, 80, 839},
    {80, 30, 903},
    {30, 90, 1063},
    {90, 40, 744},
    {40, 100, 1226}
  },

  tnormal_1 = {
    {100, 40, 932},
    {40, 80, 540},
    {80, 30, 1102},
    {30, 70, 740},
    {70, 30, 1000},
    {30, 60, 751},
    {60, 20, 1082},
    {20, 1, 546}
  },

  tnormal_2 = {
    {1, 50, 1383},
    {50, 10, 774},
    {10, 60, 1097},
    {60, 30, 678},
    {30, 80, 839},
    {80, 30, 903},
    {30, 90, 1063},
    {90, 40, 744},
    {40, 100, 1226}
  },

  demat = {
    {100, 40, 932},
    {40, 80, 540},
    {80, 30, 1102},
    {30, 70, 740},
    {70, 30, 1000},
    {30, 60, 751},
    {60, 20, 1082},
    {20, 1, 546}
  },

  tshort_1 = {
    {100, 20, 974},
    {20, 50, 633},
    {50, 10, 1101}
  },

  tshort_2 = {
    {10, 70, 689},
    {70, 30, 1000},
    {30, 100, 1271}
  },

  crash1 = {
    {100, 50, 194},
    {50, 95, 182},
    {95, 45, 146},
    {45, 90, 158},
    {90, 40, 158},
    {40, 85, 352},
    {85, 35, 289},
    {35, 80, 244},
    {80, 30, 279},
    {30, 75, 348},
    {75, 25, 146},
    {25, 70, 678},
    {70, 20, 443},
    {20, 65, 342},
    {65, 15, 270},
    {15, 65, 296},
    {65, 25, 331},
    {25, 80, 792},
    {80, 55, 1167},
    {55, 100, 920}
  },

  crash2 = {
    {100, 20, 522},
    {80, 10, 267},
    {10, 70, 859},
    {70, 5, 557},
    {5, 60, 1010},
    {60, 20, 639},
    {20, 0, 1074}
  },

  crash2m = {
    {1, 45, 800},
    {45, 0, 300},
    {0, 0, 312},
    {0, 90, 212},
    {90, 0, 372},
    {0, 50, 300},
    {0, 0, 200},
    {0, 0, 200},
    {1, 50, 200},
    {1, 60, 372},
    {60, 5, 872},
    {5, 80, 1645},
    {1, 50, 500},
    {1, 50, 500},
    {1, 100, 900}
  },

  hadsdem = {
    {100, 20, 702},
    {20, 80, 593},
    {80, 10, 947},
    {10, 70, 752},
    {70, 1, 1183}
  },

  matshort = {
    {1, 50, 837},
    {50, 30, 805},
    {30, 100, 1164}
  },

  cloak = {
    {1, 90, 1000}
  },

  cloak2 = {
    {90, 1, 1000}
  },

  fland = {
    {100, 1, 700},
    {1, 100, 300}
  },
}

function EXPORTS.doo()
  lua_thread.create(fade, fade_sequences.mat)
end

function main()
  wait(0)
  while true do
    wait(0)
  end
end

function fade(sequence)
	doorl = TARDIS_API.TARDIS_ext_objs()[0]
	doorr = TARDIS_API.TARDIS_ext_objs()[1]
	main = TARDIS_API.TARDIS_ext_objs()[3]
	nvc_visible = true

  tfade = TARDIS_API.TARDIS_ext_objs()[5]
  TARDIS = TARDIS_API.TARDIS_ext_handle()

  for i, s in ipairs(sequence) do
    from = s[1]
    to = s[2]
    time_limit = s[3]
		-- Visible range: 100-255
    from = from * 1.55 + 100
    to = to * 1.55 + 100
    setCarVisible(TARDIS, false)
    setObjectVisible(tfade, true)
		start = os.clock() * 1000
    repeat
      time = os.clock() * 1000 - start
      alpha = math.floor((to - from) / time_limit * time + from)
			if alpha > 255 then alpha = 255 end
			if alpha < 100 then
				if s[2] == 0 then alpha = 100 else alpha = 101 end
			end
			if nvc_visible and alpha == 100 then
				setObjectVisible(doorl, false)
				setObjectVisible(doorr, false)
				setObjectVisible(main, false)
				nvc_visible = false
			elseif not nvc_visible and alpha > 100 then
				setObjectVisible(doorl, true)
				setObjectVisible(doorr, true)
				setObjectVisible(main, true)
				nvc_visible = true
			end
			mad.set_object_model_alpha(tfade, alpha)
			wait(0)
    until time >= time_limit
  end
end

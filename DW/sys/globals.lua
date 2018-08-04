script_name("DW_globals")
script_author("Mavl Pond")
script_version("1.0")
script_version_number(1)
script_description("Storage for global variables")

local globals = {}

function EXPORTS.set(varname, value)
  globals[varname] = value
end

function EXPORTS.get(varname)
  return globals[varname]
end

function EXPORTS.dump()
	local dump = "\n-- Global variables dump --\n"
  for k,v in pairs(globals) do
		dump = dump..string.format("%s = %s\n", k, v)
	end
	print(dump)
end

function EXPORTS.flush()
	flush()
end

function flush()
	globals = {
		["IS_TIMELORD"]=true,
		["IN_TINTERIOR"]=false,
		["TARDIS_DRIFTED"]=false,
		["IS_REGENERATING"]=false
	}
end

function main()
	flush()
	wait(-1)
end

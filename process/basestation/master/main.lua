require "utils.tableutils"
require "sys.tick"
local console 		= require "sys.console"
core				= require "sys.core"

local slaveconn		= require "slaveconn"
local authmgr		= require "authmgr"

console {
	addr =  ":"..core.envget("admin_port")
}
core.start(function()
	local loglevel 	= tonumber(core.envget("log_level"))
	local logdefault= tonumber(core.envget("log_default"))
	core.debug(1, "set debug level to ".. loglevel ..", log default flag:"..logdefault)
	core.debuglevel(loglevel, logdefault)
	slaveconn:listen()

end)


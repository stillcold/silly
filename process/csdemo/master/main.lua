require "utils.tableutils"
require "sys.tick"
local console 		= require "sys.console"
core				= require "sys.core"

local slaveConn		= require "slaveConn"
local rpcHandleDef	= require "Slave2Master"
local rpcSenderDef	= require "Master2Slave"

console {
	addr =  ":"..core.envget("admin_port")
}
core.start(function()
	core.debuglevel(1, -1)
	-- core.debuglevel(1)
	core.debug(0, "check debug out")
	core.debug(1, "debug level 1")
	core.debug(2, "debug level 2")
	core.debug("default debug")
	slaveConn:Listen()

	RegisterTick(function()
		local conn = slaveConn:GetClientConnById(1)
		if conn then
			Master2Slave:Test(conn, {testSendMaster2Slave = "hahaha"})
		end
	end, 5 * 1000)
end)


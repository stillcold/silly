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
	local logLv 	= tonumber(core.envget("log_level"))
	local logDefault= tonumber(core.envget("log_default"))
	core.debug(1, "set debug level to ".. logLv ..", log default flag:"..logDefault)
	core.debuglevel(logLv, logDefault)
	slaveConn:Listen()

	RegisterTick(function()
		local conn = slaveConn:GetClientConnById(1)
		if conn then
			Master2Slave:Test(conn, {testSendMaster2Slave = "hahaha"})
		end
	end, 5 * 1000)
end)


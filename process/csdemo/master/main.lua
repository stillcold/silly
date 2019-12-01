require "utils.tableutils"
require "sys.tick"
local console 		= require "sys.console"
local core			= require "sys.core"

local slaveConn		= require "slaveConn"
local rpcHandleDef	= require "Slave2Master"
local rpcSenderDef	= require "Master2Slave"

console {
	addr =  ":"..core.envget("admin_port")
}
core.start(function()
	slaveConn:Listen()

	RegisterTick(function()
		local conn = slaveConn:GetClientConnById(1)
		if conn then
			Master2Slave:Test(conn, {testSendMaster2Slave = "hahaha"})
		end
	end, 5 * 1000)
end)


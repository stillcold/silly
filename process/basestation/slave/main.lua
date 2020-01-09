require "sys.tick"
require "utils.tableutils"
core 				= require "sys.core"
local masterConn 	= require "masterConn"
require "reciever"

function GetMasterConn()
	-- This result maybe nil!!
	return masterConn:GetServerConn()
end


core.start(function()
	local logLv 	= tonumber(core.envget("log_level"))
	local logDefault= tonumber(core.envget("log_default"))
	core.debug(1, "set debug level to ".. logLv ..", log default flag:"..logDefault)
	core.debuglevel(logLv, logDefault)
	masterConn:Connect()

	RegisterTick(function()
		Slave2Master:Test(GetMasterConn(), 100, "send to server", {hello = "world"})
	end, 10 * 1000)
end)


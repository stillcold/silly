require "sys.tick"
require "utils.tableutils"
core 				= require "sys.core"
local masterConn 	= require "masterConn"
require "reciever"

function GetMasterConn()
	return masterConn:GetServerConn()
end


core.start(function()
	local logLv 	= tonumber(core.envget("log_level"))
	local logDefault= tonumber(core.envget("log_default"))
	core.debug(1, "set debug level to ".. logLv ..", log default flag:"..logDefault)
	core.debuglevel(logLv, logDefault)
	if not masterConn:Connect() then
		core.exit()
		return
	end
	Slave2Master:Test(GetMasterConn(), 100, "send to server", {hello = "world"})
end)


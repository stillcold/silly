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
	masterConn:Connect()

	RegisterTick(function()
		local ret = Slave2Master:Test(GetMasterConn(), 100, "send to server", {hello = "world"})
		core.debug(1, "ret from server", ret)
	end, 10 * 1000)
end)


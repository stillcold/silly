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
	core.debuglevel(1, -1)
	masterConn:Connect()

	RegisterTick(function()
		Slave2Master:Test(GetMasterConn(), 100, "send to server", {hello = "world"})
	end, 10 * 1000)
end)


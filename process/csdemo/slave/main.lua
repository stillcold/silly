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
	if not masterConn:Connect() then
		core.debug(1, "connect server fail, app will quit")
		core.exit()
		return
	end

	core.debuglevel(1, -1)
	local count = 0

	RegisterTick(function()
		count = count + 1
		if count >= 2 then
			core.debug(1, "test close connection automaticly.")
			masterConn:Close()
			core.exit()
			return
		end

		core.debug(1, "master conn is", GetMasterConn())
		Slave2Master:Test(GetMasterConn(), 100, "send to server", {hello = "world"})
	end, 3 * 1000)
end)


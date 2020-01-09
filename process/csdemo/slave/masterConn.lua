local core			= require "sys.core"

local client		= require "saux.client"
local rpcHandleDef	= require "Master2Slave"
local rpcSenderDef	= require "Slave2Master"

local host = core.envget "service_host"
local port = core.envget "service_port"

local onClose = function(fd, addr, errno)
	core.debug(1, "on mater closed app will quit", fd, addr, errno)
	core.exit()
end

client:Init(host, port, rpcHandleDef, rpcSenderDef, onClose)

return client

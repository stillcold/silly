local core			= require "sys.core"

local client		= require "saux.client"
local rpcHandleDef	= require "Master2Slave"
local rpcSenderDef	= require "Slave2Master"

local host = core.envget "master_host"
local port = core.envget "master_listen_port"

local onClose = function(fd, addr, errno)
	core.debug(1, "on mater closed", fd, addr, errno)
end

client:Init(host, port, rpcHandleDef, rpcSenderDef, onClose)

return client

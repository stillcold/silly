local core			= require "sys.core"

local client		= require "saux.client"
local rpcHandleDef	= require "Master2Slave"
local rpcSenderDef	= require "Slave2Master"

local host = core.envget "service_host"
local port = core.envget "service_port"

client:Init(host, port, rpcHandleDef, rpcSenderDef)

return client

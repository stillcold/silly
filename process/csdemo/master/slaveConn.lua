local core			= require "sys.core"
local server		= require "saux.server"
local rpcHandleDef	= require "Slave2Master"
local rpcSenderDef	= require "Master2Slave"
require "dispatch"
local ip = core.envget "server_ip"
local port = core.envget "server_port"

server:Init(ip, port, rpcHandleDef, rpcSenderDef)

return server

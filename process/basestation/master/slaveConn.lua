local core			= require "sys.core"
local server		= require "saux.server"
local rpcHandleDef	= require "Slave2Master"
local rpcSenderDef	= require "Master2Slave"
require "dispatch"
local ip = core.envget "master_listen_ip"
local port = core.envget "master_listen_port"

core.debug("server bind ".. ip .. ":" .. port)
server:Init(ip, port, rpcHandleDef, rpcSenderDef)

return server

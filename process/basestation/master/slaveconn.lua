local core			= require "sys.core"
local server		= require "saux.server"
local rpchandledef	= require "slave2master"
local rpcsenderdef	= require "master2slave"
require "dispatch"
local ip = core.envget "master_listen_ip"
local port = core.envget "master_listen_port"

core.debug("server bind ".. ip .. ":" .. port)
local function onaccept(clientid, fd, addr)
	print("accept", clientid, fd, addr)
end

local function onclose(clientid, fd, addr, errno)
	print("closed", clientid, fd, addr, errno)
end

server:init(ip, port, rpchandledef, rpcsenderdef, onaccept, onclose)

return server

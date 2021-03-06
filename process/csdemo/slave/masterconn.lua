local core			= require "sys.core"

local client		= require "saux.client"
local rpchandledef	= require "master2slave"
local rpcsenderdef	= require "slave2master"

local host = core.envget "service_host"
local port = core.envget "service_port"

local onclose = function(fd, addr, errno)
	core.debug(1, "on mater closed app will quit", fd, addr, errno)
	core.exit()
end

client:init(host, port, rpchandledef, rpcsenderdef, onclose)

return client

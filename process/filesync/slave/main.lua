require "SAConfig"

local core 		= require "sys.core"
local rpc 		= require "saux.rpc"
local rpcproto = require "rpcproto"
print(lfs.currentdir())

rpcclient = rpc.createclient {
	addr = core.envget "service_addr",
	proto = rpcproto,
	timeout = 5000,
	close = function(fd, errno)
		core.log("close", fd, errno)
	end
}

core.start(function()
	local ok = rpcclient:connect()
	core.log("rpc connect status", ok)
	assert(ok)
	rpcclient:call("rrpc_sum", {val1 = 1, val2 = 2, suffix = "test"})

end)


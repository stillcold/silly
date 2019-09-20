require "SAConfig"

local core 		= require "sys.core"
local rpc 		= require "saux.rpc"
local rpcproto = require "rpcproto"
local dns = require "sys.dns"

local host = core.envget "service_host"
local port = core.envget "service_port"

g_RpcClient = nil

print(lfs.currentdir())

core.start(function()
	
	-- 转成IPV4格式的ip地址
	local ip = dns.resolve(host, "A")
	print("ip is", ip)

	g_RpcClient = rpc.createclient {
		addr = ip..":"..port,
		proto = rpcproto,
		timeout = 5000,
		close = function(fd, errno)
			core.log("close", fd, errno)
		end
	}


	local ok = rpcclient:connect()
	core.log("rpc connect status", ok)
	assert(ok)
	g_RpcClient:call("rrpc_sum", {val1 = 1, val2 = 2, suffix = "test"})

end)


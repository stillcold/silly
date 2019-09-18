require "SAConfig"

local console 	= require "sys.console"
local core 		= require "sys.core"
local proto = require "rpcproto"
local rpc 		= require "saux.rpc"

require "Slave2Master"

local handle = {}
for funcName,func in pairs(Slave2Master) do
	print(funcName, proto:tag(funcName))
	handle[proto:tag(funcName)] = func
end

print(lfs.currentdir())

local server = rpc.createserver {
	addr = core.envget "service_addr",
	-- addr = "127.0.0.1:9002",
	proto = proto,
	accept = function(fd, addr)
		print("accept", addr)
		core.log("accept", fd, addr)
	end,
	close = function(fd, errno)
		core.log("close", fd, errno)
	end,
	call = function(fd, cmd, msg)
		print("call in", cmd, msg)
		handle[cmd](Slave2Master, fd, msg)
		-- return assert(Slave2Master[cmd])(fd, cmd, msg)
	end,
}

local ok = server:listen()
core.log("rpc server start:", ok)

addr = core.envget ("service_addr")
print("addr", addr)

console {
	addr =  ":"..core.envget("admin_port")
}

require "SAConfig"

local console 	= require "sys.console"
local core 		= quire "sys.core"
local rpc 		= require "saux.rpc"


-- local Handle = require "Slave2Master"

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
		return assert(DO[cmd])(fd, cmd, msg)
	end,
}

local ok = server:listen()
core.log("rpc server start:", ok)

addr = core.envget ("service_port")
print("addr", addr)

console {
	addr =  ":"..core.envget("admin_port")
}

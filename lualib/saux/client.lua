local core		= require "sys.core"
local rpc		= require "saux.rpc"
local rpcproto	= require "saux.xproto"
local dns		= require "sys.dns"
local serialize	= require "sys.serialize"
local rpcDef	= require "saux.rpcDef"

local Client 	= {
	m_Server = nil
}

local rpcClient

-- global function like GetServerConn can be define somewhere.
function Client:GetServerConn()
	return nil
end

function Client:Init(host, port, rpcHandleDef, rpcSenderDef)
	local ip = dns.resolve(host, "A")

	local rpcHandle = rpcDef:InitRpcHandle(rpcHandleDef)

	rpcClient	= rpc.createclient{
		addr	= ip..":"..port,

		proto	= rpcproto,

		timeout	= 5000,

		call	= function(fd, cmd, msg)
			core.debug(0, "rpc call in", fd, cmd, msg)
			return rpcHandle["rpc"](fd, cmd, msg)
		end,

		close	= function(fd, errno)
			core.debug(1, "connection closed ", fd, errno)
		end,
	}

	local bServer = false
	rpcDef:AttachRpcSender(rpcSenderDef, rpcClient, bServer)

	return rpcClient
end

function Client:Connect()
	local ok = rpcClient:connect()
	print("client connect result:", ok)
	return ok
end

return Client

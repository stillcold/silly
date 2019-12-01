local console	= require "sys.console"
local core		= require "sys.core"
local proto		= require "saux.xproto"
local rpc		= require "saux.rpc"
local rpcDef	= require "saux.rpcDef"

require "sys.serialize"

local Server = {
	m_RpcServer		= nil,
	m_ClientId2Conn = {},
	m_ClientId2Addr = {},
}

local rpcServer

function Server:GenClientId()
	for i = 1, 2^32 - 1 do
		if not self.m_ClientId2Conn[i] then
			return i
		end
	end
	
end

-- This function is very slow, do not use it frequenly.
function Server:GetClientIdByConn(conn)
	for k,v in pairs(self.m_ClientId2Conn) do
		if v == conn then
			return k
		end
	end
end

function Server:GetClientConnById(id)
	return self.m_ClientId2Conn[id]
end

function Server:GetClientAddrById(id)
	return self.m_ClientId2Addr[id]
end

function Server:CleanClientInfo(id)
	self.m_ClientId2Conn[id] = nil
	self.m_ClientId2Addr[id] = nil
end

function Server:Init(ip, port, rpcHandleDef, rpcSenderDef)

	local rpcHandle = rpcDef:InitRpcHandle(rpcHandleDef)

	rpcServer 	= rpc.createserver{
		addr    = ip..":"..port,
		proto   = proto,
		
		accept  = function(fd, addr)
			core.log("accept", fd, addr)

			local clientId = self:GenClientId()

			self.m_ClientId2Conn[clientId] = fd
			self.m_ClientId2Addr[clientId] = addr
		end,

		close   = function(fd, errno)
			core.log("connection closed ", fd, errno)
			
			local clientId = self:GetClientIdByConn(fd)
			if clientId then
				local addr = self:GetClientAddrById(clientId)
				core.log("clean client info on close id="..clientId..
					", fd=".. fd..", addr=".. addr..", error="..errno)
				self:CleanClientInfo(clientId)
			end
		end,

		call	= function(fd, cmd, msg)
			return rpcHandle["rpc"](fd, cmd, msg)
		end,
	}
	local bServer = true
	rpcDef:AttachRpcSender(rpcSenderDef, rpcServer, bServer)
	self.m_RpcServer = rpcServer
	return rpcServer
end

function Server:Listen()
	local ok = self.m_RpcServer:listen()
	core.log("server start result: ", ok)
	return ok
end

return Server

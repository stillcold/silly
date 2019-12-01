require "sys.serialize"
local core = require "sys.core"
local RpcDef = {}

local TypeMap = {
	I	= "number",
	T	= "table",
	S	= "string",
}

function RpcDef:GetRealType(simpleType)
	return TypeMap[simpleType]
end

function RpcDef:InitRpcHandle(rpcHandleDef)
	local handle 		= rpcHandleDef[1]
	local funcDef		= rpcHandleDef[2]

	local dispatcher	= {}

	local handleDesc	= {}

	for i, def in ipairs(funcDef) do
		local rpcName 		= def[1]
		local argTypeList 	= def[2]
		handleDesc [rpcName] = argTypeList
	end

	dispatcher["rpc"] = function(fd, cmd, msg)

		local args 		= unserialize(msg.content)
		if not args then
			return
		end

		local rpcName 	= args[1]
		if not rpcName then
			core.log("no rpcname found in msg", msg)
			return
		end
		local definedTypeList = handleDesc[rpcName]
		if not definedTypeList then
			core.log("no define found", rpcName)
			return
		end
		if not handle[rpcName] then
			core.log("no handle found", rpcName)
			return
		end
		if not self:CheckRpcArgs(args, definedTypeList) then
			return
		end
		local argc = #args - 1
		local ret = handle[rpcName](handle, fd, table.unpack(args, 2, argc + 1))
		return "rpc", {content = ret}
	end

	return dispatcher
end

function RpcDef:CheckRpcArgs(args, definedTypeList)
	local argc = #args - 1
	if argc ~= #definedTypeList then
		core.log("arg count mismatch", argc, #definedTypeList)
		return
	end
	for argIdx = 1,argc do
		local simpleType = string.sub(definedTypeList, argIdx, argIdx)
		local definedType = self:GetRealType(simpleType)
		if definedType ~= type(args[argIdx+1]) then
			core.log("arg type mismatch", rpcName)
			return
		end
	end
	return true
end

function RpcDef:AttachRpcSender(rpcSenderDef, rpcInstance, bServer)
	local handle 		= rpcSenderDef[1]
	local funcDef		= rpcSenderDef[2]

	local dispatcher	= {}

	local handleDesc	= {}
	for i, def in ipairs(funcDef) do
		local rpcName 		= def[1]
		local argTypeList 	= def[2]
		if bServer then
			handle[rpcName] = function(handle, fd, ...)
				local args = {rpcName, ...}
				local content = serialize(args)
				if not RpcDef:CheckRpcArgs(args, argTypeList) then
					return
				end
				local ack = rpcInstance:call(fd, "rpc", {content = content})
				if ack and ack.content then
					return ack.content
				end
			end
		else
			handle[rpcName] = function(handle, fd, ...)
				local args = {rpcName, ...}
				local content = serialize(args)
				if not RpcDef:CheckRpcArgs(args, argTypeList) then
					return
				end
				local ack = rpcInstance:call("rpc", {content = content})
				if ack and ack.content then
					return ack.content
				end
			end
		end
	end
end

return RpcDef

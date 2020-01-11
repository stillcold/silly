local crypt = require "sys.crypt"

local authmgr = {
	authed_client 	= {},
}

function authmgr:is_auth_client(clientid)
	return self.authed_client[clientid] and true or false
end

function authmgr:record_auth_client(clientid)
	self.authed_client[clientid] = os.time()
end

function slave2master:auth(fd, cryptstr, authcode)
	local authsalt  = core.envget("auth_salt")
	local decoded	= crypt.aesdecode(authsalt, cryptstr)
	if decoded == authcode then
		core.debug(2, "auth code")
	end
end

return authmgr

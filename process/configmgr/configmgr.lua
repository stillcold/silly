local configFileMgr = require "configfilemgr"
local localEnvConfig = require "localenvconfig"
local configMapMgr = require "configmapmgr"
local configMgr = {}

function configMgr:GetConfigFiles(process)
	return configFileMgr:GetConfigFiles(process)
end

function configMgr:ConfigOneFile(filePath, item, value)
	local inFile = io.open(filePath, "r")
	local fileContent = {}
	local matchIdx = 0
	local idx = 0
	if not inFile then
		return
	end

	local lineEnd = ""
	if string.find(filePath, "%.lua") then
		lineEnd = ","
	end

	for line in inFile:lines() do
		idx = idx + 1
		table.insert(fileContent, line)
		local pattern = item.."%s*="
		if string.find(line, pattern) then
			matchIdx = idx
		end
	end
	inFile:close()

	if matchIdx <= 0 then
		return
	end
	print("\tWill config "..item.." to "..value.." in ".. filePath..", line "..matchIdx)
	local outFile = io.open(filePath, "w")
	for idx, line in ipairs(fileContent) do
		if idx ~= matchIdx then
			outFile:write(line.."\n")
		else
			if type(value) == "number" then
				outFile:write(line:gsub("=(.+)", [[= ]]..value)..lineEnd.."\n")
			else
				outFile:write(line:gsub("=(.+)", [[= "]]..value..[["]])..lineEnd.."\n")
			end
		end
	end
	outFile:close()
end

function configMgr:ConfigOneItemInProcess(process, item, value)
	if not (process and item and value ) then return end
	for vkPair in self:GetConfigFiles(process) do
		local filePath = vkPair[1]
		local fileType = vkPair[2]

		self:ConfigOneFile(filePath, item, value)

	end
end

function configMgr:GetLocalEnvValue(process, item)
	-- 映射的本地配置名
	local localEnv = configMapMgr:GetLocalEnv(process, item)
	print("\tLocalEnv name of process " .. process .. " for item ".. item .. " is "..(localEnv or "nil"))
	if not localEnv then return end

	return localEnvConfig[localEnv]
end

function configMgr:GetToConfigItemInProcess(process)
	if process == "one" then
		return {
			"Cookie", 
			"Sign", 
			"InternalIp", 
			"InternalHttpPort", 
			"PublicHttpHost",
			"PublicHttpPort",
			"HttpDir",
			"MindMapDir",
		}
	end
	if process == "todolist" then
		return {
			"Cookie",
			"Sign",
			"DbUser",
			"DbPass",
			"DbHost",
		}
	end
end

function configMgr:ConfigProcess(process)
	local toConfigItem = self:GetToConfigItemInProcess(process)
	if not toConfigItem then return end

	for _,item in ipairs(toConfigItem) do
		print("To config item " .. item .. " in " .. process .. "...")
		local value = self:GetLocalEnvValue(process, item)
		self:ConfigOneItemInProcess(process, item, value)
	end
end

function configMgr:DoGen()
	self:ConfigProcess("one")
	self:ConfigProcess("filesync")
	self:ConfigProcess("todolist")
	print("done!")
	-- self:ConfigProcessItem("one", "bootstrap", 1)
end

return configMgr

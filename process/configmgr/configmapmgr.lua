
local configMap = {
	-- Below is a sample
	-- Cookie = { one = "Coocie_One", todolist = "Cookie_todolist"}
}

local configMapMgr = {}

function configMapMgr:GetLocalEnv(process, item)
	local itemInfo = configMap[item]
	-- 如果没有定义就返回他自己
	if not itemInfo then
		return item
	end

	if type(itemInfo) == "table" then
		return itemInfo[process] or item
	end

	return item

end

return configMapMgr

local loadstring = load
local debugflag = 0


-- encode and decode func is the same.
local function encodeFun1(str)
	if not str then return end
	if type(str) ~= "string" then return str end

	local function reverse(beginIdx, endIdx)
		local subStr = string.sub(str, beginIdx, endIdx)
		return string.reverse(subStr)
	end

	local len = #str
	local effectLen = 1
	local lastEffect = 1
	local tbl = {}
	local maxLoopTimes = 100
	local loopTimes = 0

	while(true) do
		loopTimes = loopTimes + 1
		if effectLen > len or loopTimes > maxLoopTimes then
			
			if lastEffect <= len then
				table.insert(tbl, reverse(lastEffect, len))
			end

			break
		end

		table.insert(tbl, reverse(lastEffect, effectLen))

		local tmp = effectLen + 1
		effectLen = lastEffect + effectLen
		lastEffect = tmp
	end

	return table.concat(tbl)
end

local decodeFun1 = encodeFun1

function serialize(obj)
    -- local lua = ""
	local tbl = {}
    local t = type(obj)
    if t == "number" then
        -- lua = lua .. obj
		table.insert(tbl, tostring(obj))
    elseif t == "boolean" then
        -- lua = lua .. tostring(obj)
		table.insert(tbl, tostring(obj))
    elseif t == "string" then
        -- lua = lua .. string.format("%q", obj)
		table.insert(tbl, string.format("%q", obj))
    elseif t == "table" then
        -- lua = lua .. "{\n"
		table.insert(tbl, "{\n")
    	for k, v in pairs(obj) do
        	-- lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
        	table.insert(tbl, "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n")
    	end
    	local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
        	for k, v in pairs(metatable.__index) do
            	-- lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
            	table.insert(tbl, "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n")
        	end
    	end
        -- lua = lua .. "}"
		table.insert(tbl, "}")
    elseif t == "nil" then
        return nil
    else
        error("can not serialize a " .. t .. " type.")
    end
	-- return lua
	
	local raw = table.concat(tbl)
	local encoded = encodeFun1(raw)

	return raw
end

function unserialize(lua)
    local t = type(lua)
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
		-- local decoded = encodeFun1(lua)
        lua = tostring(lua) -- tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
    end

	-- local decoded = encodeFun1(lua)
    lua = "return " .. lua
	-- print("decoded -->"..decoded)
    local func = loadstring(lua)
    if func == nil then
        return nil
    end
    return func()
end

--[[
-- 测试代码如下
data = {["a"] = "a", ["b"] = "b", [1] = 1, [2] = 2, ["t"] = {1, 2, 3}}
local sz = serialize(data)
print(sz)
print("---------")
print(serialize(unserialize(sz)))
--]]

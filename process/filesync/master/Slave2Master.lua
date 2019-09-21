local core = require "sys.core"

Slave2Master = {}

function Slave2Master:rrpc_sum(pipe, ...)
	local args = {...}
	for k,v in pairs(args) do
		print(k,v)
	end
	return "arpc_sum",{val = 1, suffix = "connected"}
end

function Slave2Master:Handshake(pipe, data)
	local name = data.name

	if g_Name2Fd[name] then
		print("try register name fail", name)
		return "HandshakeDone", {val = "taken"}
	end
	
	g_Name2Fd[name] = pipe
	print("name resgiter done", name)
	return "HandshakeDone", {val = "done"}	
end

-- 查询搜索库的文件概况
function Slave2Master:GetSearchRepoOverview()
	local data = {}

	local dirPath = core.envget("search_repo_path")

	for filePath in lfs.dir(dirPath) do
		if filePath ~= "." and filePath ~= ".." then
			local fullPath = dirPath.."/"..filePath
			print(fullPath)
			local att = lfs.attributes(fullPath)

			data[filePath] = {}
			data[filePath].size = att.size or 0
			data[filePath].modification = att.modification or 0
			-- table.insert(data, filePath)
			-- table.insert(data, att.size or 0)
			-- table.insert(data, att.modification or 0)
		end
	end

	local str = serialize(data)

	return "ReplySearchRepoOverview", {overview = str}
end



local client = require "http.client"

local CodeMgr = {}

function CodeMgr:ConvertReturnToFile(httpBody, targetFilePath)
	local file = io.open(targetFilePath, "w+")
	if file then
		if file:write(httpBody) == nil then return false end
		io.close(file)
		return true
	else
		return false
	end
end

function CodeMgr:DownLoadCode()
	local CodeConfig = SAConfig.CodeConfig
	for _, toDownload in pairs(CodeConfig.Alias) do
		local url = "http://"..CodeConfig.Host..":"..CodeConfig.Port.."/"..CodeConfig.DownloadPreUrl..toDownload[1]
		print(url)
		local status, head, body = client.GET(url)

		if status == 200 then
			print("downloading "..toDownload[1].." as "..toDownload[2])
			self:ConvertReturnToFile(body, toDownload[2] or toDownload[1])
		end

		print("Code all set, start all modules now...")
		
	end
	require "HttpServer"

end


return CodeMgr

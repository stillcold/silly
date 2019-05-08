
local client = require "http.client"

local CodeMgr = {}

function CodeMgr:DownLoadCode()
	local CodeConfig = SAConfig.CodeConfig
	for _, toDownload in pairs(CodeConfig.Alias) do
		local url = "http://"..CodeConfig.Host..":"..CodeConfig.Port.."/"..CodeConfig.DownloadPreUrl..toDownload[1]
		print(url)
		local status, head, body = client.GET(url)
		print(status, head, body)

		if status == 200 then
			require "HttpServer"
		end
	end
end


return CodeMgr

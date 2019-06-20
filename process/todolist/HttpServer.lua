
local server = require "http.server"
local write = server.write
local httpIndex = require "Index"
local console = require "sys.console"
local db = require "DbMgr"
local json = require "sys/json"

local dispatch = {}

local defaultHead = httpIndex.Head
local defaultTail = httpIndex.Tail
local default = defaultHead..defaultTail

dispatch["/"] = function(fd, reqeust, body)
	local body = default
	local head = {
		"Content-Type: text/html",
		}

	write(fd, 200, head, body)
end

local content = ""

dispatch["/search"] = function(fd, request, body)
	-- write(fd, 200, {"Content-Type: text/plain"}, content)
	if request.form.Hello then
		content = request.form.Hello
	end
	
	-- local body = httpIndex.SearchResultHead..searchMgr:GetAnswer(content)..httpIndex.SearchResultTail
	local HighTime = os.time() + 24 * 3600
	local LowTime = os.time() - 2 * 24 * 3600
	if content == "today" or content == "today todo" or content == "今日任务" then
		HighTime = os.time() + 24 * 3600
	end
	
	if content == "week" or content == "week todo" or content == "本周任务" then
		HighTime = os.time() + 2 * 7 * 24 * 3600
	end
	
	local queryResult = db:GetRecordByRemindTimeRange(LowTime, HighTime)
	local showTbl = {}
	local result = ""
	for k,v in pairs (queryResult or {}) do
		print(k,v.AllProps)
		print(v.Id)
		showTbl[v.Id] = v.AllProps
		local jsonStr = v.AllProps
		local jsonTbl = json.decode(jsonStr)
		local text = jsonTbl.content
		result = result..[[<a href = "delete?todoType=content&id=]]..v.Id..[[">done</a>&nbsp;&nbsp;]]..text..[[<br>]]
	end
	-- local result = json.encode(showTbl)
	local body = httpIndex.SearchResultHead..result..httpIndex.SearchResultTail
	local head = {
		"Content-Type: text/html",
		}
	write(fd, 200, head, body)
end



dispatch["/delete"] = function(fd, request, body)
	print("try delete")
	-- write(fd, 200, {"Content-Type: text/plain"}, content)
	if request.form then
		content 	= request.form.todoType
		editTarget 	= request.form.id
	end

	db:DeleteRecordById(editTarget)
	
	-- local body = httpIndex.SearchResultHead..searchMgr:GetAnswer(content)..httpIndex.SearchResultTail
	local HighTime = os.time() + 24 * 3600
	local LowTime = os.time() - 2 * 24 * 3600
	if content == "today" or content == "today todo" or content == "今日任务" then
		HighTime = os.time() + 24 * 3600
	end
	
	if content == "week" or content == "week todo" or content == "本周任务" then
		HighTime = os.time() + 2 * 7 * 24 * 3600
	end
	
	local queryResult = db:GetRecordByRemindTimeRange(LowTime, HighTime)
	local showTbl = {}
	local result = ""
	for k,v in pairs (queryResult or {}) do
		print(k,v.AllProps)
		showTbl[v.Id] = v.AllProps
		result = result..v.AllProps.."<br>"
	end
	-- local result = json.encode(showTbl)
	local body = httpIndex.SearchResultHead..result..httpIndex.SearchResultTail
	local head = {
		"Content-Type: text/html",
		}
	write(fd, 200, head, body)
end





-- Entry!
server.listen(":8090", function(fd, request, body)
	local c = dispatch[request.uri]
	if c then
		c(fd, request, body)
	else
		print("Unsupport uri", request.uri)
		write(fd, 404, {"Content-Type: text/plain"}, "404 Page Not Found")
	end
end)


console {
	addr = ":2323"
	}


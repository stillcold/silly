
local server = require "http.server"
local write = server.write
local httpIndex = require "Index"
local console = require "sys.console"
local db = require "DbMgr"
local json = require "sys/json"
local dateUtil = require "utils/dateutil"

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
	local dayRange = 1
	if content == "today" or content == "today todo" or content == "今日任务" then
		HighTime = os.time() + 24 * 3600
		dayRange = 2
	end
	
	if content == "week" or content == "week todo" or content == "本周任务" then
		LowTime = os.time() - 7 * 24 * 3600
		HighTime = os.time() + 10 * 24 * 3600
		dayRange = 10
	end
	
	if content == "month" or content == "month todo" or content == "本月任务" then
		LowTime = os.time() - 31 * 24 * 3600
		HighTime = os.time() + 33 * 24 * 3600
		dayRange = 33
	end
	
	if content == "all" or content == "all todo" or content == "所有任务" then
		LowTime = 0
		HighTime = os.time() + 24 * 3600 * 366 * 10 -- 10年
		dayRange = -1
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
		result = result..[[<a href = "delete?todoType=]]..content..[[&id=]]..v.Id..[[">done</a>&nbsp;&nbsp;]]..text..[[<br>]]
	end
	
	result = result.."<br>"
	
	-- 检查生日部分
	local nowTime = os.time()
	local today = os.date("*t", nowTime)
	queryResult = db:GetAllBirthdayRecord(LowTime, HighTime)
	for k,v in pairs (queryResult or {}) do
		local jsonStr = v.AllProps
		local jsonTbl = json.decode(jsonStr)
		print(k, jsonTbl.date)
		local year, month, day = string.match(jsonTbl.date or "", "(%d+)[^%d]+(%d+)[^%d]+(%d+)")
		local isYangLi = jsonTbl.isYangLi
		year 	= tonumber(year)
		month 	= tonumber(month)
		day 	= tonumber(day)
		
		local birthdayDate = {year = year, month = month, day = day}
		
		-- 农历
		if isYangLi == false or isYangLi == "false" then
			local birthDayYangLiDate = dateUtil:NongLi2YangLiDate(birthdayDate)
			local todayNongLiDate = dateUtil:YangLi2NongLiDate({year = today.year, month = today.month, day = today.day})
			if dateUtil:IsBirthdayDateNear(nowTime, birthdayDate, true, dayRange) then
				local text = v.Name
				local nongliText = "(农历 "..birthdayDate.year.."-"..birthdayDate.month.."-"..birthdayDate.day..")"
				result = result..birthDayYangLiDate.month.."月"..birthDayYangLiDate.day.."日"..nongliText.."是<em>"..text.."</em>的生日"..[[<br>]]
			end
			
		-- 阳历
		else
			local yangLiDayOfThisYear = {year = today.year, month = birthdayDate.month, day = birthdayDate.day, hour = 12, min = 0, sec = 0}
			local yangLiTimeOfThisYear = os.time(yangLiDayOfThisYear)
		
			if yangLiTimeOfThisYear >= LowTime and yangLiTimeOfThisYear <= HighTime then
				local text = v.Name
				local yangliText = "(阳历 "..birthdayDate.year.."-"..birthdayDate.month.."-"..birthdayDate.day..")"
				result = result..birthdayDate.month.."月"..birthdayDate.day.."日"..yangliText.."是<em>"..text.."</em>的生日"..[[<br>]]
			end
		end
		
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
		print(v.Id)
		showTbl[v.Id] = v.AllProps
		local jsonStr = v.AllProps
		local jsonTbl = json.decode(jsonStr)
		local text = jsonTbl.content
		result = result..[[<a href = "delete?todoType=]]..content..[[&id=]]..v.Id..[[">done</a>&nbsp;&nbsp;]]..text..[[<br>]]
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


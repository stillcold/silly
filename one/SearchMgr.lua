local httpIndex = require "Index"
local searchMgr = {}

local keywordTbl = require "KeywordTbl"

function searchMgr:ParseKeywordPlain(tbl)
    for k,v in pairs (tbl) do
        tbl[k] = {content = v, priority = 0}
    end

    return tbl
end

function searchMgr:ParseKeywordByRule(keywordInfoTbl)

    local tbl = {}
    local keywordsSubTbl,extra = keywordInfoTbl[1], keywordInfoTbl[2]
    if not extra or not extra.parseRule then
        for k,v in pairs (keywordsSubTbl or {}) do
		    local longKey = k
		    if extra and extra.title then
			    longKey = extra.title.."-"..longKey
		    end
		    tbl[longKey] = {content = v, priority = extra.priority or 0}
	    end
    elseif extra.parseRule == 1 then
        for _,kvPair in ipairs (keywordsSubTbl or {}) do
		    local longKey = kvPair[1]
		    if extra and extra.title then
			    longKey = extra.title.."-"..longKey
		    end
		    tbl[longKey] = {content = kvPair[2], priority = kvPair[3] or 0}
	    end
	elseif extra.parseRule == 2 then
		for _,kvPair in ipairs(keywordsSubTbl or {}) do
			local longKey = kvPair.key
		    if extra and extra.title then
			    longKey = extra.title.."-"..longKey
		    end
		    tbl[longKey] = {content = kvPair.richTxt, priority = kvPair.priority or 0}
		end
    end

	return tbl
end


searchMgr:ParseKeywordPlain(keywordTbl)


local keywordsDir = "keywords/"
local allAlias = SAConfig.CodeConfig.Alias

local toLoadKeywords = {}

for idx,aliasTbl in pairs(allAlias) do
	if string.find(aliasTbl[1], "keyword") then
		local baseFileName = string.match(aliasTbl[2], "(%w+).lua")
		print(baseFileName)
		table.insert(toLoadKeywords, baseFileName)
	end
end 

for _, fileBaseName in pairs (toLoadKeywords) do
	local moduleName = keywordsDir..fileBaseName
	print("loading module for search "..moduleName)
	local keywordInfoTbl = require (moduleName)
    local parsedTbl = searchMgr:ParseKeywordByRule(keywordInfoTbl)

    for k,v in  pairs (parsedTbl) do
        keywordTbl[k] = v
    end

end


function searchMgr:IsAllKeywordMatch(toSearchTbl, keywordFromTbl)
	for _,toSearchKey in ipairs(toSearchTbl) do
		if not string.find(keywordFromTbl, toSearchKey) then
			return false
		end
	end

	return true
end

function searchMgr:GetSearchTblByInput(content)
	local tosearchTbl = {}
	for key in string.gmatch(content, "([^%+]+)") do
		table.insert(tosearchTbl, key)
	end
	return tosearchTbl
end

function searchMgr:GetAnswer(content)
	print("search text is: "..content.." lenth is "..#content)
	local tosearchTbl = self:GetSearchTblByInput(content)
	local ret = {}
    local candidate = {}
	local matchCount = 0
	for keyword,richTxt in pairs(keywordTbl) do
		if self:IsAllKeywordMatch(tosearchTbl, keyword) then
			local showTxt = self:ConvertToReadbleText(keyword, richTxt.content)
			table.insert(candidate, {showTxt, richTxt.priority or 0})
			matchCount = matchCount + 1
		end
	end

    table.sort(candidate, function (a,b)
        if a[2] > b[2] then return true end
    end
    )

    for _,result in ipairs(candidate) do
        table.insert(ret, result[1])
    end

	table.insert(ret, self:GetSummary(matchCount))
	print("search hit count is "..matchCount)

	-- local res = table.concat( ret, global.httpLineEndTag)
	local res = table.concat( ret, "")
	return res
end

function searchMgr:GetDetail(content)
	print("search text is: "..content.." lenth is "..#content)
	local ret = {}
	local matchCount = 0
	for keyword,richTxt in pairs(keywordTbl) do
		if keyword == content then
			matchCount = matchCount + 1
			-- table.insert(ret, self:GetDetailTips(matchCount))

			local showTxt = self:ConvertToReadbleCode(keyword, richTxt.content)
			table.insert(ret,  showTxt)
			
		end
	end

	local res = table.concat( ret, global.httpMultiLineTag)
	return res
end

function searchMgr:GetSummary(resultCount)
	if resultCount > 0 then
		return global.httpMultiLineTag..global.httpBoldTagBegin..global.summaryOkText..resultCount..global.httpBoldTagEnd
	end

	return global.summaryFailText
	
end

function searchMgr:GetDetailTips(count)
	return global.httpBoldTagBegin..global.detialOkText..count..global.httpBoldTagEnd
end

function searchMgr:ConvertToReadbleText(keyword, richTxt)
	local firstWordIdx = string.find(richTxt, "[%\n%S]")
	richTxt = string.sub(richTxt, firstWordIdx or 1)
	richTxt = string.gsub(richTxt, "\n", "<br>")
	richTxt = httpIndex.SearchItemContentBegin..richTxt..httpIndex.SearchItemContentEnd
	-- return global.httpBoldTagBegin..keyword..global.httpBoldTagEnd..global.httpLineEndTag..richTxt   
	return httpIndex.SearchItemBegin..keyword..httpIndex.SearchItemMiddle..keyword..httpIndex.SearchItemEnd..richTxt   
end

function searchMgr:ConvertToReadbleCode(keyword, richTxt)
	return httpIndex.CodeBegin..richTxt..httpIndex.CodeEnd   
end

return searchMgr

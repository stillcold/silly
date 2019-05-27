local httpIndex = require "Index"
local searchMgr = {}

local keywordTbl = require "KeywordTbl"

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
	local keywordsSubTbl,extra = keywordInfoTbl[1], keywordInfoTbl[2]
	for k,v in pairs (keywordsSubTbl or {}) do
		local longKey = k
		if extra and extra.title then
			longKey = extra.title.."-"..longKey
		end
		keywordTbl[longKey] = v
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
	local matchCount = 0
	for keyword,richTxt in pairs(keywordTbl) do
		if self:IsAllKeywordMatch(tosearchTbl, keyword) then
			local showTxt = self:ConvertToReadbleText(keyword, richTxt)
			table.insert(ret,  showTxt)
			matchCount = matchCount + 1
		end
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

			local showTxt = self:ConvertToReadbleCode(keyword, richTxt)
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

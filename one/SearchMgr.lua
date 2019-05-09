local searchMgr = {}

local keywordTbl = require "KeywordTbl"

local keywordsDir = "keywords/"
local toLoadKeywords = {"StarBiwuShowOrders"}

for _, fileBaseName in pairs (toLoadKeywords) do
	local moduleName = keywordsDir..fileBaseName
	print("loading module for search "..moduleName)
	local keywordsSubTbl = require (moduleName)
	for k,v in pairs (keywordsSubTbl or {}) do
		keywordTbl[k] = v
	end
end

function searchMgr:GetAnswer(content)
	print("search text is: "..content.." lenth is "..#content)
	local ret = {}
	local matchCount = 0
	for keyword,richTxt in pairs(keywordTbl) do
		if string.find(keyword, content) then
			local showTxt = self:ConvertToReadbleText(keyword, richTxt)
			table.insert(ret,  showTxt)
			matchCount = matchCount + 1
		end
	end

	table.insert(ret, self:GetSummary(matchCount))
	print("search hit count is "..matchCount)

	local res = table.concat( ret, global.httpMultiLineTag)
	return res
end

function searchMgr:GetSummary(resultCount)
	if resultCount > 0 then
		return global.summaryOkText..resultCount
	end

	return global.summaryFailText
	
end

function searchMgr:ConvertToReadbleText(keyword, richTxt)
	return global.httpBoldTagBegin..keyword..global.httpBoldTagEnd..global.httpLineEndTag..richTxt   
end

return searchMgr

local searchMgr = {}

local keywordTbl = require "KeywordTbl"


function searchMgr:GetAnswer(content)
	print("search text is: "..content)
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

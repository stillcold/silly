local searchMgr = {}

local keywordTbl = require "KeywordTbl"


function searchMgr:GetAnswer(content)
	print("search text is: "..content)
	local ret = {}
	local matchCount = 0
	for keyword,richTxt in pairs(keywordTbl) do
		if string.find(keyword, content) then
			table.insert(ret, richTxt)
			matchCount = matchCount + 1
		end
	end

	table.insert(ret, self:GetSummary(matchCount))
	print("search hit count is "..matchCount)

	local res = table.concat( ret, global.httpLineEndTag)
	return res
end

function searchMgr:GetSummary(resultCount)
	if resultCount > 0 then
		return global.summaryOkText..resultCount
	end

	return global.summaryFailText
	
end

return searchMgr
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
			tbl[longKey] = {content = v, priority = extra.priority or 0, title = extra.title, key = k}
		end
	elseif extra.parseRule == 1 then
		for _,kvPair in ipairs (keywordsSubTbl or {}) do
			local longKey = kvPair[1]
			if extra and extra.title then
				longKey = extra.title.."-"..longKey
			end
			tbl[longKey] = {content = kvPair[2], priority = kvPair[3] or 0, title = extra.title, key = kvPair[1]}
		end
	elseif extra.parseRule == 2 then
		for _,kvPair in ipairs(keywordsSubTbl or {}) do
			local longKey = kvPair.key
			if extra and extra.title then
				longKey = extra.title.."-"..longKey
			end
			tbl[longKey] = {content = kvPair.richTxt, priority = kvPair.priority or 0, title = extra.title, key = kvPair.key}
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
		local baseFileName = string.match(aliasTbl[2], "([%w_]+).lua")
		print(baseFileName)
		table.insert(toLoadKeywords, baseFileName)
	end
end

for _,fileName in pairs(global.__extraDownload or {}) do
	table.insert(toLoadKeywords, fileName)
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
	local totalCount = #toSearchTbl or 1
	local matchedCount = 0
	for _,toSearchKey in ipairs(toSearchTbl) do
		if string.find(string.lower(keywordFromTbl), string.lower(toSearchKey)) then
			matchedCount = matchedCount + 1
			-- return false
		end
	end

	if matchedCount >= 1 then
		return true, matchedCount * 10000 / totalCount
	end

	return false, 0
end

function searchMgr:GetSearchTblByInput(content)
	local tosearchTbl = {}
	for key in string.gmatch(content, "([^%+]+)") do
		table.insert(tosearchTbl, key)
	end
	return tosearchTbl
end

function searchMgr:ConvetToRichTitle(key ,title, toSearchTbl)
	local plainShowTxt = key.." - "..title
	local ret = plainShowTxt
	for _,toSearchKey in ipairs(toSearchTbl) do
		ret = string.gsub(ret, toSearchKey, "<em>"..toSearchKey.."</em>")
	end
	return ret
end

function searchMgr:GetAnswer(content)
	print("search text is: "..content.." lenth is "..#content)
	local tosearchTbl = self:GetSearchTblByInput(content)
	local ret = {}
	local candidate = {}
	local matchCount = 0
	for keyword,richTxt in pairs(keywordTbl) do
		local bMatch, matchFactor = self:IsAllKeywordMatch(tosearchTbl, keyword)
		if bMatch then
			-- local showTitle = (richTxt.key or keyword).." - " .. richTxt.title
			local showTitle = self:ConvetToRichTitle(richTxt.key or keyword, richTxt.title, tosearchTbl)
			local showTxt = self:ConvertToReadbleText(keyword, richTxt.content, showTitle)
			table.insert(candidate, {showTxt, richTxt.priority * matchFactor or 0})
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

	local res = table.concat( ret, "" )
	return res
end

function searchMgr:GetDetail(content)
	print("search text is: "..content.." lenth is "..#content)
	local ret = {}
	local matchCount = 0
	for keyword,richTxt in pairs(keywordTbl) do
		if keyword == content then
			matchCount = matchCount + 1
			local showTxt = self:ConvertToReadbleCode(keyword, richTxt.content)
			table.insert(ret,  showTxt)

		end
	end

	local res = table.concat( ret, global.httpMultiLineTag )
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

function searchMgr:ConvertToReadbleText(keyword, richTxt, showTitle)
	local firstWordIdx = string.find(richTxt, "[%\n%S]")
	richTxt = string.sub(richTxt, firstWordIdx or 1)
	richTxt = string.gsub(richTxt, "\n", "<br>")
	richTxt = httpIndex.SearchItemContentBegin..richTxt..httpIndex.SearchItemContentEnd
	return httpIndex.SearchItemBegin..keyword..httpIndex.SearchItemMiddle..showTitle..httpIndex.SearchItemEnd..richTxt   
end

function searchMgr:ConvertToReadbleCode(keyword, richTxt)
	return httpIndex.CodeBegin..richTxt..httpIndex.CodeEnd   
end

return searchMgr


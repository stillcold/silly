local httpIndex = require "Index"
local markdown = require "http.markdown"
local searchMgr = {}
local json = require"sys.json"

local keywordTbl = require "KeywordTbl"

function searchMgr:ParseKeywordPlain(tbl)
	for k,v in pairs (tbl) do
		tbl[k] = {richTxt = v, priority = 0}
	end

	return tbl
end

function searchMgr:ParseKeywordByRule(keywordInfoTbl)

	local defaultTextType = "code"
	local tbl = {}
	local keywordsSubTbl,extra = keywordInfoTbl[1], keywordInfoTbl[2]

	if not extra or not extra.parseRule then
		for k,v in pairs (keywordsSubTbl or {}) do
			local longKey = k
			if extra and extra.title then
				longKey = extra.title.."-"..longKey
			end
			tbl[longKey] = {richTxt = v, priority = extra.priority or 0, title = extra.title, key = k, textType = defaultTextType}
		end
	elseif extra.parseRule == 1 then
		for _,kvPair in ipairs (keywordsSubTbl or {}) do
			local longKey = kvPair[1]
			if extra and extra.title then
				longKey = extra.title.."-"..longKey
			end
			tbl[longKey] = {richTxt = kvPair[2], priority = kvPair[3] or 0, title = extra.title, key = kvPair[1], textType = defaultTextType}
		end
	elseif extra.parseRule == 2 then
		for _,kvPair in ipairs(keywordsSubTbl or {}) do
			local longKey = kvPair.key
			if extra and extra.title then
				longKey = extra.title.."-"..longKey
			end
			tbl[longKey] = {richTxt = kvPair.richTxt, priority = kvPair.priority or 0, title = extra.title, key = kvPair.key, textType = kvPair.textType or defaultTextType}
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
	local plainShowTxt = key.." - "..(title or "")
	local ret = plainShowTxt
	for _,toSearchKey in ipairs(toSearchTbl) do
		local ignoreCasePattern = string.gsub(toSearchKey, "(%a)", function(c)
			return string.format("[%s%s]", string.lower(c), string.upper(c))
		end)
		ret = string.gsub(ret, ignoreCasePattern, "<em>".."%1".."</em>")
	end
	return ret
end

function searchMgr:GetAnswer(content)
	print("search text is: "..content.." lenth is "..#content)
	local tosearchTbl = self:GetSearchTblByInput(content)
	local ret = {}
	local candidate = {}
	local matchCount = 0
	for keyword,item in pairs(keywordTbl) do
		local bMatch, matchFactor = self:IsAllKeywordMatch(tosearchTbl, keyword)
		if bMatch then
			-- local showTitle = (item.key or keyword).." - " .. item.title
			local showTitle = self:ConvetToRichTitle(item.key or keyword, item.title, tosearchTbl)
			local showTxt = self:ConvertToReadbleSearchItem(keyword, item, showTitle)
			table.insert(candidate, {showTxt, item.priority * matchFactor or 0})
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
	for keyword,item in pairs(keywordTbl) do
		if keyword == content then
			matchCount = matchCount + 1
			local showTxt = self:ConvertToReadbleDetailTxt(keyword, item)
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

function searchMgr:ConvertToReadbleSearchItem(keyword, item, showTitle)
	local richTxt = item.richTxt

	local firstWordIdx = string.find(richTxt, "[%\n%S]")
	richTxt = string.sub(richTxt, firstWordIdx or 1)
	richTxt = string.gsub(richTxt, "\n", "<br>")

	richTxt = httpIndex.SearchItemContentBegin..richTxt..httpIndex.SearchItemContentEnd
	return httpIndex.SearchItemBegin..keyword..httpIndex.SearchItemMiddle..showTitle..httpIndex.SearchItemEnd..richTxt   
end

function searchMgr:GenerateMindMapFile(textTbl)
	local mindMapConfig = SAConfig.CodeConfig.MindMapConfig
	local dynamicJsFileName = mindMapConfig.GenDynamicFilePath..mindMapConfig.GenDynamicFileName
	print(dynamicJsFileName)
	local f = io.open(dynamicJsFileName, "w")
	-- local f = io.open("t.txt","w")
	local head = [=[!function(e){var t={};function n(r){if(t[r])return t[r].exports;var o=t[r]={i:r,l:!1,exports:{}};return e[r].call(o.exports,o,o.exports,n),o.l=!0,o.exports}n.m=e,n.c=t,n.d=function(e,t,r){n.o(e,t)||Object.defineProperty(e,t,{configurable:!1,enumerable:!0,get:r})},n.r=function(e){Object.defineProperty(e,"__esModule",{value:!0})},n.n=function(e){var t=e&&e.__esModule?function(){return e.default}:function(){return e};return n.d(t,"a",t),t},n.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},n.p="",n(n.s=1)}([function(e){e.exports=]=]
	local tail = [=[},function(e,t,n){"use strict";function r(e){e=JSON.parse(e);try{let t={root:{data:{text:e.name},children:[]}};return function e(t,n){for(let r in t){if(!t.hasOwnProperty(r)||r.startsWith("."))continue;let o={data:{text:r},children:[]},i=t[r];"object"==typeof i||"string"==typeof i?(i[".level"]&&(o.data.priority=i[".level"]),e(i,o.children)):o.data.priority=i,n.push(o)}}(e.mindmap,t.root.children),JSON.stringify(t)}catch(e){return null}}n.r(t);var o=n(0);window.onload=(()=>{const e=ace.edit("editor"),t=ace.require("ace/mode/json").Mode;e.session.setMode(new t),e.setValue(JSON.stringify(o,null,"  "));const n=window.km=new kityminder.Minder;function i(){n.importData("json",r(e.getValue()))}n.renderTo("#minder-view"),i(),n.disable(),n.execCommand("hand"),document.querySelector("#generate-btn").onclick=i,document.querySelector("#save-btn").onclick=function(){n.exportData("png").then(e=>{const t=document.createElement("a");t.href=e,t.download="skill-set.png",t.click(),document.querySelector("canvas").remove()})}})}]);]=]
	f:write(head)
	f:write(json.encode(textTbl))
	f:write(tail)
	f:close()
	
	local htmlFileName = "dynamic.html"--os.time()..".html"
	local newIdxFileName = mindMapConfig.GenDynamicFilePath..htmlFileName
	local newIdx = io.open(newIdxFileName,"w+")
	newIdx:write([=[
CTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SkillSet Demo</title>

    <link rel="stylesheet" href="kityminder.core.css">
    <style type="text/css">
        body {
            margin: 0;
            padding: 0;
            height: 100%;
        }

        #editor {
            width: 400px;
            height: calc(100vh - 22px);
        }

        #generate-btn, #save-btn {
            display: inline-block;
        }

        #minder-view {
            position: absolute;
            border: 1px solid #ccc;
            left: 0;
            top: 0;
            bottom: 0;
            right: 0;
        }
		#skillset-input-box{
            display: none;
        }
    </style>
</head>
<body>
<div id="skillset-input-box">
    <div id="editor"></div>
    <button id="generate-btn">Generate</button>
    <button id="save-btn">Save as PNG</button>
</div>
<div id="minder-view"></div>

<script type="text/javascript" src="https://cdn.bootcss.com/ace/1.3.1/ace.js"></script>
<script type="text/javascript" src="https://cdn.bootcss.com/ace/1.3.1/mode-json.js"></script>
<script type="text/javascript" src="kity.min.js"></script>
<script type="text/javascript" src="kityminder.core.min.js"></script>
<script type="text/javascript" src="bundle_dynamic.js"></script>
</body>
</html>
	]=])
	newIdx:close()
	return htmlFileName
end


function searchMgr:ConvertToReadbleDetailTxt(keyword, item)
	local richTxt = item.richTxt

	if item.textType == "code" then
		return httpIndex.CodeBegin..richTxt..httpIndex.CodeEnd   
	elseif item.textType == "markdown" then
		return markdown(richTxt)
	elseif item.textType == "mindmap" then
		local testTbl = assert(load(richTxt))()  --testFun()
		local newIdx = self:GenerateMindMapFile(testTbl)
		local newHref = "http://10.240.163.122/mind/skillSet/"..newIdx
		return [=[
<script language="javascript" type="text/javascript"> 
window.location.href="]=]..newHref..[=["; 
</script>]=]
		-- return [=[<a href="]=]..newHref..[=[">Mindmap has generated</a>]=]
	end

	return httpIndex.CodeBegin..richTxt..httpIndex.CodeEnd   

end

return searchMgr


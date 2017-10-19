local format = string.format
local gsub = string.gsub
local char = string.char
local aux = {}

local html_unescape = {
	['quot'] = '"',
	['amp'] = '&',
	['lt'] = '<',
	['gt'] = '>',
}

function aux.htmlunescape(html)
	html = gsub(html, "&#(%d+);", function(s)
		return string.char(tonumber(s))
	end)
	html = gsub(html, "&(%a+);", html_unescape)
	return html
end

function aux.urlencode(url)
	print(url)
	url = gsub(url, "([^0-9a-zA-Z$-_%.+!*(),])", function(n)
		local s = format("%%%02X", n:byte(1))
		print(s)
		return s
	end)
	return url
end

function aux.urldecode(url)
	url = gsub(url, "%%([0-9A-Fa-F][0-9A-Fa-F])", function (s)
		return string.char(tonumber(s, 16))
	end)
	return url
end



function aux.setcookie(header, cookie)
	local c = header['Set-Cookie']
	if c then
		table.insert(cookie, c)
	end
end

function aux.getcookie(cookie)
	return "Cookie:" .. table.concat(cookie, ";")
end

return aux


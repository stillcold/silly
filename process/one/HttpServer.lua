
local server = require "http.server"
local searchMgr = require "SearchMgr"
local write = server.write
local htmlTags = require "HtmlTags"
local console = require "sys.console"

local dispatch = {}

local defaultHead = htmlTags.Head
local defaultTail = htmlTags.Tail
local default = defaultHead..defaultTail

dispatch["/"] = function(fd, reqeust, body)
	local body = default
	local head = {
		"Content-Type: text/html",
		}

	write(fd, 200, head, body)
end

local content = ""

dispatch["/download"] = function(fd, request, body)
	write(fd, 200, {"Content-Type: text/plain"}, content)
end

dispatch["/upload"] = function(fd, request, body)
	if request.form.Hello then
		content = request.form.Hello
	end
	local body = "Upload done, please access download to see the result"
	local head = {
		"Content-Type: text/plain",
		}
	write(fd, 200, head, body)
end

dispatch["/search"] = function(fd, request, body)
	if request.form.Hello then
		content = request.form.Hello
	end
	local body = htmlTags.SearchResultHead..searchMgr:GetAnswer(content)..htmlTags.SearchResultTail
	local head = {
		"Content-Type: text/html",
		}
	write(fd, 200, head, body)
end

dispatch["/detail"] = function(fd, request, body)
	if request.form.Hello then
		content = request.form.Hello
	end
	local body = htmlTags.SearchResultHead..searchMgr:GetDetail(content)..htmlTags.SearchResultTail
	local head = {
		"Content-Type: text/html",
		}
	write(fd, 200, head, body)
end

-- Entry!
server.listen(":8089", function(fd, request, body)
	local c = dispatch[request.uri]
	if c then
		c(fd, request, body)
	else
		print("Unsupport uri", request.uri)
		write(fd, 404, {"Content-Type: text/plain"}, "404 Page Not Found")
	end
end)


console {
	addr = ":1234"
	}

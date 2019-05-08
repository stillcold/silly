require "global"
local CodeMgr = require "CodeMgr"
local core = require "sys.core"

core.start(function()
	CodeMgr:DownLoadCode()
	-- core.exit()
end)


print("code ok")

local server = require "http.server"
local searchMgr = require "SearchMgr"
local write = server.write
local dispatch = {}

local defaultHead = [[
		<html>
			<head>
			<title>Chao's Coding Assist</title>
			<center>Chao's Coding Assist</center>
			</head>
			<body>
			<center>
				<form action="search" method="POST">
				<input type="text" name="Hello"/>
				<input type="submit" name="submit" value="Search" />
				</form>
			</center>
			</body>
	]]
local defaultTail = [[
		</html>
	]]
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
	local body = defaultHead..searchMgr:GetAnswer(content)..defaultTail
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


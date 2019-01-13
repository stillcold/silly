local server = require "http.server"
local write = server.write
local dispatch = {}

dispatch["/"] = function(fd, reqeust, body)
	local body = [[
		<html>
			<head>Simple http server</head>
			<body>
				<form action="upload" method="POST">
				<input type="text" name="Hello"/>
				<input type="submit" name="submit"/>
				</form>
			</body>
		</html>
	]]
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


server.listen(":8089", function(fd, request, body)
	local c = dispatch[request.uri]
	if c then
		c(fd, request, body)
	else
		print("Unsupport uri", request.uri)
		write(fd, 404, {"Content-Type: text/plain"}, "404 Page Not Found")
	end
end)


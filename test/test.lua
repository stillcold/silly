local core = require "sys.core"
local env = require "sys.env"

local modules = {
	"testtag",
	"testsocket",
	"testmulticast",
	"testdns",
	"testrpc",
	"testudp",
	"testwakeup",
	"testtimer",
	"testnetstream",
	"testnetpacket",
	"testchannel",
	"testcrypt",
	"testhttp",
	"testredis",
	"testmysql",
}

local M = ""
local gprint = print
local function print(...)
	gprint(M, ...)
end

print("env.get", env.get("hello"))

_ENV.print = print

core.start(function()
	local entry = {}
	for k, v in pairs(modules) do
		entry[k] = require(v)
	end

	for k, v in ipairs(modules) do
		M = v .. ":"
		print("=========start=========\n")
		assert(entry[k])()
		print("======success==========\n")
	end
	core.exit()
end)





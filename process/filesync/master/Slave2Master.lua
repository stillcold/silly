Slave2Master = {}

function Slave2Master:rrpc_sum(pipe, ...)
	local args = {...}
	for k,v in pairs(args) do
		print(k,v)
	end
end



function Master2Slave:Test(conn, tbl)
	core.debug(1, "rpc from server is ")
	PrintTable(tbl)
	return "ack from client on recieve master rpc"
end


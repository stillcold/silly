function Master2Slave:Test(conn, tbl)
	print("rpc from server is ")
	PrintTable(tbl)
	return "ack from client on recieve master rpc"
end


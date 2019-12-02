function Slave2Master:Test(conn, num, str, tbl)
	print(num, str)
	PrintTable(tbl)

	Master2Slave:Test(conn, {msg = "test rpc before ack"})

	return "ack from server"
end

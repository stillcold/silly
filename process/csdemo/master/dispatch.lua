function Slave2Master:Test(conn, num, str, tbl)
	core.debug(1, num, str)

	PrintTable(tbl, 1)

	Master2Slave:Test(conn, {msg = "test rpc before ack"})

	return "ack from server"
end

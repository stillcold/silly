function Slave2Master:Test(conn, num, str, tbl)
	print(num, str)
	PrintTable(tbl)

	return "ack from server"
end

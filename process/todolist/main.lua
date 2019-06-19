local core = require "sys.core"
local mysql = require "sys.db.mysql"
local json = require "sys/json"

local function selectTable()
	local db = mysql.create {
		host="127.0.0.1:3306",
		user="root",
		password="netpassmysql",


	}
	db:connect()
	local status, res = db:query("show databases;")
	print("mysql show databases;", status)
	if not status then return end
	status, res = db:query("use todo;")
	print("use todo;", status)
	return db
end

local function insertRecord(db, Id, RemindTime, AllProps, Name, FartherId, ChildId, BeginTime, EndTime)

	Id = Id or os.time()
	FartherId = FartherId or 0
	ChildId = ChildId or 0
	Name = Name or "name"
	RemindTime = RemindTime or os.time()
	BeginTime = BeginTime or os.time()
	EndTime = EndTime or os.time()
	AllProps = AllProps or "{}"

	local statement = string.format ("insert into todo (Id,FartherId,ChildId,Name,RemindTime,BeginTime,EndTime,AllProps) values (%.0f, %.0f, %.0f, '%s', %.0f, %.0f, %.0f, '%s')",Id,FartherId,ChildId,Name,RemindTime,BeginTime,EndTime,AllProps)

	print(statement)
	local status,res = db:query(statement)
	print(status, res)
	for k,v in pairs (res) do
		print(k,v)
	end
end

core.start(function()
	local db = selectTable()
	if not db then return end

	local id = os.time()
	local remindTime = os.time() + 1000
	local prop = {}
	prop.info = "hi"
	local propStr = json.encode(prop)

	insertRecord(db, id, remindTime, propStr)


end)




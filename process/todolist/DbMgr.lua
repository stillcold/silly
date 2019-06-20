local mysql = require "sys.db.mysql"
local json = require "sys/json"

local DbMgr = {}

DbMgr.db = nil

function DbMgr:SelectTable()
	local db = mysql.create {
		host="127.0.0.1:3306",
		user="todo",
		password="mytodo",
	}
	db:connect()
	local status, res = db:query("show databases;")
	print("mysql show databases;", status)
	if not status then return end
	status, res = db:query("use todo;")
	print("use todo;", status)
	self.db = db
	return db
end

function DbMgr:InsertRecord(Id, RemindTime, AllProps, Name, FartherId, ChildId, BeginTime, EndTime)

	if not DbMgr.db then
		self:SelectTable()
	end

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
	local status,res = self.db:query(statement)
	print(status, res)
	for k,v in pairs (res) do
		print(k,v)
	end
end

function DbMgr:GetRecordByRemindTimeRange(LowTime, HighTime)

	if not DbMgr.db then
		self:SelectTable()
	end

	Id = Id or os.time()
	FartherId = FartherId or 0
	ChildId = ChildId or 0
	Name = Name or "name"
	RemindTime = RemindTime or os.time()
	BeginTime = BeginTime or os.time()
	EndTime = EndTime or os.time()
	AllProps = AllProps or "{}"

	local statement = string.format ("select * from todo where RemindTime > %.0f and RemindTime < %0.f",LowTime, HighTime)

	print(statement)
	local status,res = self.db:query(statement)
	print(status, res)
	
	return res
end

return DbMgr

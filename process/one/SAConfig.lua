SAConfig = {
	CodeConfig = {
		Host = "127.0.0.1",
		Port = "80",
		-- DownloadPreUrl = "x_egine_private_code/DownloadCode.php?fileName=",
		DownloadPreUrl = "DownloadCode.php?actionName=no&fileName=",
		ListDirPreUrl = "DownloadCode.php?actionName=list&fileName=",
		DownloadDir = {
			{"keywords", "extra"},
		},
		Alias = {
			{"Index", "process/one/Index.lua"},
			{"KeywordTbl", "process/one/KeywordTbl.lua"},
			{"keywords/J1900", "process/one/keywords/J1900.lua"},
			{"keywords/XEngineConfig", "process/one/keywords/XEngineConfig.lua"},
		},
	},
	
}

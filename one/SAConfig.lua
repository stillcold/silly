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
			{"Index", "one/Index.lua"},
			{"KeywordTbl", "one/KeywordTbl.lua"},
			{"keywords/J1900", "one/keywords/J1900.lua"},
			{"keywords/XEngineConfig", "one/keywords/XEngineConfig.lua"},
		},
	},
	
}

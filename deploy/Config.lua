local config = {
	file_encode_config = {
		encode_key = "xiaoxiao",
		encode_len = 100,
		encode_tail = ".sherry",
		encode_map = {
			-- fileName, encode_algrithm_version, use_binary_encode
			{"encoded-codemgr-src/DownloadCode.php" , 1, true},
			{"encoded-codemgr-src/x_code_deploy_dir/Index.lua" , 1, true},
			{"encoded-codemgr-src/x_code_deploy_dir/KeywordTbl.lua" , 1, true},
			{"encoded-codemgr-src/x_code_deploy_dir/keywords/StarBiwuShowOrders.lua" , 1, true},
			{"encoded-codemgr-src/x_code_deploy_dir/keywords/J1900.lua" , 1, true},
			{"encoded-codemgr-src/x_code_deploy_dir/keywords/WorkConfig.lua" , 1, true},
			{"encoded-codemgr-src/x_code_deploy_dir/keywords/XEngineConfig.lua" , 1, true},
		}
	}
	
}


return config

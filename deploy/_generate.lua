
local encoder = require "Encode/SheeryEncoder"
local config = require "Config"

for idx,originalFileNameItem in ipairs(config.file_encode_config.encode_map) do

	local originalFileName = originalFileNameItem[1]

	local encode_version = originalFileNameItem[2]

	local encode_type = originalFileNameItem[3]

	local encodedFileName = originalFileName..config.file_encode_config.encode_tail

	-- encoder:EncodeFile(config.file_encode_config.encode_key, originalFileName, encodedFileName, config.file_encode_config.encode_len, encode_version)

	if encode_type then
		encoder:DecodeBinaryFile(config.file_encode_config.encode_key, encodedFileName, originalFileName, config.file_encode_config.encode_len, encode_version)
	else
		encoder:DecodeFile(config.file_encode_config.encode_key, encodedFileName, originalFileName, config.file_encode_config.encode_len, encode_version)
	end
	
end

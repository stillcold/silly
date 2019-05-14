
local encoder = require "SheeryEncoder"
local config = require "Config"

for idx,originalFileNameItem in ipairs(config.file_encode_config.encode_map) do

	local originalFileName = originalFileNameItem[1]

	local encode_version = originalFileNameItem[2]

	local encode_type = originalFileNameItem[3]

	local encodedFileName = originalFileName..config.file_encode_config.encode_tail

	os.remove(encodedFileName)

	if encode_type then
		encoder:EncodeFileBinary(config.file_encode_config.encode_key, originalFileName, encodedFileName, config.file_encode_config.encode_len, encode_version)
	else
		encoder:EncodeFile(config.file_encode_config.encode_key, originalFileName, encodedFileName, config.file_encode_config.encode_len, encode_version)
	end

	os.remove(originalFileName)
end

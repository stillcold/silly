-- git igonore file content-- one/KeywordTbl.lualocal keyWord2Answer = {	accountId = [=[	GetAccount by playerId:<br>	mysql -h192.168.131.240 -P3310 -upangu -ppangu<br>	use pangu;<br>	select accountname from character_basic where id = 320400014;<br>	select sdkuid1 from account where name = "QNMobile126848";<br>]=],	player = [=[	local player = g_ServerPlayerMgr:GetById(playerid)<br>	if not player then return end	]=],}keyWord2Answer["git ignore"] = [=[ 	git update-index --assume-unchanged [file-path]<br>	git update-index --no-assume-unchanged [file-path]	]=]keyWord2Answer["git use vim"] = [=[ 	git config --global core.editor "vim"	]=]keyWord2Answer["character type"] = [=[ Attacker:TypeIs(EnumObjectType.Player)]=]return keyWord2Answer
#region working files
	global $WorkingFolder=@ScriptDir
	global $FolderResources=$WorkingFolder&"\resources"
	if NOT FileExists($FolderResources) then DirCreate($FolderResources)
	global $FolderBin=$WorkingFolder&"\bin"
	if NOT FileExists($FolderBin) then DirCreate($FolderBin)
	if @Compiled then
		global $configPath="config.ini"
	Else
		global $configPath="secret\config.ini"
	endif
	global $OffsetFile=$FolderResources&"\OffSet.txt"
#endregion working files
#region sqlite
	func _DBvarInit()
		global $qryResult=""
		global $quietSQLQuery = 1
		global $dbfile ="SubteBA.db"
		global $dbfullPath = $FolderResources & "\" & $dbfile
		ConsoleWrite('<<    DataBase: '&$dbfullPath & @crlf )
		global $sqliteDLLfile="System.Data.SQLite.32.2012.dll"
		global $sSQliteDll =""
		Global $EncryptDB=0
	endfunc
#endregion sqlite
#region Send Telegram msg
	$nuevaLinea="%0A"
#endregion
#region GetUpdates
	$GetUpdateTimeSec=10
	$TweeterScrapMin=5
	ConsoleWrite('<<    Tweeter Scrap every Min ' & Sec2Time($TweeterScrapMin*60 ))
	ConsoleWrite('  //  Telegram GetUpdates every Sec ' & Sec2Time($GetUpdateTimeSec) & @crlf )
	$GetUpdateTimeMsec=$GetUpdateTimeSec*1000
	$TweeterScrapMsec=$TweeterScrapMin*60*1000
#endregion
#region Tweeter reads
	global $DEVChatID = IniRead($configPath,"dev","chatID","00000000")
	$BOT_ID = IniRead($configPath,"botUDF","BotID","00000000")
	$BotToken = IniRead($configPath,"botUDF","BotToken","00000000")
	global $token=IniRead($configPath,"bot","token","")
	global $StartTimeScrap=IniRead($configPath,"Times","StartTimeScrapHH:MM","00:00")
	global $StartTimeBot=IniRead($configPath,"Times","StartTimeBotHH:MM","00:00")
	global $EndTimeScrap=IniRead($configPath,"Times","EndTimeScrapHH:MM","23:59")
	global $EndTimeBot=IniRead($configPath,"Times","EndTimeBotHH:MM","23:59")
#endregion
_DBvarInit()



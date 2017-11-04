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
	ConsoleWrite('<<   Config: '&$configPath & @crlf )
	global $OffsetFile=$FolderResources&"\OffSet.txt"
#endregion working files
#region sqlite
	func _DBvarInit()
		global $qryResult=""
		global $quietSQLQuery = 1
		global $dbfile ="SubteBA.db"
		global $dbfullPath = $FolderResources & "\" & $dbfile
		ConsoleWrite('<<   DataBase: '&$dbfullPath & @crlf )
		global $sqliteDLLfile="System.Data.SQLite.32.2012.dll"
		global $sSQliteDll =""
		Global $EncryptDB=0
	endfunc
#endregion sqlite
#region Send Telegram msg
	global $nuevaLinea="%0A"
	Dim $MsgClass[5] ;ClaseMensage,
	Func InitMsgClass()
		for $u=0 to UBound($MsgClass)-1
			$MsgClass[$u]=""
		next
	EndFunc
	global $msgToAllSecuence=IniRead($configPath,"Messaging","msgToAllSecuence","xxxxx")
#endregion
#region Telegram Bot
	global $DEVChatID = IniRead($configPath,"dev","chatID","00000000")
	global $BOT_ID = IniRead($configPath,"botUDF","BotID","00000000")
	global $BotToken = IniRead($configPath,"botUDF","BotToken","00000000")
	global $token=IniRead($configPath,"bot","token","")
#endregion
#region Tweeter reads
	global $StartTimeScrap=IniRead($configPath,"Times","StartTimeScrapHH:MM","00:00")
	global $EndTimeScrap=IniRead($configPath,"Times","EndTimeScrapHH:MM","23:59")
		ConsoleWrite('<<   Tweeter Scrap Time '& $StartTimeScrap & "  To "  & $EndTimeScrap )

	global $TweeterScrapMin=IniRead($configPath,"Times","TweeterScrapMin","5")
		ConsoleWrite(' //  Tweeter Scrap every Min ' & Sec2Time($TweeterScrapMin*60 ) & @CRLF)
	global $TweeterScrapMsec=$TweeterScrapMin*60*1000
#endregion
#region GetUpdates
	global $StartTimeBot=IniRead($configPath,"Times","StartTimeBotHH:MM","00:00")
	global $EndTimeBot=IniRead($configPath,"Times","EndTimeBotHH:MM","23:59")
		ConsoleWrite('<<   TlgmBot Scrap Time '& $StartTimeBot & "  To "  & $EndTimeBot )

	global $GetUpdateTimeSec=IniRead($configPath,"Times","BotUpdateTimeSec","10")
		ConsoleWrite('//  Telegram GetUpdates every Sec ' & Sec2Time($GetUpdateTimeSec) & @crlf )
	global $GetUpdateTimeMsec=$GetUpdateTimeSec*1000
	global $ahora=1
	global $KeyBoardActive=0
#endregion
_DBvarInit()



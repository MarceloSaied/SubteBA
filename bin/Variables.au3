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


#endregion working files
#region sqlite
	func _DBvarInit()
		global $qryResult=""
		global $quietSQLQuery = 1
		global $dbfile ="SubteBA.db"
		global $dbfullPath = $FolderResources & "\" & $dbfile
		ConsoleWrite('@@$dbfullPath = ' & $dbfullPath & @crlf )
		global $sqliteDLLfile="System.Data.SQLite.32.2012.dll"
		global $sSQliteDll =""
		Global $EncryptDB=0
	endfunc
#endregion sqlite
#region Tweeter reads
	global $token=IniRead($configPath,"bot","token","")
	global $StartTimeScrap=IniRead($configPath,"Times","StartTimeScrapHH:MM","00:00")
	global $StartTimeBot=IniRead($configPath,"Times","StartTimeBotHH:MM","00:00")
	global $EndTimeScrap=IniRead($configPath,"Times","EndTimeScrapHH:MM","23:59")
	global $EndTimeBot=IniRead($configPath,"Times","EndTimeBotHH:MM","23:59")
#endregion
_DBvarInit()



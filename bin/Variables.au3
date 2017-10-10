#region working files
	global $WorkingFolder=@ScriptDir
	global $FolderResources=$WorkingFolder&"\resources"
	if NOT FileExists($FolderResources) then DirCreate($FolderResources)
	global $FolderBin=$WorkingFolder&"\bin"
	if NOT FileExists($FolderBin) then DirCreate($FolderBin)
	if @Compiled then
		global $token=IniRead("config.ini","bot","token","")
	Else
		global $token=IniRead("secret\config.ini","bot","token","")
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
	global $StartTimeScrap=IniRead("config.ini","Times","StartTimeScrapHH:MM","00:00")
	global $StartTimeBot=IniRead("config.ini","Times","StartTimeBotHH:MM","00:00")
	global $EndTimeScrap=IniRead("config.ini","Times","EndTimeScrapHH:MM","23:59")
	global $EndTimeBot=IniRead("config.ini","Times","EndTimeBotHH:MM","23:59")
#endregion
_DBvarInit()



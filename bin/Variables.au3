#region working files
	global $WorkingFolder=@ScriptDir
	global $FolderResources=$WorkingFolder&"\resources"
	if NOT FileExists($FolderResources) then DirCreate($FolderResources)
	global $FolderBin=$WorkingFolder&"\bin"
	if NOT FileExists($FolderBin) then DirCreate($FolderBin)
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
_DBvarInit()



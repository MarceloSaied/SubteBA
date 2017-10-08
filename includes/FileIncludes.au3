#region File includes
	FileInstall("helper\SendTelegramSubteBA/SendTelegramSubteBA.exe", @TempDir & "\SendTelegramSubteBA.exe", 1)

	if not @Compiled then
		FileCopy("secret\"&$dbfile, $dbfullPath,0)
		FileCopy("sqlite\System.Data.SQLite.32.2012.dll", $FolderBin&"\"&$sqliteDLLfile,0)
	else
		FileInstall("secret\"&$dbfile, $dbfullPath, 0)
		FileInstall("sqlite\System.Data.SQLite.32.2012.dll", $FolderBin&"\"&$sqliteDLLfile, 1)
	endif
#endregion File includes
#region File includes
;~ 	FileInstall("helper\SendTelegramSubteBA/SendTelegramSubteBA.exe", @TempDir & "\SendTelegramSubteBA.exe", 1)

	if not @Compiled then
		FileCopy("secret\"&$dbfile, $dbfullPath,0)
		FileCopy("sqlite\System.Data.SQLite.32.2012.dll", $FolderBin&"\"&$sqliteDLLfile,0)
	else
		FileInstall("secret\SubteBA.db", $dbfullPath, 0)
;~ 		ConsoleWrite('@@ $dbfullPath = ' & $dbfullPath & @crlf )
		FileInstall("secret\config.ini", "config.ini", 1)
		FileInstall("sqlite\System.Data.SQLite.32.2012.dll", $FolderBin&"\System.Data.SQLite.32.2012.dll", 1)
		FileInstall("resources\json2.txt",$FolderResources & "\json2.txt", 1)
				ConsoleWrite('@@ $FolderResources = ' & $FolderResources & @crlf )
		FileInstall("resources\jsonpath-0.8.0.js",$FolderResources & "\jsonpath-0.8.0.js", 1)
		FileInstall("resources\Keys_polyfill.txt",$FolderResources & "\Keys_polyfill.txt", 1)
	endif
#endregion File includes
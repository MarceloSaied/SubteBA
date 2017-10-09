#region File includes

	if not @Compiled then
		FileCopy("secret\"&$dbfile, $dbfullPath,0)
		FileCopy("sqlite\System.Data.SQLite.32.2012.dll", $FolderBin&"\"&$sqliteDLLfile,0)
		FileCopy("resources\json2.txt",$FolderResources & "\json2.txt")
		FileCopy("resources\jsonpath-0.8.0.js",$FolderResources & "\jsonpath-0.8.0.js")
		FileCopy("resources\Keys_polyfill.txt",$FolderResources & "\Keys_polyfill.txt")
	else
		FileInstall("secret\"&$dbfile, $dbfullPath, 0)
		FileInstall("sqlite\System.Data.SQLite.32.2012.dll", $FolderBin&"\"&$sqliteDLLfile, 1)
		FileInstall("resources\json2.txt",$FolderResources & "\json2.txt", 1)
		FileInstall("resources\jsonpath-0.8.0.js",$FolderResources & "\jsonpath-0.8.0.js", 1)
		FileInstall("resources\Keys_polyfill.txt",$FolderResources & "\Keys_polyfill.txt", 1)
	endif
#endregion File includes
#region ===========================================================================
	Func _ConfigInitial()
		ConsoleWrite('++ConfigDBInitial() = ' & @CRLF)
		_SQLite_down()
;~ 		_DBvarInit()
		; -------check if SQLIte SubteBA db exist
		SQLite_init()
	;~ 	$SQLq = "SELECT name FROM sqlite_temp_master WHERE type='table';"
	;~ 	_SQLITErun($SQLq, $dbfile, $quietSQLQuery)
	;~ 	;-------- Init Log
	;~ 	_initLog()
		;------------------------------------------------------------------------------
	EndFunc   ;==>_ConfigDBInitial
#endregion
#region  ==== SQL functions =======================================================================
	Func SQLInsertMessage($TweetID,$TweeMsg,$TweeDate)
;~ 		ConsoleWrite('++InsertMessageSQL() = '& @crlf)
		$query='INSERT INTO messages VALUES (' & $TweetID & ',"' & $TweeMsg & '" ,' & $TweeDate & ') ;'
		if _SQLITErun($query,$dbfullPath,$quietSQLQuery) Then
			return true
		Else
			MsgBox(48+4096,"Error inserting mesages ErrNo 1010" & @CRLF & $query,0,0)
			Return false
		EndIf
	EndFunc
	Func SQLGetUsers()
;~ 		ConsoleWrite('++SQLGetUsers() = '& @crlf)
		$query='SELECT * FROM Users ;'
		_SQLITEqry($query,$dbfullPath)
	EndFunc
	Func SQLExistUser($UserID)
;~ 	ConsoleWrite('++SQLExistUser() = '& @crlf)
		$query='SELECT UserID FROM Users WHERE UserID="'&$UserID &'";'
		_SQLITEqry($query,$dbfullPath)
		If  IsArray($qryResult) Then
			if UBound($qryResult)>1 then
				return $qryResult[1][0]
			EndIf
			return 0
		endif
		Return 0
	EndFunc
	Func SQLregister($UserID,$Fname,$Lname,$epoch)
;~ 	ConsoleWrite('++SQLregister() = '& @crlf)
		if SQLExistUser($UserID)=0 then
			SQLInsertUser($UserID,$Fname,$Lname,$epoch)
		endif
	EndFunc
	Func SQLInsertUser($UserID,$Fname,$Lname,$epoch)
;~ 	ConsoleWrite('++SQLInsertUser() = '& @crlf)
		$query='INSERT INTO Users VALUES (' & $UserID & ',"' & $Fname & '","' & $Lname & '",1,0,' & $epoch & ') ;'
		if _SQLITErun($query,$dbfullPath,$quietSQLQuery) Then
			return true
		Else
			MsgBox(48+4096,"Error inserting User ErrNo 1011" & @CRLF & $query,0,0)
			Return false
		EndIf
	EndFunc
#endregion
#region  ==== Bot Messages handeling ===================================================================
	Func GetBotUpdates()
		$urlMSG="https://api.telegram.org/" & $token & "/getUpdates"
		$sGet = HttpGetJson($urlMSG)
		if $sGet<>"" then
			return $sGet
		Else
			$s_text="Error getUpdates from Telegram = "
			ConsoleWrite('!! ' & $s_text & @crlf & "! " & $sGet)
			return false
		endif
	EndFunc
#endregion
#region   ===========================================================================
	func closeall()
		_SQLite_Close()
		_SQLite_Shutdown()
		exit 30
	EndFunc
#endregion
#region =====================================   Helpers functions  ===============================
	Func StripStrJS($st)
		$st=StringReplace($st,'","',":::")
		$st=clearstring($st)
		$st=StringReplace($st,"[","")
		$st=StringReplace($st,"]","")
		$st=StringReplace($st,'"',"")
		$stArr=StringSplit($st,":::",1)
		return $stArr
	EndFunc
	Func StripIntJS($st)
		$st=StringReplace($st,',',":::")
		$st=clearstring($st)
		$st=StringReplace($st,"[","")
		$st=StringReplace($st,"]","")
		$st=StringReplace($st,'"',"")
		$stArr=StringSplit($st,":::",1)
		return $stArr
	EndFunc
#endregion
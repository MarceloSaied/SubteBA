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
	Func SQLGetActiveUsers()
;~ 		ConsoleWrite('++SQLGetActiveUsers() = '& @crlf)
		$query='SELECT * FROM Users WHERE Active=1 ;'
		_SQLITEqry($query,$dbfullPath)
	EndFunc
	Func SQLGetDevUsers()
;~ 		ConsoleWrite('++SQLGetDevUsers() = '& @crlf)
		$query='SELECT * FROM Users WHERE Active=1 AND Dev=1 ;'
		_SQLITEqry($query,$dbfullPath)
	EndFunc
	Func SQLExist_Message($TweetID)
;~ 		ConsoleWrite('++Exist_Message() = '&$TweetID& @crlf)
		$query='SELECT id FROM messages WHERE id="'&$TweetID &'";'
		_SQLITEqry($query,$dbfullPath)
		If  IsArray($qryResult) Then
			if UBound($qryResult)>1 then
				return $qryResult[1][0]
			EndIf
			return 0
		endif
		Return 0
	EndFunc
#endregion
#region  ==== send messages =======================================================================
	Func SendTelegramMessages($TweetArr)
		If IsArray($TweetArr) Then
			$U = UBound($TweetArr) - 1
			For $i = $u To 1 Step -1
				sendmessages($TweetArr[1])
			Next
			Exit 30
		Else
			Exit 21
		EndIf
	EndFunc
;~  	Func sendmessages($message)  ;~ from file of recipients
;~ 		Local $fileh = FileOpen("secret\recipients.txt", 0)
;~ 		If $fileh = -1 Then
;~ 			Exit 26
;~ 		EndIf
;~ 		While 1
;~ 			Local $chatidLine = FileReadLine($fileh)
;~ 			If @error = -1 Then ExitLoop
;~ 			$chatidArr = StringSplit($chatidLine, ',')
;~ 			$chatid = $chatidArr[1]
;~ 			if $chatID<>"" then
;~ 				ConsoleWrite('- $chatid = ' & $chatid & "  ->  " & $chatidArr[2] & @CRLF)
;~ 				$respuesta = SendTelegramexec($chatid,$message)
;~ 			$respuesta  0 is ok
;~ 			endif
;~ 		WEnd
;~ 		FileClose($fileh)
;~ 	EndFunc   ;==>_sendmessages
	Func ReformatMessage($message)
;~ 	ConsoleWrite('++ReformatMessage() = '& @crlf)
		$msgArr=StringSplit($message,"Actualizado",1)
		$diaHoraArr=stringsplit(StringStripWS($msgArr[2],1+2)," ")
		$hora=$diaHoraArr[2]
		$dia=$diaHoraArr[1]
		$msg="<b>"&$hora&"</b>"&"     " & $dia&"%0A"&StringStripWS($msgArr[1],1+2)
		return $msg
	EndFunc
	Func sendmessages($message)
		$message=ReformatMessage($message)
		SQLGetActiveUsers()
		If  IsArray($qryResult) Then
			for $i=1 to UBound($qryResult)-1
				$isDev = $qryResult[$i][4]
				$chatid = $qryResult[$i][0]
				$ChatUser = $qryResult[$i][1] & " " & $qryResult[$i][2]
				if $chatID<>"" then
					select
						Case $SendToAll = 1
							ConsoleWrite('- $chatid = ' & $chatid & "  ->  " & $ChatUser & @CRLF)
							$respuesta = SendTelegramexec($chatid,$message)
						Case $isDev = 1 AND $SendToAll = 0
							ConsoleWrite('- $chatid = ' & $chatid & "  ->  " & $ChatUser & @CRLF)
							$respuesta = SendTelegramexec($chatid,$message)
					endSelect
					;~ $respuesta  0 is ok
				endif
			next
			return true
		endif
		Return false
	EndFunc   ;==>_sendmessages
	Func SendTelegramexec($chatid,$msgtext="testeo harcoded")
		$urlMSG="https://api.telegram.org/" & $token & "/sendMessage?chat_id=" & $chatid & _
		"&text=" & $msgtext & "&parse_mode=HTML"
		$sGet = HttpGet($urlMSG)

		if $sget<>"0"  then
			ConsoleWrite('Tlgm sent = ' & $msgtext & @crlf )
			return 0
		Else
			$s_text="Error sending message to Telegram = " & $sGet
			ConsoleWrite('!! ' & $s_text & @crlf )
			return 1
		endif
	EndFunc
#endregion
#region  ==== Tweeter handeling ===================================================================
	func _ScrapTweetMessages($Username)
		Local $sData = InetRead("https://twitter.com/"&$Username)
		Local $nBytesRead = @extended
		ConsoleWrite('@@(' & @ScriptName & '-' & @ScriptLineNumber & ') : $nBytesRead = ' & $nBytesRead & @CRLF)
		$htmltxt = BinaryToString($sData)
		If $nBytesRead < 100 Then	Exit 25
		return $htmltxt
	EndFunc
	Func _gettweetArr($htmltxt)
		$MSGArr = StringRegExp($htmltxt, '(?s)(?i)<div class="js-tweet-text-container">(.*?)</DIV>', 3)
		if IsArray($MSGArr) then
			dim  $TweetMSGArr[UBound($MSGArr)]
			For $i = 0 To UBound($MSGArr) -1
				$TweetMessage = StringRegExp($MSGArr[$i], '(?s)(?i)<p(.*?)>(.*?)</p>', 1)
				$mensaje = clearstring($TweetMessage[1])
				$TweetMSGArr[$i]=$mensaje
			Next
			$TweetDate = StringRegExp($htmltxt, '(?s)(?i)data-time="(.*?)"', 3)
			$TweetIDArr = StringRegExp($htmltxt, '(?s)(?i)data-tweet-id="(.*?)"', 3)
			$TweetArrAux = _mergeArray($TweetIDArr, $TweetMSGArr)
			$TweetArr = _mergeArray($TweetArrAux, $TweetDate)
	;~ 		_ArrayDisplay($TweetArr)
			return $TweetArr
		Else
			ConsoleWrite('!!!(' &  @ScriptLineNumber & ') : Error on  $MSGArr = ' & $MSGArr & @crlf )
			return 0
		endif
	EndFunc
#endregion
#region  ==== Bot Messages handeling ===================================================================
	func UpdateUsers()
		ConsoleWrite('  Update users ' & @crlf)
		local $s=GetBotUpdates()
		if $s then
			$oJSON = _OO_JSON_Init()
			$jsonObj = $oJSON.parse($s)
			if $jsonObj.ok  then
				if $jsonObj.jsonPath( "$.result").stringify() = "[[]]" then
					ConsoleWrite(' No Bot data ' & @crlf)
				Else
					$UserIDArr = StripIntJS($jsonObj.jsonPath( "$.result..message.from.id").stringify())
					$FnameArr = StripStrJS($jsonObj.jsonPath( "$.result..message.from.first_name").stringify())
					$LnameArr = StripStrJS($jsonObj.jsonPath( "$.result..message.from.last_name").stringify())
					$epochArr = StripIntJS($jsonObj.jsonPath( "$.result..message.date").stringify())
					for $i=1 to $UserIDArr[0]
						SQLregister($UserIDArr[$i],$FnameArr[$i],$LnameArr[$i],$epochArr[$i])
					next
				endif
			endif
		endif
	EndFunc
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
	Func SQLregister($UserID,$Fname,$Lname,$epoch)
;~ 	ConsoleWrite('++SQLregister() = '& @crlf)
		if SQLExistUser($UserID)=0 then
			SQLInsertUser($UserID,$Fname,$Lname,$epoch)
		endif
	EndFunc
	Func SQLInsertUser($UserID,$Fname,$Lname,$epoch)
;~ 	ConsoleWrite('++SQLInsertUser() = '& @crlf)
		ConsoleWrite('  Nuevo usuario = '& $Fname & "  "  & $Lname  & @crlf)
		$query='INSERT INTO Users VALUES (' & $UserID & ',"' & $Fname & '","' & $Lname & '",1,0,' & $epoch & ') ;'
		if _SQLITErun($query,$dbfullPath,$quietSQLQuery) Then
			return true
		Else
			MsgBox(48+4096,"Error inserting User ErrNo 1011" & @CRLF & $query,0,0)
			Return false
		EndIf
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
#endregion
#region   ===========================================================================

	func closeall()
		_SQLite_Close()
		_SQLite_Shutdown()
		exit 30
	EndFunc
#endregion
#region =====================================   Helpers functions  ===============================
	Func _mergeArray($array1, $array2)
		$array1 = _ArrayAdd_Column($array1)
		$size = UBound($array1)
		$newCol = UBound($array1, 2) - 1
		For $i = 0 To $size - 1
			$array1[$i][$newCol] = $array2[$i]
		Next
	;~   _ArrayDisplay($array1)
		Return $array1
	EndFunc   ;==>_mergeArray
	Func _ArrayAdd_Column($Array)
		Local $aTemp[UBound($Array)][UBound($Array, 0) + 1]
		For $i = 0 To UBound($Array) - 1

			For $j = 0 To UBound($Array, 0) - 1
				If UBound($Array, 0) = 1 Then $aTemp[$i][0] = $Array[$i]
				If UBound($Array, 0) > 1 Then $aTemp[$i][$j] = $Array[$i][$j]
			Next
		Next
		Return $aTemp
	EndFunc   ;==>_ArrayAdd_Column
	Func _ClearSciteConsole()
		ConsoleWrite('!!!!!!!!!!!_ClearSciteConsole Func General 92!!!!!!!!!!!!  ' & @CRLF)
		ControlSend("[CLASS:SciTEWindow]", "", "Scintilla2", "+{F5}")
	EndFunc   ;==>_ClearSciteConsole
	Func _GetDOSOutput($sCommand)
	 ConsoleWrite('++_GetDOSOutput $sCommand = ' & $sCommand & @crlf )
		Local $iPID, $sOutput = ""
		$iPID = Run('"' & @ComSpec & '" /c ' & $sCommand, "", @SW_HIDE, 2 + 4)
		While 1
			$sOutput &= StdoutRead($iPID, False, False)
			$err=@error
			If $err Then
				ConsoleWrite('!!  _GetDOSOutput $err = ' & $err & @crlf )
				ExitLoop
			EndIf
	;~ 	Sleep(10)
		WEnd
		ConsoleWrite('>> 	Output = ' & $sOutput & @crlf )
		Return $sOutput
	EndFunc   ;==>_GetDOSOutput
#endregion
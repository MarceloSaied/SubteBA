#region ====INIT ===============================================================
	Func _ConfigInitial()

;~ 		ConsoleWrite('++ConfigDBInitial() = ' & @CRLF)
		_SQLite_down()
;~ 		_DBvarInit()
		; -------check if SQLIte SubteBA db exist
		SQLite_init()
		$SQLq = "SELECT name FROM sqlite_temp_master WHERE type='table';"
		_SQLITErun($SQLq, $dbfile, $quietSQLQuery)
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
	Func SQLInsertUserMessage($TweetID,$TweeMsg,$UserID,$Fname,$Lname,$TweeDate)
;~ 		ConsoleWrite('++InsertMessageSQL() = '& @crlf)
		$query='INSERT INTO UserMessages VALUES (' & $TweetID & ',"' & _
		$TweeMsg & '" ,' & $UserID & ',"' & $Fname &"_"& $Lname & '",' & $TweeDate & ') ;'
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
	Func TelegramInitialMessage($UserID)
;~ 	ConsoleWrite('++TelegramInitialMessage() = '& @crlf)
		$message ="SubteBA BOT , lee los informes de Subte BA en Twitter, y los manda por este canal. "
		$message&='Este canal no es official del subte de Buenos Aires Ni de Metrovias.'  & $nuevaLinea
		$message&= $nuevaLinea
		$message&='Commandos:'  & $nuevaLinea
		$message&='/START -> Activa la recepcion de alertas. '  & $nuevaLinea
		$message&='/STOP  -> Desactiva la recepcion de alertas. '  & $nuevaLinea
		$message&='/INFO -> Muestra este mensage'  & $nuevaLinea
		$message&= $nuevaLinea
		$message&='Futuros Comandos:'  & $nuevaLinea
		$message&='/ACTIVAR A B -> Recepcion de alertas de la Linea A, B (C, D, E, H, P, U)'  & $nuevaLinea
		$message&='/DESACTIVAR A B -> Recepcion de alertas de la Linea A, B (C, D, E, H, P, U)'  & $nuevaLinea
		$message&='/ESTACIONES A -> lista de estaciones de la linea A( B, C, D, E, H, P, U)'  & $nuevaLinea
		$message&='/HORARIOS  -> Horarios de actividad'  & $nuevaLinea
		$message&='/MAPA  -> Mapa de lineas de subte'  & $nuevaLinea
		$message&='/PROPUESTA propuesta -> Enviar propuestas'  & $nuevaLinea

		$respuesta = SendTelegramexec($UserID,$message)
		return $respuesta
;~ 		ConsoleWrite('@@(' & @ScriptLineNumber & ') : $respuestaInitialMessage = ' & $respuesta & @crlf )
	EndFunc
	Func TelegramSTOPMessage($UserID)
		$message ="Los mensajes de alertas han sido deshabilitados" & $nuevaLinea
		$message&='/START -> Para habilitar la recepcion de alertas'  & $nuevaLinea
		$message&='INFO -> para mas informacion.'  & $nuevaLinea

		$respuesta = SendTelegramexec($UserID,$message)
		return $respuesta
;~ 		ConsoleWrite('@@(' & @ScriptLineNumber & ') : TelegramSTOPMessage = ' & $respuesta & @crlf )
	EndFunc
	Func TelegramSTARTMessage($UserID)
		$message ="Los mensajes de alertas han sido habilitados" & $nuevaLinea
		$message&='/STOP-> Para deshabilitar la recepcion de alertas'  & $nuevaLinea
		$message&='INFO -> para mas informacion.'  & $nuevaLinea

		$respuesta = SendTelegramexec($UserID,$message)
		return $respuesta
;~ 		ConsoleWrite('@@(' & @ScriptLineNumber & ') : TelegramSTARTMessage = ' & $respuesta & @crlf )
	EndFunc
	Func TelegramErrorMessage($UserID)
		$message ="No se ha registrado el cambio requerido." & $nuevaLinea
		$message&='Reintente enviar el comando nuevamente.'  & $nuevaLinea
		$message&='INFO -> para mas informacion.'  & $nuevaLinea

		$respuesta = SendTelegramexec($UserID,$message)
		return $respuesta
;~ 		ConsoleWrite('@@(' & @ScriptLineNumber & ') : TelegramErrorMessage = ' & $respuesta & @crlf )
	EndFunc
	Func TelegramBaseMessage($TweetID,$USRmsg,$UserID,$Fname,$Lname,$epoch)
		$message ="No logro entender el mensaje."
		$message&='Reintente enviar el comando nuevamente.'  & $nuevaLinea
		$message&='INFO -> para mas informacion.'& $nuevaLinea & $nuevaLinea
		$message&="Su mensage:" & $nuevaLinea & $USRmsg
		$respuesta = SendTelegramexec($UserID,$message)
		SQLInsertUserMessage($TweetID,$USRmsg,$UserID,$Fname,$Lname,$epoch)
		return $respuesta
;~ 		ConsoleWrite('@@(' & @ScriptLineNumber & ') : TelegramErrorMessage = ' & $respuesta & @crlf )
	EndFunc
	Func ReformatMessage($message)
;~ 	ConsoleWrite('++ReformatMessage() = '& @crlf)
		$msgArr=StringSplit($message,"Actualizado",1)
		$diaHoraArr=stringsplit(StringStripWS($msgArr[2],1+2)," ")
		$hora=$diaHoraArr[2]
		$dia=$diaHoraArr[1]
		$msg="<b>"&$hora&"</b>"&"     " & $dia & $nuevaLinea & StringStripWS($msgArr[1],1+2)
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
	Func SendTelegramexec($chatid,$msgtext="testeo harcoded",$DisableNotification=True)
		$urlMSG="https://api.telegram.org/" & $token & "/sendMessage?chat_id=" & $chatid & _
		"&text=" & $msgtext & "&parse_mode=HTML"
		If $DisableNotification = True Then $urlMSG &= "&disable_notification=True"
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
#region  ==== Tweeter scrapping ===================================================================
	Func TweeterMessages($Username)
		ConsoleWrite('++TweeterMessages() = '& $Username &@crlf)
		$htmltxt=_ScrapTweetMessages($Username)
		if $htmltxt<>"" then
			$TweetArr = _gettweetArr($htmltxt)
			if IsArray($TweetArr) then
				$newMessagesFlag=0
				_ArraySort($TweetArr, 0, 0, 0, 2)
				For $i = 0 To UBound($TweetArr) -1
					$TweetID = $TweetArr[$i][0]
					$TweeMsg = $TweetArr[$i][1]
					$TweeDate = $TweetArr[$i][2]
					if not SQLExist_Message($TweetID) then
						SQLInsertMessage($TweetID,$TweeMsg,$TweeDate)
						$TweetMinOld= (_GetUnixTime() - $TweeDate)/60
						if $TweetMinOld < 60 then
							sendmessages($TweeMsg)
							$newMessagesFlag=1
							ConsoleWrite('+ New messages ' & _NowTime(4) & "   ")
						Else
							ConsoleWrite('+ Old messages ' & $TweetMinOld & "   ")
						endif
					endif
					sleep(2000)
				Next
				if $newMessagesFlag=0 then ConsoleWrite('  No new messages ' & _NowTime(4) & @CRLF)
			endif
		endif
	EndFunc
	func _ScrapTweetMessages($Username)
		Local $sData = InetRead("https://twitter.com/"&$Username)
		Local $nBytesRead = @extended
		ConsoleWrite('@@ BytesRead = ' & $nBytesRead &"   ")
		$htmltxt = BinaryToString($sData)
		If $nBytesRead < 100000 or StringInStr($htmltxt,"subteba")<1 Then
			ConsoleWrite('  Connection issue contacting  ' & "https://twitter.com/"&$Username& @crlf)
			$htmltxt=""
			Return $htmltxt
		endif
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
;~ 	Func isbot($jsonObj)
;~ 		ConsoleWrite('++isbot() = '& @crlf)
;~ 		$res = StripStrJS($jsonObj.jsonPath( "$.result..message.from.is_bot").stringify())
;~ 		ConsoleWrite('@@(' & @ScriptLineNumber & ') : $res = ' & $res & @crlf )
;~ 		return $res
;~ 	EndFunc

	Func Get_BotOffSet()
;~ 		ConsoleWrite('++Get_BotOffSet() = '& @crlf)
		if NOT FileExists($OffsetFile) then
			$fileh = FileOpen($OffsetFile,1+8)
			If $fileh = -1 Then
				ConsoleWrite('   "Unable to open file 1.' & $OffsetFile )
				return 0
			endif
			FileClose($fileh)
		EndIf
		$fileh = FileOpen($OffsetFile,0)
		If $fileh = -1 Then
			ConsoleWrite('   "Unable to open file 2.' & $OffsetFile )
			return 0
		endif
		Local $offset = FileReadLine($fileh)
		if @error = -1 Then
			FileClose($fileh)
			return 0
		endif
		ConsoleWrite("Get OffSet:"& $offset)
		FileClose($fileh)
		return $offset
	EndFunc
	Func Set_BotOffSet($offset)
		ConsoleWrite('++Set_BotOffSet() = '&$offset& @crlf)
		if NOT FileExists($OffsetFile) then
			$fileh = FileOpen($OffsetFile,1+8)
			If $fileh = -1 Then
				ConsoleWrite('   "Unable to open file 3.' & $OffsetFile )
				return 0
			endif
			FileClose($fileh)
		EndIf
		$fileh = FileOpen($OffsetFile,2)
		If $fileh = -1 Then
			ConsoleWrite('   "Unable to open file 4.' & $OffsetFile )
			return 0
		endif
		FileWriteLine($fileh,$offset)
		if @error = -1 Then
			FileClose($fileh)
			return 0
		endif
		ConsoleWrite("    Set OffSet:"& $offset &@crlf)
		FileClose($fileh)
		return 1
	EndFunc
	func UpdateUsers()
		ConsoleWrite('  '&@HOUR & ':' & @MIN&'  Update users.  ' )
		local $s=GetBotUpdates()
		if $s then
			$s=ParseForUserUpdate($s)
			ConsoleWrite('@@ $s = ' & $s & @crlf )
			if $s then
				$oJSON = _OO_JSON_Init()
				$jsonObj = $oJSON.parse($s)
				if $jsonObj.ok  then
					if $jsonObj.jsonPath( "$.result").stringify() = "[[]]" then
						ConsoleWrite(' No Bot data ' & @crlf)
					Else
						ConsoleWrite('  Updating... ' & @crlf)
						$UpdateIDArr = StripIntJS($jsonObj.jsonPath( "$.result..update_id").stringify()  )
						$UserIDArr =   StripIntJS($jsonObj.jsonPath( "$.result..message.from.id").stringify())
						$FnameArr =    StripStrJS($jsonObj.jsonPath( "$.result..message.from.first_name").stringify())
						$LnameArr =    StripStrJS($jsonObj.jsonPath( "$.result..message.from.last_name").stringify())
						$epochArr =    StripIntJS($jsonObj.jsonPath( "$.result..message.date").stringify())
						$menssageArr = StripStrJS($jsonObj.jsonPath( "$.result..message.text").stringify())
						$IsBot =       StripIntJS($jsonObj.jsonPath( "$.result..message.from.is_bot").stringify())
						if $UserIDArr[0] = $UpdateIDArr[0] AND  $UserIDArr[0] = $FnameArr[0] AND _
							$UserIDArr[0] = $LnameArr[0]    AND  $UserIDArr[0] = $epochArr[0] AND _
							$UserIDArr[0] = $menssageArr[0] AND  $UserIDArr[0] = $IsBot[0]  then
							$retBad=0
							for $i=1 to $UserIDArr[0]
								if $IsBot[$i] <> "true" then
									$ret=SQLregister($UserIDArr[$i],$FnameArr[$i],$LnameArr[$i],$epochArr[$i],$menssageArr[$i])
									$ret1=ParseBotMessage($UserIDArr[$i],$FnameArr[$i],$LnameArr[$i],$epochArr[$i],$menssageArr[$i],$UpdateIDArr[$i])
									ConsoleWrite('>> $ret1 = ' & $ret1 & @crlf )
									if (Not $ret) or (Not $ret1)  then	$retBad+=1
									$UpdateID=$UpdateIDArr[$i]
								Else
									ConsoleWrite('+(' & @ScriptLineNumber & ') : $menssageArr[$i] = ' & $menssageArr[$i] & @crlf )
									ConsoleWrite('+(' & @ScriptLineNumber & ') : $IsBot[$i] = ' & $IsBot[$i] & @crlf )
									$retBad=1
								endif
							next
							if $retBad=0 then Set_BotOffSet($UpdateID+1)
						Else
							_printFromArray($UserIDArr)
							_printFromArray($FnameArr)
							_printFromArray($LnameArr)
							_printFromArray($epochArr)
							_printFromArray($menssageArr)
							ConsoleWrite('  Error in JS array . exiting..... ' & @crlf)
							exit 29
						endif
					endif
				endif
			endif
		endif
	EndFunc
	Func GetBotUpdates()
		$offset=Get_BotOffSet()
		$urlMSG="https://api.telegram.org/" & $token & "/getUpdates?offset="&$offset
		$sGet = HttpGetJson1($urlMSG)
;~ 		ConsoleWrite('@@ $sGet = ' & $sGet & @crlf )
		if $sGet<>"" then
			return $sGet
		Else
			$s_text="  Error getUpdates from Telegram = "
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
	Func ParseForUserUpdate($s)
;~ 		if StringInStr($s,'"location":') Then
;~ 			$s='{"ok":true,"result":[]}'
;~ 			return $s
;~ 		endif
;~ 		eliminate location info
;~ "location":{"latitude":-34.631010,"longitude":-58.469731}}
		$s=StringRegExpReplace($s,'(?s)(?i)"location":{"latitude":(.*?),"longitude":(.*?)}'  ,  '"text": ""' )
;~ 		eliminate contact info
		$s=StringRegExpReplace($s,'(?s)(?i)"contact":(.*?)}'  ,  '"text": ""' )
;~ 		replace username last-name
		$s=StringReplace($s,'"username":','"last_name":')
;~ 		eliminate sticker info
		$s=StringRegExpReplace($s,'(?s)(?i)"sticker":(.*?)}(.*?)}'  ,  '"text": ""' )
		return $s
	EndFunc
	Func SQLregister($UserID,$Fname,$Lname,$epoch,$mensage)
;~ 	ConsoleWrite('++SQLregister() = '& @crlf)
		$existUser=0
		If SQLExistUser($UserID)=$userID then $existUser=1
		if $existUser=0 then
			$setactive=1
			$ret=SQLInsertUser($UserID,$Fname,$Lname,$epoch,$setactive)
			if $ret then
				$ret=TelegramSTOPMessage($UserID)
				if $ret=0 then return true
			else
				$ret=TelegramErrorMessage($UserID)
				if $ret=0 then return true
			endif
			return false
		endif

		$setactive=-1
		if AIMessage($mensage,"/START") then $setactive=1
		if AIMessage($mensage,"/STOP") then $setactive=0
		if $existUser=1 AND $setactive<>-1 then
			$ret=SQLUpdateUserActive($UserID,$Fname,$Lname,$setactive)
			if $ret and $setactive=0 then
				$ret=TelegramSTOPMessage($UserID)
				if $ret=0 then return true
			endif
			if $ret and $setactive=1 then
				$ret=TelegramSTARTMessage($UserID)
				if $ret=0 then return true
			endif
			if NOT $ret then TelegramErrorMessage($UserID)
			return false
		endif

		return true
	EndFunc
	Func SQLInsertUser($UserID,$Fname,$Lname,$epoch,$active=1)
		ConsoleWrite('  Nuevo usuario = '& $Fname & "  "  & $Lname  & @crlf)
		$query='INSERT INTO Users VALUES (' & $UserID & ',"' & $Fname & '","' & $Lname & '",' & $active &',0,' & $epoch & ') ;'
		if _SQLITErun($query,$dbfullPath,$quietSQLQuery) Then
			return true
		Else
			MsgBox(48+4096,"Error inserting User ErrNo 1011" & @CRLF & $query,0,0)
			Return false
		EndIf
	EndFunc
	Func SQLUpdateUserActive($UserID,$Fname,$Lname,$active=1)
		ConsoleWrite('    Usuario Activo 1/Start 0/Stop= '&$active& "  " & $Fname & "  "  & $Lname  & @crlf)
		$query='UPDATE  Users SET Active=' & $active &' WHERE UserID='& $UserID & ' ;'
		if _SQLITErun($query,$dbfullPath,$quietSQLQuery) Then
			return true
		Else
			ConsoleWrite("       Error updating active user User ErrNo 1012" & @CRLF & $query& @crlf)
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
	Func _timeBetween($cTime, $sTime, $eTime)
		 If Not _DateIsValid('2000/01/01 ' & $cTime) Then Return -1
		 If Not _DateIsValid('2000/01/01 ' & $sTime) Then Return -2
		 If Not _DateIsValid('2000/01/01 ' & $eTime) Then Return -3
		 ;~  ConsoleWrite(_DateDiff('s', '2000/01/01 ' & $cTime & ':00', '2000/01/01 ' & $sTime & ':00') & @CRLF)
		 ;~  ConsoleWrite(_DateDiff('s', '2000/01/01 ' & $cTime & ':00', '2000/01/01 ' & $eTime & ':00') & @CRLF)
		 If _DateDiff('s', '2000/01/01 ' & $cTime & ':00', '2000/01/01 ' & $sTime & ':00') < 0 And _
			 _DateDiff('s', '2000/01/01 ' & $cTime & ':00', '2000/01/01 ' & $eTime & ':00') > 0 Then
			  Return 1
		 Else
			  Return 0
		 EndIf
	EndFunc  ; ==>_timeBetween
#endregion
#region time
	Func  Sec2Time($nr_sec)
		$sec2time_hour = Int($nr_sec / 3600)
		$sec2time_min = Int(($nr_sec - $sec2time_hour * 3600) / 60)
		$sec2time_sec = $nr_sec - $sec2time_hour * 3600 - $sec2time_min * 60
		Return StringFormat('%02d:%02d:%02d', $sec2time_hour, $sec2time_min, $sec2time_sec)
	EndFunc   ;==>Sec2Time
	Func _GetUnixTime($sDate = 0);Date Format: 2013/01/01 00:00:00 ~ Year/Mo/Da Hr:Mi:Se
		Local $aSysTimeInfo = _Date_Time_GetTimeZoneInformation()
		Local $utcTime = ""
		If Not $sDate Then $sDate = _NowCalc()
		If Int(StringLeft($sDate, 4)) < 1970 Then Return ""
		If $aSysTimeInfo[0] = 2 Then
			$utcTime = _DateAdd('n', $aSysTimeInfo[1] + $aSysTimeInfo[7], $sDate)
		Else
			$utcTime = _DateAdd('n', $aSysTimeInfo[1], $sDate)
		EndIf
		Return _DateDiff('s', "1970/01/01 00:00:00", $utcTime)
	EndFunc   ;==>_GetUnixTime
#endregion
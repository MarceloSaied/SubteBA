#region init
	#NoTrayIcon
	#include <Misc.au3>
	If _Singleton(@ScriptName, 1) = 0 Then ; allow only one instance
		MsgBox(0, "Warning", "An occurence of " & @ScriptName & " is already running")
		Exit
	EndIf
#endregion init
#region includes
	#include <includes.au3>
#endregion includes



local $Username=IniRead("..\..\secret\config.ini","Twitter","Username","subteba")
Local $sData = InetRead("https://twitter.com/"&$Username)
Local $nBytesRead = @extended
ConsoleWrite('@@(' & @ScriptName & '-' & @ScriptLineNumber & ') : $nBytesRead = ' & $nBytesRead & @CRLF)
$htmltxt = BinaryToString($sData)
If $nBytesRead < 100 Then
;~   ConsoleWrite('@@ EXITCODE 10 : $nBytesRead = ' & $nBytesRead & @crlf )
	Exit 5
EndIf
$TweetMSGArr = StringRegExp($htmltxt, '(?s)(?i)<div class="js-tweet-text-container">(.*?)</DIV>', 3)
$TweetIDArr = StringRegExp($htmltxt, '(?s)(?i)data-tweet-id="(.*?)"', 3)
;~ data-tweet-id="915890851867275265"

$TweetArr = _mergeArray($TweetIDArr, $TweetMSGArr)
;~ _ArrayDisplay($TweetArr)


If IsArray($TweetArr) Then
	$U = UBound($TweetArr) - 1
	For $i = $u To 1 Step -1
		$TweetMessage = StringRegExp($TweetArr[$i][1], '(?s)(?i)<p(.*?)>(.*?)</p>', 1)
		$mensaje = clearstring($TweetMessage[1])
;~ 		_sendmessages($mensaje)
	Next
	Exit 10
Else
	Exit 1
EndIf

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
Func _sendmessages($message)
	Local $fileh = FileOpen("..\..\secret\recipients.txt", 0)
	If $fileh = -1 Then
		Exit
	EndIf
	While 1
		Local $chatidLine = FileReadLine($fileh)
		If @error = -1 Then ExitLoop
		$chatidArr = StringSplit($chatidLine, ',')
		$chatid = $chatidArr[1]
		ConsoleWrite('@@ $chatid = ' & $chatid & "  ->  " & $chatidArr[2] & @CRLF)
		$sCommandStart = @TempDir & '\SendTelegramSubteBA.exe -m "' & $message & '" -chatid ' & $chatid
		$respuesta = _GetDOSOutput($sCommandStart)
		ConsoleWrite('@ $respuesta = ' & $respuesta & @CRLF)
	WEnd
	FileClose($fileh)
EndFunc   ;==>_sendmessages
Func _ClearSciteConsole()
	ConsoleWrite('!!!!!!!!!!!_ClearSciteConsole Func General 92!!!!!!!!!!!!  ' & @CRLF)
	ControlSend("[CLASS:SciTEWindow]", "", "Scintilla2", "+{F5}")
EndFunc   ;==>_ClearSciteConsole
Func _GetDOSOutput($sCommand)
;~ 	 ConsoleWrite('++_GetDOSOutput $sCommand = ' & $sCommand & @crlf )
	Local $iPID, $sOutput = ""
	$iPID = Run('"' & @ComSpec & '" /c ' & $sCommand, "", @SW_HIDE, 2 + 4)
	While 1
		$sOutput &= StdoutRead($iPID, False, False)
		If @error Then
			ExitLoop
		EndIf
;~ 	Sleep(10)
	WEnd
;~ 	 ConsoleWrite('>> 	Output = ' & $sOutput & @crlf )
	Return $sOutput
EndFunc   ;==>_GetDOSOutput

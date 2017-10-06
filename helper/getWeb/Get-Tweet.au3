#include <Array.au3>
#include <..\..\udf\CleanString.au3>

FileInstall("../SendTelegramSubteBA/SendTelegramSubteBA.exe", @TempDir & "\SendTelegramSubteBA.exe" , 1 )
Local $sData = InetRead("https://twitter.com/subteba")
Local $nBytesRead = @extended
$htmltxt=BinaryToString($sData)

$TweetArr=""
$TweetArr = StringRegExp($htmltxt,'(?s)(?i)<div class="js-tweet-text-container">(.*?)</DIV>',3)
if IsArray($TweetArr) then
$U=UBound($TweetArr)-1
  For $i = $u To 1 Step -1
	 $TweetMessage = StringRegExp($TweetArr[$i],'(?s)(?i)<p(.*?)>(.*?)</p>',1)
	 $mensaje=clearstring($TweetMessage[1])
	 _sendmessages($mensaje)
  Next
  exit 10
Else
  exit 1
endif


Func _sendmessages($message)
  Local $fileh = FileOpen("..\..\secret\recipients.txt", 0)
  If $fileh = -1 Then
	  Exit
  EndIf
  While 1
	  Local $chatidLine = FileReadLine($fileh)
	  If @error = -1 Then ExitLoop
	  $chatidArr=StringSplit($chatidLine,',')
	  $chatid=$chatidArr[1]
	  ConsoleWrite('@@ $chatid = ' & $chatid & "  ->  " & $chatidArr[2] & @crlf )
	  $sCommandStart=@TempDir&'\SendTelegramSubteBA.exe -m "'&$message& '" -chatid '& $chatid
	  $respuesta=_GetDOSOutput($sCommandStart )
	  ConsoleWrite('@ $respuesta = ' & $respuesta & @crlf )
  WEnd
  FileClose($fileh)
EndFunc
 Func _ClearSciteConsole()
	 ConsoleWrite('!!!!!!!!!!!_ClearSciteConsole Func General 92!!!!!!!!!!!!  '& @crlf)
	 ControlSend("[CLASS:SciTEWindow]", "", "Scintilla2", "+{F5}")
 EndFunc
 Func _GetDOSOutput($sCommand )
;~ 	 ConsoleWrite('++_GetDOSOutput $sCommand = ' & $sCommand & @crlf )
	 Local $iPID, $sOutput = ""
	 $iPID = Run('"' & @ComSpec & '" /c ' & $sCommand, "", @SW_HIDE, 2 + 4)
	 While 1
		 $sOutput &= StdoutRead($iPID, false, False)
		 If @error Then
			 ExitLoop
		 EndIf
	 ;~ 	Sleep(10)
	 WEnd
;~ 	 ConsoleWrite('>> 	Output = ' & $sOutput & @crlf )
	 Return $sOutput
 EndFunc   ;==>_GetDOSOutput

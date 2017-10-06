#include <Array.au3>
#include <..\..\udf\CleanString.au3>

FileInstall("../SendTelegramSubteBA/SendTelegramSubteBA.exe", @TempDir & "\SendTelegramSubteBA.exe" , 1 )
Local $sData = InetRead("https://twitter.com/subteba")
Local $nBytesRead = @extended
$htmltxt=BinaryToString($sData)

$TweetMSGArr = StringRegExp($htmltxt,'(?s)(?i)<div class="js-tweet-text-container">(.*?)</DIV>',3)
$TweetIDArr = StringRegExp($htmltxt,'(?s)(?i)data-tweet-id="(.*?)"',3)
;~ data-tweet-id="915890851867275265"

$TweetArr=_mergeArray($TweetIDArr,$TweetMSGArr)
;~ _ArrayDisplay($TweetArr)


if IsArray($TweetArr) then
  $U=UBound($TweetArr)-1
  For $i = $u To 1 Step -1
	 $TweetMessage = StringRegExp($TweetArr[$i][1],'(?s)(?i)<p(.*?)>(.*?)</p>',1)
	 $mensaje=clearstring($TweetMessage[1])
;~ 	 _sendmessages($mensaje)
  Next
  exit 10
Else
  exit 1
endif

func _mergeArray($array1,$array2)
  $array1=_ArrayAdd_Column($array1)
  $size = UBound($array1)
  $newCol =UBound($array1,2)-1
  For $i = 0 To $size - 1
	 $array1[$i][$newCol] = $array2[$i]
  Next
;~   _ArrayDisplay($array1)
  return $array1
EndFunc
Func _ArrayAdd_Column($Array)
    Local $aTemp[UBound($Array)][UBound($Array, 0) + 1]
    For $i = 0 To UBound($Array) - 1

        For $j = 0 To UBound($Array, 0) - 1
            If UBound($Array, 0) = 1 Then $aTemp[$i][0] = $Array[$i]
            If UBound($Array, 0) > 1 Then $aTemp[$i][$j] = $Array[$i][$j]
        Next
    Next
    Return $aTemp
EndFunc  ;==>_ArrayAdd_Column
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

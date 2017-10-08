#region init
	#NoTrayIcon
	#include <Misc.au3>
	If _Singleton(@ScriptName, 1) = 0 Then ; allow only one instance
		MsgBox(0, "Warning", "An occurence of " & @ScriptName & " is already running")
		Exit
	EndIf
	#include <includes\includes.au3>
	_ConfigInitial()
#endregion init


local $Username=IniRead("..\..\secret\config.ini","Twitter","Username","subteba")
while 1
	$htmltxt=_ScrapTweetMessages($Username)
	$TweetArr = _gettweetArr($htmltxt)

	For $i = 0 To UBound($TweetArr) -1
		$TweetID = $TweetArr[$i][0]
		$TweeMsg = $TweetArr[$i][1]
		$TweeDate = $TweetArr[$i][2]
		if not Exist_Message($TweetID) then
			$query='INSERT INTO messages VALUES (' & $TweetID & ',"' & $TweeMsg & '" ,' & $TweeDate & ') ;'
			if _SQLITErun($query,$dbfullPath,$quietSQLQuery) Then
			Else
				MsgBox(48+4096,"Error inserting mesages ErrNo 1010" & @CRLF & $query,0,0)
;~ 			Return false
			EndIf
			sendmessages($TweeMsg)
		endif
	Next

	$minutes=15
	sleep($minutes*60*1000)
wend
;~ SendTelegramMessages($TweetArr)
closeall()






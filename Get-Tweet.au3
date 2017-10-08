#region init
	#NoTrayIcon
	#include <Misc.au3>
	If _Singleton(@ScriptName, 1) = 0 Then ; allow only one instance
		MsgBox(0, "Warning", "An occurence of " & @ScriptName & " is already running")
		Exit
	EndIf

$SendToAll=0 ; si es 0 solo se manda a Dev users
              ; si es 1 se manda a todos


	#include <includes\includes.au3>
	_ConfigInitial()
#endregion init



local $Username=IniRead("..\..\secret\config.ini","Twitter","Username","subteba")
while 1
	$htmltxt=_ScrapTweetMessages($Username)
	$TweetArr = _gettweetArr($htmltxt)
	if IsArray($TweetArr) then
		$newMessagesFlag=0
		For $i = 0 To UBound($TweetArr) -1
			$TweetID = $TweetArr[$i][0]
			$TweeMsg = $TweetArr[$i][1]
			$TweeDate = $TweetArr[$i][2]
			if not SQLExist_Message($TweetID) then
				SQLInsertMessage($TweetID,$TweeMsg,$TweeDate)
				sendmessages($TweeMsg)
				$newMessagesFlag=1
				ConsoleWrite('+ New messages ' & _NowTime(4) & @CRLF)
			endif
		Next
		if $newMessagesFlag=0 then ConsoleWrite(' No new messages ' & _NowTime(4) & @CRLF)
	endif
	$minutes=0.5
	sleep($minutes*60*1000)
wend
;~ SendTelegramMessages($TweetArr)
closeall()






#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=images\twirl.ico
#AutoIt3Wrapper_Outfile=release\Get-Tweet.exe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=SubteBA Telegram Alerter
#AutoIt3Wrapper_Res_Description=SubteBA Telegram Alerter
#AutoIt3Wrapper_Res_Fileversion=0.2.0.21
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=By Marcelo Saied
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#region init
	#NoTrayIcon
	#include <Misc.au3>
	If _Singleton(@ScriptName, 1) = 0 Then ; allow only one instance
		MsgBox(0, "Warning", "An occurence of " & @ScriptName & " is already running")
		Exit
	EndIf

	$SendToAll=1 ; si es 0 solo se manda a Dev users
					  ; si es 1 se manda a todos


	#include <includes\includes.au3>
	_ConfigInitial()
#endregion init

local $Username=IniRead("..\..\secret\config.ini","Twitter","Username","subteba")
while 1
;~ Get tweeter data , and send messages
	If _timeBetween(@HOUR & ':' & @MIN, $StartTimeScrap, $EndTimeScrap) then
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
			if $newMessagesFlag=0 then ConsoleWrite('  No new messages ' & _NowTime(4) & @CRLF)
		endif
	Else
		ConsoleWrite('  Out of Scrap Time '& @CRLF)
	endif

	$minutes=7
	ConsoleWrite('   sleeping '&$minutes& @CRLF)
	sleep($minutes*60*1000)

	If _timeBetween(@HOUR & ':' & @MIN, $StartTimeBot, $EndTimeBot) then
		UpdateUsers()
	endif
wend

closeall()






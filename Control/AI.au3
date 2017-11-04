Func AImessage($msg,$word)
;~ 	ConsoleWrite('++AImessage() = '& @crlf)
	if $msg<>"" then
		if StringInStr($msg,$word,2) then 	return 1
		return 0
	Else
		return 0
	endif
EndFunc
Func ParseBotMessage($UserID,$Fname,$Lname,$epoch,$mensage,$TweetID,$MsgID)
;~ 	ConsoleWrite('++ParseBotMessage() = '& @crlf)
	if AIMessage($mensage,"/START") then return true
	if AIMessage($mensage,"/STOP") then return true
	if AIMessage($mensage,"info") or AIMessage($mensage,"informacion")  or AIMessage($mensage,"/INFO") or AIMessage($mensage,"help") then
		$ret=TelegramInitialMessage($UserID)
		if $ret=0 then return true
		return false
	endif

	if AIMessage($mensage,"/ACTIVAR") then
		$ret=KeyboardActivate($UserID)
		$ahora=0
		if $ret then return true
		return false
	endif

	if AIMessage($mensage,"/DESACTIVAR") then
		$ret=KeyboardDesActivate($UserID)
		$ahora=0
		if $ret then
			SQLregisterKeyboard($UserID,$MsgID,$epoch)
			return true
		endif
		return false
	endif

	if AIMessage($mensage,$msgToAllSecuence) then
		$msg=StringReplace($mensage,$msgToAllSecuence&" ","")
		$ret=sendmessages($msg & " Actualizado " & @MDAY &"/"& @MON &"/"&@YEAR & " " & _NowTime(4))
		if $ret then return true
		return false
	endif

	if AIMessage($mensage,"Location:")=1 then
		$ret=TelegramLocationMessage($TweetID,$mensage,$UserID,$Fname,$Lname,$epoch)
		if $ret=0 then return true
		return false
	endif

	$ret=TelegramBaseMessage($TweetID,$mensage,$UserID,$Fname,$Lname,$epoch)
	if $ret=0 then return true
	return false
EndFunc

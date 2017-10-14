Func AImessage($msg,$word)
;~ 	ConsoleWrite('++AImessage() = '& @crlf)
	if $msg<>"" then
		if StringInStr($msg,$word,2) then 	return 1
		return 0
	Else
		return 0
	endif
EndFunc
Func ParseBotMessage()
;~ 	ConsoleWrite('++ParseBotMessage() = '& @crlf)
	if AIMessage($mensage,"info") or AIMessage($mensage,"informacion")  or AIMessage($mensage,"/INFO") or AIMessage($mensage,"help") then
		$ret=TelegramInitialMessage($UserID)
		if $ret=0 then return true
		return false
	endif



	$ret=TelegramBaseMessage($UserID)
	if $ret=0 then return true
	return false
EndFunc



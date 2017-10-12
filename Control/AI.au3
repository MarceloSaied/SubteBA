Func AImessage($msg,$word)
;~ 	ConsoleWrite('++AImessage() = '& @crlf)
	if $msg<>"" then
		if StringInStr($msg,$word) then 	return 1
		return 0
	Else
		return 0
	endif
EndFunc

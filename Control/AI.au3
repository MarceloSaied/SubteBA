Func AImessage($msg,$word)
;~ 	ConsoleWrite('++AImessage() = '& @crlf)
	if $msg<>"" then
		if StringInStr($msg,$word,2) then 	return 1
		return 0
	Else
		return 0
	endif
EndFunc
Func ParseBotMessage($UserID,$Fname,$Lname,$epoch,$mensage,$TweetID)
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
		if $ret then return true
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

func KeyboardActivate($UserID)
	$keybrd =  '{"inline_keyboard":['
	$keybrd &= '['
	$keybrd &= '{"text":"Linea A","callback_data":"A_ON"},'
	$keybrd &= '{"text":"Linea B","callback_data":"B_ON"},'
	$keybrd &= '{"text":"Linea C","callback_data":"C_ON"}'
	$keybrd &= '],['
	$keybrd &= '{"text":"Linea E","callback_data":"E_ON"},'
	$keybrd &= '{"text":"Linea F","callback_data":"F_ON"},'
	$keybrd &= '{"text":"Linea H","callback_data":"H_ON"}'
	$keybrd &= '],['
	$keybrd &= '{"text":"Linea P","callback_data":"P_ON"},'
	$keybrd &= '{"text":"Linea U","callback_data":"U_ON"},'
	$keybrd &= '{"text":"Todas","callback_data":"TODAS_ON"}'
	$keybrd &= '],['
	$keybrd &= ']'
	$keybrd &= ']}'
	$res=_SendMsg($UserID,"Elija una Linea para activar las alertas","HTML",$keybrd)
	if $res then return True
	return false
EndFunc
func KeyboardDesActivate($UserID)
	$keybrd =  '{"inline_keyboard":['
	$keybrd &= '['
	$keybrd &= '{"text":"Linea A","callback_data":"A_OFF"},'
	$keybrd &= '{"text":"Linea B","callback_data":"B_OFF"},'
	$keybrd &= '{"text":"Linea C","callback_data":"C_OFF"}'
	$keybrd &= '],['
	$keybrd &= '{"text":"Linea E","callback_data":"E_OFF"},'
	$keybrd &= '{"text":"Linea F","callback_data":"F_OFF"},'
	$keybrd &= '{"text":"Linea H","callback_data":"H_OFF"}'
	$keybrd &= '],['
	$keybrd &= '{"text":"Linea P","callback_data":"P_OFF"},'
	$keybrd &= '{"text":"Linea U","callback_data":"U_OFF"},'
	$keybrd &= '{"text":"Todas","callback_data":"TODAS_OFF"}'
	$keybrd &= '],['
	$keybrd &= ']'
	$keybrd &= ']}'
	$res=_SendMsg($UserID,"Elija una Linea para desactivar las alertas","HTML",$keybrd)
	if $res then return True
	return false
EndFunc
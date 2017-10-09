#region init
	#NoTrayIcon
	#include <Misc.au3>
	If _Singleton(@ScriptName, 1) = 0 Then ; allow only one instance
		MsgBox(0, "Warning", "An occurence of " & @ScriptName & " is already running")
		Exit
	EndIf

	#include <includes\includesJS.au3>
	_ConfigInitial()
#endregion init

;~ new user
;~ local $s='{"ok":true,"result":[{"update_id":566511565,"message":{"message_id":340,"from":{"id":205102520,"is_bot":false,"first_name":"Marcelo","last_name":"Saied","language_code":"en-US"},"chat":{"id":205102519,"first_name":"Marcelo","last_name":"Saied","type":"private"},"date":1507310174,"text":"/start","entities":[{"offset":0,"length":6,"type":"bot_command"}]}}]}'
;~ mensages
;~ local $s='{"ok":true,"result":[{"update_id":566511562,"message":{"message_id":35,"from":{"id":205102519,"is_bot":false,"first_name":"Marcelo","last_name":"Saied","language_code":"en-US"},"chat":{"id":205102519,"first_name":"Marcelo","last_name":"Saied","type":"private"},"date":1506834706,"text":"msg 1"}}  ]}'

;~ Local $s='{"ok":true,"result":[{"update_id":566511567,"message":{"message_id":453,"from":{"id":205102520,"is_bot":false,"first_name":"Marcelo","last_name":"Saied","language_code":"en-US"},"chat":{"id":205102519,"first_name":"Marcelo","last_name":"Saied","type":"private"},"date":1507501930,"text":"hello there"}},{"update_id":566511568,"message":{"message_id":454,"from":{"id":205102521,"is_bot":false,"first_name":"Marcelo","last_name":"Saied","language_code":"en-US"},"chat":{"id":205102521,"first_name":"Marcelo","last_name":"Saied","type":"private"},"date":1507507372,"text":"msg1"}},{"update_id":566511569,"message":{"message_id":455,"from":{"id":205102522,"is_bot":false,"first_name":"Marcelo","last_name":"Saied","language_code":"en-US"},"chat":{"id":205102519,"first_name":"Marcelo","last_name":"Saied","type":"private"},"date":1507513642,"text":"mensage2 , coma, mensage3"}}]}'

local $s=GetBotUpdates()
if $s then
	$oJSON = _OO_JSON_Init()
	$jsonObj = $oJSON.parse($s)
	$type = $jsonObj.type($jsonObj)
	ConsoleWrite("$jsonObj.type($jsonObj  ->" & $type & @CR) ;
	if $jsonObj.ok  then
		if $jsonObj.jsonPath( "$.result").stringify() = "[[]]" then
			ConsoleWrite(' No Bot data ' & @crlf)
		Else
;~ 			ConsoleWrite("=2==result==================================="  & @CR)
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result").stringify() &  @CR )
;~ 			ConsoleWrite("=3=update_id================================="  & @CR)
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..update_id").stringify() &  @CR )
;~ 			ConsoleWrite("=3==message_id==============================="  & @CR)
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message").stringify() &  @CR )
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message_id").stringify() &  @CR )
;~ 			ConsoleWrite("=3==FROM====================================="  & @CR)
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.from").stringify() &  @CR )
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.from.id").stringify() &  @CR )
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.from.is_bot").stringify() &  @CR )
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.from.first_name").stringify() &  @CR )
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.from.last_name").stringify() &  @CR )
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.from.language_code").stringify() &  @CR )
;~ 			ConsoleWrite("=3==CHAT====================================="  & @CR)
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.chat").stringify() &  @CR )
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.chat.id").stringify() &  @CR )
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.chat.first_name").stringify() &  @CR )
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.chat.last_name").stringify() &  @CR )
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.chat.type").stringify() &  @CR )
;~ 			ConsoleWrite("=4===DATE===================================="  & @CR)
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.date").stringify() &  @CR )
;~ 			ConsoleWrite("=5===TEXT==================================="  & @CR)
;~ 			ConsoleWrite("-> " & $jsonObj.jsonPath( "$.result..message.text").stringify() &  @CR )

			$UserIDArr = StripIntJS($jsonObj.jsonPath( "$.result..message.from.id").stringify())
			_printFromArray($UserIDArr)
			$FnameArr = StripStrJS($jsonObj.jsonPath( "$.result..message.from.first_name").stringify())
			_printFromArray($FnameArr)
			$LnameArr = StripStrJS($jsonObj.jsonPath( "$.result..message.from.last_name").stringify())
			_printFromArray($LnameArr)
			$epochArr = StripIntJS($jsonObj.jsonPath( "$.result..message.date").stringify())
			_printFromArray($epochArr)
			$menssageJSArr = StripStrJS($jsonObj.jsonPath( "$.result..message.text").stringify())
			_printFromArray($menssageJSArr)

			for $i=1 to $UserIDArr[0]
				SQLregister($UserIDArr[$i],$FnameArr[$i],$LnameArr[$i],$epochArr[$i])
			next
		endif
	endif


endif

#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=images\twirl.ico
#AutoIt3Wrapper_Outfile=release\Get-Tweet.exe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=SubteBA Telegram Alerter
#AutoIt3Wrapper_Res_Description=SubteBA Telegram Alerter
#AutoIt3Wrapper_Res_Fileversion=0.2.0.27
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=By Marcelo Saied
#AutoIt3Wrapper_Run_Obfuscator=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#region init
	#NoTrayIcon
	#include <Misc.au3>
	If _Singleton(@ScriptName, 1) = 0 Then ; allow only one instance
		MsgBox(0, "Warning", "An occurence of " & @ScriptName & " is already running")
		Exit
	EndIf

	$SendToAll=0 ; si es 0 solo se manda a Dev users
					  ; si es 1 se manda a todos
	if @Compiled then $SendToAll=1

	#include <includes\includes.au3>
	_ConfigInitial()
#endregion init
local $Username=IniRead("..\..\secret\config.ini","Twitter","Username","subteba")

#region testeos
;~ 	ConsoleWrite("Test _SendMsg      -> "  & @TAB & _SendMsg($DEVChatID,"Testeo _SendMsg") & @CRLF)
	$keybrd='[[Hello,Hello2]]'
;~ 	$keybrd = '{"keyboard":[[{ text: "Yes" }],[{ text: "No" }]] }'
;~ 	$keybrd = "[['top-left', 'top-right'],['bottom-left', 'bottom-right']]"
;~ 	$keybrd='[[KeyboardButton(text="Yes"), KeyboardButton(text="No")]]'
	ConsoleWrite("Test _SendMsg      -> "  & @TAB & _SendMsg($DEVChatID,"Test _SendMsg","HTML",$keybrd) & @CRLF)

;~ 	$Path="images\workflow1.jpg"
;~ 	$Caption="testeo de envio de imagen imagen"
;~ 	$DEVChatID=464405525 ; gille
;~ 	_SendPhoto($DEVChatID, $Path, $Caption)
	exit
#endregion
while 1
;~ Get tweeter data , and send messages
	$beginScrap = TimerInit()
	If _timeBetween(@HOUR & ':' & @MIN, $StartTimeScrap, $EndTimeScrap) then
		TweeterMessages($Username)
		consolewrite('>>   '&$Username&' Scrap time: '&Sec2Time(TimerDiff($beginScrap)/1000) & @crlf)
	Else
		ConsoleWrite(' Out of Scrap Time '& $StartTimeScrap & "  To "  & $EndTimeScrap & @CRLF)
	endif

	while ($TweeterScrapMsec - TimerDiff($beginScrap)) > 0
;~ 		ConsoleWrite('>>        TweeterScrapMsec = ' & $TweeterScrapMsec & " > "& TimerDiff($beginScrap)&@crlf )
		$beginGetUpdates = TimerInit()
		If _timeBetween(@HOUR & ':' & @MIN, $StartTimeBot, $EndTimeBot) then
			UpdateUsers()
		endif
		while $GetUpdateTimemsec > TimerDiff($beginGetUpdates)
;~ 			ConsoleWrite('@@GetUpdateTimemsec = ' & $GetUpdateTimemsec & " > "& TimerDiff($beginGetUpdates)&@crlf )
			Sleep(100)
		wend
	wend
wend

closeall()






#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=images\Rocket.ico
#AutoIt3Wrapper_Outfile=release\Get-Bot.exe
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Telegram Bot Handeler
#AutoIt3Wrapper_Res_Description=Telegram Bot Handeler
#AutoIt3Wrapper_Res_Fileversion=0.2.0.47
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

while 1
;~ Get tweeter data , and send messages
	$beginGetUpdates = TimerInit()
	If _timeBetween(@HOUR & ':' & @MIN, $StartTimeBot, $EndTimeBot) then
		UpdateUsers()
	endif
	while $GetUpdateTimemsec > TimerDiff($beginGetUpdates)
		Sleep(100)
	wend
wend

closeall()






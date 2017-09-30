#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\images\RT1.ico
#AutoIt3Wrapper_Outfile=SendTelegramSubteBA.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment="By Marcelo N. Saied "
#AutoIt3Wrapper_Res_Description="Send Telegram application Message"
#AutoIt3Wrapper_Res_Fileversion=1.0.0.1
#AutoIt3Wrapper_Res_ProductVersion=1.0
#AutoIt3Wrapper_Res_LegalCopyright=Marcelo N. Saied
#AutoIt3Wrapper_Res_Field=Productname|SendTelegramSubteBA.exe
#AutoIt3Wrapper_Res_Field=ProductVersion|Version 1.0
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/mergeonly
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; *** Start added by AutoIt3Wrapper ***
#include <FileConstants.au3>
; *** End added by AutoIt3Wrapper ***
;===================================================================
;===================================================================
;===                                                             ===
;===   Name   = SendTelegramSubteBA.exe                                 ===
;===                                                             ===
;===   Description:Send Telegram application Message             ===
;===                                                             ===
;===   Author: Marcelo N. Saied                                  ===
;===           marcelosaied@gmail.com                            ===
;===                                                             ===
;===   Automation and Scripting Language: AUTOIT  v3.3.8.1       ===
;===           http://www.autoitscript.com/site/                 ===
;===                                                             ===
;===   Created on: Jan 9 , 2016                                  ===
;===                                                             ===
;===================================================================
;===================================================================
#Region  ------------ AutoIt3Wrapper
$chatID=""
#EndRegion
#Region  ------------ Modules
	#include <File.au3>
	#include <Constants.au3>
	#include <Date.au3>
	#include <Array.au3>
	#include <date.au3>
	#include <IE.au3>
	#include <Array.au3>
	#include "..\..\udf\WinHttp.au3"
#EndRegion
#Region  -----------------------------  parse arguments ------------------------------
; Help
   $helpText="Help:                                                                     " & @crlf & _
			"                                                                           " & @crlf & _
			"      Usage:                                                               " & @crlf & _
			"          SendTelegramSubteBA.exe -m <message> -chatid chatid <optional>   " & @crlf & _
			"                                                                           " & @crlf & _
			"          -m   message                                                     " & @crlf & _
			"          -chatid  chatid  <optional>                                      " & @crlf & _
			"                                                                           " & @crlf & _
			"            Author: Saied, Marcelo                                         " & @crlf & _
			"                                                                           " & @crlf & _
			"                                      2017                                 " & @crlf & _
			"                                                                           " & @crlf & _
			"                                                                           " & @crlf & _
			"                                                                           " & @crlf & _
			"                                                                           "
;~

   if $CmdLine[0]=0 then
	  ConsoleWrite($helpText)
	   exit 1
   endif
   if StringStripWS($CmdLine[1],4)="?"   then  ; output help
	  ConsoleWrite($helpText)
	    exit 3
	endif
;~ 	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $CmdLine[0] = ' & $CmdLine[0] & @crlf )
    if $CmdLine[0]<2 then  ; if no 3 argumentes then exit    -f filename  -u username -p password  ([-d][-nd])
	  ConsoleWrite("No enough arguments. <Usage>: SendTelegramSubteBA.exe -m <message> -chatid  chatid  <optional>  ")
	  exit 5
   endif

   for $x=1 to $CmdLine[0]-1
	  Select
		case $CmdLine[$x] = "-m"
			$x = $x + 1
			if StringLen($CmdLine[$x]) > 2 then   $mensaje=$CmdLine[$x]
		case $CmdLine[$x] = "-chatid"
			$x = $x + 1
			if StringLen($CmdLine[$x]) > 2 then   $chatID=$CmdLine[$x]
		 Case Else
			ConsoleWrite("No enough arguments <Usage>: SendTelegram.exe -m <message>  ")
			ConsoleWrite("                              SendTelegram.exe ?  for help  ")
			ConsoleWrite(@CRLF)
			exit 6
	  EndSelect
   Next
#EndRegion

SendTelegram($mensaje)
Func SendTelegram($msgtext="testeo")
	if SendTelegramexec($msgtext) Then
		sleep(3000)
		if $chatID<>"" then	SendTelegramexec($msgtext)
	endif
EndFunc

Func SendTelegramexec($msgtext="testeo harcoded")
	local $token=IniRead("..\..\secret\config.ini","bot","token","")
	$urlMSG="https://api.telegram.org/" & $token & "/sendMessage?chat_id=" & $chatid & "&text=" & $msgtext
	$sGet = HttpGet($urlMSG)

	if $sGet<>"0" then
		ConsoleWrite('Telegram Message sent = ' & $msgtext & @crlf )
		return 0
	Else
		$s_text="Error sending message to Telegram = "
		return 1
	endif
EndFunc

exit

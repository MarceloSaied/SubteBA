;---------- error class 1 -------------------------------
;~ 	Global $oMyError = ObjEvent("AutoIt.Error","MyErrFunc")
;~ 	Func MyErrFunc()
;~ 		Local $HexNumber = Hex($oMyError.Number, 8)
;~ 		ConsoleWrite("! COM Error !  Number: " & $HexNumber & @crlf &  "! ScriptLine: " & $oMyError.scriptline & @crlf & _
;~ 		"! Source: "  & $oMyError.source & @crlf & "! Description:" & $oMyError.WinDescription  & @LF & _
;~ 		"! Lastdllerror: " & $oMyError.lastdllerror & @crlf )
;~ 		SetError(1)
;~ 	 Endfunc
;---------- error class 2 -------------------------------
	Global Const $oErrorHandler = ObjEvent("AutoIt.Error", "ObjErrorHandler")
	Func ObjErrorHandler()
		ConsoleWrite(   "A COM Error has occured!" & @CRLF  & @CRLF & _
                                "err.description is: "    & @TAB & $oErrorHandler.description    & @CRLF & _
                                "err.windescription:"     & @TAB & $oErrorHandler & @CRLF & _
                                "err.number is: "         & @TAB & Hex($oErrorHandler.number, 8)  & @CRLF & _
                                "err.lastdllerror is: "   & @TAB & $oErrorHandler.lastdllerror   & @CRLF & _
                                "err.scriptline is: "     & @TAB & $oErrorHandler.scriptline     & @CRLF & _
                                "err.source is: "         & @TAB & $oErrorHandler.source         & @CRLF & _
                                "err.helpfile is: "       & @TAB & $oErrorHandler.helpfile       & @CRLF & _
                                "err.helpcontext is: "    & @TAB & $oErrorHandler.helpcontext & @CRLF _
                            )
	EndFunc

;~  Func MyErrFunct() ; Com Error Handler
;~     $HexNumber = Hex($oMyError.number, 8)
;~     $oMyRet[0] = $HexNumber
;~     $oMyRet[1] = StringStripWS($oMyError.description,3)
;~     ConsoleWrite("### COM Error !  Number: " & $HexNumber & "   ScriptLine: " & $oMyError.scriptline & "   Description:" & $oMyRet[1] & @LF)
;~     SetError(1); something to check for when this function returns
;~     Return
;~ EndFunc  ;==>MyErrFunc

;~ ; Register a customer error handler
;~ _IEErrorHandlerRegister("IEMyErrFunc")
;~ ; Do something
;~ ; Deregister the customer error handler
;~ _IEErrorHandlerDeRegister()
;~ ; Do something else
;~ ; Register the default IE.au3 COM Error Handler
;~ _IEErrorHandlerRegister()
;~ ; Do more work

;~ Func IEMyErrFunc()
;~ 	Local $HexNumber = Hex($oMyError.Number, 8)
;~ 	ConsoleWrite("> COM Error !  Number: " & $HexNumber & @crlf &  "> ScriptLine: " & $oMyError.scriptline & @crlf & _
;~ 	"> Source: "  & $oMyError.source & @crlf & "> Description:" & $oMyError.WinDescription  & @LF & _
;~ 	"> Lastdllerror: " & $oMyError.lastdllerror & @crlf )
;~ 	SetError(1)
;~  Endfunc


;
; Convert Windows error code to message.
;~ ;
;~ Func _WinAPI_GetErrorMessageByCode($code)
;~     Local $tBufferPtr = DllStructCreate("ptr")
;~     Local $pBufferPtr = DllStructGetPtr($tBufferPtr)

;~     Local $nCount = _WinAPI_FormatMessage(BitOR($__WINAPICONSTANT_FORMAT_MESSAGE_ALLOCATE_BUFFER, $__WINAPICONSTANT_FORMAT_MESSAGE_FROM_SYSTEM), _
;~         0, $code, 0, $pBufferPtr, 0, 0)
;~     If @error Then Return SetError(@error, 0, "")

;~      Local $sText = ""
;~     Local $pBuffer = DllStructGetData($tBufferPtr, 1)
;~     If $pBuffer Then
;~         If $nCount > 0 Then
;~             Local $tBuffer = DllStructCreate("wchar[" & ($nCount+1) & "]", $pBuffer)
;~             $sText = DllStructGetData($tBuffer, 1)
;~         EndIf
;~         _WinAPI_LocalFree($pBuffer)
;~     EndIf

;~     Return $sText
;~ EndFunc   ;==>_WinAPI_GetErrorMessageByCode
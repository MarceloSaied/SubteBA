;_ReduceMemory UDF
Func _ReduceMemory($PID = 0)
	ConsoleWrite('++_ReduceMemory() = '& @crlf )
    ; Discussion: <a href='http://www.autoitscript.com/forum/topic/13399-reducememory-udf' class='bbc_url' title=''>http://www.autoitscript.com/forum/topic/13399-reducememory-udf</a>
    ; Description: Removes as many pages as possible from the working set of the specified process.
    ; Return: Success = 1, Failure = 0
    ; Based on _WinAPI_EmptyWorkingSet by Yashied w/ proper access flags
    Local $Ret
    If (Not $PID) Then
        $Ret = DllCall("kernel32.dll", "handle", "GetCurrentProcessId")
        If @error Or (Not $Ret[0]) Then Return SetError(1, 0, 0)
        $PID = $Ret[0]
    EndIf
    Local $hProcess = DllCall('kernel32.dll', 'ptr', 'OpenProcess', 'dword', 0x00000700, 'int', 0, 'dword', $PID)
    If (@error) Or (Not $hProcess[0]) Then Return SetError(2, 0, 0)
    Local $Ret = DllCall(@SystemDir & '\psapi.dll', 'int', 'EmptyWorkingSet', 'ptr', $hProcess[0])
    If (@error) Or (Not $Ret[0]) Then $Ret = 0
    DllCall('kernel32.dll', 'int', 'CloseHandle', 'ptr', $hProcess[0])
    If Not IsArray($Ret) Then Return SetError(3, 0, 0)
    Return 1
EndFunc   ;==>_ReduceMemory

Func _MSec()
    Local $stSystemTime = DllStructCreate('ushort;ushort;ushort;ushort;ushort;ushort;ushort;ushort')
    DllCall('kernel32.dll', 'none', 'GetSystemTime', 'ptr', DllStructGetPtr($stSystemTime))
    $sMilliSeconds = StringFormat('%03d', DllStructGetData($stSystemTime, 8))
    $stSystemTime = 0
    Return $sMilliSeconds
EndFunc
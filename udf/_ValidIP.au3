; #FUNCTION# ====================================================================================================================
; Name...........: _ValidIP
; Description ...: Verifies that an IP address is a valid IPv4 address or not
; Syntax.........: _ValidIP($sIP)
; Parameters ....: $sIP - IP address to validate
;
; Return values .: Success - String containing IP Address in Hex, @error is ASC value of the Class of the IP address
;                 Failure - -1, sets @error
;                 |1 - IP address starts with an invalid number = 0, 127 , 169 or is > 239
;                 |2 - one of the octets of the IP address is out of the range 0-255 or contains invalid characters
;                 |3 - IP Address is not a valid dotted IP address (ex. valid address 190.40.100.20)
; Author ........: BrewManNH
; Modified.......:
; Remarks .......: Class A networks can't start with 0.xx.xx.xx. 127.xx.xx.xx isn't a valid IP address range. 169.xx.xx.xx is reserved and is invalid
;                 and any address that starts above 239, ex. 240.xx.xx.xx is reserved and should never be used or seen out in "the wild".
;                 The address range 224-239 1s reserved as well for Multicast  groups but can be a valid IP address range if you're
;                 using it as such.
;                 This will validate an IP address that is 4 octets long, and contains only numbers and falls within valid IP address values.
;                 Anything else sent to it should fail the test and return -1.
; Related .......:
; Link ..........: _GetIP
; Example .......: No
; ===============================================================================================================================
Func _ValidIP($sIP)
    $Array = StringSplit($sIP, ".", 2)
    If Not IsArray($Array) Or UBound($Array) <> 4 Then Return SetError(3, 0, -1)
    $String = "0x"
    If $Array[0] <= 0 Or $Array[0] > 239 Or $Array[0] = 127 Or $Array[0] = 169 Then
        Return SetError(1, 0, -1)
    EndIf
    For $I = 0 To 3
        If $Array[$I] < 0 Or $Array[$I] > 255 Or Not StringIsDigit($Array[$I]) Then
            Return SetError(2, 0, -1)
        EndIf
        $String &= StringRight(Hex($Array[$I]), 2)
    Next
    Switch $Array[0]
        Case 1 To 126
            SetError(65)
            Return $String
        Case 128 To 191
            SetError(66)
            Return $String
        Case 192 To 223
            SetError(67)
            Return $String
        Case 224 To 239
           SetError(68)
           Return $String
    EndSwitch
EndFunc   ;==>_ValidIP

Func _IsValidIP($IPaddr)
	if $IPaddr="255.255.255.255" or $IPaddr="255.255.255.0" or $IPaddr="255.255.0.0" or $IPaddr="255.0.0.0" then return SetError(1, 0, 0)
    Local $result
    $result = StringRegExp($IPaddr, "\b(25[0-5]\.|2[0-4]\d\.|1\d\d\.|[1-9]\d\.|[1-9]\.){1}((25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)\.){2}(25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)\b",2)
    If @error Then Return SetError(1, 0, 0)
    If StringReplace($IPaddr, $result[0], "") <> "" Then
        Return SetError(1, 0, 0)
    Else
        Return SetError(0, 0, 1)
    EndIf
EndFunc
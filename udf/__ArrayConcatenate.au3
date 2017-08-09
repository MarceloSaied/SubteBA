; #FUNCTION# =====================================================================
; Name...........: __ArrayConcatenate
; Description ...: Concatenate two 1D or 2D arrays
; Syntax.........: __ArrayConcatenate(ByRef $avArrayTarget, Const ByRef $avArraySource)
; Parameters ....: $avArrayTarget - The array to concatenate onto
;                 $avArraySource - The array to concatenate from - Must be 1D or 2D to match $avArrayTarget,
;                                  and if 2D, then Ubound($avArraySource, 2) <= Ubound($avArrayTarget, 2).
; Return values .: Success - Index of last added item
;                 Failure - -1, sets @error to 1 and @extended per failure (see code below)
; Author ........: Ultima
; Modified.......: PsaltyDS - 1D/2D version, changed return value and @error/@extended to be consistent with __ArrayAdd()
; Remarks .......:
; Related .......: __ArrayAdd, _ArrayPush
; Link ..........;
; Example .......; Yes
; ===============================================================================
Func __ArrayConcatenate(ByRef $avArrayTarget, Const ByRef $avArraySource)
    If Not IsArray($avArrayTarget) Then Return SetError(1, 1, -1); $avArrayTarget is not an array
    If Not IsArray($avArraySource) Then Return SetError(1, 2, -1); $avArraySource is not an array

    Local $iUBoundTarget0 = UBound($avArrayTarget, 0), $iUBoundSource0 = UBound($avArraySource, 0)
    If $iUBoundTarget0 <> $iUBoundSource0 Then Return SetError(1, 3, -1); 1D/2D dimensionality did not match
    If $iUBoundTarget0 > 2 Then Return SetError(1, 4, -1); At least one array was 3D or more

    Local $iUBoundTarget1 = UBound($avArrayTarget, 1), $iUBoundSource1 = UBound($avArraySource, 1)

    Local $iNewSize = $iUBoundTarget1 + $iUBoundSource1
    If $iUBoundTarget0 = 1 Then
       ; 1D arrays
        ReDim $avArrayTarget[$iNewSize]
        For $i = 0 To $iUBoundSource1 - 1
            $avArrayTarget[$iUBoundTarget1 + $i] = $avArraySource[$i]
        Next
    Else
       ; 2D arrays
        Local $iUBoundTarget2 = UBound($avArrayTarget, 2), $iUBoundSource2 = UBound($avArraySource, 2)
        If $iUBoundSource2 > $iUBoundTarget2 Then Return SetError(1, 5, -1); 2D boundry of source too large for target
        ReDim $avArrayTarget[$iNewSize][$iUBoundTarget2]
        For $r = 0 To $iUBoundSource1 - 1
            For $c = 0 To $iUBoundSource2 - 1
                $avArrayTarget[$iUBoundTarget1 + $r][$c] = $avArraySource[$r][$c]
            Next
        Next
    EndIf

    Return $iNewSize - 1
EndFunc;==>__ArrayConcatenate
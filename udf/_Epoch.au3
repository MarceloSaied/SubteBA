
;~ ConsoleWrite("EPOCH time 1234567890 is " & _Epoch_decrypt(1234567890) & @CRLF)
;~ ConsoleWrite("Date 4712/12/31 23:59:59 is EPOCH " & _Epoch_encrypt("4712/12/31 23:59:59") & @CRLF)



	Func _EPOCH_decrypt($iEpochTime)
		 Local $iDayToAdd = Int($iEpochTime / 86400)
		 Local $iTimeVal = Mod($iEpochTime, 86400)
		 If $iTimeVal < 0 Then
			  $iDayToAdd -= 1
			  $iTimeVal += 86400
		 EndIf
		 Local $i_wFactor = Int((573371.75 + $iDayToAdd) / 36524.25)
		 Local $i_xFactor = Int($i_wFactor / 4)
		 Local $i_bFactor = 2442113 + $iDayToAdd + $i_wFactor - $i_xFactor
		 Local $i_cFactor = Int(($i_bFactor - 122.1) / 365.25)
		 Local $i_dFactor = Int(365.25 * $i_cFactor)
		 Local $i_eFactor = Int(($i_bFactor - $i_dFactor) / 30.6001)
		 Local $aDatePart[3]
		 $aDatePart[2] = $i_bFactor - $i_dFactor - Int(30.6001 * $i_eFactor)
		 $aDatePart[1] = $i_eFactor - 1 - 12 * ($i_eFactor - 2 > 11)
		 $aDatePart[0] = $i_cFactor - 4716 + ($aDatePart[1] < 3)
		 Local $aTimePart[3]
		 $aTimePart[0] = Int($iTimeVal / 3600)
		 $iTimeVal = Mod($iTimeVal, 3600)
		 $aTimePart[1] = Int($iTimeVal / 60)
		 $aTimePart[2] = Mod($iTimeVal, 60)
		 Return StringFormat("%.2d/%.2d/%.2d %.2d:%.2d:%.2d", $aDatePart[0], $aDatePart[1], $aDatePart[2], $aTimePart[0], $aTimePart[1], $aTimePart[2])
	EndFunc


	Func _Epoch_encrypt($date)
		 Local $main_split = StringSplit($date, " ")
		 If $main_split[0] - 2 Then
			  Return SetError(1, 0, "") ; invalid time format
		 EndIf
		 Local $asDatePart = StringSplit($main_split[1], "/")
		 Local $asTimePart = StringSplit($main_split[2], ":")
		 If $asDatePart[0] - 3 Or $asTimePart[0] - 3 Then
			  Return SetError(1, 0, "") ; invalid time format
		 EndIf
		 If $asDatePart[2] < 3 Then
			  $asDatePart[2] += 12
			  $asDatePart[1] -= 1
		 EndIf
		 Local $i_aFactor = Int($asDatePart[1] / 100)
		 Local $i_bFactor = Int($i_aFactor / 4)
		 Local $i_cFactor = 2 - $i_aFactor + $i_bFactor
		 Local $i_eFactor = Int(1461 * ($asDatePart[1] + 4716) / 4)
		 Local $i_fFactor = Int(153 * ($asDatePart[2] + 1) / 5)
		 Local $aDaysDiff = $i_cFactor + $asDatePart[3] + $i_eFactor + $i_fFactor - 2442112
		 Local $iTimeDiff = $asTimePart[1] * 3600 + $asTimePart[2] * 60 + $asTimePart[3]
		 Return $aDaysDiff * 86400 + $iTimeDiff
	EndFunc
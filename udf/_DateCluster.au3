Global $aMonths[12] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
Func _dateCluster($left,$top)
	ConsoleWrite('++() = '& @crlf)
	;-------------------- date older than -------------
	GUICtrlCreateLabel("Older than days", $left-2, $top, 80, 17)
	GUICtrlCreateLabel("(Between [days])", $left-2, $top+17, 80, 17)
	$TXT_TaskFolderCreation_olderThan = GUICtrlCreateInput(0, $left+80, $top, 40, 21,$ES_NUMBER)

	$DT_olderThan= GUICtrlCreateDate(_nowcalc(), $left+80+45, $top, 195, 21)
	GUICtrlSetOnEvent($DT_olderThan, "_DT_olderThanChange")
	;--------------------------------------------------
EndFunc
Func _DT_olderThanChange()
	ConsoleWrite('++_DT_olderThanChange() = '&  @crlf)
	$sDate_1 = _GetDate($DT_olderThan)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sDate_1 = ' & $sDate_1 & @crlf )
	$dias=_DateDiff('D',$sDate_1,_NowCalc())
	If $dias>-1 Then
		GUICtrlSetData($TXT_TaskFolderCreation_olderThan,$dias)
	Else
		GUICtrlSetData($TXT_TaskFolderCreation_olderThan,"0")
	endif
EndFunc
Func _GetDate($hCID)
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $hCID = ' & $hCID & @crlf )
    ; Split date parts
    $aDate = StringSplit(GUICtrlRead($hCID), " ")
    ; Convert month name to number
    $iMon = StringFormat("%02i", _ArraySearch($aMonths, $aDate[2]) + 1)
    ; Return the correct format
    Return StringReplace($aDate[4] & "/" & $iMon & "/" & $aDate[3],",","")
EndFunc
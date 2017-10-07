Func _ConfigDBInitial($flagForceUpdateProjectData = 0)
	ConsoleWrite('++ConfigDBInitial() = ' & @CRLF)
	$quiet = True
	_SQLite_down()
	; -------config dbs
	_DBvarInit()
	; -------check if SQLIte profile db exist
	SQLite_init()
	$SQLq = "SELECT name FROM sqlite_temp_master WHERE type='table';"
	_SQLITErun($SQLq, $dbfile, $quietSQLQuery)
	ConsoleWrite('! $profiledbfile = ' & $profiledbfile & @CRLF)
;~ 		; ---------- update projects db files packaged  . listed in fileIncludes.au3
;~ 			for $i=0 to UBound($packagedDBs)-1
;~ 				_UpdatePrjDBprofile($FgmDataFolder & "\" & $packagedDBs[$i])
;~ 			next
	;----------  check schema nad update profile db
	_CheckProfileDbSchema()
	; ------ check configed db fgm
	$FGMdbFile = _ActiveDatabaseFile()
	_SQLite_down()
	;-  check if proyect database was already updated for this version compilation
	;   $flagForceUpdateProjectData=0  ; Force project data update
	If _CheckProyectDBupdate() Or $flagForceUpdateProjectData Then
		If $flagForceUpdateProjectData = 1 Then ConsoleWrite('! Force project data update  $flagForceUpdateProjectData=1 ' & @CRLF)
		GUICtrlSetState($LBL_ProgressGui_Load, $GUI_SHOW)
		If $FGMdbFile <> "" Then
			; -------check SQLIte profile db
;~ 					$dbtemp= $FGMdbFile
			$FGMdbFile = $FgmDataFolder & "\" & $FGMdbFile
;~ 					$res=Filecopy($tempDir & "\"&$dbtemp,$FGMdbFile,1)
			SQLite_init()
			$SQLq = "SELECT name FROM sqlite_temp_master WHERE type='table';"
			_SQLITErun($SQLq, $FGMdbFile, $quietSQLQuery)
			;-----------  profile database merge on upgrade
;~ 				If _CheckIfUpgraded() Then
			ConsoleWrite('! profile database merge on upgrade ' & @CRLF)
;~ 						_LoadTimerPrint("before Mergedb " & @ScriptLineNumber )
			;---------- merge  FGM.db to profile servers  Mergedb.au3
			_CopyTableFromDB($FGMdbFile, "servers", $profiledbfile, "FGMservers", '', $quiet)
;~ 						_LoadTimerPrint("after _CopyTableFromDB() " & $FGMdbFile)
			_CopyTableFromDB($FGMdbFile, "servergroups", $profiledbfile, "FGMservergroups", '', $quiet)
;~ 						_LoadTimerPrint("after _CopyTableFromDB() " & $FGMdbFile)
			_CopyTableFromDB($FGMdbFile, "RServerGroup", $profiledbfile, "FGMRServerGroup", '', $quiet)
;~ 						_LoadTimerPrint("after _CopyTableFromDB() " & $FGMdbFile)
			If _UpdateFromServersFGM($quiet) Then
				_MarkUpdated("UpdatedDB")
			Else
				_MarkUpdated("UpdateDB")
			EndIf
			If Not @Compiled Then _MarkUpdated("UpdateDB")
			_SQLite_Close()
;~ 				endif
			;-----------------------------
			_updateProyectDBupdateValue($version)
		Else
			ConsoleWrite('!!! no merger nada porque no hay fgmdb seleccionada ' & @CRLF)
		EndIf
		GUICtrlSetState($LBL_ProgressGui_Load, $GUI_HIDE)
	Else
		ConsoleWrite('!!! No Update of Proyect data, since its has bee updated earlier in this version ' & @CRLF)
	EndIf
	;------------ add dummy server --------
	_Update_DummyServer()
	;-------- delete credential that do not match login
	_DeleteCredassert()
	;-------- Init Log
	_initLog()
	;------------------------------------------------------------------------------
EndFunc   ;==>_ConfigDBInitial
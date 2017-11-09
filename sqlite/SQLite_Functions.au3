	func SQLite_init()
;~ 		ConsoleWrite('++SQLite_init() = ' & @crlf )
		$sqliteDLLfile=$FolderBin &"\System.Data.SQLite.32.2012.dll"
		$sSQliteDll = _SQLite_Startup($sqliteDLLfile,0,1)
		Local $err=@error
		Sleep(1000)
		if $sSQliteDll = "" then
			MsgBox(16, "Database Error", "Database error . ErrNo 1000/" & $err & @CRLF & "version " & _SQLite_LibVersion())
			Exit 11
		EndIf
	EndFunc
	Func _SQLite_down()
;~ 		ConsoleWrite('++_SQLite_down() = ' & @crlf )
		If $sSQliteDll<>"" Then DllClose($sSQliteDll)
		$sSQliteDll =""
	EndFunc
	func _SQLITErun($SQLq,$DBfile,$quiet=true,$sqlClose=1)
		While 1
			If $quiet=False Then ConsoleWrite('-->_SQLITErun = ' & $DBfile & @crlf & " >> " & $SQLq & @crlf )
			$ExitOnError=1
			Local $hDB=_SQLite_Open($DBfile)
			If $EncryptDB Then _SQLite_Exec(-1, _PragmaQuery($DBfile,"") )
			$iRval= _SQLite_Exec(-1, $SQLq)       ;~ 		Local $d = _SQLite_Exec(-1, $SQLq, "_cb") ; _cb will be called for each row
			If $iRval<>0 Then ConsoleWrite('_SQLite_Exec= ' & $iRval& @crlf )
			if $sqlClose=1 then
				_SQLite_Close($hDB)
			endif
			if $iRval = $SQLITE_OK then
				Return True
			else
				Switch $iRval
					case 5
						$ExitOnError=0
						$s_text="SQLITE return code " & $iRval
						_ConsoleWrite($s_text,3)
						sleep(1000)
					case 21
						MsgBox(16, "Database Error: " & $iRval,"Database not found at "& $DBfile & ". check file/path . ErrNo 1001c" & @crlf & _SQLite_ErrMsg() & @crlf &  $SQLq  & @crlf & $DBfile  )
					case 26
						$encriptedMsg="DataBase file is encrypted or is not a database"
						MsgBox(16, "Database Error: " & $iRval,"Database error . ErrNo 1001q" & @crlf & $encriptedMsg & @crlf & $DBfile  )
					case Else
						MsgBox(16, "Database Error: " & $iRval,"Database error . ErrNo 1001w" & @crlf & _SQLite_ErrMsg() & @crlf &  $SQLq  & @crlf & $DBfile  )
				EndSwitch
				if $ExitOnError=1 then
					_SQLite_QueryFinalize($SQLq)
					_SQLite_Close($hDB)
					exit
				endif
;~ 				return false
			endif
			return true
		wend
	EndFunc
	Func _SQLITEqry($SQLq,$DBfile,$quiet=true,$sqlClose=1)
		While 1
			If $quiet=False Then ConsoleWrite('-->_SQLITEqry = ' & $DBfile & @crlf& " >> " & $SQLq & @crlf )
			$ExitOnError=1
			Local $hDB=_SQLite_Open($DBfile)
			If $EncryptDB Then _SQLite_Exec(-1, _PragmaQuery($DBfile,"") )
			local $iRows, $iColumns
			$iRval = _SQLite_GetTable2d($hDB,$SQLq, $qryResult, $iRows, $iColumns)
			If $iRval = $SQLITE_OK  Or $iRval=$SQLITE_DONE Then
				If $quiet=False Then
					ConsoleWrite(" >> Rows="&ubound($qryResult,1)&"   Cols="&ubound($qryResult,2)&@crlf)
					_SQLite_Display2DResult($qryResult)
				endif
			Else
				Switch $iRval
					case 5
						$ExitOnError=0
						$s_text="SQLITE return code " & $iRval
						_ConsoleWrite($s_text,3)
						sleep(1000)
					case 21
						MsgBox(16, "Database Error: " & $iRval,"Database not found at "& $DBfile & ". check file/path . ErrNo 1001c" & @crlf & _SQLite_ErrMsg() & @crlf &  $SQLq  & @crlf & $DBfile  )
					case 26
						$encriptedMsg="DataBase file is encrypted or is not a database"
						MsgBox(16, "Database Error: " & $iRval,"Database error . ErrNo 1001q" & @crlf & $encriptedMsg & @crlf & $DBfile  )
					case Else
						MsgBox(16, "Database Error: " & $iRval,"Database error . ErrNo 1001w" & @crlf & _SQLite_ErrMsg() & @crlf &  $SQLq  & @crlf & $DBfile  )
				EndSwitch
				if $ExitOnError=1 then
					_SQLite_QueryFinalize($SQLq)
					_SQLite_Close($hDB)
					exit
				endif
;~ 				return false
			EndIf
			if $sqlClose=1 then
				_SQLite_Close($hDB)
			endif
			return true
		wend
	EndFunc
	Func _PragmaQuery($db,$SQLq)
	;~ 	ConsoleWrite('++_PragmaQuery() = '& @crlf)
		Switch $db
			Case $dbfile
				$SQLq='PRAGMA key = "' & $defaultdbencript & '";'&$SQLq
			case Else
				$SQLq='PRAGMA key = "' & $defaultdbencript & '";'&$SQLq
		EndSwitch
		Return $SQLq
	EndFunc
	Func _cb($aRow)
		For $s In $aRow
			ConsoleWrite("=>"& $s & @TAB)
		Next
		ConsoleWrite(@CRLF)
	EndFunc   ;==>_cb
	Func _SQLITEgetUnit($query,$db,$quiet=false,$sqlClose=1) ; returns one unit result from query
;~ 		ConsoleWrite('++_SQLITEgetUnit() = '& @crlf)
;~ 		$quietSQLQuery=false  no muestra los queries
;~ 		$vervoseSQLQuery=true
		_SQLITEqry($query,$db,$quiet,$sqlClose)
		If  IsArray($qryResult) then
			If UBound($qryResult)>1 then
				Return $qryResult[1][0]
			Else
				Return ""
			endif
		endif
		return 0
	EndFunc
#cs
;~ func SQLite_InMemory()   $profiledbfile
;~ 	$hMemDb = _SQLite_Open(":memory:") ; Creates a :memory: database
;~ 	$hMemDb = _SQLite_Open("Diffreport.db") ; Creates a :memory: database
;~ 	If @error Then
;~ 		ConsoleWrite("Can't create a memory Database!" & @CRLF)
;~ 		Exit $hMemDb
;~ 	EndIf
;~ 	_SQLite_Exec($hMemDb,"PRAGMA journal_mode = OFF;")
;~ 	_SQLite_Exec($hMemDb,"PRAGMA temp_store = MEMORY;")
;~ 	_SQLite_Exec($hMemDb, "PRAGMA synchronous = OFF;")
;~ EndFunc
#ce

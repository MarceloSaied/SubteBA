#include-once
Global Const $STR_NOCASESENSEBASIC = 2 ; Not case sensitive, using a basic comparison
; #INDEX# =======================================================================================================================
; Title .........: File
; AutoIt Version : 3.3.12.0
; Language ......: English
; Description ...: Functions that assist with files and directories.
; Author(s) .....: Brian Keene, Michael Michta, erifash, Jon, JdeB, Jeremy Landes, MrCreatoR, cdkid, Valik, Erik Pilsits, Kurt, Dale, guinness, DXRW4E, Melba23
; Dll(s) ........: shell32.dll
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
; _FileListToArrayRec
; ===============================================================================================================================

; #INTERNAL_USE_ONLY#============================================================================================================
; __FLTAR_ListToMask
; __FLTAR_AddToList
; __FLTAR_AddFileLists
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Author ........: Tylo <tylo at start dot no>
; Modified.......: Xenobiologist, Gary, guinness, DXRW4E
; ===============================================================================================================================


; #FUNCTION# ====================================================================================================================
; Author ........: Melba23 - with credits for code snippets to Ultima, Partypooper, Spiff59, guinness, wraithdu
; Modified ......:
; ===============================================================================================================================
Func _FileListToArrayRec($sInitialPath, $sMask = "*", $iReturn = 0, $iRecur = 0, $iSort = 0, $iReturnPath = 1)
	Local $asReturnList[100] = [0], $asFileMatchList[100] = [0], $asRootFileMatchList[100] = [0], $asFolderMatchList[100] = [0], $asFolderSearchList[100] = [1]
	Local $sInclude_List = "*", $sExclude_List, $sExclude_List_Folder, $sInclude_File_Mask = ".+", $sExclude_File_Mask = ":", $sInclude_Folder_Mask = ".+", $sExclude_Folder_Mask = ":"
	Local $sFolderSlash = "", $iMaxLevel, $hSearch, $bFolder, $sRetPath = "", $sCurrentPath, $sName, $iAttribs, $iHide_HS = 0, $iHide_Link = 0, $bLongPath = False
	Local $asFolderFileSectionList[100][2] = [[0, 0]], $sFolderToFind, $iFileSectionStartIndex, $iFileSectionEndIndex

	; Check for valid path
	If StringLeft($sInitialPath, 4) == "\\?\" Then
		$bLongPath = True
	EndIf
	If Not FileExists($sInitialPath) Then Return SetError(1, 1, "")

	; Check if folders should have trailing \ and ensure that initial path does have one
	If StringRight($sInitialPath, 1) = "\" Then
		$sFolderSlash = "\"
	Else
		$sInitialPath = $sInitialPath & "\"
	EndIf
	; Add path to folder search list
	$asFolderSearchList[1] = $sInitialPath

	; Check for Default keyword
	If $sMask = Default Then $sMask = "*"
	If $iReturn = Default Then $iReturn = 0
	If $iRecur = Default Then $iRecur = 0
	If $iSort = Default Then $iSort = 0
	If $iReturnPath = Default Then $iReturnPath = 1

	; Check for H or S omitted
	If BitAND($iReturn, 4) Then
		$iHide_HS += 2
		$iReturn -= 4
	EndIf
	If BitAND($iReturn, 8) Then
		$iHide_HS += 4
		$iReturn -= 8
	EndIf

	; Check for link/junction omitted
	If BitAND($iReturn, 16) Then
		$iHide_Link = 0x400
		$iReturn -= 16
	EndIf

	; Check for valid recur value
	If $iRecur > 1 Or Not IsInt($iRecur) Then Return SetError(1, 6, "")
	; If required, determine \ count for max recursive level setting
	If $iRecur < 0 Then
		StringReplace($sInitialPath, "\", "", 0, $STR_NOCASESENSEBASIC)
		$iMaxLevel = @extended - $iRecur
	EndIf

	; Check mask parameter
	Local $aMaskSplit = StringSplit($sMask, "|")
	; Check for multiple sections and set values
	Switch $aMaskSplit[0]
		Case 3
			$sExclude_List_Folder = $aMaskSplit[3]
			ContinueCase
		Case 2
			$sExclude_List = $aMaskSplit[2]
			ContinueCase
		Case 1
			$sInclude_List = $aMaskSplit[1]
	EndSwitch

	; Create Include mask for files
	If $sInclude_List <> "*" Then
		If Not __FLTAR_ListToMask($sInclude_File_Mask, $sInclude_List) Then Return SetError(1, 2, "")
	EndIf
	; Set Include mask for folders
	Switch $iReturn
		Case 0
			; Folders affected by mask if not recursive
			Switch $iRecur
				Case 0
					; Folders match mask for compatibility
					$sInclude_Folder_Mask = $sInclude_File_Mask
			EndSwitch
		Case 2
			; Folders affected by mask
			$sInclude_Folder_Mask = $sInclude_File_Mask
	EndSwitch

	; Create Exclude List mask for files
	If $sExclude_List <> "" Then
		If Not __FLTAR_ListToMask($sExclude_File_Mask, $sExclude_List) Then Return SetError(1, 3, "")
	EndIf

	; Create Exclude mask for folders
	If $iRecur Then
		If $sExclude_List_Folder Then
			If Not __FLTAR_ListToMask($sExclude_Folder_Mask, $sExclude_List_Folder) Then Return SetError(1, 4, "")
		EndIf
		; If folders only
		If $iReturn = 2 Then
			; Folders affected by normal mask
			$sExclude_Folder_Mask = $sExclude_File_Mask
		EndIf
	Else
		; Folders affected by normal mask
		$sExclude_Folder_Mask = $sExclude_File_Mask
	EndIf

	; Verify other parameters
	If Not ($iReturn = 0 Or $iReturn = 1 Or $iReturn = 2) Then Return SetError(1, 5, "")
	If Not ($iSort = 0 Or $iSort = 1 Or $iSort = 2) Then Return SetError(1, 7, "")
	If Not ($iReturnPath = 0 Or $iReturnPath = 1 Or $iReturnPath = 2) Then Return SetError(1, 8, "")

	; Prepare for DllCall if required
	If $iHide_HS Or $iHide_Link Then
		Local $tFile_Data = DllStructCreate("struct;align 4;dword FileAttributes;uint64 CreationTime;uint64 LastAccessTime;uint64 LastWriteTime;" & _
				"dword FileSizeHigh;dword FileSizeLow;dword Reserved0;dword Reserved1;wchar FileName[260];wchar AlternateFileName[14];endstruct")
		Local $pFile_Data = DllStructGetPtr($tFile_Data), $hDLL = DllOpen('kernel32.dll'), $aDLL_Ret
	EndIf

	; Search within listed folders
	While $asFolderSearchList[0] > 0

		; Set path to search
		$sCurrentPath = $asFolderSearchList[$asFolderSearchList[0]]
		; Reduce folder search list count
		$asFolderSearchList[0] -= 1
		; Determine return path to add to file/folder name
		Switch $iReturnPath
			; Case 0 ; Name only
			; Leave as ""
			Case 1 ;Relative to initial path
				$sRetPath = StringReplace($sCurrentPath, $sInitialPath, "")
			Case 2 ; Full path
				If $bLongPath Then
					$sRetPath = StringTrimLeft($sCurrentPath, 4)
				Else
					$sRetPath = $sCurrentPath
				EndIf
		EndSwitch

		; Get search handle - use code matched to required listing
		If $iHide_HS Or $iHide_Link Then
			; Use DLL code
			$aDLL_Ret = DllCall($hDLL, 'ptr', 'FindFirstFileW', 'wstr', $sCurrentPath & "*", 'ptr', $pFile_Data)
			If @error Or Not $aDLL_Ret[0] Then
				ContinueLoop
			EndIf
			$hSearch = $aDLL_Ret[0]
		Else
			; Use native code
			$hSearch = FileFindFirstFile($sCurrentPath & "*")
			; If folder empty move to next in list
			If $hSearch = -1 Then
				ContinueLoop
			EndIf
		EndIf

		; If sorting files and folders with paths then store folder name and position of associated files in list
		If $iReturn = 0 And $iSort And $iReturnPath Then
			__FLTAR_AddToList($asFolderFileSectionList, $sRetPath, $asFileMatchList[0] + 1)
		EndIf

		; Search folder - use code matched to required listing
		While 1
			; Use DLL code
			If $iHide_HS Or $iHide_Link Then
				; Use DLL code
				$aDLL_Ret = DllCall($hDLL, 'int', 'FindNextFileW', 'ptr', $hSearch, 'ptr', $pFile_Data)
				; Check for end of folder
				If @error Or Not $aDLL_Ret[0] Then
					ExitLoop
				EndIf
				; Extract data
				$sName = DllStructGetData($tFile_Data, "FileName")
				; Check for .. return - only returned by the DllCall
				If $sName = ".." Then
					ContinueLoop
				EndIf
				$iAttribs = DllStructGetData($tFile_Data, "FileAttributes")
				; Check for hidden/system attributes and skip if found
				If $iHide_HS And BitAND($iAttribs, $iHide_HS) Then
					ContinueLoop
				EndIf
				; Check for link attribute and skip if found
				If $iHide_Link And BitAND($iAttribs, $iHide_Link) Then
					ContinueLoop
				EndIf
				; Set subfolder flag
				$bFolder = False
				If BitAND($iAttribs, 16) Then
					$bFolder = True
				EndIf
			Else
				; Use native code
				$sName = FileFindNextFile($hSearch)
				; Check for end of folder
				If @error Then
					ExitLoop
				EndIf
				; Set subfolder flag - @extended set in 3.3.1.1 +
				$bFolder = @extended
			EndIf

			; If folder then check whether to add to search list
			If $bFolder Then
				Select
					Case $iRecur < 0 ; Check recur depth
						StringReplace($sCurrentPath, "\", "", 0, $STR_NOCASESENSEBASIC)
						If @extended < $iMaxLevel Then
							ContinueCase ; Check if matched to masks
						EndIf
					Case $iRecur = 1 ; Full recur
						If Not StringRegExp($sName, $sExclude_Folder_Mask) Then ; Add folder unless excluded
							__FLTAR_AddToList($asFolderSearchList, $sCurrentPath & $sName & "\")
						EndIf
						; Case $iRecur = 0 ; Never add
						; Do nothing
				EndSelect
			EndIf

			If $iSort Then ; Save in relevant folders for later sorting
				If $bFolder Then
					If StringRegExp($sName, $sInclude_Folder_Mask) And Not StringRegExp($sName, $sExclude_Folder_Mask) Then
						__FLTAR_AddToList($asFolderMatchList, $sRetPath & $sName & $sFolderSlash)
					EndIf
				Else
					If StringRegExp($sName, $sInclude_File_Mask) And Not StringRegExp($sName, $sExclude_File_Mask) Then
						; Select required list for files
						If $sCurrentPath = $sInitialPath Then
							__FLTAR_AddToList($asRootFileMatchList, $sRetPath & $sName)
						Else
							__FLTAR_AddToList($asFileMatchList, $sRetPath & $sName)
						EndIf
					EndIf
				EndIf
			Else ; Save directly in return list
				If $bFolder Then
					If $iReturn <> 1 And StringRegExp($sName, $sInclude_Folder_Mask) And Not StringRegExp($sName, $sExclude_Folder_Mask) Then
						__FLTAR_AddToList($asReturnList, $sRetPath & $sName & $sFolderSlash)
					EndIf
				Else
					If $iReturn <> 2 And StringRegExp($sName, $sInclude_File_Mask) And Not StringRegExp($sName, $sExclude_File_Mask) Then
						__FLTAR_AddToList($asReturnList, $sRetPath & $sName)
					EndIf
				EndIf
			EndIf

		WEnd

		; Close current search
		FileClose($hSearch)

	WEnd

	; Close the DLL if needed
	If $iHide_HS Then
		DllClose($hDLL)
	EndIf

	; Sort results if required
	If $iSort Then
		Switch $iReturn
			Case 2 ; Folders only
				; Check if any folders found
				If $asFolderMatchList[0] = 0 Then Return SetError(1, 9, "")
				; Correctly size folder match list
				ReDim $asFolderMatchList[$asFolderMatchList[0] + 1]
				; Copy size folder match array
				$asReturnList = $asFolderMatchList
				; Simple sort list
				__ArrayDualPivotSort($asReturnList, 1, $asReturnList[0])
			Case 1 ; Files only
				; Check if any files found
				If $asRootFileMatchList[0] = 0 And $asFileMatchList[0] = 0 Then Return SetError(1, 9, "")
				If $iReturnPath = 0 Then ; names only so simple sort suffices
					; Combine file match lists
					__FLTAR_AddFileLists($asReturnList, $asRootFileMatchList, $asFileMatchList)
					; Simple sort combined file list
					__ArrayDualPivotSort($asReturnList, 1, $asReturnList[0])
				Else
					; Combine sorted file match lists
					__FLTAR_AddFileLists($asReturnList, $asRootFileMatchList, $asFileMatchList, 1)
				EndIf
			Case 0 ; Both files and folders
				; Check if any root files or folders found
				If $asRootFileMatchList[0] = 0 And $asFolderMatchList[0] = 0 Then Return SetError(1, 9, "")
				If $iReturnPath = 0 Then ; names only so simple sort suffices
					; Combine file match lists
					__FLTAR_AddFileLists($asReturnList, $asRootFileMatchList, $asFileMatchList)
					; Set correct count for folder add
					$asReturnList[0] += $asFolderMatchList[0]
					; Resize and add file match array
					ReDim $asFolderMatchList[$asFolderMatchList[0] + 1]
					_ArrayConcatenate($asReturnList, $asFolderMatchList, 1)
					; Simple sort final list
					__ArrayDualPivotSort($asReturnList, 1, $asReturnList[0])
				Else
					; Size return list
					Local $asReturnList[$asFileMatchList[0] + $asRootFileMatchList[0] + $asFolderMatchList[0] + 1]
					$asReturnList[0] = $asFileMatchList[0] + $asRootFileMatchList[0] + $asFolderMatchList[0]
					; Sort root file list
					__ArrayDualPivotSort($asRootFileMatchList, 1, $asRootFileMatchList[0])
					; Add the sorted root files at the top
					For $i = 1 To $asRootFileMatchList[0]
						$asReturnList[$i] = $asRootFileMatchList[$i]
					Next
					; Set next insertion index
					Local $iNextInsertionIndex = $asRootFileMatchList[0] + 1
					; Sort folder list
					__ArrayDualPivotSort($asFolderMatchList, 1, $asFolderMatchList[0])
					; Work through folder list
					For $i = 1 To $asFolderMatchList[0]
						; Add folder to return list
						$asReturnList[$iNextInsertionIndex] = $asFolderMatchList[$i]
						$iNextInsertionIndex += 1
						; Format folder name for search
						If $sFolderSlash Then
							$sFolderToFind = $asFolderMatchList[$i]
						Else
							$sFolderToFind = $asFolderMatchList[$i] & "\"
						EndIf
						; Find folder in FolderFileSectionList
						For $j = 1 To $asFolderFileSectionList[0][0]
							; If found then deal with files
							If $sFolderToFind = $asFolderFileSectionList[$j][0] Then
								; Set file list indexes
								$iFileSectionStartIndex = $asFolderFileSectionList[$j][1]
								If $j = $asFolderFileSectionList[0][0] Then
									$iFileSectionEndIndex = $asFileMatchList[0]
								Else
									$iFileSectionEndIndex = $asFolderFileSectionList[$j + 1][1] - 1
								EndIf
								; Sort files if required
								If $iSort = 1 Then
									__ArrayDualPivotSort($asFileMatchList, $iFileSectionStartIndex, $iFileSectionEndIndex)
								EndIf
								; Add files to return list
								For $k = $iFileSectionStartIndex To $iFileSectionEndIndex
									$asReturnList[$iNextInsertionIndex] = $asFileMatchList[$k]
									$iNextInsertionIndex += 1
								Next
								ExitLoop
							EndIf
						Next
					Next
				EndIf
		EndSwitch
	Else ; No sort
		; Check if any file/folders have been added
		If $asReturnList[0] = 0 Then Return SetError(1, 9, "")
		; Remove any unused return list elements from last ReDim
		ReDim $asReturnList[$asReturnList[0] + 1]

	EndIf

	Return $asReturnList
EndFunc   ;==>_FileListToArrayRec

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __FLTAR_AddFileLists
; Description ...: Add internal lists after resizing and optional sorting
; Syntax ........: __FLTAR_AddFileLists(ByRef $asTarget, $asSource_1, $asSource_2[, $iSort = 0])
; Parameters ....: $asReturnList - Base list
;                  $asRootFileMatchList - First list to add
;                  $asFileMatchList - Second list to add
;                  $iSort - (Optional) Whether to sort lists before adding
;                  |$iSort = 0 (Default) No sort
;                  |$iSort = 1 Sort in descending alphabetical order
; Return values .: None - array modified ByRef
; Author ........: Melba23
; Remarks .......: This function is used internally by _FileListToArrayRec
; ===============================================================================================================================
Func __FLTAR_AddFileLists(ByRef $asTarget, $asSource_1, $asSource_2, $iSort = 0)
	; Correctly size root file match array
	ReDim $asSource_1[$asSource_1[0] + 1]
	; Simple sort root file match array if required
	If $iSort = 1 Then __ArrayDualPivotSort($asSource_1, 1, $asSource_1[0])
	; Copy root file match array
	$asTarget = $asSource_1
	; Add file match count
	$asTarget[0] += $asSource_2[0]
	; Correctly size file match array
	ReDim $asSource_2[$asSource_2[0] + 1]
	; Simple sort file match array if required
	If $iSort = 1 Then __ArrayDualPivotSort($asSource_2, 1, $asSource_2[0])
	; Add file match array
	_ArrayConcatenate($asTarget, $asSource_2, 1)
EndFunc   ;==>__FLTAR_AddFileLists

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __FLTAR_AddToList
; Description ...: Add element to [?] or [?][2] list which is resized if necessary
; Syntax ........: __FLTAR_AddToList(ByRef $asList, $vValue_0, [$vValue_1])
; Parameters ....: $aList - List to be added to
;                  $vValue_0 - Value to add to array  - if $vValue_1 exists value added to [?][0] element in [?][2] array
;                  $vValue_1 - Value to add to [?][1] element in [?][2] array (optional)
; Return values .: None - array modified ByRef
; Author ........: Melba23
; Remarks .......: This function is used internally by _FileListToArrayRec
; ===============================================================================================================================
Func __FLTAR_AddToList(ByRef $aList, $vValue_0, $vValue_1 = -1)
	If $vValue_1 = -1 Then ; [?] array
		; Increase list count
		$aList[0] += 1
		; Double list size if too small (fewer ReDim needed)
		If UBound($aList) <= $aList[0] Then ReDim $aList[UBound($aList) * 2]
		; Add value
		$aList[$aList[0]] = $vValue_0
	Else ; [?][2] array
		$aList[0][0] += 1
		If UBound($aList) <= $aList[0][0] Then ReDim $aList[UBound($aList) * 2][2]
		$aList[$aList[0][0]][0] = $vValue_0
		$aList[$aList[0][0]][1] = $vValue_1
	EndIf
EndFunc   ;==>__FLTAR_AddToList

; #INTERNAL_USE_ONLY#============================================================================================================
; Name...........: __FLTAR_ListToMask
; Description ...: Convert include/exclude lists to SRE format
; Syntax ........: __FLTAR_ListToMask(ByRef $sMask, $sList)
; Parameters ....: $asMask - Include/Exclude mask to create
;                  $asList - Include/Exclude list to convert
; Return values .: Success: 1
;                  Failure: 0
; Author ........: SRE patterns developed from those posted by various forum members and Spiff59 in particular
; Remarks .......: This function is used internally by _FileListToArrayRec
; ===============================================================================================================================
Func __FLTAR_ListToMask(ByRef $sMask, $sList)
	; Check for invalid characters within list
	If StringRegExp($sList, "\\|/|:|\<|\>|\|") Then Return 0
	; Strip WS and insert | for ;
	$sList = StringReplace(StringStripWS(StringRegExpReplace($sList, "\s*;\s*", ";"), $STR_STRIPLEADING + $STR_STRIPTRAILING), ";", "|")
	; Convert to SRE pattern
	$sList = StringReplace(StringReplace(StringRegExpReplace($sList, "[][$^.{}()+\-]", "\\$0"), "?", "."), "*", ".*?")
	; Add prefix and suffix
	$sMask = "(?i)^(" & $sList & ")\z"
	Return 1
EndFunc   ;==>__FLTAR_ListToMask


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __ArrayDualPivotSort
; Description ...: Helper function for sorting 1D arrays
; Syntax.........: __ArrayDualPivotSort ( ByRef $aArray, $iPivot_Left, $iPivot_Right [, $bLeftMost = True ] )
; Parameters ....: $avArray  - Array to sort
;                  $iPivot_Left  - Index of the array to start sorting at
;                  $iPivot_Right - Index of the array to stop sorting at
;                  $bLeftMost    - Indicates if this part is the leftmost in the range
; Return values .: None
; Author ........: Erik Pilsits
; Modified.......: Melba23
; Remarks .......: For Internal Use Only
; Related .......:
; Link ..........:
; Example .......:
; ===============================================================================================================================
Func __ArrayDualPivotSort(ByRef $aArray, $iPivot_Left, $iPivot_Right, $bLeftMost = True)
	If $iPivot_Left > $iPivot_Right Then Return
	Local $iLength = $iPivot_Right - $iPivot_Left + 1
	Local $i, $j, $k, $iAi, $iAk, $iA1, $iA2, $iLast
	If $iLength < 45 Then ; Use insertion sort for small arrays - value chosen empirically
		If $bLeftMost Then
			$i = $iPivot_Left
			While $i < $iPivot_Right
				$j = $i
				$iAi = $aArray[$i + 1]
				While $iAi < $aArray[$j]
					$aArray[$j + 1] = $aArray[$j]
					$j -= 1
					If $j + 1 = $iPivot_Left Then ExitLoop
				WEnd
				$aArray[$j + 1] = $iAi
				$i += 1
			WEnd
		Else
			While 1
				If $iPivot_Left >= $iPivot_Right Then Return 1
				$iPivot_Left += 1
				If $aArray[$iPivot_Left] < $aArray[$iPivot_Left - 1] Then ExitLoop
			WEnd
			While 1
				$k = $iPivot_Left
				$iPivot_Left += 1
				If $iPivot_Left > $iPivot_Right Then ExitLoop
				$iA1 = $aArray[$k]
				$iA2 = $aArray[$iPivot_Left]
				If $iA1 < $iA2 Then
					$iA2 = $iA1
					$iA1 = $aArray[$iPivot_Left]
				EndIf
				$k -= 1
				While $iA1 < $aArray[$k]
					$aArray[$k + 2] = $aArray[$k]
					$k -= 1
				WEnd
				$aArray[$k + 2] = $iA1
				While $iA2 < $aArray[$k]
					$aArray[$k + 1] = $aArray[$k]
					$k -= 1
				WEnd
				$aArray[$k + 1] = $iA2
				$iPivot_Left += 1
			WEnd
			$iLast = $aArray[$iPivot_Right]
			$iPivot_Right -= 1
			While $iLast < $aArray[$iPivot_Right]
				$aArray[$iPivot_Right + 1] = $aArray[$iPivot_Right]
				$iPivot_Right -= 1
			WEnd
			$aArray[$iPivot_Right + 1] = $iLast
		EndIf
		Return 1
	EndIf
	Local $iSeventh = BitShift($iLength, 3) + BitShift($iLength, 6) + 1
	Local $iE1, $iE2, $iE3, $iE4, $iE5, $t
	$iE3 = Ceiling(($iPivot_Left + $iPivot_Right) / 2)
	$iE2 = $iE3 - $iSeventh
	$iE1 = $iE2 - $iSeventh
	$iE4 = $iE3 + $iSeventh
	$iE5 = $iE4 + $iSeventh
	If $aArray[$iE2] < $aArray[$iE1] Then
		$t = $aArray[$iE2]
		$aArray[$iE2] = $aArray[$iE1]
		$aArray[$iE1] = $t
	EndIf
	If $aArray[$iE3] < $aArray[$iE2] Then
		$t = $aArray[$iE3]
		$aArray[$iE3] = $aArray[$iE2]
		$aArray[$iE2] = $t
		If $t < $aArray[$iE1] Then
			$aArray[$iE2] = $aArray[$iE1]
			$aArray[$iE1] = $t
		EndIf
	EndIf
	If $aArray[$iE4] < $aArray[$iE3] Then
		$t = $aArray[$iE4]
		$aArray[$iE4] = $aArray[$iE3]
		$aArray[$iE3] = $t
		If $t < $aArray[$iE2] Then
			$aArray[$iE3] = $aArray[$iE2]
			$aArray[$iE2] = $t
			If $t < $aArray[$iE1] Then
				$aArray[$iE2] = $aArray[$iE1]
				$aArray[$iE1] = $t
			EndIf
		EndIf
	EndIf
	If $aArray[$iE5] < $aArray[$iE4] Then
		$t = $aArray[$iE5]
		$aArray[$iE5] = $aArray[$iE4]
		$aArray[$iE4] = $t
		If $t < $aArray[$iE3] Then
			$aArray[$iE4] = $aArray[$iE3]
			$aArray[$iE3] = $t
			If $t < $aArray[$iE2] Then
				$aArray[$iE3] = $aArray[$iE2]
				$aArray[$iE2] = $t
				If $t < $aArray[$iE1] Then
					$aArray[$iE2] = $aArray[$iE1]
					$aArray[$iE1] = $t
				EndIf
			EndIf
		EndIf
	EndIf
	Local $iLess = $iPivot_Left
	Local $iGreater = $iPivot_Right
	If (($aArray[$iE1] <> $aArray[$iE2]) And ($aArray[$iE2] <> $aArray[$iE3]) And ($aArray[$iE3] <> $aArray[$iE4]) And ($aArray[$iE4] <> $aArray[$iE5])) Then
		Local $iPivot_1 = $aArray[$iE2]
		Local $iPivot_2 = $aArray[$iE4]
		$aArray[$iE2] = $aArray[$iPivot_Left]
		$aArray[$iE4] = $aArray[$iPivot_Right]
		Do
			$iLess += 1
		Until $aArray[$iLess] >= $iPivot_1
		Do
			$iGreater -= 1
		Until $aArray[$iGreater] <= $iPivot_2
		$k = $iLess
		While $k <= $iGreater
			$iAk = $aArray[$k]
			If $iAk < $iPivot_1 Then
				$aArray[$k] = $aArray[$iLess]
				$aArray[$iLess] = $iAk
				$iLess += 1
			ElseIf $iAk > $iPivot_2 Then
				While $aArray[$iGreater] > $iPivot_2
					$iGreater -= 1
					If $iGreater + 1 = $k Then ExitLoop 2
				WEnd
				If $aArray[$iGreater] < $iPivot_1 Then
					$aArray[$k] = $aArray[$iLess]
					$aArray[$iLess] = $aArray[$iGreater]
					$iLess += 1
				Else
					$aArray[$k] = $aArray[$iGreater]
				EndIf
				$aArray[$iGreater] = $iAk
				$iGreater -= 1
			EndIf
			$k += 1
		WEnd
		$aArray[$iPivot_Left] = $aArray[$iLess - 1]
		$aArray[$iLess - 1] = $iPivot_1
		$aArray[$iPivot_Right] = $aArray[$iGreater + 1]
		$aArray[$iGreater + 1] = $iPivot_2
		__ArrayDualPivotSort($aArray, $iPivot_Left, $iLess - 2, True)
		__ArrayDualPivotSort($aArray, $iGreater + 2, $iPivot_Right, False)
		If ($iLess < $iE1) And ($iE5 < $iGreater) Then
			While $aArray[$iLess] = $iPivot_1
				$iLess += 1
			WEnd
			While $aArray[$iGreater] = $iPivot_2
				$iGreater -= 1
			WEnd
			$k = $iLess
			While $k <= $iGreater
				$iAk = $aArray[$k]
				If $iAk = $iPivot_1 Then
					$aArray[$k] = $aArray[$iLess]
					$aArray[$iLess] = $iAk
					$iLess += 1
				ElseIf $iAk = $iPivot_2 Then
					While $aArray[$iGreater] = $iPivot_2
						$iGreater -= 1
						If $iGreater + 1 = $k Then ExitLoop 2
					WEnd
					If $aArray[$iGreater] = $iPivot_1 Then
						$aArray[$k] = $aArray[$iLess]
						$aArray[$iLess] = $iPivot_1
						$iLess += 1
					Else
						$aArray[$k] = $aArray[$iGreater]
					EndIf
					$aArray[$iGreater] = $iAk
					$iGreater -= 1
				EndIf
				$k += 1
			WEnd
		EndIf
		__ArrayDualPivotSort($aArray, $iLess, $iGreater, False)
	Else
		Local $iPivot = $aArray[$iE3]
		$k = $iLess
		While $k <= $iGreater
			If $aArray[$k] = $iPivot Then
				$k += 1
				ContinueLoop
			EndIf
			$iAk = $aArray[$k]
			If $iAk < $iPivot Then
				$aArray[$k] = $aArray[$iLess]
				$aArray[$iLess] = $iAk
				$iLess += 1
			Else
				While $aArray[$iGreater] > $iPivot
					$iGreater -= 1
				WEnd
				If $aArray[$iGreater] < $iPivot Then
					$aArray[$k] = $aArray[$iLess]
					$aArray[$iLess] = $aArray[$iGreater]
					$iLess += 1
				Else
					$aArray[$k] = $iPivot
				EndIf
				$aArray[$iGreater] = $iAk
				$iGreater -= 1
			EndIf
			$k += 1
		WEnd
		__ArrayDualPivotSort($aArray, $iPivot_Left, $iLess - 1, True)
		__ArrayDualPivotSort($aArray, $iGreater + 1, $iPivot_Right, False)
	EndIf
EndFunc   ;==>__ArrayDualPivotSort

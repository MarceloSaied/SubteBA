#include-once

; #INDEX# ======================================================================================================================
; Title .........: ArrayWorkshop [version 1.0.0]
; AutoIt Version : 3.3.14.2
; Language ......: English
; Description ...: Multidimensional array functions.
; Notes .........: In this library, an array region is defined as follows:
;                  1. items within a one dimensional array
;                  2. lists within a two dimensional array (rows or columns)
;                  3. tables within a three dimensional array
;                  4. cuboidal areas within a four dimension array
;                  5. four dimensional cuboids within a five dimensional array
;                  etc...
;                  To reduce bloat, several functions access part of the script referred to (in the comments) as 'Remote Loops'.
;                  Arrays containing zero elements are not supported and will cause functions to return an error.
;                  Limiting the number of dimensions to single digits was a practical decision to simplify syntax.
;                  Credit must go to fellow AutoIt forum members whose code or suggestions have been influential in the
;                  development of these functions: Jos van der Zande, jguinch, jchd, LazyCoder, Tylo, Ultima, Melba23, BrewManNH
;                  The above list is not exhaustive, nor are the names in any particular order.
; Author(s) .....: czardas
; ==============================================================================================================================

; #CURRENT# ====================================================================================================================
; _ArrayAttach     [limit = 9 dimensions]
; _ArraySortXD     [limit = 9 dimensions]
; _ArrayTransform  [limit = 9 dimensions]
; _ArrayUniqueXD   [limit = 9 dimensions]
; _DeleteDimension [limit = 9 dimensions]
; _DeleteRegion    [limit = 9 dimensions]
; _ExtractRegion   [limit = 9 dimensions]
; _InsertRegion    [limit = 9 dimensions]
; _PreDim          [limit = 9 dimensions]
; _ReverseArray    [limit = 9 dimensions]
; _SearchArray     [limit = 9 dimensions]
; _ShuffleArray    [limit = 9 dimensions]
; ==============================================================================================================================

; #INTERNAL_USE_ONLY#===========================================================================================================
; __AcquireExponent, __CreateTrac, __ExtractVector, __FindExact, __FindExactCase, __FindString, __FindStringCase, __FindWord,
; __FindWordCase __FloodFunc, ___FloodXD, ___FormatNum, __GetBounds, __HiddenIndices, ___Search1D, ___NewArray, ___NumCompare,
; __QuickSort1D, __QuickSortXD, __ResetBounds, ___Reverse1D, __Separate1D, __Separate256, __SeparateXD, __Shuffle1D,
; __ShuffleXD , __TagSortSwap, __TagSortSwapXD
; ==============================================================================================================================

#Au3Stripper_Off
Global $g__ARRWSHOP_RESUME = True ; prevents certain processes from running when set to False [do not use in your script]
Global Const $g__ARRWSHOP_SUB = ChrW(57344) ; [U+E000]

; #FUNCTION# ===================================================================================================================
; Name...........: _ArrayAttach
; Description ...: Joins two arrays together.
; Syntax.........: _ArrayAttach($aTarget, $aSource [, $iDimension = 1])
; Parameters.....; $aTarget - [ByRef] Target array to which the source array (or data) will be concatenated.
;                  $aSource - The array to attach to the target.
;                  $iDimension - [Optional] Integer value - the dimension in which concatenation occurs. Default = 1st dimension
; Return values .: Success - Returns the modified array ByRef.
;                  Failure sets @error as follows:
;                  |@error = 1 $aTarget is not a valid array.
;                  |@error = 2 Dimension limit exceeded.
;                  |@error = 3 Arrays must contain at least one element.
;                  |@error = 4 Output array size exceeds AutoIt limits.
; Author ........: czardas
; Comments ......; This function is limited to arrays of up to nine dimensions.
;                  Extra dimensions are added to the target when:
;                  1. the source array has more dimensions than the target [or]
;                  2. the 3rd parameter ($iDimension) is greater than the number of dimensions available.
; ==============================================================================================================================
Func _ArrayAttach(ByRef $aTarget, $aSource, $iDimension = 1)
	If Not IsArray($aTarget) Then Return SetError(1) ; the target must be an array

	Local $aBoundSrc[1]
	If Not IsArray($aSource) Then ; convert $aSource into an array
		$aBoundSrc[0] = $aSource ; use $aBoundSrc as a temporary array to preserve memory
		$aSource = $aBoundSrc ; conversion by assignment
	EndIf

	$aBoundSrc = __GetBounds($aSource, 9) ; get the bounds of the source array
	If @error Then Return SetError(3) ; $aSource must contain at least one element

	Local $aBoundTgt = __GetBounds($aTarget, 9) ; get the bounds of the target array
	If @error Then Return SetError(3) ; $aTarget must contain at least one element

	$iDimension = ($iDimension = Default) ? 1 : Int($iDimension)
	If $aBoundTgt[0] > 9 Or $aBoundSrc[0] > 9 Or $iDimension > 9 Or $iDimension < 1 Then Return SetError(2) ; dimension limit exceeded

	Local $iDim = ($aBoundSrc[0] > $aBoundTgt[0]) ? $aBoundSrc[0] : $aBoundTgt[0] ; minimum number of dimensions needed for the output
	If $iDimension > $iDim Then $iDim = $iDimension ; the specified dimension may not yet exist

	Local $aBoundNew[$iDim + 1] ; output bounds
	$aBoundNew[0] = $iDim ; element 0 contains the number of dimensions

	For $i = 1 To $iDim ; get the minimum bounds within all dimensions
		If $i <> $iDimension Then
			$aBoundNew[$i] = ($aBoundSrc[$i] > $aBoundTgt[$i]) ? $aBoundSrc[$i] : $aBoundTgt[$i]
		Else ; expansion within the explicit dimension is determined differently
			$aBoundNew[$i] = $aBoundSrc[$i] + $aBoundTgt[$i] ; add the number of sub-indices together
		EndIf
		$aBoundSrc[$i] -= 1 ; convert to the final index value in each dimension of the source array
	Next

	Local $iCount = 1 ; check output bounds remain within range
	For $i = 1 To $aBoundNew[0]
		$iCount *= $aBoundNew[$i]
		If $iCount > 16777216 Then Return SetError(4) ; output array size exceeds AutoIt limits
	Next

	_PreDim($aTarget, $iDim) ; add more dimensions if needed
	__ResetBounds($aTarget, $aBoundNew) ; ReDim the target to make space for more elements

	If $iDim = 1 Then ; [do not send to remote loop region]
		For $iRegion = $aBoundTgt[$iDimension] To $aBoundNew[$iDimension] - 1 ; to the new bounds of the [only] dimension
			$aTarget[$iRegion] = $aSource[$iRegion - $aBoundTgt[$iDimension]]
		Next
		Return
	EndIf

	Local $sTransfer = '$aSource' & __HiddenIndices($aBoundSrc[0], $iDimension), _ ; to access elements at their original indices
			$iFrom, $aFloodFill = __FloodFunc()
	$aBoundSrc[$iDimension] = 0 ; whichever loop this relates to must only run once on each encounter

	For $iRegion = $aBoundTgt[$iDimension] To $aBoundNew[$iDimension] - 1 ; to the new bounds of the specified dimension
		$iFrom = $iRegion - $aBoundTgt[$iDimension] ; adjusted to begin transfer from source element 0
		$aFloodFill[$iDim]($aTarget, $aBoundSrc, $iDimension, $iRegion, $iFrom, $aSource, $sTransfer) ; flood the region
	Next
EndFunc    ;==>_ArrayAttach

; #FUNCTION# ===================================================================================================================
; Name...........: _ArraySortXD
; Description ...: Sorts multidimensional arrays according to miscellaneous criteria.
; Syntax.........: _ArraySortXD($aArray [, $iDimension = 1 [, $iAlgorithm = 0 [, $iEnd = -1 [, $1 = 0 [, $2 = 0 ], etc... ]]]]
; Parameters.....; $aArray - [ByRef] The array to sort.
;                  $iDimension - [Optional] Integer value - the dimension in which sorting occurs. Default = 1st dimension
;                  $iAlgorithm - [Optional] Integer value - defines the sorting criteria. Default = lexical [see comments]
;                  $iEnd - [Optional] Integer value - final index to stop sorting (within the explicit dimension). Default = -1
;                  $1, $2, $3, $4, $5, $6, $7, $8, $9 - [Optional] - start sub-indices within each dimension. [see comments]
; Return values .: Success - Returns the modified array ByRef.
;                  Failure sets @error as follows:
;                  |@error = 1 The first parameter is not a valid array.
;                  |@error = 2 Array does not contain any elements.
;                  |@error = 3 Dimension does not exist.
;                  |@error = 4 Out of range start parameter detected.
;                  |@error = 5 Out of range $iEnd value detected.
;                  |@error = 6 Bad algorithm detected.
; Author ........: czardas
; Comments ......; The algorithm parameter is binary flag. You can combine any of the following values:
;                  $iAlgorithm = 0 - alphabetical (lexical - applies to all items including numbers)
;                  $iAlgorithm = 1 - descending (applies to sorted items only)
;                  $iAlgorithm = 2 - numeric (applies to numbers only)
;                  $iAlgorithm = 4 - alphanumeric (applies to all items - overrides flag 2)
;                  $iAlgorithm = 256 - sort decimal strings by magnitude (combine with flags 2 and 4)
;                  $iAlgorithm = 512 - maintain original sequence of non-numeric items (only applies to flag 2)
;                  You can combine the various flags using BitOR() or you can also add them together.
;                  When sorting with flag 2, numbers always appear before unsorted items.
;                  When sorting with flag 4, numbers appear before non-numeric items in ascending order.
;                  Flag 256 will be ignored if not combined with flags 2 or 4.
;                  Flag 512 will be ignored if not combined with flag 2.
;                  -----------------------------------------------------------
;                  Optional start sub-indices; $1, $2, $3, $4, $5, $6, $7, $8 and $9; work as follows:
;                  In the explicit dimension the start index should be less than $iEnd.
;                  In all other dimensions start values also represent end values. [range = 1, not multi-regional within XD]
;                  This function works for arrays of up to nine dimensions.
; ==============================================================================================================================
Func _ArraySortXD(ByRef $aArray, $iDimension = 1, $iAlgorithm = 0, $iEnd = -1, $1 = 0, $2 = 0, $3 = 0, $4 = 0, $5 = 0, $6 = 0, $7 = 0, $8 = 0, $9 = 0)
	If Not IsArray($aArray) Then Return SetError(1) ; $aArray must be an array

	Local $aBound = __GetBounds($aArray) ; get the bounds of the array
	If @error Then Return SetError(2) ; $aArray must contain more than zero elements

	$iDimension = ($iDimension = Default) ? 1 : Int($iDimension)
	If $iDimension > $aBound[0] Or $iDimension < 1 Then Return SetError(3) ; dimension limit exceeded

	Local $aParam = [$aBound[0], $1, $2, $3, $4, $5, $6, $7, $8, $9] ; [$aParam can be oversized]
	For $i = 1 To $aBound[0]
		$aParam[$i] = ($aParam[$i] = Default) ? 0 : Int($aParam[$i])
		If $aParam[$i] < 0 Or $aParam[$i] >= $aBound[$i] Then Return SetError(4) ; out of range start parameter was detected
	Next

	$iEnd = ($iEnd = -1 Or $iEnd = Default) ? $aBound[$iDimension] - 1 : Int($iEnd)
	Local $iStart = $aParam[$iDimension]
	If $iEnd <= $iStart Or $iEnd >= $aBound[$iDimension] Then Return SetError(5) ; meaningless $iEnd value

	$iAlgorithm = ($iAlgorithm = Default) ? 0 : Int($iAlgorithm)
	If BitAND(0xFFFFFCF8, $iAlgorithm) Then Return SetError(6) ; meaningless $iAlgorithm

	; determine the type of algorithm
	Local $bNumeric = BitAND($iAlgorithm, 2) Or BitAND($iAlgorithm, 4), _
			$bAlpha = BitAND($iAlgorithm, 4) Or Not $bNumeric, _
			$bDecimals = $bNumeric And BitAND($iAlgorithm, 256), _
			$bSequential = BitAND($iAlgorithm, 512) And BitAND($iAlgorithm, 2) And Not $bAlpha, _
			$bReverse = Mod($iAlgorithm, 2) <> 0

	Local $aTrac, $aVector, $iItems = 0 ; to count numeric elements [if needed]

	If $aBound[0] = 1 Then ; First deal with 1D arrays [optimized for algorithms 0, 2 and 4 without any other flags]
		If $bNumeric Then ; numeric [1D]
			If Not ($bDecimals Or $bSequential) Then ; tracking is not needed [conditional may require modification at some point to accomodate new algorithms]
				$iItems = __Separate1D($aArray, $iStart, $iEnd) ; place numbers before strings
				__QuickSort1D($aArray, $iStart, $iStart + $iItems - 1, 2) ; sort numbers numerically

			Else ; employ a track and trace mechanism
				$aTrac = __CreateTrac($aBound[$iDimension], $iStart, $iEnd) ; instead of sorting the array we will track migrating indices

				If $bDecimals Then
					$aVector = $aArray
					$iItems = __Separate256($aVector, $aTrac, $iStart, $iEnd) ; [numbers and decimal strings]
					__QuickSortXD($aVector, $aTrac, $iStart, $iStart + $iItems - 1, 256) ; pretend to sort the array but instead relocate indices in $aTrac
					$aVector = '' ; reduce memory usage ASAP
				Else ; [$bSequential = True]
					$iItems = __SeparateXD($aArray, $aTrac, $iStart, $iEnd) ; [numbers only]
					__QuickSortXD($aArray, $aTrac, $iStart, $iStart + $iItems - 1, 2) ; pretend to sort the array but instead relocate indices in $aTrac
				EndIf
			EndIf

			If $bAlpha Then
				If $bDecimals Then
					__QuickSortXD($aArray, $aTrac, $iStart + $iItems, $iEnd, 0) ; sort strings lexically
				Else
					__QuickSort1D($aArray, $iStart + $iItems, $iEnd, 0) ; sort strings lexically and finish
					If $bReverse Then ___Reverse1D($aArray, $iStart, $iEnd) ; descending
					Return ; finished
				EndIf

			ElseIf $bSequential Then
				__QuickSort1D($aTrac, $iStart + $iItems, $iEnd, 2) ; sort non-numeric element indices corrupted during separation

			ElseIf Not $bDecimals Then ; tracking was not used, so we are almost done here
				If $bReverse Then ___Reverse1D($aArray, $iStart, $iStart + $iItems - 1) ; descending
				Return ; finished
			EndIf

			If $bReverse Then ___Reverse1D($aTrac, $iStart, ($bAlpha ? $iEnd : $iStart + $iItems - 1)) ; reverse indices in $aTrac
			__TagSortSwap($aArray, $aTrac, $iStart, $iEnd) ; similar to the knight's tour problem

		Else ; lexical [1D]
			__QuickSort1D($aArray, $iStart, $iEnd, 0)
			If $bReverse Then ___Reverse1D($aArray, $iStart, $iEnd) ; descending
		EndIf

	Else ; multidimensional [XD]
		$aTrac = __CreateTrac($aBound[$iDimension], $iStart, $iEnd) ; used to track migrating indices
		$aVector = __ExtractVector($aArray, $iDimension, $aParam) ; first extract the vector to use for sorting (row or column etc...)

		; now come similar arguments as for 1D
		If $bNumeric Then ; numeric [XD]
			$iItems = $bDecimals ? __Separate256($aVector, $aTrac, $iStart, $iEnd) : __SeparateXD($aVector, $aTrac, $iStart, $iEnd)
			__QuickSortXD($aVector, $aTrac, $iStart, $iStart + $iItems - 1, ($bDecimals ? 256 : 2)) ; relocate indices in $aTrac

			If $bAlpha Then
				__QuickSortXD($aVector, $aTrac, $iStart + $iItems, $iEnd, 0) ; sort strings lexically
			ElseIf $bSequential Then
				$aVector = '' ; free up memory
				__QuickSort1D($aTrac, $iStart + $iItems, $iEnd, 2) ; sort non-numeric element indices corrupted during separation
			EndIf
			$aVector = '' ; as above
			If $bReverse Then ___Reverse1D($aTrac, $iStart, ($bAlpha ? $iEnd : $iStart + $iItems - 1))
		Else
			__QuickSortXD($aVector, $aTrac, $iStart, $iEnd, 0) ; relocate indices in $aTrac
			$aVector = '' ; as above
			If $bReverse Then ___Reverse1D($aTrac, $iStart, $iEnd) ; descending
		EndIf

		If $aBound[0] = 2 And $iDimension = 1 Then ; slightly more optimal method
			__TagSortSwapXD($aArray, $aTrac, $iStart, $iEnd) ; similar to the knight's tour problem

		Else
			$aParam = $aBound ; original parameters are no longer needed
			$aParam[$iDimension] = 1
			Local $aRegion = ___NewArray($aParam) ; to store extracted regions
			For $i = 1 To $aParam[0]
				$aParam[$i] -= 1
			Next

			Local $sIndices = __HiddenIndices($aBound[0], $iDimension), $fnFloodFill = __FloodFunc()[$aBound[0]], _
					$iCurr, $iNext, $sTransfer = '$aSource' & $sIndices ; array syntax

			; [now comes the knight's tour in 9 dimensions] ;)
			For $iInit = $iStart To $iEnd ; initialize each swap sequence
				If $aTrac[$iInit] <> $iInit Then ; regions will now be overwritten in accordance with tracking information
					$iCurr = $iInit ; set the current region as the start of the sequence

					$fnFloodFill($aRegion, $aParam, $iDimension, 0, $iInit, $aArray, $sTransfer) ; extract region
					$sTransfer = '$aTarget' & $sIndices ; array syntax

					Do
						$fnFloodFill($aArray, $aParam, $iDimension, $iCurr, $aTrac[$iCurr], '', $sTransfer) ; overwrite each region in the sequence
						$iNext = $aTrac[$iCurr] ; get the next index in the sequence
						$aTrac[$iCurr] = $iCurr ; set to ignore overwritten regions on subsequent encounters
						$iCurr = $iNext ; follow the trail as far as it goes [index could be higher or lower]
					Until $aTrac[$iCurr] = $iInit ; all sequences end at this juncture

					$sTransfer = '$aSource' & $sIndices ; now we know where to put the initial region we copied earlier
					$fnFloodFill($aArray, $aParam, $iDimension, $iCurr, 0, $aRegion, $sTransfer)
					$aTrac[$iCurr] = $iCurr ; set to ignore on subsequent encounters [as above]
				EndIf
			Next
		EndIf
	EndIf
EndFunc    ;==>_ArraySortXD

; #FUNCTION# ===================================================================================================================
; Name...........: _ArrayTransform
; Description ...: Alters the shape of a multidimensional array without losing data.
; Syntax.........: _ArrayTransform($aArray [, $sShape = Default])
; Parameters.....; $aArray - The array to modify.
;                  $sShape - [Optional] String or integer value - output dimension bounds sequence [See Comments]
; Return values .: Success - Returns the transformed array [ByRef].
;                  Failure sets @error as follows:
;                  |@error = 1 The 1st parameter is not a valid array.
;                  |@error = 2 Bad $sShape parameter.
; Author ........: czardas
; Comments ......: The shape parameter must be a sequence of unique digits: each refering to a different dimension.
;                  For a 2D array the default shape parameter is '21', and for 3D it is '321' etc...
;                  The default output sequence transposes the array by reversing the dimension bounds ==> [7][8] becomes [8][7].
;                  If you want a different output shape, change the dimension bounds sequence.
;                  eg. when $sShape = '2431', [1][2][3][4] will become [2][4][3][1]
;                  This function is limited to arrays of between two and nine dimensions.
; ==============================================================================================================================
Func _ArrayTransform(ByRef $aArray, $sShape = Default) ; [default shape = reverse sequence '987654321']
	If Not IsArray($aArray) Then Return SetError(1) ; not a valid array.

	Local $aBound = __GetBounds($aArray)
	If @error Or $aBound[0] = 1 Or $aBound[0] > 9 Then Return SetError(1)
	If $sShape = Default Then $sShape = StringRight('987654321', $aBound[0])
	If StringLen($sShape) <> $aBound[0] Or Not StringIsDigit($sShape) Then Return SetError(2) ; bad $sShape parameter

	Local $aTrac = StringSplit($sShape, ''), $sTransfer = '$aSource'
	For $i = 1 To $aBound[0]
		If Not StringInStr($sShape, $i) Then Return SetError(2) ; bad $sShape parameter [dimensions must already exist]
		$sTransfer &= '[$a[' & $aTrac[$i] & ']]' ; default ==> '$aSource[$a[9]][$a[8]][$a[7]][$a[6]][$a[5]] etc...'
	Next

	Local $aBoundNew = $aBound
	__TagSortSwap($aBoundNew, $aTrac, 1, $aBoundNew[0])

	Local $aNewArray = ___NewArray($aBoundNew), $fnFloodFill = __FloodFunc()[$aBound[0]]

	For $i = 1 To $aBoundNew[0]
		$aBoundNew[$i] -= 1
	Next
	$fnFloodFill($aNewArray, $aBoundNew, 0, 0, '', $aArray, $sTransfer)
	$aArray = $aNewArray
EndFunc    ;==>_ArrayTransform

; #FUNCTION# ===================================================================================================================
; Name...........: _ArrayUniqueXD
; Description ...: Removes duplicate items from an array (or duplicate regions from a multidimensional array).
; Syntax.........: _ArrayUniqueXD($aArray [, $bCaseSense = False [, $iDimension = 1]])
; Parameters.....; $aArray - The array containing duplicate regions to be removed.
;                  $bCaseSense - [Optional] Set to true for case sensitive matches. Default value = False
;                  $iDimension - [Optional] Integer value - the dimension to which uniqueness applies. Default = 1st dimension
; Return values .: Success - Returns the unique array [ByRef].
;                  Failure sets @error as follows:
;                  |@error = 1 The 1st parameter is not an array.
;                  |@error = 2 The 1st parameter does not contain any elements.
;                  |@error = 3 The 3rd parameter is not a valid dimension.
; Author ........: czardas
; Comments ......; This function is limited to (medium sized) arrays of up to five dimensions.
;                  All elements within a region must be duplicated (in juxtaposed positions) before removal takes place.
;                  Integers of the same magnitude are treated as duplicates regardless of data type.
;                  This function does not remove regions containing objects, DLLStructs or other arrays.
; Example .......; _ArrayUniqueXD($aArray, Default, 2) ; [$iDimension = 2] ; ==> deletes duplicate COLUMNS from a 2D array
; ==============================================================================================================================
Func _ArrayUniqueXD(ByRef $aArray, $bCaseSense = Default, $iDimension = 1)
	If Not IsArray($aArray) Or UBound($aArray, 0) > 9 Then Return SetError(1) ; not a valid array

	Local $aBound = __GetBounds($aArray, 9)
	If @error Then Return SetError(2) ; array contains zero elements

	$iDimension = ($iDimension = Default) ? 1 : Int($iDimension)
	If $iDimension < 1 Or $iDimension > $aBound[0] Then Return SetError(3) ; dimension does not exist

	If $aBound[$iDimension] < 2 Then Return ; the array is already unique

	For $i = 1 To 9
		$aBound[$i] -= 1 ; set the max index in each dimension
	Next

	Local $sExpression = '$aArray' ; to access elements at their original indices

	For $i = 1 To $aBound[0]
		If $i <> $iDimension Then
			$sExpression &= '[$' & $i & ']' ; default expression = '$aArray[$iFrom][$2][$3][$4][$5] etc...'
		Else
			$sExpression &= '[$iFrom]'
		EndIf
	Next

	Local $sTransfer = '$aTarget' & __HiddenIndices($aBound[0], $iDimension), _
			$fnFloodFill = __FloodFunc()[$aBound[0]], $iDim = $aBound[0], _ ; preserve this value
			$iItems = 0, $aFunction[1] = [0], $vElement, $iInt, $sName

	$aBound[0] = $aBound[$iDimension] ; the first loop will run to the bounds of the specified dimension
	$aBound[$iDimension] = 0 ; whichever loop this relates to must only run once on each encounter

	If $bCaseSense = Default Then $bCaseSense = False
	Local $oDictionary = ObjCreate("Scripting.Dictionary")

	For $iFrom = 0 To $aBound[0]
		$sName = '' ; clear previous name

		For $9 = 0 To $aBound[9]
			For $8 = 0 To $aBound[8]
				For $7 = 0 To $aBound[7]
					For $6 = 0 To $aBound[6]
						For $5 = 0 To $aBound[5]
							For $4 = 0 To $aBound[4]
								For $3 = 0 To $aBound[3]
									For $2 = 0 To $aBound[2]
										For $1 = 0 To $aBound[1]
											$vElement = Execute($sExpression) ; get the data contained in each element

											; use non-hexadecimal characters (other than x) as datatype identifiers and convert the data to hexadecimal where necessary
											Switch VarGetType($vElement)
												Case 'String'
													If Not $bCaseSense Then $vElement = StringUpper($vElement) ; generates a case insensitive name segment
													$sName &= 's' & StringToBinary($vElement, 4) ; UTF8 [$SB_UTF8]
												Case 'Int32', 'Int64' ; use decimal without conversion
													; the minus sign of a negative integer is replaced with 'g': to distinguish it from the positive value
													$sName &= ($vElement < 0) ? 'g' & StringTrimLeft($vElement, 1) : 'i' & $vElement
												Case 'Double' ; may be an integer
													$iInt = Int($vElement)
													$sName &= ($vElement = $iInt) ? (($iInt < 0) ? 'g' & StringTrimLeft($iInt, 1) : 'i' & $iInt) : 'h' & Hex($vElement)
												Case 'Bool' ; True or False
													$sName &= ($vElement = True) ? 't' : 'v'
												Case 'Binary'
													$sName &= 'y' & $vElement
												Case 'Ptr'
													$sName &= 'p' & $vElement
												Case 'Keyword' ; Default or Null (other variable declarations are illegal)
													$sName &= ($vElement = Default) ? 'w' : 'n'
												Case 'Function', 'UserFunction' ; string conversion will fail
													For $k = 1 To $aFunction[0] ; unique functions are stored in a separate array
														If $vElement = $aFunction[$k] Then ; this function has been encountered previously
															$sName &= 'u' & $k
															ContinueLoop 2
														EndIf
													Next
													$aFunction[0] += 1
													If $aFunction[0] > UBound($aFunction) - 1 Then ReDim $aFunction[$aFunction[0] + 10]
													$aFunction[$aFunction[0]] = $vElement
													$sName &= 'u' & $aFunction[0]
												Case Else ; Array, Object, DLLStruct [or Map]
													$sName = False ; set to ignore
													ExitLoop 5
											EndSwitch
										Next
									Next
								Next
							Next
						Next
					Next
				Next
			Next
		Next

		If $sName Then
			If $oDictionary.Exists($sName) Then ContinueLoop ; this region has been seen previously
			$oDictionary.Item($sName) ; use $sName as key
		EndIf

		; overwrite the next region (assumes that the first duplicate region will be found quite quickly)
		If $iDim = 1 Then
			$aArray[$iItems] = $aArray[$iFrom]
		Else
			$fnFloodFill($aArray, $aBound, $iDimension, $iItems, $iFrom, '', $sTransfer) ; access the remote loop region
		EndIf
		$iItems += 1
	Next

	$aBound[0] = $iDim ; reset the number of dimensions
	For $i = 1 To $aBound[0] ; reset the bounds
		$aBound[$i] += 1
	Next
	$aBound[$iDimension] = $iItems ; new bounds of the explicit dimension
	__ResetBounds($aArray, $aBound) ; remove the remaining duplicate array regions
EndFunc    ;==>_ArrayUniqueXD

; #FUNCTION# ===================================================================================================================
; Name...........: _DeleteDimension
; Description ...: Delete dimensions, or a range of dimensions, from a multidimensional array.
; Syntax.........: _DeleteDimension(ByRef $aArray, $iDimension, $iRange = 1)
; Parameters.....; $aArray - [ByRef] The array from which dimensions are deleted.
;                  $iDimension - Integer value - the dimension (or the first dimension) to delete.
;                  $iRange - [Optional] Integer value - the number of dimensions to delete. Default = 1
; Return values .: Success - Returns the modified array ByRef.
;                  Failure sets @error as follows:
;                  |@error = 1 $aArray is not a valid array.
;                  |@error = 2 Dimension limit exceeded.
;                  |@error = 3 Arrays must contain at least one element.
;                  |@error = 4 Meaningless range value [range must be greater than zero].
;                  |@error = 5 Illegal operation - deleting all dimensions is not supported.
; Author ........: czardas
; Comments ......; Beware - deleting dimensions can have very destructive effect on the array's contents.
;                  Deletes all regions with indices greater than zero while removing each dimension.
;                  This function will not delete all the dimensions from an array.
;                  This function is limited to arrays of up to nine dimensions.
; ==============================================================================================================================
Func _DeleteDimension(ByRef $aArray, $iDimension, $iRange = 1)
	If Not IsArray($aArray) Then Return SetError(1) ; this parameter must be an array

	Local $aBound = __GetBounds($aArray)
	If @error Then Return SetError(3) ; arrays must contain at least one element
	If $aBound[0] > 9 Then Return SetError(2)

	$iDimension = Int($iDimension)
	If $iDimension < 1 Or $iDimension > $aBound[0] Then Return SetError(2)

	; check for dimension range overflow and set to ignore [subject to review]
	$iRange = ($iRange = Default) ? 1 : Int($iRange)
	If $iRange < 1 Then Return SetError(4) ; range must be greater than zero
	If $iDimension + $iRange - 1 >= $aBound[0] Then $iRange = 1 + $aBound[0] - $iDimension
	If $iRange = $aBound[0] Then Return SetError(5) ; illegal operation [deleting all dimensions is not an intended feature]

	Local $sTransfer = '$aSource', $iCount = 1, $aBoundNew[$aBound[0] - $iRange + 1]
	$aBoundNew[0] = $aBound[0] - $iRange

	For $i = 1 To $aBound[0]
		If $i < $iDimension Or $i > $iDimension + $iRange - 1 Then ; dimensions to keep
			$aBoundNew[$iCount] = $aBound[$i] ; assign the bounds of the new array
			$sTransfer &= '[$a[' & $iCount & ']]'
			$iCount += 1

		Else ; dimensions to delete
			For $i = $iDimension To $iDimension + $iRange - 1 ; run through the range
				$sTransfer &= '[0]' ; delete / hide dimensions from the fill instructions
			Next
			$i -= 1 ; prevents incrementing the loop iteration count twice
		EndIf
	Next

	Local $aNewArray = ___NewArray($aBoundNew)

	For $i = 1 To $aBoundNew[0]
		$aBoundNew[$i] -= 1 ; maximum sub-index within each dimension
	Next

	Local $aFloodFill = __FloodFunc()
	$aFloodFill[$aBoundNew[0]]($aNewArray, $aBoundNew, 0, 0, '', $aArray, $sTransfer) ; flood the new array

	$aArray = $aNewArray
EndFunc    ;==>_DeleteDimension

; #FUNCTION# ===================================================================================================================
; Name...........: _DeleteRegion
; Description ...: Deletes a region from a multidimensional array.
; Syntax.........: _DeleteRegion($aArray, $iDimension [, $iSubIndex = 0 [, $iRange = 1]])
; Parameters.....; $aArray - [ByRef] The array to delete the region from.
;                  $iDimension - [Optional] Integer value - the dimension used to define the region. Default = 1
;                  $iSubIndex - [Optional] Integer value - the index, or start of, of the region to delete. Default = 0
;                  $iRange - [Optional] Integer value - the size of the region to delete. Default = 1
; Return values .: Success - Returns the modified array ByRef.
;                  Failure sets @error as follows:
;                  |@error = 1 $aArray is not a valid array.
;                  |@error = 2 Dimension limit exceeded.
;                  |@error = 3 Dimension does not exist in the array.
;                  |@error = 4 Arrays must contain at least one element.
;                  |@error = 5 Sub-index does not exist in the dimension.
;                  |@error = 6 Invalid Range.
; Author ........: czardas
; Comments ......; This function is limited to arrays of up to nine dimensions.
; ==============================================================================================================================
Func _DeleteRegion(ByRef $aArray, $iDimension = 1, $iSubIndex = 0, $iRange = 1)
	If Not IsArray($aArray) Then Return SetError(1)

	Local $aBound = __GetBounds($aArray) ; get the bounds of each dimension
	If @error Then Return SetError(4) ; $aArray must contain at least one element
	If $aBound[0] > 9 Then Return SetError(2) ; nine dimension limit

	$iDimension = ($iDimension = Default) ? 1 : Int($iDimension)
	If $iDimension > $aBound[0] Or $iDimension < 1 Then Return SetError(3) ; out of bounds dimension

	$iSubIndex = ($iSubIndex = Default) ? 0 : Int($iSubIndex)
	If $iSubIndex < 0 Or $iSubIndex > $aBound[$iDimension] - 1 Then Return SetError(5) ; sub-index does not exist in the dimension

	$iRange = ($iRange = Default) ? 1 : Int($iRange)
	If $iRange < 1 Then Return SetError(6) ; range must be greater than zero
	$iRange = ($iSubIndex + $iRange < $aBound[$iDimension]) ? $iRange : $aBound[$iDimension] - $iSubIndex ; corrects for overflow
	If $iRange = $aBound[$iDimension] Then Return SetError(6) ; deleting the whole region is not currently supported [give reason]

	$aBound[$iDimension] -= $iRange ; the size of the dimension in the new array

	If $aBound[0] = 1 Then
		For $iNext = $iSubIndex To $aBound[$iDimension] - 1
			$aArray[$iNext] = $aArray[$iNext + $iRange]
		Next
		ReDim $aArray[$aBound[$iDimension]]
		Return
	EndIf

	Local $iMaxIndex = $aBound[$iDimension] - 1
	For $i = 1 To $aBound[0]
		$aBound[$i] -= 1
	Next
	$aBound[$iDimension] = 0 ; set to loop once [one region at a time]

	Local $iFrom, $sTransfer = '$aTarget' & __HiddenIndices($aBound[0], $iDimension), $fnFloodFill = __FloodFunc()[$aBound[0]]

	For $iNext = $iSubIndex To $iMaxIndex
		$iFrom = $iNext + $iRange
		$fnFloodFill($aArray, $aBound, $iDimension, $iNext, $iFrom, '', $sTransfer) ; overwrite the final [untouched] region
	Next

	$aBound[$iDimension] = $iMaxIndex
	For $i = 1 To $aBound[0]
		$aBound[$i] += 1
	Next

	__ResetBounds($aArray, $aBound) ; delete remaining indices
EndFunc    ;==>_DeleteRegion

; #FUNCTION# ===================================================================================================================
; Name...........: _ExtractRegion
; Description ...: Extracts a region from a multidimensional array.
; Syntax.........: _ExtractRegion($aArray, $iDimension [, $iSubIndex = 0 [, $iRange = 1]])
; Parameters.....; $aArray - The array from which to extract the region.
;                  $iDimension - Integer value - the dimension used to define the region.
;                  $iSubIndex - [Optional] Integer value - the index, or start of, of the region to extract. Default = 0
;                  $iRange - [Optional] Integer value - the number of regions to extract. Default = 1
; Return values .: Success - Returns a new array containing all the extracted regions within the defined range.
;                  Failure sets @error as follows:
;                  |@error = 1 $aArray is not a valid array.
;                  |@error = 2 Dimension limit exceeded.
;                  |@error = 3 Dimension does not exist in the array.
;                  |@error = 4 Arrays must contain at least one element.
;                  |@error = 5 Sub-index does not exist in the dimension.
;                  |range must be greater than zero
; Author ........: czardas
; Comments ......; This function is limited to arrays of up to nine dimensions.
;                  The extracted region will contain the same number of dimensions as the original array.
; ==============================================================================================================================
Func _ExtractRegion($aArray, $iDimension, $iSubIndex = 0, $iRange = 1)
	If Not IsArray($aArray) Then Return SetError(1)

	Local $aBound = __GetBounds($aArray) ; get the bounds of each dimension
	If @error Then Return SetError(4) ; $aArray must contain at least one element
	If $aBound[0] > 9 Then Return SetError(2) ; nine dimension limit

	$iDimension = Int($iDimension)
	If $iDimension > $aBound[0] Or $iDimension < 1 Then Return SetError(3) ; out of bounds dimension

	$iSubIndex = ($iSubIndex = Default) ? 0 : Int($iSubIndex)
	If $iSubIndex < 0 Or $iSubIndex > $aBound[$iDimension] - 1 Then Return SetError(5) ; sub-index does not exist in the dimension

	$iRange = ($iRange = Default) ? 1 : Int($iRange)
	If $iRange < 1 Then Return SetError(6) ; range must be greater than zero
	$iRange = ($iSubIndex + $iRange < $aBound[$iDimension]) ? $iRange : $aBound[$iDimension] - $iSubIndex

	$aBound[$iDimension] = $iRange ; the size of the dimension in the new array
	Local $aRegion = ___NewArray($aBound) ; create new array

	For $i = 1 To $aBound[0]
		$aBound[$i] -= 1
	Next

	If $aBound[0] = 1 Then
		For $iNext = 0 To $iRange - 1
			$aRegion[$iNext] = $aArray[$iNext + $iSubIndex]
		Next
		Return $aRegion
	EndIf

	$aBound[$iDimension] = 0 ; set to loop once [one region at a time]

	Local $iFrom, $sTransfer = '$aSource' & __HiddenIndices($aBound[0], $iDimension), $fnFloodFill = __FloodFunc()[$aBound[0]]

	For $iNext = 0 To $iRange - 1
		$iFrom = $iNext + $iSubIndex
		$fnFloodFill($aRegion, $aBound, $iDimension, $iNext, $iFrom, $aArray, $sTransfer) ; extract region
	Next

	Return $aRegion
EndFunc    ;==>_ExtractRegion

; #FUNCTION# ===================================================================================================================
; Name...........: _InsertRegion
; Description ...: Inserts a multidimensional array into another multidimensional array.
; Syntax.........: _InsertRegion($aTarget, $aSource [, $iDimension = 1 [, $iSubIndex = 0]])
; Parameters.....; $aTarget - The array to modify.
;                  $aSource - The array to insert.
;                  $iDimension - Integer value - the dimension in which insertion takes place.
;                  $iSubIndex - [Optional] Integer value - sub-index within the dimension where insertion occurs. Default = 0
; Return values .: Success - Returns the target array ByRef.
;                  Failure sets @error as follows:
;                  |@error = 1 $aTarget is not a valid array.
;                  |@error = 2 $aSource is not a valid array.
;                  |@error = 3 Arrays must contain at least one element.
;                  |@error = 4 Array bounds do not match.
;                  |@error = 5 Output array size exceeds AutoIt limits.
;                  |@error = 6 $iSubIndex is out of range.
; Author ........: czardas
; Comments ......; This function is limited to arrays of up to nine dimensions.
;                  The target array must contain the same number of dimensions as the source array.
;                  With the exception of $iDimension; the bounds of all other dimensions, in both arrays, must match.
; ==============================================================================================================================
Func _InsertRegion(ByRef $aTarget, $aSource, $iDimension = 1, $iSubIndex = 0)
	If Not IsArray($aTarget) Or UBound($aTarget, 0) > 9 Then Return SetError(1)
	If Not IsArray($aSource) Or UBound($aSource, 0) > 9 Then Return SetError(2)

	Local $aBoundTgt = __GetBounds($aTarget)
	If @error Then Return SetError(3) ; arrays must contain at least one element

	Local $aBoundSrc = __GetBounds($aSource)
	If @error Then Return SetError(3) ; arrays must contain at least one element

	$iDimension = ($iDimension = Default) ? 1 : Int($iDimension)
	For $i = 1 To $aBoundTgt[0]
		If $aBoundTgt[$i] <> $aBoundSrc[$i] And $iDimension <> $i Then Return SetError(4) ; array bounds are inconsistent
	Next

	$iSubIndex = ($iSubIndex = Default) ? 0 : Int($iSubIndex)
	If $iSubIndex < 0 Or $iSubIndex > $aBoundTgt[$iDimension] Then Return SetError(5) ; $iSubIndex is out of range

	Switch $iSubIndex
		Case 0
			_ArrayAttach($aSource, $aTarget, $iDimension)
			If @error Then Return SetError(6) ; output array size exceeds AutoIt limits
			$aTarget = $aSource

		Case $aBoundTgt[$iDimension]
			_ArrayAttach($aTarget, $aSource, $iDimension)
			If @error Then Return SetError(6) ; output array size exceeds AutoIt limits

		Case Else
			; check output bounds remain within range before modifications begin
			$aBoundSrc[$iDimension] += $aBoundTgt[$iDimension]
			Local $iCount = 1
			For $i = 1 To $aBoundSrc[0]
				$iCount *= $aBoundSrc[$i]
				If $iCount > 16777216 Then Return SetError(6) ; output array size exceeds AutoIt limits
			Next

			Local $aEnd = _ExtractRegion($aTarget, $iDimension, $iSubIndex, 16777216) ; out of bounds range values extract all remaining sub-indices within the dimension
			If @error Then Return SetError(@error)

			$aBoundTgt[$iDimension] = $iSubIndex
			__ResetBounds($aTarget, $aBoundTgt)
			_ArrayAttach($aTarget, $aSource, $iDimension)
			_ArrayAttach($aTarget, $aEnd, $iDimension)
	EndSwitch
EndFunc    ;==>_InsertRegion

; #FUNCTION# ===================================================================================================================
; Name...........: _PreDim
; Description ...: Changes the size of an array by adding, or removing, dimensions.
; Syntax.........: _PreDim($aArray, $iDimensions [, $iPush = False])
; Parameters.....; $aArray - The original array.
;                  $iDimensions - The number of dimensions in the returned array.
;                  $bPush - [Optional] If set to True, new dimensions are created on, or removed from, the left [see comments].
; Return values .: Returns the modified array ByRef.
;                  Failure sets @error as follows:
;                  |@error = 1 The first parameter is not an array.
;                  |@error = 2 The requested array has more than 9 dimensions.
;                  |@error = 3 The original array has more than 9 dimensions.
;                  |@error = 4 Arrays must contain at least one element.
; Author.........: czardas
; Comments ......; This function works for up to 9 dimensions.
;                  By default, new dimensions are added to the right in a standard sequence: $aArray[7][6] ==> $aArray[7][6][1]
;                  Dimensions are removed in reverse sequence: $aArray[7][6] ==> $aArray[7]
;                  When the $bPush parameter is set to True, the original array will be pushed to higher dimensions:
;                  $aArray[7][6] ==> $aArray[1][7][6], or the process reversed: $aArray[7][6] ==> $aArray[6]
; ==============================================================================================================================
Func _PreDim(ByRef $aArray, $iDimensions, $bPush = False)
	If Not IsArray($aArray) Then Return SetError(1)

	$iDimensions = Int($iDimensions)
	If $iDimensions < 1 Or $iDimensions > 9 Then Return SetError(2)

	Local $iPreDims = UBound($aArray, 0) ; current number of dimensions
	If $iPreDims = $iDimensions Then Return ; no change
	If $iPreDims > 9 Then Return SetError(3) ; too many dimensions

	Local $aBound = __GetBounds($aArray) ; get the size of each original dimension
	If @error Then Return SetError(4) ; $aArray must contain at least one element

	$aBound[0] = $iDimensions ; overwrite this value with the new number of dimensions

	Local $sTransfer = '[$a[1]][$a[2]][$a[3]][$a[4]][$a[5]][$a[6]][$a[7]][$a[8]][$a[9]]' ; array syntax to be sent to the remote loop region

	If $bPush Then ; prefix dimensions, or delete from the left
		Local $iOffset = Abs($iDimensions - $iPreDims)
		If $iPreDims > $iDimensions Then ; lower dimensions get deleted
			For $i = 1 To $iDimensions ; shift elements to lower indices
				$aBound[$i] = $aBound[$i + $iOffset]
			Next
			$sTransfer = '$aSource' & StringLeft('[0][0][0][0][0][0][0][0]', $iOffset * 3) & StringLeft($sTransfer, $iDimensions * 7)

		Else ; lower dimensions are created
			ReDim $aBound[$iDimensions + 1] ; make space for more dimensions
			For $i = $iDimensions To $iOffset + 1 Step -1 ; shift elements to higher indices
				$aBound[$i] = $aBound[$i - $iOffset]
			Next
			For $i = 1 To $iOffset ; assign the size of each additional dimension [1][1][1]... etc...
				$aBound[$i] = 1
			Next

			$sTransfer = '$aSource' & StringMid($sTransfer, 1 + $iOffset * 7, $iPreDims * 7)
		EndIf

	Else ; Default behaviour = append dimensions, or delete from the right
		ReDim $aBound[$iDimensions + 1] ; modify the number of dimensions [according to the new array]

		For $i = $iPreDims + 1 To $iDimensions ; assign the size of each new dimension ...[1][1][1] etc...
			$aBound[$i] = 1
		Next
		$sTransfer = '$aSource' & StringLeft($sTransfer, $iPreDims * 7)
	EndIf

	; add or remove dimensions
	Local $aNewArray = ___NewArray($aBound)

	For $i = 1 To $iDimensions
		$aBound[$i] -= 1 ; convert elements to the maximum index value within each dimension
	Next

	; access the remote loop region
	Local $iSubIndex = 0, $aFloodFill = __FloodFunc()
	$aFloodFill[$iDimensions]($aNewArray, $aBound, 0, $iSubIndex, '', $aArray, $sTransfer)

	$aArray = $aNewArray
EndFunc    ;==>_PreDim

; #FUNCTION# ===================================================================================================================
; Name...........: _ReverseArray
; Description ...: Reverses regions within a multidimensional array.
; Syntax.........: _ReverseArray($aArray [, $iDimension = 1 [, $iStart = 0 [, $iEnd = -1]]])
; Parameters.....; $aArray - The array to modify.
;                  $iDimension - [Optional] Integer value - the dimension in which the array sub-indices (regions) are reversed.
;                  $iStart - [Optional] The start sub-index within the defined dimension. Default value = 0
;                  $iEnd - [Optional] Integer value - The end sub-index within the defined dimension. Default value = -1
; Return values .: Success - Returns the reversed array [ByRef].
;                  Failure sets @error as follows:
;                  |@error = 1 The 1st parameter is not a valid array.
;                  |@error = 2 The 1st parameter does not contain any elements.
;                  |@error = 3 The dimension does not exist.
;                  |@error = 4 Meaningless $iStart value.
;                  |@error = 5 Meaningless $iEnd value.
; Author ........: czardas
; Comments ......; This function is limited to arrays of up to nine dimensions.
; ==============================================================================================================================
Func _ReverseArray(ByRef $aArray, $iDimension = 1, $iStart = 0, $iEnd = -1)
	If Not IsArray($aArray) Or UBound($aArray, 0) > 9 Then Return SetError(1) ; not a valid array

	Local $aBound = __GetBounds($aArray)
	If @error Then Return SetError(2) ; array contains zero elements

	$iDimension = ($iDimension = Default) ? 1 : Int($iDimension)
	If $iDimension < 1 Or $iDimension > $aBound[0] Then Return SetError(3) ; dimension does not exist

	$iStart = ($iStart = Default) ? 0 : Int($iStart)
	If $iStart < 0 Or $iStart > $aBound[$iDimension] - 2 Then Return SetError(4) ; meaningless $iStart value

	$iEnd = ($iEnd = -1 Or $iEnd = Default) ? $aBound[$iDimension] - 1 : Int($iEnd)
	If $iEnd <= $iStart Or $iEnd >= $aBound[$iDimension] Then Return SetError(5) ; meaningless $iEnd value

	If $aBound[0] = 1 Then
		___Reverse1D($aArray, $iStart, $iEnd)
	Else
		$aBound[$iDimension] = 1
		Local $aRegion = ___NewArray($aBound) ; to store extracted regions

		For $i = 1 To $aBound[0]
			$aBound[$i] -= 1
		Next

		Local $sIndices = __HiddenIndices($aBound[0], $iDimension), $fnFloodFill = __FloodFunc()[$aBound[0]], _
				$sTransfer = '$aSource' & $sIndices ; array syntax

		While $iEnd > $iStart
			$fnFloodFill($aRegion, $aBound, $iDimension, 0, $iStart, $aArray, $sTransfer) ; extract the current start region

			$sTransfer = '$aTarget' & $sIndices
			$fnFloodFill($aArray, $aBound, $iDimension, $iStart, $iEnd, '', $sTransfer) ; overwrite the current start region

			$sTransfer = '$aSource' & $sIndices
			$fnFloodFill($aArray, $aBound, $iDimension, $iEnd, 0, $aRegion, $sTransfer) ; overwrite the current end region

			$iStart += 1
			$iEnd -= 1
		WEnd
	EndIf
EndFunc    ;==>_ReverseArray

; #FUNCTION# ===================================================================================================================
; Name...........: _SearchArray
; Description ...: Searches through a multidimensional array.
; Syntax.........: _SearchArray($aArray, $vSearchTerm [, $bCaseSense = False [, $iDimension = 1]])
; Parameters.....; $aArray - [ByRef] Target array to which the source array (or data) will be concatenated.
;                  $vSearchTerm - The string or data to search for.
;                  $bCaseSense - [Optional] Boolean value - case sensitive search. Default = False
;                  $iDimension - [Optional] Integer value - the dimension used to conduct the search. Default = 1st dimension
;                  $iAlgo - [Optional] Algorithm: 1 = exact match, 2 = find a string, 3 = find a word within text. [Default = 1]
; Return values .: Success - Returns an array of all regions containing the term searched for within the defined dimension.
;                  Failure sets @error as follows:
;                  |@error = 1 $aArray is not a valid array.
;                  |@error = 2 Arrays must contain a minimum of one element.
;                  |@error = 3 Dimension limit exceeded.
;                  |@error = 4 Bad algorithm.
;                  |@error = 5 No matches found.
; Author ........: czardas
; Comments ......; This function is limited to arrays of up to nine dimensions.
;                  Searching through a 2D array in the first dimension returns an array of all rows containing the search term.
;                  Searching a 2D array in the second dimension will return an array of all columns containing the search term.
;                  Searching any array will return an array of regions containing the search term within the defined dimension.
;                  [$iAlgo = 3] A word may contain any characters. Word boundaries are defined by non-alphanumeric characters.
;                  May return FP matches if $iAlgo = 3, $vSearchTerm contains '\E' and $aArray contains the code point U+E000.
; ==============================================================================================================================
Func _SearchArray($aArray, $vSearchTerm, $bCaseSense = False, $iDimension = 1, $iAlgo = 1) ; [Exact Match]
	If Not IsArray($aArray) Then Return SetError(1) ; this parameter must be an array

	Local $aBound = __GetBounds($aArray)
	If @error Then Return SetError(2) ; arrays must contain at least one element
	If $aBound[0] > 9 Then Return SetError(3) ; dimension range exceeded

	$iDimension = ($iDimension = Default) ? 1 : Int($iDimension)
	If $iDimension < 1 Or $iDimension > $aBound[0] Then Return SetError(3)

	$iAlgo = ($iAlgo = Default) ? 1 : Int($iAlgo)
	If $iAlgo < 1 Or $iAlgo > 3 Then Return SetError(4)

	If $aBound[0] = 1 Then ; 1D special case
		$aArray = ___Search1D($aArray, $vSearchTerm, $bCaseSense, $iAlgo)
		Return @error ? SetError(5) : $aArray
	EndIf

	For $i = 1 To $aBound[0]
		$aBound[$i] -= 1 ; maximum index value within each dimension
	Next

	Local $iItems = 0, $iMaxIndex = $aBound[$iDimension], $fnFloodFill = __FloodFunc()[$aBound[0]], $aFunc = ['__FindExact', '__FindString', '__FindWord'], _
			$sTransfer = $aFunc[$iAlgo - 1] & ($bCaseSense ? 'Case' : '') & '($aTarget, $a, $aBound, $iFrom, "$aTarget' & _
			__HiddenIndices($aBound[0], $iDimension) & '")' ; string to execute

	$aBound[0] = $vSearchTerm
	$aBound[$iDimension] = 0 ; this loop must only run once on each encounter

	For $iFrom = 0 To $iMaxIndex ; loop through sub-indices within the dimension
		$fnFloodFill($aArray, $aBound, $iDimension, $iItems, $iFrom, '', $sTransfer) ; overwrite the current region while searching

		If Not $g__ARRWSHOP_RESUME Then ; a match halted the search during the overwrite
			$iItems += 1 ; set to overwrite the next region
			$g__ARRWSHOP_RESUME = True ; resume searching on the next pass
		EndIf
	Next

	If $iItems = 0 Then Return SetError(5) ; no matches found

	$aBound[0] = UBound($aBound) - 1 ; reset all bounds
	For $i = 1 To $aBound[0]
		$aBound[$i] += 1
	Next
	$aBound[$iDimension] = $iItems
	__ResetBounds($aArray, $aBound) ; remove mismatches

	Return $aArray
EndFunc    ;==>_SearchArray

; #FUNCTION# ===================================================================================================================
; Name...........: _ShuffleArray
; Description ...: Shuffles multidimensional regions within an array, or items within multidimensional regions.
; Syntax.........: _ShuffleArray($aArray [, $iDimension = 1 [, $bFruitMachineStyle = False]])
; Parameters.....; $aArray - The original array.
;                  $iDimension - [Optional] - The dimension used to define the regions to be shuffled. Default = 1
;                  $bFruitMachineStyle - [Optional] Shuffle all items within regions defined by the dimension. Default = False
; Return values .: Returns the modified array ByRef.
;                  Failure sets @error as follows:
;                  |@error = 1 The first parameter is not a valid array.
;                  |@error = 2 The first parameter contains the wrong number of dimensions.
;                  |@error = 3 The second parameter does not relate to any of the dimensions available.
;                  |@error = 4 Arrays must contain at least one element.
; Author.........: czardas
; Comments ......; This function works for arrays of up to 9 dimensions.
;                  Setting $iDimension = 0 overrides the 3rd parameter and shuffles everything - anywhere within the array.
; Example .......; _ShuffleArray($aArray, 2, True) ; ==> This is a fruit machine!
; ==============================================================================================================================
Func _ShuffleArray(ByRef $aArray, $iDimension = 1, $bFruitMachineStyle = False)
	If Not IsArray($aArray) Then Return SetError(1)

	Local $aBound = __GetBounds($aArray) ; get the bounds of each dimension
	If @error Then Return SetError(4) ; $aArray must contain at least one element

	If $aBound[0] > 9 Then Return SetError(2) ; nine dimension limit

	$iDimension = ($iDimension = Default) ? 1 : Int($iDimension)
	If $iDimension > $aBound[0] Or $iDimension < 0 Then Return SetError(3) ; out of bounds dimension

	Local $aTemp = $aBound ; regional bounds
	For $i = 1 To $aBound[0]
		$aBound[$i] -= 1
	Next

	Local $iSubIndex, $sTransfer, $aFloodFill = __FloodFunc()

	If $iDimension > 0 Then ; shuffle regions or elements within regions
		If $aBound[0] > 1 Then
			$aTemp[$iDimension] = 1
			Local $aRegion = ___NewArray($aTemp) ; to store extracted regions
			Local $sIndices = __HiddenIndices($aBound[0], $iDimension)

			$aTemp = $aBound
			$aTemp[$iDimension] = 0 ; set to loop once [one region at a time]

			If $bFruitMachineStyle Then ; contents will be shuffled within each region
				$sTransfer = '$aSource' & $sIndices ; array syntax
				For $iSubIndex = 0 To $aBound[$iDimension] ; loop through all indices within the dimension
					$aFloodFill[$aBound[0]]($aRegion, $aTemp, $iDimension, 0, $iSubIndex, $aArray, $sTransfer) ; extract region
					__ShuffleXD($aRegion, $aTemp) ; shuffle the extracted region
					$aFloodFill[$aBound[0]]($aArray, $aTemp, $iDimension, $iSubIndex, 0, $aRegion, $sTransfer) ; reinsert the shuffled region
				Next
			Else ; regions will be shuffled within the dimension
				Local $iRandom
				$sTransfer = '$aSource' & $sIndices

				For $iSubIndex = 0 To $aBound[$iDimension]
					$aFloodFill[$aBound[0]]($aRegion, $aTemp, $iDimension, 0, $iSubIndex, $aArray, $sTransfer) ; extract each region

					$sTransfer = '$aTarget' & $sIndices
					$iRandom = Random(0, $aBound[$iDimension], 1) ; acquire a random index
					$aFloodFill[$aBound[0]]($aArray, $aTemp, $iDimension, $iSubIndex, $iRandom, $aArray, $sTransfer) ; replace the original region

					$sTransfer = '$aSource' & $sIndices
					$aFloodFill[$aBound[0]]($aArray, $aTemp, $iDimension, $iRandom, 0, $aRegion, $sTransfer) ; replace the extracted region at the acquired index
				Next
			EndIf

		Else ; not a multidimensional array
			__Shuffle1D($aArray) ; shuffle the contents
		EndIf

	Else ; totally random - ignoring dimension bounds
		__ShuffleXD($aArray, $aBound)
	EndIf
EndFunc    ;==>_ShuffleArray

#Region - Miscellaneous

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with numeric sort. Decimal strings should first be formatted with ___FormatNum()
; Author ........: czardas
; ==============================================================================================================================
Func ___AcquireExponent($vNum)
	Local $bString = IsString($vNum)
	If $bString Then $vNum = StringReplace($vNum, '-', '') ; the minus symbol must first be stripped
	Return $bString ? ((StringLeft($vNum, 1) = '.') ? StringLen(StringRegExpReplace($vNum, '\.0*', '')) - StringLen($vNum) : StringInStr($vNum, '.') - 2) : Number(StringRight(StringFormat('%.1e', $vNum / 1), 4))
EndFunc    ;==>___AcquireExponent

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Description ...: Return an array with a range of assigned index values (used to track migration patterns in __QuickSortXD).
; Author ........: czardas
; ===============================================================================================================================
Func __CreateTrac($iBound, $iStart, $iEnd)
	Local $aTracker[$iBound]
	For $i = $iStart To $iEnd
		$aTracker[$i] = $i ; fill the (tracking) range with indices
	Next
	Return $aTracker
EndFunc    ;==>__CreateTrac

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: Extract a vector (list) from any dimension within a multidimensional array.
; ==============================================================================================================================
Func __ExtractVector($aArray, $iDimension, $aIndices)
	$aIndices[$iDimension] = '$a[1]' ; $aIndices[$iDimension] is the remote loop count
	Local $sTransfer = '$aSource' ; the main array is the source
	For $i = 1 To $aIndices[0]
		$sTransfer &= '[' & $aIndices[$i] & ']'
	Next

	Local $iBound = UBound($aArray, $iDimension), $aVector[$iBound], $iSubIndex = 0, $aBound = ['', $iBound - 1]

	___Flood1D($aVector, $aBound, $iDimension, $iSubIndex, '', $aArray, $sTransfer)
	Return $aVector
EndFunc    ;==>__ExtractVector

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with _ArraySearch - non-case-sensitive comparison.
; ==============================================================================================================================
Func __FindExact($aTarget, $a, $aBound, $iFrom, $sSyntax) ; [default algorithm]
	$sSyntax = Execute($sSyntax)
	If $g__ARRWSHOP_RESUME And $aBound[0] = $sSyntax Then $g__ARRWSHOP_RESUME = False
	Return $sSyntax
	#forceref $aTarget, $a, $iFrom
EndFunc    ;==>__FindExact

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with _ArraySearch - case-sensitive comparison.
; ==============================================================================================================================
Func __FindExactCase($aTarget, $a, $aBound, $iFrom, $sSyntax)
	$sSyntax = Execute($sSyntax)
	If $g__ARRWSHOP_RESUME And $aBound[0] == $sSyntax Then $g__ARRWSHOP_RESUME = False
	Return $sSyntax
	#forceref $aTarget, $a, $iFrom
EndFunc    ;==>__FindExactCase

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with _ArraySearch - search within strings - non-case-sensitive comparison.
; ==============================================================================================================================
Func __FindString($aTarget, $a, $aBound, $iFrom, $sSyntax)
	$sSyntax = Execute($sSyntax)
	If $g__ARRWSHOP_RESUME And StringInStr($sSyntax, $aBound[0]) Then $g__ARRWSHOP_RESUME = False
	Return $sSyntax
	#forceref $aTarget, $a, $iFrom
EndFunc    ;==>__FindString

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with _ArraySearch - search within strings - case-sensitive comparison.
; ==============================================================================================================================
Func __FindStringCase($aTarget, $a, $aBound, $iFrom, $sSyntax)
	$sSyntax = Execute($sSyntax)
	If $g__ARRWSHOP_RESUME And StringInStr($sSyntax, $aBound[0], 1) Then $g__ARRWSHOP_RESUME = False
	Return $sSyntax
	#forceref $aTarget, $a, $iFrom
EndFunc    ;==>__FindStringCase

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with _ArraySearch - search between word boundaries - non-case-sensitive comparison.
; ==============================================================================================================================
Func __FindWord($aTarget, $a, $aBound, $iFrom, $sSyntax)
	$sSyntax = Execute($sSyntax)
	If $g__ARRWSHOP_RESUME And StringRegExp(StringReplace($sSyntax, '\E', $g__ARRWSHOP_SUB, 0, 1), '(*UCP)(?i)(\A|[^[:alnum:]])(\Q' & StringReplace($aBound[0], '\E', $g__ARRWSHOP_SUB, 0, 1) & '\E)(\z|[^[:alnum:]])') Then $g__ARRWSHOP_RESUME = False
	Return $sSyntax
	#forceref $aTarget, $a, $iFrom
EndFunc    ;==>__FindWord

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with _ArraySearch - search between word boundaries - case-sensitive comparison.
; ==============================================================================================================================
Func __FindWordCase($aTarget, $a, $aBound, $iFrom, $sSyntax)
	$sSyntax = Execute($sSyntax)
	If $g__ARRWSHOP_RESUME And StringRegExp(StringReplace($sSyntax, '\E', $g__ARRWSHOP_SUB, 0, 1), '(*UCP)(\A|[^[:alnum:]])(\Q' & StringReplace($aBound[0], '\E', $g__ARRWSHOP_SUB, 0, 1) & '\E)(\z|[^[:alnum:]])') Then $g__ARRWSHOP_RESUME = False
	Return $sSyntax
	#forceref $aTarget, $a, $iFrom
EndFunc    ;==>__FindWordCase

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: Return an array of functions used for populating multidimensional array elements.
; ==============================================================================================================================
Func __FloodFunc()
	Local $aFloodFunc = ['', ___Flood1D, ___Flood2D, ___Flood3D, ___Flood4D, ___Flood5D, ___Flood6D, ___Flood7D, ___Flood8D, ___Flood9D]
	Return $aFloodFunc
EndFunc    ;==>__FloodFunc

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with numeric sort. ['\A[\+\-]?(\d*\.?\d+|d+\.)\z' only ==> 1.0 .01 0.]
; Author ........: czardas
; ==============================================================================================================================
Func ___FormatNum($sNum)
	If Not StringRegExp($sNum, '[1-9]') Then Return 0
	$sNum = StringReplace($sNum, '+', '') ; get rid of plus symbol
	$sNum = StringRegExpReplace($sNum, "^-?\K(?=\.)", "0") ; add zeros [courtesy of jguinch]
	$sNum = StringRegExpReplace($sNum, "^-?\K0+(?=[1-9]|0\.?)|\.0*$|\.\d*[1-9]\K0+", "") ; strip zeros [courtesy of jguinch]

	If Execute($sNum) == $sNum Then Return Execute($sNum) ; return a number
	Return StringInStr($sNum, '.') ? StringRegExpReplace($sNum, '(\A\-?)(0)', '\1') : $sNum & '.' ; for fast comparison with floats [^^ StringCompare('1.', 1) > 0]
EndFunc    ;==>___FormatNum

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: Get the bounds of each available dimension in a multidimensional array.
; ==============================================================================================================================
Func __GetBounds($aArray, $iHypothetical = 0)
	Local $iMaxDim = UBound($aArray, 0)
	Local $aBound[($iHypothetical ? $iHypothetical : $iMaxDim) + 1] ; [or ==> Local $aBound[9]]
	$aBound[0] = $iMaxDim
	For $i = 1 To $iMaxDim
		$aBound[$i] = UBound($aArray, $i)
		If $aBound[$i] = 0 Then Return SetError(1)
	Next
	If $iHypothetical Then
		For $i = $iMaxDim + 1 To $iHypothetical
			$aBound[$i] = 1 ; imaginary dimensions
		Next
	EndIf
	Return $aBound
EndFunc    ;==>__GetBounds

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: Return a fragment of code which is the format for the $sTransfer parameter in ___FloodXD.
; ==============================================================================================================================
Func __HiddenIndices($iBound, $iDimension)
	Local $sSyntax = '' ; to access elements at their original indices
	For $i = 1 To $iBound
		If $i <> $iDimension Then
			$sSyntax &= '[$a[' & $i & ']]' ; default ==> '$aSource[$iFrom][$a[2]][$a[3]][$a[4]][$a[5]] etc...'
		Else
			$sSyntax &= '[$iFrom]'
		EndIf
	Next
	Return $sSyntax
EndFunc    ;==>__HiddenIndices

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: Create an array of between one and nine dimensions using predefined bounds.
; ==============================================================================================================================
Func ___NewArray($aBound)
	Switch $aBound[0]
		Case 1
			Local $aArray[$aBound[1]]
		Case 2
			Local $aArray[$aBound[1]][$aBound[2]]
		Case 3
			Local $aArray[$aBound[1]][$aBound[2]][$aBound[3]]
		Case 4
			Local $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]]
		Case 5
			Local $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]][$aBound[5]]
		Case 6
			Local $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]][$aBound[5]][$aBound[6]]
		Case 7
			Local $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]][$aBound[5]][$aBound[6]][$aBound[7]]
		Case 8
			Local $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]][$aBound[5]][$aBound[6]][$aBound[7]][$aBound[8]]
		Case 9
			Local $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]][$aBound[5]][$aBound[6]][$aBound[7]][$aBound[8]][$aBound[9]]
	EndSwitch
	Return $aArray
EndFunc    ;==>___NewArray

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with _SortArray() numeric comparison [str > num(?), num > str(?), str > str(?)]
; Author ........: czardas
; ==============================================================================================================================
Func ___NumCompare($vNum1, $vNum2) ; ($vNum1 > $vNum2)
	If IsNumber($vNum1) And IsNumber($vNum2) Then
		If $vNum1 = $vNum2 Then Return 0
		Return ($vNum1 > $vNum2) ? 1 : -1
	EndIf

	If $vNum1 == '1.#INF' Or $vNum2 == '-1.#INF' Then Return 1 ; these values interfere with the comparison below
	If $vNum1 == '-1.#INF' Or $vNum2 == '1.#INF' Then Return -1 ; ditto

	Local $bNeg1 = (StringLeft($vNum1, 1) = '-')
	If $bNeg1 <> (StringLeft($vNum2, 1) = '-') Then Return $bNeg1 ? -1 : 1

	Local $iExp1 = ___AcquireExponent($vNum1), $iExp2 = ___AcquireExponent($vNum2)
	If $iExp1 <> $iExp2 Then Return (($iExp1 > $iExp2) ? 1 : -1) * ($bNeg1 ? -1 : 1) ; negative magnitude changes the result

	Local $bType1 = (VarGetType($vNum1) = 'Double'), $bType2 = (VarGetType($vNum2) = 'Double')
	If $bType1 Or $bType2 Then ; grab all 17 digits from the double
		$vNum1 = $bType1 ? StringLeft(StringReplace(StringFormat('%.17e', $vNum1), '.', ''), 17) : StringReplace($vNum1, '.', '')
		$vNum2 = $bType2 ? StringLeft(StringReplace(StringFormat('%.17e', $vNum2), '.', ''), 17) : StringReplace($vNum2, '.', '')
	EndIf
	Return StringCompare($vNum1, $vNum2) * ($bNeg1 ? -1 : 1) ; negative magnitude changes the result
EndFunc    ;==>___NumCompare

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __QuickSort1D [adaptation of __ArrayQuickSort1D]
; Description ...: Helper function for sorting 1D arrays
; Author ........: Jos van der Zande, LazyCoder, Tylo, Ultima
; Modified.......: czardas - replaced alphanumeric sort with separate lexical and numeric sorting algorithms.
; ===============================================================================================================================
Func __QuickSort1D(ByRef $aArray, $iStart, $iEnd, $iAlgorithm = 0)
	If $iEnd <= $iStart Then Return

	Local $vTmp
	; InsertionSort (faster for smaller segments)
	If ($iEnd - $iStart) < 15 Then
		Switch $iAlgorithm
			Case 0 ; lexical
				For $i = $iStart + 1 To $iEnd
					$vTmp = $aArray[$i]
					For $j = $i - 1 To $iStart Step -1
						If StringCompare($vTmp, $aArray[$j]) >= 0 Then ExitLoop
						$aArray[$j + 1] = $aArray[$j]
					Next
					$aArray[$j + 1] = $vTmp
				Next
				Return

			Case 2 ; numeric strict
				For $i = $iStart + 1 To $iEnd
					$vTmp = $aArray[$i]
					If IsNumber($vTmp) Then
						For $j = $i - 1 To $iStart Step -1
							If $vTmp >= $aArray[$j] And IsNumber($aArray[$j]) Then ExitLoop
							$aArray[$j + 1] = $aArray[$j]
						Next
						$aArray[$j + 1] = $vTmp
					EndIf
				Next
				Return
		EndSwitch

		Return
	EndIf

	; QuickSort
	Local $L = $iStart, $R = $iEnd, $vPivot = $aArray[Int(($iStart + $iEnd) / 2)]
	Do
		If $iAlgorithm = 0 Then ; lexical
			While StringCompare($aArray[$L], $vPivot) < 0
				$L += 1
			WEnd
			While StringCompare($aArray[$R], $vPivot) > 0
				$R -= 1
			WEnd

		ElseIf $iAlgorithm = 2 Then ; numeric strict
			While $aArray[$L] < $vPivot
				$L += 1
			WEnd
			While $aArray[$R] > $vPivot
				$R -= 1
			WEnd
		EndIf

		If $L <= $R Then ; Swap
			$vTmp = $aArray[$L]
			$aArray[$L] = $aArray[$R]
			$aArray[$R] = $vTmp
			$L += 1
			$R -= 1
		EndIf
	Until $L > $R

	__QuickSort1D($aArray, $iStart, $R, $iAlgorithm)
	__QuickSort1D($aArray, $L, $iEnd, $iAlgorithm)
EndFunc    ;==>__QuickSort1D

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name...........: __QuickSortXD [adaptation of __ArrayQuickSort1D]
; Description ...: Helper function for sorting multidimensional arrays
; Author ........: Jos van der Zande, LazyCoder, Tylo, Ultima
; Modified.......: czardas  - to sort indices of an X-dimensional array vector, instead of overwriting complete regions or rows.
; ===============================================================================================================================
Func __QuickSortXD($aArray, ByRef $aTrac, $iStart, $iEnd, $iAlgorithm = 0)
	If $iEnd <= $iStart Then Return

	Local $iTmp
	; InsertionSort (faster for smaller segments)
	If ($iEnd - $iStart) < 15 Then
		Switch $iAlgorithm
			Case 0 ; lexical
				For $i = $iStart + 1 To $iEnd
					$iTmp = $aTrac[$i]
					For $j = $i - 1 To $iStart Step -1
						If (StringCompare($aArray[$iTmp], $aArray[$aTrac[$j]]) >= 0) Then ExitLoop
						$aTrac[$j + 1] = $aTrac[$j]
					Next
					$aTrac[$j + 1] = $iTmp
				Next

			Case 2 ; (or 4) numeric strict [also applies to algorithm 4]
				For $i = $iStart + 1 To $iEnd
					$iTmp = $aTrac[$i]
					For $j = $i - 1 To $iStart Step -1
						If $aArray[$iTmp] >= $aArray[$aTrac[$j]] Then ExitLoop
						$aTrac[$j + 1] = $aTrac[$j]
					Next
					$aTrac[$j + 1] = $iTmp
				Next

			Case 256 ; numeric [preprocessed; decimal string formatting required, see ___FormatNum]
				For $i = $iStart + 1 To $iEnd
					$iTmp = $aTrac[$i]
					For $j = $i - 1 To $iStart Step -1
						If ___NumCompare($aArray[$iTmp], $aArray[$aTrac[$j]]) >= 0 Then ExitLoop
						$aTrac[$j + 1] = $aTrac[$j]
					Next

					$aTrac[$j + 1] = $iTmp
				Next
		EndSwitch

		Return
	EndIf

	; QuickSort
	Local $L = $iStart, $R = $iEnd, $vPivot = $aArray[$aTrac[Int(($iStart + $iEnd) / 2)]]
	Do
		If $iAlgorithm = 0 Then ; lexical
			While StringCompare($aArray[$aTrac[$L]], $vPivot) < 0
				$L += 1
			WEnd
			While StringCompare($aArray[$aTrac[$R]], $vPivot) > 0
				$R -= 1
			WEnd

		ElseIf $iAlgorithm = 2 Then ; numeric strict [strings not allowed]
			While $aArray[$aTrac[$L]] < $vPivot
				$L += 1
			WEnd
			While $aArray[$aTrac[$R]] > $vPivot
				$R -= 1
			WEnd

		ElseIf $iAlgorithm = 256 Then ; numeric greedy [includes decimal strings]
			While ___NumCompare($aArray[$aTrac[$L]], $vPivot) < 0
				$L += 1
			WEnd
			While ___NumCompare($aArray[$aTrac[$R]], $vPivot) > 0
				$R -= 1
			WEnd
		EndIf

		If $L <= $R Then ; Swap
			$iTmp = $aTrac[$L]
			$aTrac[$L] = $aTrac[$R]
			$aTrac[$R] = $iTmp
			$L += 1
			$R -= 1
		EndIf
	Until $L > $R

	__QuickSortXD($aArray, $aTrac, $iStart, $R, $iAlgorithm)
	__QuickSortXD($aArray, $aTrac, $L, $iEnd, $iAlgorithm)
EndFunc    ;==>__QuickSortXD

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: ReDim arrays of different dimensions.
; ==============================================================================================================================
Func __ResetBounds(ByRef $aArray, $aBound)
	Switch $aBound[0]
		Case 1
			ReDim $aArray[$aBound[1]]
		Case 2
			ReDim $aArray[$aBound[1]][$aBound[2]]
		Case 3
			ReDim $aArray[$aBound[1]][$aBound[2]][$aBound[3]]
		Case 4
			ReDim $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]]
		Case 5
			ReDim $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]][$aBound[5]]
		Case 6
			ReDim $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]][$aBound[5]][$aBound[6]]
		Case 7
			ReDim $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]][$aBound[5]][$aBound[6]][$aBound[7]]
		Case 8
			ReDim $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]][$aBound[5]][$aBound[6]][$aBound[7]][$aBound[8]]
		Case 9
			ReDim $aArray[$aBound[1]][$aBound[2]][$aBound[3]][$aBound[4]][$aBound[5]][$aBound[6]][$aBound[7]][$aBound[8]][$aBound[9]]
	EndSwitch
EndFunc    ;==>__ResetBounds

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Description ...: Helper function: reverses a 1D array.
; Author ........: czardas
; ===============================================================================================================================
Func ___Reverse1D(ByRef $aArray, $iStart, $iStop)
	Local $vTemp
	While $iStop > $iStart
		$vTemp = $aArray[$iStart]
		$aArray[$iStart] = $aArray[$iStop]
		$aArray[$iStop] = $vTemp
		$iStart += 1
		$iStop -= 1
	WEnd
EndFunc    ;==>___Reverse1D

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with _ArraySearch - searches through a 1D array.
; ==============================================================================================================================
Func ___Search1D($aArray, $vSearchTerm, $bCaseSense, $iAlgo)
	Local $iItems = 0
	Switch $iAlgo
		Case 1 ; find exact match
			If $bCaseSense Then ; case-sensitive
				For $i = 0 To UBound($aArray) - 1
					If $aArray[$i] == $vSearchTerm Then
						$aArray[$iItems] = $aArray[$i]
						$iItems += 1
					EndIf
				Next
			Else ; optimal [using a second loop avoids using a conditional within the loop]
				For $i = 0 To UBound($aArray) - 1
					If $aArray[$i] = $vSearchTerm Then
						$aArray[$iItems] = $aArray[$i]
						$iItems += 1
					EndIf
				Next
			EndIf

		Case 2 ; find a string within a string
			For $i = 0 To UBound($aArray) - 1
				If StringInStr($aArray[$i], $vSearchTerm, $bCaseSense) Then
					$aArray[$iItems] = $aArray[$i]
					$iItems += 1
				EndIf
			Next

		Case 3 ; find a word within text
			Local $sPattern = $bCaseSense ? '(*UCP)(\A|[^[:alnum:]])(\Q' : '(*UCP)(?i)(\A|[^[:alnum:]])(\Q'
			For $i = 0 To UBound($aArray) - 1
				If StringRegExp(StringReplace($aArray[$i], '\E', $g__ARRWSHOP_SUB, 0, 1), $sPattern & StringReplace($vSearchTerm, '\E', $g__ARRWSHOP_SUB, 0, 1) & '\E)(\z|[^[:alnum:]])') Then
					$aArray[$iItems] = $aArray[$i]
					$iItems += 1
				EndIf
			Next
	EndSwitch

	If Not $iItems Then Return SetError(1)
	ReDim $aArray[$iItems]

	Return $aArray
EndFunc    ;==>___Search1D

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with numeric sort. [numbers other than -1.#IND = OK]
; ==============================================================================================================================
Func __Separate1D(ByRef $aArray, $iStart, $iEnd)
	Local $vTemp, $iItems = 0
	For $i = $iStart To $iEnd
		If IsNumber($aArray[$i]) And Not ($aArray[$i] == '-1.#IND') Then
			$vTemp = $aArray[$iStart + $iItems]
			$aArray[$iStart + $iItems] = $aArray[$i]
			$aArray[$i] = $vTemp
			$iItems += 1
		EndIf
	Next
	Return $iItems ; the number of numeric items
EndFunc    ;==>__Separate1D

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with numeric sort - separates numbers from strings. [numbers (!-1.#IND) = OK, decimal strings = OK]
; Author ........: czardas
; ==============================================================================================================================
Func __Separate256(ByRef $aArray, ByRef $aTrac, $iStart, $iEnd)
	Local $vTemp, $iItems = 0
	For $i = $iStart To $iEnd
		If (IsNumber($aArray[$aTrac[$i]]) And Not ($aArray[$aTrac[$i]] == '-1.#IND')) Or IsString($aArray[$aTrac[$i]]) * StringRegExp($aArray[$aTrac[$i]], '\A\h*[\+\-]?\h*(\d*\.?\d+|\d+\.)\h*\z') Then
			$vTemp = $aTrac[$iStart + $iItems]
			$aTrac[$iStart + $iItems] = $aTrac[$i]
			$aTrac[$i] = $vTemp

			If IsString($aArray[$aTrac[$iStart + $iItems]]) Then $aArray[$aTrac[$iStart + $iItems]] = ___FormatNum(StringStripWS($aArray[$aTrac[$iStart + $iItems]], 8)) ; format numeric strings ready for comparison
			$iItems += 1
		EndIf
	Next
	Return $iItems ; the number of numeric items
EndFunc    ;==>__Separate256

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: For use with numeric sort - separates numbers from strings. [numbers (! -1.#IND) = OK]
; Author ........: czardas
; ==============================================================================================================================
Func __SeparateXD(ByRef $aArray, ByRef $aTrac, $iStart, $iEnd)
	Local $vTemp, $iItems = 0
	For $i = $iStart To $iEnd
		If IsNumber($aArray[$aTrac[$i]]) And Not ($aArray[$aTrac[$i]] == '-1.#IND') Then
			$vTemp = $aTrac[$iStart + $iItems]
			$aTrac[$iStart + $iItems] = $aTrac[$i]
			$aTrac[$i] = $vTemp
			$iItems += 1
		EndIf
	Next
	Return $iItems ; the number of numeric items
EndFunc    ;==>__SeparateXD

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: Shuffle a one dimensional array.
; ==============================================================================================================================
Func __Shuffle1D(ByRef $aArray)
	Local $vTemp, $iRandom, $iBound = UBound($aArray) - 1
	For $i = 0 To $iBound
		$iRandom = Random(0, $iBound, 1)
		$vTemp = $aArray[$i]
		$aArray[$i] = $aArray[$iRandom]
		$aArray[$iRandom] = $vTemp
	Next
EndFunc    ;==>__Shuffle1D

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Description ...: Shuffle a multidimensional array.
; ==============================================================================================================================
Func __ShuffleXD(ByRef $aArray, $aBound)
	ReDim $aBound[10] ; [could possibly be dealt with earlier by the call to _GetBounds]
	Local $vTemp, $R[10] ; [random indices]
	For $9 = 0 To $aBound[9]
		For $8 = 0 To $aBound[8]
			For $7 = 0 To $aBound[7]
				For $6 = 0 To $aBound[6]
					For $5 = 0 To $aBound[5]
						For $4 = 0 To $aBound[4]
							For $3 = 0 To $aBound[3]
								For $2 = 0 To $aBound[2]
									For $1 = 0 To $aBound[1]
										For $i = 1 To $aBound[0]
											$R[$i] = Random(0, $aBound[$i], 1)
										Next
										Switch $aBound[0]
											Case 1
												$vTemp = $aArray[$1]
												$aArray[$1] = $aArray[$R[1]]
												$aArray[$R[1]] = $vTemp
											Case 2
												$vTemp = $aArray[$1][$2]
												$aArray[$1][$2] = $aArray[$R[1]][$R[2]]
												$aArray[$R[1]][$R[2]] = $vTemp
											Case 3
												$vTemp = $aArray[$1][$2][$3]
												$aArray[$1][$2][$3] = $aArray[$R[1]][$R[2]][$R[3]]
												$aArray[$R[1]][$R[2]][$R[3]] = $vTemp
											Case 4
												$vTemp = $aArray[$1][$2][$3][$4]
												$aArray[$1][$2][$3][$4] = $aArray[$R[1]][$R[2]][$R[3]][$R[4]]
												$aArray[$R[1]][$R[2]][$R[3]][$R[4]] = $vTemp
											Case 5
												$vTemp = $aArray[$1][$2][$3][$4][$5]
												$aArray[$1][$2][$3][$4][$5] = $aArray[$R[1]][$R[2]][$R[3]][$R[4]][$R[5]]
												$aArray[$R[1]][$R[2]][$R[3]][$R[4]][$R[5]] = $vTemp
											Case 6
												$vTemp = $aArray[$1][$2][$3][$4][$5][$6]
												$aArray[$1][$2][$3][$4][$5][$6] = $aArray[$R[1]][$R[2]][$R[3]][$R[4]][$R[5]][$R[6]]
												$aArray[$R[1]][$R[2]][$R[3]][$R[4]][$R[5]][$R[6]] = $vTemp
											Case 7
												$vTemp = $aArray[$1][$2][$3][$4][$5][$6][$7]
												$aArray[$1][$2][$3][$4][$5][$6][$7] = $aArray[$R[1]][$R[2]][$R[3]][$R[4]][$R[5]][$R[6]][$R[7]]
												$aArray[$R[1]][$R[2]][$R[3]][$R[4]][$R[5]][$R[6]][$R[7]] = $vTemp
											Case 8
												$vTemp = $aArray[$1][$2][$3][$4][$5][$6][$7][$8]
												$aArray[$1][$2][$3][$4][$5][$6][$7][$8] = $aArray[$R[1]][$R[2]][$R[3]][$R[4]][$R[5]][$R[6]][$R[7]][$R[8]]
												$aArray[$R[1]][$R[2]][$R[3]][$R[4]][$R[5]][$R[6]][$R[7]][$R[8]] = $vTemp
											Case 9
												$vTemp = $aArray[$1][$2][$3][$4][$5][$6][$7][$8][$9]
												$aArray[$1][$2][$3][$4][$5][$6][$7][$8][$9] = $aArray[$R[1]][$R[2]][$R[3]][$R[4]][$R[5]][$R[6]][$R[7]][$R[8]][$R[9]]
												$aArray[$R[1]][$R[2]][$R[3]][$R[4]][$R[5]][$R[6]][$R[7]][$R[8]][$R[9]] = $vTemp
										EndSwitch
									Next
								Next
							Next
						Next
					Next
				Next
			Next
		Next
	Next
EndFunc    ;==>__ShuffleXD

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Description ...: Helper function for populating 1D arrays. [knight's tour type algorithm]
; Author ........: czardas
; ===============================================================================================================================
Func __TagSortSwap(ByRef $aArray, ByRef $aTrac, $iStart, $iEnd)
	Local $vFirst, $i, $iNext

	For $iInit = $iStart To $iEnd ; initialize each swap sequence
		If $aTrac[$iInit] <> $iInit Then ; elements will now be swapped in a sequence
			$i = $iInit ; set the current index to the start of the sequence
			$vFirst = $aArray[$i] ; copy data [although we don't know where to put it yet]

			Do
				$aArray[$i] = $aArray[$aTrac[$i]] ; overwrite each element in the sequence
				$iNext = $aTrac[$i] ; get the next index in the sequence
				$aTrac[$i] = $i ; set to ignore overwritten elements on subsequent encounters
				$i = $iNext ; follow the trail as far as it goes [index could be higher or lower]
			Until $aTrac[$i] = $iInit ; all sequences end at this juncture

			$aArray[$i] = $vFirst ; now we know where to put the initial element we copied earlier
			$aTrac[$i] = $i ; set to ignore on subsequent encounters [as above]
		EndIf
	Next
EndFunc    ;==>__TagSortSwap

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Description ...: Helper function for populating 2D arrays. [knight's tour type algorithm]
; Author ........: czardas
; ===============================================================================================================================
Func __TagSortSwapXD(ByRef $aArray, ByRef $aTrac, $iStart, $iEnd)
	Local $iCols = UBound($aArray, 2), $aFirst[$iCols], $i, $iNext

	For $iInit = $iStart To $iEnd ; initialize each potential overwrite sequence [separate closed system]
		If $aTrac[$iInit] <> $iInit Then ; rows will now be overwritten in accordance with tracking information
			$i = $iInit ; set the current row as the start of the sequence

			For $j = 0 To $iCols - 1
				$aFirst[$j] = $aArray[$i][$j] ; copy the first row [although we don't know where to put it yet]
			Next

			Do
				For $j = 0 To $iCols - 1
					$aArray[$i][$j] = $aArray[$aTrac[$i]][$j] ; overwrite each row [following the trail]
				Next
				$iNext = $aTrac[$i] ; get the index of the next row in the sequence
				$aTrac[$i] = $i ; set to ignore rows already processed [may be needed once, or not at all]
				$i = $iNext ; follow the trail as far as it goes [indices could be higher or lower]
			Until $aTrac[$i] = $iInit ; all tracking sequences end at this juncture

			For $j = 0 To $iCols - 1
				$aArray[$i][$j] = $aFirst[$j] ; now we know where to put the initial row we copied earlier
			Next
			$aTrac[$i] = $i ; set to ignore rows already processed [as above]
		EndIf
	Next
EndFunc    ;==>__TagSortSwapXD

#EndRegion  - Miscellaneous

#Region - Remote Loops

; #INTERNAL_USE_ONLY# ==========================================================================================================
; Name...........: ___Flood1D, ___Flood2D, ___Flood3D, ___Flood4D, ___Flood5D, ___Flood6D, ___Flood7D, ___Flood8D, ___Flood9D
; Description ...: Flood the region of a multidimensional array defined by the sub-index within the specified dimension.
; Syntax.........: ___FloodXD($aTarget, $aBound, $iDimension, $iSubIndex, $iFrom, $aSource, $sTransfer)
; Parameters.....; $aTarget - Array to populate.
;                  $aBound - Array containing the bounds of each dimension.
;                  $iDimension - Integer value defining the dimension.
;                  $iSubIndex - Integer value of the sub-index within the dimension.
;                  $iFrom - [Hidden] Integer value defining a sub-index within $aSource.
;                  $aSource - [Hidden] Array containing data which may be used to populate the target array.
;                  $sTransfer - String of instructions used to acquire data.
; Return values .: [ByRef] The target array after the region has been flooded.
; Author ........: czardas
; Comments ......; Using remote loops cuts out several hundred lines of duplicated code.
;                  Recursively targeting a custom function, whichever dimension, is straight forward and reasonably optimal.
;                  The approach may introduce a small circumstantial speed deficit, which seems a fair trade-off.
;                  The sequence of loops runs backwards: optimized for higher dimensions with less bounds.
;                  Only the elements associated with the specified sub-index within the defined dimension are overwritten.
;                  Setting $iDimension to 0 causes the functions to overwrite all the elements within the target array.
;                  The $sTransfer parameter must be runnable code.
;                  Unused hidden parameters should be passed as empty strings.
;                  $aBound[0] can also be used as a wild card.
; ==============================================================================================================================
Func ___Flood1D(ByRef $aTarget, $aBound, $iDimension, $iSubIndex, $iFrom, $aSource, $sTransfer) ; [still experimental]
	#forceref $iDimension, $iFrom, $aSource ; $iDimension would normally not apply here (special case)
	Local $a[10] = ['', 0, 0, 0, 0, 0, 0, 0, 0, 0] ; loop iteration count [or indices of higher dimensions within the source array]
	For $a[1] = $iSubIndex To $aBound[1] ; from the start to the bounds of the 1st dimension (special case)
		; only one operation is needed in this special case
		$aTarget[$a[1]] = Execute($sTransfer) ; hidden parameters may appear in the code being executed
	Next
EndFunc    ;==>___Flood1D

; ==============================================================================================================================
; the following functions are slightly different
; ==============================================================================================================================
Func ___Flood2D(ByRef $aTarget, $aBound, $iDimension, $iSubIndex, $iFrom, $aSource, $sTransfer)
	#forceref $iFrom, $aSource ; hidden parameters
	Local $a[10] = ['', 0, 0, 0, 0, 0, 0, 0, 0, 0] ; loop iteration count [or indices of higher dimensions within the source array]
	For $a[2] = 0 To $aBound[2]
		For $a[1] = 0 To $aBound[1]
			$a[$iDimension] = $iSubIndex ; override the iteration count (fast method) - $a[0] has no influence
			$aTarget[$a[1]][$a[2]] = Execute($sTransfer) ; hidden parameters may appear in the code being executed
		Next
	Next
EndFunc    ;==>___Flood2D

; ==============================================================================================================================
; see previous description and comments
; ==============================================================================================================================
Func ___Flood3D(ByRef $aTarget, $aBound, $iDimension, $iSubIndex, $iFrom, $aSource, $sTransfer)
	#forceref $iFrom, $aSource ; as above
	Local $a[10] = ['', 0, 0, 0, 0, 0, 0, 0, 0, 0] ; as above
	For $a[3] = 0 To $aBound[3]
		For $a[2] = 0 To $aBound[2]
			For $a[1] = 0 To $aBound[1]
				$a[$iDimension] = $iSubIndex ; as above
				$aTarget[$a[1]][$a[2]][$a[3]] = Execute($sTransfer) ; as above
			Next
		Next
	Next
EndFunc    ;==>___Flood3D

; ==============================================================================================================================
; see previous description and comments
; ==============================================================================================================================
Func ___Flood4D(ByRef $aTarget, $aBound, $iDimension, $iSubIndex, $iFrom, $aSource, $sTransfer)
	#forceref $iFrom, $aSource
	Local $a[10] = ['', 0, 0, 0, 0, 0, 0, 0, 0, 0]
	For $a[4] = 0 To $aBound[4]
		For $a[3] = 0 To $aBound[3]
			For $a[2] = 0 To $aBound[2]
				For $a[1] = 0 To $aBound[1]
					$a[$iDimension] = $iSubIndex
					$aTarget[$a[1]][$a[2]][$a[3]][$a[4]] = Execute($sTransfer)
				Next
			Next
		Next
	Next
EndFunc    ;==>___Flood4D

; ==============================================================================================================================
; see previous description and comments
; ==============================================================================================================================
Func ___Flood5D(ByRef $aTarget, $aBound, $iDimension, $iSubIndex, $iFrom, $aSource, $sTransfer)
	#forceref $iFrom, $aSource
	Local $a[10] = ['', 0, 0, 0, 0, 0, 0, 0, 0, 0]
	For $a[5] = 0 To $aBound[5]
		For $a[4] = 0 To $aBound[4]
			For $a[3] = 0 To $aBound[3]
				For $a[2] = 0 To $aBound[2]
					For $a[1] = 0 To $aBound[1]
						$a[$iDimension] = $iSubIndex
						$aTarget[$a[1]][$a[2]][$a[3]][$a[4]][$a[5]] = Execute($sTransfer)
					Next
				Next
			Next
		Next
	Next
EndFunc    ;==>___Flood5D

; ==============================================================================================================================
; see previous description and comments
; ==============================================================================================================================
Func ___Flood6D(ByRef $aTarget, $aBound, $iDimension, $iSubIndex, $iFrom, $aSource, $sTransfer)
	#forceref $iFrom, $aSource
	Local $a[10] = ['', 0, 0, 0, 0, 0, 0, 0, 0, 0]
	For $a[6] = 0 To $aBound[6]
		For $a[5] = 0 To $aBound[5]
			For $a[4] = 0 To $aBound[4]
				For $a[3] = 0 To $aBound[3]
					For $a[2] = 0 To $aBound[2]
						For $a[1] = 0 To $aBound[1]
							$a[$iDimension] = $iSubIndex
							$aTarget[$a[1]][$a[2]][$a[3]][$a[4]][$a[5]][$a[6]] = Execute($sTransfer)
						Next
					Next
				Next
			Next
		Next
	Next
EndFunc    ;==>___Flood6D

; ==============================================================================================================================
; see previous description and comments
; ==============================================================================================================================
Func ___Flood7D(ByRef $aTarget, $aBound, $iDimension, $iSubIndex, $iFrom, $aSource, $sTransfer)
	#forceref $iFrom, $aSource
	Local $a[10] = ['', 0, 0, 0, 0, 0, 0, 0, 0, 0]
	For $a[7] = 0 To $aBound[7]
		For $a[6] = 0 To $aBound[6]
			For $a[5] = 0 To $aBound[5]
				For $a[4] = 0 To $aBound[4]
					For $a[3] = 0 To $aBound[3]
						For $a[2] = 0 To $aBound[2]
							For $a[1] = 0 To $aBound[1]
								$a[$iDimension] = $iSubIndex
								$aTarget[$a[1]][$a[2]][$a[3]][$a[4]][$a[5]][$a[6]][$a[7]] = Execute($sTransfer)
							Next
						Next
					Next
				Next
			Next
		Next
	Next
EndFunc    ;==>___Flood7D

; ==============================================================================================================================
; see previous description and comments
; ==============================================================================================================================
Func ___Flood8D(ByRef $aTarget, $aBound, $iDimension, $iSubIndex, $iFrom, $aSource, $sTransfer)
	#forceref $iFrom, $aSource
	Local $a[10] = ['', 0, 0, 0, 0, 0, 0, 0, 0, 0]
	For $a[8] = 0 To $aBound[8]
		For $a[7] = 0 To $aBound[7]
			For $a[6] = 0 To $aBound[6]
				For $a[5] = 0 To $aBound[5]
					For $a[4] = 0 To $aBound[4]
						For $a[3] = 0 To $aBound[3]
							For $a[2] = 0 To $aBound[2]
								For $a[1] = 0 To $aBound[1]
									$a[$iDimension] = $iSubIndex
									$aTarget[$a[1]][$a[2]][$a[3]][$a[4]][$a[5]][$a[6]][$a[7]][$a[8]] = Execute($sTransfer)
								Next
							Next
						Next
					Next
				Next
			Next
		Next
	Next
EndFunc    ;==>___Flood8D

; ==============================================================================================================================
; see previous description and comments
; ==============================================================================================================================
Func ___Flood9D(ByRef $aTarget, $aBound, $iDimension, $iSubIndex, $iFrom, $aSource, $sTransfer)
	#forceref $iFrom, $aSource
	Local $a[10] = ['', 0, 0, 0, 0, 0, 0, 0, 0, 0]
	For $a[9] = 0 To $aBound[9]
		For $a[8] = 0 To $aBound[8]
			For $a[7] = 0 To $aBound[7]
				For $a[6] = 0 To $aBound[6]
					For $a[5] = 0 To $aBound[5]
						For $a[4] = 0 To $aBound[4]
							For $a[3] = 0 To $aBound[3]
								For $a[2] = 0 To $aBound[2]
									For $a[1] = 0 To $aBound[1]
										$a[$iDimension] = $iSubIndex
										$aTarget[$a[1]][$a[2]][$a[3]][$a[4]][$a[5]][$a[6]][$a[7]][$a[8]][$a[9]] = Execute($sTransfer)
									Next
								Next
							Next
						Next
					Next
				Next
			Next
		Next
	Next
EndFunc    ;==>___Flood9D

#EndRegion  - Remote Loops
#Au3Stripper_On

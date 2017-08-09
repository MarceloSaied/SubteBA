		Func _Hashing1($Password,$Hashflag=0)
			ConsoleWrite('++_Hashing() = '& @crlf )
			for $i=0 to 10
	;~ 			_Crypt_Startup()
	;~ 			$bAlgorithm = $CALG_AES_128
	;~ 			$bAlgorithm = $CALG_3DES
	;~ 			$hKey = _Crypt_DeriveKey($HashingPassword, $bAlgorithm) ; Declare a password string and algorithm to create a cryptographic key.
				if $Hashflag=0 then
					; Encrypt the text with the new cryptographic key.
					Local $bEncrypted = _Crypt_EncryptData($Password, $hKey, $bAlgorithm)
				Else
					;~ _Crypt_DecryptData($vData, $vCryptKey, $iALG_ID [, $fFinal = True])
					; Encrypt the data using the generic password string.
					Local $bEncrypted = BinaryToString(_Crypt_DecryptData($Password, $hKey, $bAlgorithm))
					ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $Password = ' & _Crypt_DecryptData($Password, $hKey, $bAlgorithm) & @crlf )
				EndIf

	;~ 			_Crypt_DestroyKey($hKey) ; Destroy the cryptographic key.
	;~ 			_Crypt_Shutdown() ; Shutdown the crypt library.
				if $bEncrypted<>"ÿÿÿÿ" then ExitLoop
				ConsoleWrite('-->$bEncrypted = ' & $bEncrypted & @crlf )
			Next
			ConsoleWrite('-->$bEncrypted = ' & $bEncrypted & @crlf )
			return $bEncrypted
		EndFunc

;~ 		$fraseIN1="vivaboca1"
;~ 		$resultado=_Hashing($fraseIN1)
;~ 		$resultado=_Hashing($resultado,1)
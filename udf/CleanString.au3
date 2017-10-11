func clearstring($mensage)
;~    $mensage = StringReplace($mensage,"(","")
;~    $mensage = StringReplace($mensage,")","")
   $mensage = StringReplace($mensage,","," ")
   $mensage = StringReplace($mensage,"'","")
   $mensage = StringReplace($mensage,"¨","")
   $mensage = StringReplace($mensage,"|","")
   $mensage = StringReplace($mensage,"`","")
   $mensage = StringReplace($mensage,"´","")
   $mensage = _Latin_char_Remover($mensage)
;~ 	ConsoleWrite('+(' & @ScriptName & '-' & @ScriptLineNumber & ') : $mensage = ' & $mensage & @crlf )
   return $mensage
EndFunc

Func _Latin_char_Remover($string_to_change)

	 $string_to_change = StringReplace($string_to_change, 'Ã-', 'i')
	 $string_to_change = StringReplace($string_to_change, 'Ã­', 'i')
	 $string_to_change = StringReplace($string_to_change, 'Ãº', 'u')
	 $string_to_change = StringReplace($string_to_change, 'iº', 'u')
	 $string_to_change = StringReplace($string_to_change, 'Ã©', 'e')
	 $string_to_change = StringReplace($string_to_change, 'Ã³', 'o')
	 $string_to_change = StringReplace($string_to_change, 'Ã¡', 'a')
;~ 	 $string_to_change = StringReplace($string_to_change, 'Ã', 'i')

	 $string_to_change = StringReplace($string_to_change, 'á', 'a')
	 $string_to_change = StringReplace($string_to_change, 'Á', 'A')
	 $string_to_change = StringReplace($string_to_change, 'Â', 'A')
	 $string_to_change = StringReplace($string_to_change, 'Ä', 'A')

	 $string_to_change = StringReplace($string_to_change, 'Ç', 'C')

	 $string_to_change = StringReplace($string_to_change, 'é', 'e')
	 $string_to_change = StringReplace($string_to_change, 'É', 'E')
	 $string_to_change = StringReplace($string_to_change, 'Ë', 'E')

	 $string_to_change = StringReplace($string_to_change, 'í', 'i')
	 $string_to_change = StringReplace($string_to_change, 'Í', 'I')
	 $string_to_change = StringReplace($string_to_change, 'Î', 'I')

	 $string_to_change = StringReplace($string_to_change, 'ó', 'o')
	 $string_to_change = StringReplace($string_to_change, 'Ó', 'O')
	 $string_to_change = StringReplace($string_to_change, 'Ô', 'O')
	 $string_to_change = StringReplace($string_to_change, 'Ö', 'O')

	 $string_to_change = StringReplace($string_to_change, 'ú', 'u')
	 $string_to_change = StringReplace($string_to_change, 'Ú', 'U')
	 $string_to_change = StringReplace($string_to_change, 'Ü', 'U')

	 $string_to_change = StringReplace($string_to_change, 'Ý', 'Y')

	 $string_to_change = StringReplace($string_to_change, 'ñ', 'n')
	 $string_to_change = StringReplace($string_to_change, 'Ñ', 'N')
    Return $string_to_change
EndFunc   ;==>_Latin_char_Remover
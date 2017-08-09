func clearstring($mensage)
   $mensage = StringReplace($mensage,"(","")
   $mensage = StringReplace($mensage,")","")
   $mensage = StringReplace($mensage,"'","")
   $mensage = StringReplace($mensage,"�","")
   $mensage = StringReplace($mensage,"|","")
   $mensage = StringReplace($mensage,"`","")
   $mensage = StringReplace($mensage,"�","")
   $mensage = StringReplace($mensage,",","")
   $mensage = StringReplace($mensage,";","")
   $mensage = StringReplace($mensage,'"',"")
   $mensage = StringReplace($mensage,'[',"")
   $mensage = StringReplace($mensage,']',"")
   $mensage = StringReplace($mensage,'{',"")
   $mensage = StringReplace($mensage,'}',"")
   $mensage = StringReplace($mensage,'%',"")
   $mensage = _Latin_char_Remover($mensage)
   return $mensage
EndFunc

Func _Latin_char_Remover($string_to_change)

	$string_to_change = StringReplace($string_to_change, '�', 'a')
	$string_to_change = StringReplace($string_to_change, '�', 'A')
    $string_to_change = StringReplace($string_to_change, '�', 'A')
    $string_to_change = StringReplace($string_to_change, '�', 'A')

    $string_to_change = StringReplace($string_to_change, '�', 'C')

	$string_to_change = StringReplace($string_to_change, '�', 'e')
    $string_to_change = StringReplace($string_to_change, '�', 'E')
    $string_to_change = StringReplace($string_to_change, '�', 'E')

	$string_to_change = StringReplace($string_to_change, '�', 'i')
    $string_to_change = StringReplace($string_to_change, '�', 'I')
    $string_to_change = StringReplace($string_to_change, '�', 'I')

	$string_to_change = StringReplace($string_to_change, '�', 'o')
    $string_to_change = StringReplace($string_to_change, '�', 'O')
    $string_to_change = StringReplace($string_to_change, '�', 'O')
    $string_to_change = StringReplace($string_to_change, '�', 'O')

	$string_to_change = StringReplace($string_to_change, '�', 'u')
    $string_to_change = StringReplace($string_to_change, '�', 'U')
    $string_to_change = StringReplace($string_to_change, '�', 'U')

    $string_to_change = StringReplace($string_to_change, '�', 'Y')

		$string_to_change = StringReplace($string_to_change, '�', 'n')
	$string_to_change = StringReplace($string_to_change, '�', 'N')
    Return $string_to_change
EndFunc   ;==>_Latin_char_Remover
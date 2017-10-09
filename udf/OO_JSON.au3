
; This JSON/JSONPath UDF Uses the windows scripting object (instead of IE's JSON object as previously.)
; IE free version - as the IE version broke with IE11 update last 2014.
;  Added to scripting object ('polyfilled'  )
; 	-  JSON.stringify  or JSON.parse
;   -  JSONPath
;   -  Array and Object function needed for autoit to access Javascript/JSON Objects
;
; This UDF JSON.Parse - Does not use Eval to evaluate JSON.
; implementes JSON2, jsonpath-0.8.0
; You can easily change the JSON or JSONpath implementations by changing the javascript import file .

; This framework is to add OO and JSON to AutoIT
; 		- build any JSON structure using IE JSON all accessable through OO Dot syntax..
; see exmample file
;  		- use JSON strings to build objects
;		- use OO dot sysntax
;    	- add properties, methods to objects (OO)
;    	- have object arrays eg. $jsObj.array.length no more $obj[0]
;		- key values objects
; 		- access javascript objects and methods
; 		- call javascript functions from autoit
; 		- AutoIt Native JSON (no need for a JSON.UDF parser)
;		- Use javascript knowledge in AutoIt
;
;
; 	- Performance may be an issue (as its in javascript)
;   - ALL methods CASE SENSITIVE!
;



; Add methods 'item' to access array items via dot syntax.
; eg. you can't go $jsObj.array[0] in AutoIt, this frameworks lets you go $jsObj.array.item(0)
; - see example file
;

$json_text = _OO_JSON_Read_File("resources/json2.txt")

$jsonPath_text = _OO_JSON_Read_File("resources/jsonpath-0.8.0.js")

$Objectkeys_polyfill_text = _OO_JSON_Read_File("resources/Keys_polyfill.txt") ; scripting object dosen't have a keys function.

func _OO_JSON_Read_File($filename = "jsonpath-0.8.0.js")
   ;
   ; retruns a files text - you could  use it to read a JSON file into a variable.
   ; eg.
   ; $oJSON = _OO_JSON_Init()
   ; $var = _OO_JSON_Read_File("jsondata.txt")
   ; $obj = $oJSON.parse($var)

   Local $file = FileOpen($filename, 0)
   ;Local $file = FileOpen("mytest.js", 0)

; Check if file opened for reading OK
If $file = -1 Then
    MsgBox(0, "Error", "Unable to open file1. "&$filename)
    Exit
 EndIf

 ; Read in 1 character at a time until the EOF is reached
;While 1
    Local $chars = FileRead($file ) ; , 1)
    ;If @error = -1 Then ExitLoop
    ;MsgBox(0, "Char read:", $chars)
;WEnd
;ConsoleWrite(""  & $chars &  @CR )
FileClose($file)
return $chars


EndFunc


; poly fill the scripting object to give us JSON, JSONpath and Keys and useful functions for access JS objects in autoit..
$JSON_COM_extentions = 	""  & _
      $Objectkeys_polyfill_text & _
	  " Object.prototype.objGet  		=function( s ) { return eval(s) }                ;  REM = ""To get an obj $obj.objGet('JSON')  ""; " & _
	  " Array.prototype.item            =function( i ) { return this[i] }                ;  REM = ' so that arrays can work in AutoIT obj.item(0)' ; " & _
	  " Object.prototype.item           =function( i ) { return this[i] }                ;  REM = ""so that dynamic key values be obtained eg. obj.item('name' ) or just obj.surname ""; " & _
	  " Object.prototype.keys    		=function(   ) { if (typeof this == 'object') { return Object.keys(this);}   }       ;  REM = ""To get an obj json properties ""; " & _
	  " Object.prototype.keys    		=function( o ) { if (typeof o == 'object') { return Object.keys(o);}   }             ;  REM = ""To get an obj json properties  - recommended usage ""; " & _
 	  " Object.prototype.arrayAdd 		=function(  i, o ) { this[i] = o; };  ;  REM = ""Add item to array  ""; " & _
	  " Object.prototype.arrayDel 		=function(  i ) { this.splice(i,1); };  ;  REM = ""Del item to array  ""; " & _
	  " Object.prototype.isArray     	=function(   ) { return this.constructor == Array;    }   ;  REM = ""Is object an array  ""; " & _
	  " Object.prototype.type    	    =function(   ) { return typeof(this);  }         ;  REM = ""To get an obj type - not recommended ""; "  & _
	  " Object.prototype.type 		   	=function( o ) { return typeof(o);  }            ;  REM = ""To get an obj type - recommended usage ""; "


	$JSON_path_framework = "" & _
	  " var JSON = new Object(); JSON.jsonPath = function( obj,expr, arg) { return jsonPath(obj,expr, arg) };  " & _
	  $jsonPath_text

	$JSON_framework = "" & _
		  $json_text & _
	  " Object.prototype.stringify    	=function(   ) { return JSON.stringify(this) }   ;  REM = ""Print out an object  ""; " & _
 	  " Object.prototype.parse    		=function( s ) { return JSON.parse(s) }          ;  REM = ""JSON String to object  ""; "  & _
	  " Object.prototype.jsonPath    	=function(  expr, arg ) { return JSON.jsonPath(this, expr, arg) }   ;  REM = ""Query object  ""; "  & _
	  " Object.prototype.objToString    =function(   ) { return JSON.stringify(this) }   ;  REM = ""Print out an object  - depreciated ""; " & _
 	  " Object.prototype.strToObject    =function( s ) { return JSON.parse(s) }          ;  REM = ""JSON String to object - deprecciated ""; "


$JSON_COM_extentions  = $JSON_COM_extentions  & $JSON_path_framework & $JSON_framework

; build Objects in AUTO IT!
$OO_extra = "" & _
	  " Object.prototype.propAdd =function(prop, val ) { eval('this.' + prop + '=' + val )   } ; " & _
	  " Object.prototype.methAdd =function(meth, def ) { eval('this.' + meth + '= new ' + def )   } ; "

; extend javascript within AutoIT! Add a method to all objects
$OO_extend_framework = 	"" & _
" Object.prototype.protoAdd 		=function( methName, jsFunction , objectTypeName) { objectTypeName = objectTypeName || 'Object'; eval( objectTypeName + '.prototype.' +  methName + '=' + jsFunction )}; "

; methods to  add native JS functions like 'URIencode'
$OO_js_native = "" & _
	  " Object.prototype.jsFunAdd =function( funname , numParams , objectTypeName ) { " & _
			" var x = buildParamlist (numParams)  ;  objectTypeName = objectTypeName || 'Object'; " & _
	        " return eval(objectTypeName + '.prototype.' + funname + ' = function(' + x + ') { return ' + funname + '(' + x + '); }'  )  } ; "  & _
	  " function buildParamlist (numParams)   { " & _
			" var x = ' p0' ; numParams = numParams || 1 ;  " & _
			" for (var i=1; i< numParams; i++) { x=  x + ' , ' + 'p'  + i ;  } ; "  & _
			" return x; } ;"

; Strings and Numbers
; This is only useful if you want to access Javascript string and number functions.
$LiteralObj = "" & _
	  "Object.prototype.dot =function( str, jsStrFun ) { if ( typeof str == 'string' )  { return eval( '""'+  protectDoubleQuotes (str)  + '"".' + jsStrFun ) } else  { return eval( ''+  str  + '.' + jsStrFun ) }  } ; " & _
	  "function oLiteral (literal) { " & _
	  "  this.literal  = literal; " & _
      "} " & _
	  "function protectDoubleQuotes (str)   { " & _
			" return str.replace(/\\/g, '\\\\').replace(/""/g,'\\""');   " & _
			"}" & _
	  " Object.prototype.toObj =function( literal ) { if ( typeof literal == 'string' )  { return eval( 'new oLiteral(""' + protectDoubleQuotes (literal) + '"")' ) }  else {return eval( 'new oLiteral(' + literal + ')' )} } ; "  & _
	  " Object.prototype.jsMethAdd =function( funname , numParams ) { " & _
			" var x = buildParamlist (numParams)  ;  " & _
			" return eval('oLiteral.prototype.' + funname + ' = function(' + x + ') { return this.literal.' + funname + '(' + x + '); }'  )  } ; "


global $g_OO_JSON_non_IE ; global
global $g_JS_framework ; global



; OO framework for basic OO and JSON to autoIT -
$g_JS_framework  = "" & _
	  $OO_extra & _
	  $OO_js_native & _
	  $OO_extend_framework & _
	  $JSON_COM_extentions  & _
	  $LiteralObj

	  ;	  $JSON_path_framework  & _
	  ;$JSON_framework  & _


global $g_JS_HTML ; global
$g_JS_HTML = "<!DOCTYPE html>  " & _
		 " <script>" & _
		 $g_JS_framework  & _
		 "</script>" & _
		 " <body>" & _
		 "<div  id=""myIE10EvalWorkAround""  onclick=""IE10EvalWorkAroundInit()""  ></div> " & _
		 		 " </body>"

func _OO_JSON_Init ()
    ; see also _OO_JSON_custom_init
	$g_OO_JSON_non_IE = ObjCreate("ScriptControl")
	$js = $g_OO_JSON_non_IE;
    $js.language = "Jscript"

    $g_JS_framework  = "" & _
	  $OO_extra & _
	  $OO_js_native & _
	  $OO_extend_framework & _
	  $JSON_COM_extentions  & _
	  $LiteralObj

   $js.AddCode ($g_JS_framework)

   $jsObj = _JS_obj_create (  ) ; get a JS object!
   $oJSON = $jsObj.objGet("JSON") ; now we are OO!
   return $oJSON;


endfunc

func _JS_obj_create (  $def = "{}" )
   ; This used to get a handle on a Javascript object.
   ; Note, this can be used to process JSON text but is not secure. Use JSON.parse.

   ; prereq : must call _OO_JSON_Init ()
   ; usage
   ; $jsObj = _JS_obj_create ( "{ 'hello' : 'world' }" ) ;  ; Note, this is not secure. Use JSON.parse.

   ; notes
   ;$g_OO_JSON_non_IE.document.parentwindow.eval("var z "  & "= " & $def  ) ;  this dosen't work in IE10 boo! Scripting Object ok.

   $g_OO_JSON_non_IE.Eval("var z "  & "= " & $def   )
   return $g_OO_JSON_non_IE.Eval("z")
EndFunc

func _OO_JSON_Quit (  )
   ;$g_OO_JSON_non_IE = 0 this has no effect
   ; redundant
   ;_IEQuit($g_OO_JSON_non_IE)

EndFunc

;--- end of UDF

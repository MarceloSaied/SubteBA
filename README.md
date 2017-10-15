#                      SubteBA
##               SubteBA alerts for Telegram

###          Telegram Bot    = = = =    @SubteBA_bot

[Subscribirse al SubteBA Bot ](https://t.me/subteba)


<table border="0">
<tr><td>
Este BOT , lee los informes de Subte BA Buenos Aires Ciudad en Twitter, y los envia por este canal.
Este canal **no es official** del subte ni de Metrovias.
Es simplemente un testeo de la tecnologia.
</td> <td> <img src="https://github.com/MarceloSaied/SubteBA/blob/master/images/SubteBA_icon.jpg" 
alt="SubteBA Logo" height="100" width="200"> 
</td></tr>

</table>

- - -
#### Etapas de desarrollo
| Task                                  | Status     | Version| Date      |     |
| ------------------------------------- |:----------:| :-----:| :--------:|----:|
| Configuracion del Bot en Telegram     | Done       | 0.1    |  08/2017  |     | 
| Envio de mensajes a clientes telegram | Done       | 0.1    |  09/2017  |     |
| scrap twiter subteba for messages     | Done       | 0.1    |  10/2017  |     |
| send messages to users                | Done       | 0.1    |  10/2017  |     |
| store scrapped messages at database   | In Process | 0.1    |  10/2017  |     |
| send New messages to users            |            | 0.x    |  xx/2017  |     |
| get data from telegram bot            |            | 0.x    |  xx/2017  |     |
| store user id from data bot           |            | 0.x    |  xx/2017  |     |
|                                       |            | 0.x    |  xx/2017  |     |
|                                       |            | 0.x    |  xx/2017  |     |
|                                       |            | 0.x    |  xx/2017  |     |

- - -
#### Application Workflow
![Workflow1 image](https://github.com/MarceloSaied/SubteBA/blob/master/images/workflow1.jpg)

- - - 
- - -
### Datos para el desarrollo

* Secrets
	* Los secrets se guardan en un folder  "secret"
	* El folder RENsecret tiene los archivos de del folder secret , pero ofuscados
	* Archivos en SECRET folder
	
	| Nombre de archivo       | Descripcion     | 
	| ----------------------- |----------|
	| Config.ini | archivo de configuracion      | 
	| Recipients.txt | archivo temporario para desarrollo con usuarios registrados en el Bot | 
	|      |  | 


* Archivo de configuracion
	* los mensages se mandan a Telegram usando este usa un archivo de configuracion en el folder secret ( en un futuro sera copiado a temp folder en runtime)

	El archivo de configuracion es Config.ini
	
	Campos del ini 
	bot.name ==> Telegram Bot name
	bot.token ==> Telegram bot token
	dev.chatid ==> User chat ide for dev purposes
	twitter.username ==> Twitter username to scrap page ( e.i subteba)
	
	
	Config.ini
	```ini
	[bot]
	name=@SubteBA_bot
	token=bot4010332xxxxxxxx
	[dev]
	chatID=2x51xxxxx
	[Twitter]
	Username=subteba
	```

* Archivo de usuarios

	El archivo con los usuarios registrados en el Bot (solo para desarrollo) es el siguiente
	Recipients.txt
	Consta de dos datos por registro
	UserID y Nombre del usuario
	```csv
	20xx0xxxx,Marcelo Saied
	20xx0xxxx,Guillermo Blanco


	```
- - -
* Base de datos

	Las tablas son:
	
	| Tabla          | Campos    |  Triggers |Descripcion     | 
	| :------------- |:----------|:----------|:---------------|
	| Users |UserID (Int)Ix, Fname (Text), Lname (Text), Active (Bool), Dev (Bool), Since(Int) |CleanUp|Users Info| 
	| Messages  | id (Int)Ix, Message (Text)                          |           | Scrapped messages  | 
	| Users_Messages | UserID (Int)FK , MsgID (Int)FK                  |           | Users <-> Messages | 
	|  |      |    |   | 


	
	* Triggers ( DDL)
	
	CleanUp
	Deletes records from Users_Messages on Users.Active is set to 0
	
	```SQL
	CREATE TRIGGER "CleanUp" AFTER UPDATE OF "Active" ON "Users" WHEN new.Active =  0
	BEGIN
	   DELETE FROM Users_Messages WHERE Users_Messages.UserID  = OLD.UserID ;
	END
	```

	
	---

- - -

**Reporte de ideas  y Bugs** en https://github.com/MarceloSaied/SubteBA/issues
#### Slack [invite](https://join.slack.com/t/subteba/shared_invite/enQtMjQ5ODYxMjkwNzU3LWRjMDM0MmUzOTZhNWQ5N2Q4ZWM5NmM3OGM2ZmQxYzgxODdjMTk4NWZjYmNkYTEwMTEzYWI1ZTk5YTIxZTk2OGU)

### Desarrollo y aportes

* Marcelo Saied

### Especial Tanks to the AutoIT developpers , and The UDF creators
	* [Melba23](https://www.autoitscript.com/forum/profile/38576-melba23/)
	* [LinkOut](https://www.autoitscript.com/forum/profile/101631-linkout/)
		* Telegram Bot UDF
	* [TheDcoder](https://www.autoitscript.com/forum/profile/89462-thedcoder/)
	* [Jos](https://www.autoitscript.com/forum/profile/19-jos/)
	* 

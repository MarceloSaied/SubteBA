#                      SubteBA
##               SubteBA alerts for Telegram

###          Telegram Bot    = = = =    @SubteBA_bot
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
| Envio de mensajes a clientes telegram | Done       | 0.1    |  08/2017  |     |
| get data from telegram bot            | In Process | 0.1    |  xx/2017  |     |
| store user id from data bot           | In Process | 0.1    |  xx/2017  |     |
| scrap twiter subteba for messages     |            | 0.x    |  xx/2017  |     |
| store scrapped messages               |            | 0.x    |  xx/2017  |     |
| send messages to users                |            | 0.x    |  xx/2017  |     |
|                                       |            | 0.x    |  xx/2017  |     |
|                                       |            | 0.x    |  xx/2017  |     |
|                                       |            | 0.x    |  xx/2017  |     |
|                                       |            | 0.x    |  xx/2017  |     |


- - -
#### Application Workflow
![Workflow1 image](https://github.com/MarceloSaied/SubteBA/blob/master/images/workflow1.jpg)

- - - 
- - -
### Datos para el desarrollo

* nlos secrets se guardan en un folder  "secret"
* los mensages se mandan a Telegram usando este usa un archivo de configuracion en el folder secret ( en un futuro sera copiado a temp folder en runtime)

El archivo de configuracion es el siguiente

Config.ini

```ini
[bot]
name=@SubteBA_bot
token=bot4010332xxxxxxxx
[dev]
chatID=2x51xxxxx

```

- - -

- - -

**Reporte de ideas  y Bugs** en https://github.com/MarceloSaied/SubteBA/issues
#### Slack [invite](https://join.slack.com/t/subteba/shared_invite/enQtMjQ5ODYxMjkwNzU3LWRjMDM0MmUzOTZhNWQ5N2Q4ZWM5NmM3OGM2ZmQxYzgxODdjMTk4NWZjYmNkYTEwMTEzYWI1ZTk5YTIxZTk2OGU)

### Desarrollo y aportes

* Marcelo Saied

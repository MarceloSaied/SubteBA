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
| Configuracion del Bot en Telegram     | In Process | 0.1    |  08/2017  |     | 
| Envio de mensajes a clientes telegram | Done       | 0.1    |  08/2017  |     |
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

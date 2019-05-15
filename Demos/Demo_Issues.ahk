#SingleInstance force

#Include %A_ScriptDir%\..\lib\cGithub.ahk
#Include %A_ScriptDir%\..\lib\JSON\JSON.ahk
#Include %A_ScriptDir%\..\lib\log4ahk\log4ahk.ahk
#Include %A_ScriptDir%\lib\ObjTree.ahk

logger := new log4ahk()
; Set the loglevel to be filtered upon
logger.loglevel.required := logger.loglevel.TRACE2
; Set the appenders to be logged to
logger.appenders.push(new logger.appenderoutputdebug())
logger.appenders.push(new logger.appenderstdout())
; Show loglevel, current function and log message in log protocol
logger.layout.required := "[%-6.6V] %i[%M] %m"

OutputDebug "DBGVIEWCLEAR"

; #################################################################################################
; Read the Configuration and extract the data
settings := A_ScriptDir "/settings.json"
str := FileRead(settings)
logger.info(str)
obj := JSON.Load( str )

gh := new github(obj.github.name, obj.github.email, obj.github.token)

x := gh.issues.getIssues()

ExitApp

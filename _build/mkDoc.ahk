#Include %A_ScriptDir%\..\lib\cGithub.ahk  ; Where to get version to be used within documentation
#include %A_ScriptDir%\BuildTools.ahk

DocuUpdateVersion(release_version())
DocuGenerate()

ExitApp
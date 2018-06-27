on error resume next

Dim objNet
Dim objShell
Dim strStartupPath
Dim objfso

Set objNet = CreateObject("WScript.Network")
Set objShell = CreateObject("Wscript.Shell")
set objfso = CreateObject("Scripting.FileSystemObject")

'Adding of the mapping


Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
appDir = fso.GetParentFolderName(WScript.ScriptFullName)

' 1. Ensure background engine server is active (runs 100% hidden)
checkCmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ""if (-not (Test-NetConnection -ComputerName 127.0.0.1 -Port 48888 -InformationLevel Quiet)) { Start-Process node -ArgumentList 'server.js' -WorkingDirectory '" & appDir & "' -WindowStyle Hidden; Start-Sleep -Milliseconds 1200 }"""
WshShell.Run checkCmd, 0, True

' 2. Launch in modern chromeless app mode or default browser
edgePath = WshShell.ExpandEnvironmentStrings("%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe")
If Not fso.FileExists(edgePath) Then
    edgePath = WshShell.ExpandEnvironmentStrings("%ProgramFiles%\Microsoft\Edge\Application\msedge.exe")
End If

If fso.FileExists(edgePath) Then
    edgeCmd = """" & edgePath & """ --app=http://127.0.0.1:48888 --window-size=1200,800"
    WshShell.Run edgeCmd, 1, False
Else
    WshShell.Run "http://127.0.0.1:48888", 1, False
End If

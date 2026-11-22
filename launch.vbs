Set WshShell = CreateObject("WScript.Shell")
appDir = "C:\Users\Administrator\.gemini\antigravity\scratch\ApexOptimizer"

' 1. Ensure background engine server is active (runs 100% hidden)
checkCmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ""if (-not (Test-NetConnection -ComputerName 127.0.0.1 -Port 48888 -InformationLevel Quiet)) { Start-Process node -ArgumentList 'server.js' -WorkingDirectory '" & appDir & "' -WindowStyle Hidden; Start-Sleep -Milliseconds 1200 }"""
WshShell.Run checkCmd, 0, True

' 2. Launch Edge in App Mode (chromeless native desktop window)
edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
edgeCmd = """" & edgePath & """ --app=http://127.0.0.1:48888 --window-size=1200,800"
WshShell.Run edgeCmd, 1, False

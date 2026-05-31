Set WShell = CreateObject("WScript.Shell")
WShell.Run "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File ""C:\Users\pedro\D.O.N.N.A\mcp\tradingview\scripts\launch_tv_donna.ps1""", 0, False
Set WShell = Nothing

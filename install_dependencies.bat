@echo off
REM Windows Dependency Installer
REM Requires administrative privileges

echo Installing required components...
echo ---------------------------------

winget install --id Microsoft.DotNet.SDK.7 --accept-package-agreements --accept-source-agreements
winget install --id Git.Git --accept-package-agreements --accept-source-agreements
winget install --id WiresharkFoundation.Wireshark --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.PowerShell --accept-package-agreements --accept-source-agreements
winget install --id Python.Python.3.11 --accept-package-agreements --accept-source-agreements

pip install psutil matplotlib

echo Creating firewall rules...
netsh advfirewall firewall add rule name="DoS Simulator Local" dir=in action=allow program="%~dp0main.ps1" localip=127.0.0.1 remoteip=127.0.0.1 protocol=any

echo ---------------------------------
echo Installation complete!
echo Run main.ps1 to start the toolkit
pause

@echo off
REM Complete Uninstallation Script

echo Uninstalling DoS Simulator Toolkit...
echo -----------------------------------

echo Removing firewall rules...
netsh advfirewall firewall delete rule name="DoS Simulator Local"

echo Removing log files...
del /q /s "%~dp0logs\*"
rd /s /q "%~dp0logs"

echo Removing scheduled tasks...
schtasks /delete /tn "DoS-Simulator-Monitor" /f

echo Uninstallation complete!
echo All toolkit components have been removed from your system.
pause

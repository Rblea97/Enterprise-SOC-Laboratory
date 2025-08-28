@echo off
echo ===================================
echo SOC Lab Active Directory Setup
echo ===================================
echo.
echo This script will create the complete AD structure for your SOC lab.
echo Run this on the Domain Controller (DC01) as Administrator.
echo.
pause

echo Running PowerShell script...
powershell -ExecutionPolicy Bypass -File "%~dp0setup_ad_structure.ps1"

echo.
echo ===================================
echo Setup Complete!
echo ===================================
echo.
echo Next steps:
echo 1. Test user logins from Windows 10 client
echo 2. Set up Windows Event Forwarding
echo 3. Configure Splunk SIEM
echo.
pause
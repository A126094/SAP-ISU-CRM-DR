@ECHO off
echo DO YOU WANT TO REVERT THE DISASTER RECOVERY
set /p Password= Please enter password :

IF "%Password%"=="Admin@123" GOTO YES

Echo WRONG PASSWORD
pause
exit

:YES
powershell -noprofile -command "&{ start-process powershell -ArgumentList '-noprofile -file E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\DR_Shutdown_DR_Online_PT_CRM.ps1' -verb RunAs}"
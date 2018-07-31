@ECHO off
echo DO YOU WANT TO INVOKE THE DISASTER RECOVERY
set /p Password= Please enter password :

IF "%Password%"=="Admin@123" GOTO YES

Echo WRONG PASSWORD
pause
exit

:YES
powershell -noprofile -command "&{ start-process powershell -ArgumentList '-noprofile -file E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\DR_Shutdown_PT_Online_DR_ISU.ps1' -verb RunAs}"
$GUIpath="C:\PROGRA~2\SAP\FrontEnd\SAPgui";
$System="CP1";
$LogonGroup="CP1";
$Client="000"
$SystemPath="/M/SAPCRMDCLST01/S/3600/G/CP1"
$User="SAP*";
$PasswordSYS="pass"
$OutputFilePath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs\OUTPUT_DR_LOG.txt";

function startSICK
{
"*******************************************************************" | Add-Content $OutputFilePath
"SICK T-CODE run satrt date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
$command = @'
cmd.exe /C "cmd.exe /C "$GUIpath\sapshcut.exe -sysname="$System[$LogonGroup]" -system ="$System" -client="$Client" -gui="$SystemPath" -command="SICK" -user="$User" -pw="$PasswordSYS"""
'@
Invoke-Expression -Command:$command
start-sleep -s 20;
$var = new-object -comobject wscript.shell;
$intAnswer = $var.popup("Do you want to proceed?",0,"SICK succeeded",48+4)
If ($intAnswer -eq 6) 
{
	"System Database is consistent"
	if((get-process saplogon -ErrorAction SilentlyContinue) -ne $Null)
	{
		Stop-Process -Name "saplogon"
	}
} 
else 
{
	"SICK transaction failed please check database consistencies"	
	if((get-process saplogon -ErrorAction SilentlyContinue) -ne $Null)
	{
		Stop-Process -Name "saplogon"
	}
}

"SICK T-CODE run end date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath

}
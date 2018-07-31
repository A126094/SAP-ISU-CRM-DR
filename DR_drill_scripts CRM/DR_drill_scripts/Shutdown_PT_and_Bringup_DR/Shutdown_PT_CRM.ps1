###########
# 
# These script is to make the DR process at AGL faster with less manual tasks.
# These scripts deal with SAP and Database activities
#
# Project Name : DR Uplift
# Date         : 01 June 2018
# Version      : 1.0
# Author       : Abhishek Mondal / Peter Yohannes
# Requirement  : This script needs to be executed as AGL\sapinstaller user
###########


. E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Start_Stop_SAP.ps1
. E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\SQLServiceStop.ps1
. E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\AttachDettach_DB_CRM.ps1
. E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\FailoverCluster_Start_Stop.ps1
$OutputFilePath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs\OUTPUT_DR_LOG.txt";
$System_Start_Stop_Time=0;

"*******************************************************************" | Add-Content $OutputFilePath
"SAP PT system offline has been initiated for DR drill start date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath


"Please enter your choice::"
"1. Start activity bring down PT"
"2. Detach PT database"
"3. Stop SQL service for PT"
"4. EXIT"

do
{
	$Temp = Read-Host 'What is your choilce 1/2/3/4 ?';
	if ($Temp -notmatch "[0-9]")
 	{
        	Write-Host "Please enter a valid choice 1/2/3/4 "
        	$input="notok"
	}
	else
	{
		$Choice = ([int]$Temp)-1;
		if($Choice -gt 3 -or $Choice -lt 0)
		{
        		$input="notok"
		}
		else
		{
        		$input="ok"
		}
	}

}while($input -ne "ok")

switch ( $Choice)
{
	0
	{
		StopSAPSystem; 		#This will stop PT system
		detachDatabaseCRMPT; 	#Detach CPT database
		stopSQLService; 	# Stop SQL service for CPT
	}
	1
	{ 
		detachDatabaseCRMPT;
		stopSQLService;
	}
	2
	{    
		stopSQLService;

	}
	3
	{    
		Get-WmiObject -Query "select * from win32_process where name = 'powershell.exe'" | Remove-WmiObject

	}

}
$var = new-object -comobject wscript.shell;
$intAnswer = $var.popup("Do you want to proceed with DR system up?",0,"SICK succeeded",48+4)
If ($intAnswer -ne 6) 
{
	if((get-process saplogon -ErrorAction SilentlyContinue) -ne $Null)
	{

		Get-WmiObject -Query "select * from win32_process where name = 'powershell.exe'" | Remove-WmiObject
	}
}

"*******************************************************************" | Add-Content $OutputFilePath
"SAP PT system offline has been finished date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
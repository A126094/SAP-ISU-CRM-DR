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


. E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Start_Stop_SAP_PT.ps1
. E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\AttachDettach_DB_ISU_PT.ps1
. E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\FailoverCluster_Start_Stop_PT.ps1
. E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\R3transCheck_PT.ps1
$OutputFilePath="E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Logs\OUTPUT_DR_LOG.txt";
$System_Start_Stop_Time=0;

"*******************************************************************" | Add-Content $OutputFilePath
"SAP PT system offline has been initiated for DR drill start date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath


"Please enter your choice::"
"1. Start activity bring online PT"
"2. Attach PT database"
"3. Start from orphanlogin problem for PT database"
"4. Start SAP cluster of IPT"
"5. SAP PT system start"
"6. EXIT"

do
{
	$Temp = Read-Host 'What is your choilce 1/2/3/4 ?';
	if ($Temp -notmatch "[0-9]")
 	{
        	Write-Host "Please enter a valid choice 1/2/3/4"
        	$input="notok"
	}
	else
	{
		$Choice = ([int]$Temp)-1;
		if($Choice -gt 5 -or $Choice -lt 0)
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
		startClusterGroup("SQL Server (SQLSVRIPT)"); ## Start the Cluster Group
		attachDatabaseISU; #This willl attach PT database IPT
		OrphanLoginProblem;
		startClusterGroup("SAP IPT"); ## Start the Cluster Group
		StartSAPSystem; ## To start the SAP PT system IPT
	}
	1
	{ 
		attachDatabaseISU; #This willl attach PT database IPT
		OrphanLoginProblem;
		startClusterGroup("SAP IPT"); ## Start the Cluster Group
		StartSAPSystem; ## To start the SAP PT system IPT
	}
	2
	{    
		OrphanLoginProblem;
		startClusterGroup("SAP IPT"); ## Start the Cluster Group
		StartSAPSystem; ## To start the SAP PT system IPT

	}
	3
	{    
		startClusterGroup("SAP IPT"); ## Start the Cluster Group
		StartSAPSystem; ## To start the SAP PT system IPT

	}
	4
	{    
		StartSAPSystem; ## To start the SAP PT system IPT

	}
	5
	{    
		Get-WmiObject -Query "select * from win32_process where name = 'powershell.exe'" | Remove-WmiObject

	}
}


"*******************************************************************" | Add-Content $OutputFilePath
"SAP PT system online has been finished date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
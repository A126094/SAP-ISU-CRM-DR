###########
# 
# These script is to make the DR process at AGL faster with less manual tasks.
# These scripts deal with SAP and Database activities
#
# Project Name : DR Uplift
# Date         : 01 June 2018
# Version      : 1.0
# Author       : Abhishek Mondal / Peter Yohannes
# Requirement  : This script needs to be executed as AGL\<sid>adm user
###########


. E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Start_Stop_SAP.ps1
. E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\SQLServiceStop.ps1
. E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\AttachDettach_DB_CRM.ps1
. E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\FailoverCluster_Start_Stop.ps1
. E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\R3transCheck.ps1
. E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Configuration_modify_CRM.ps1
. E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Run_SAP_TCode.ps1
$OutputFilePath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs\OUTPUT_DR_LOG.txt";
$System_Start_Stop_Time=0;
#######################################
#
# Check User ID executing this script
#
#######################################
do
{
	$username = "AGL\sapinstaller"
	$Response = Read-Host 'What is the password for SAPINSTALLER ?' -AsSecureString
	$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Response));
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	$ct = [System.DirectoryServices.AccountManagement.ContextType]::Domain
	$pc = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($ct, "AGL")
	$CheckValid=$pc.ValidateCredentials($username, $password).ToString();
	$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList @($username,(ConvertTo-SecureString -String $password -AsPlainText -Force))
	$args = "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Shutdown_PT_CRM.ps1"
	if($CheckValid -eq "True"){ break;}
} while(1)
	$args1 = "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\RemovePTDisk_Wintel.ps1"
	$args2 = "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\AddDRDisktoCluster_Wintel.ps1"
	$args3 = "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\PTunmapDRmap_Storage.ps1"

If(Test-Path $OutputFilePath)
{
    Get-Item $OutputFilePath | Rename-Item -newname {"OUTPUT_DR_LOG_" + ($_.CreationTime.toString("ddMMyyyy_HHmmss")) + ".txt"}
    New-Item $OutputFilePath -ItemType file
}
Else
{
    New-Item $OutputFilePath -ItemType file
}

"*******************************************************************" | Add-Content $OutputFilePath
"SAP DR preparation has been initiated start date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath


"Please enter your choice::"
"1. Start activity bring down PT and online DR"
"2. Start from Wintel task to detach PT LUNS"
"3. Storage task to allocate Production LUNS on DR server"
"4. Starting SQL cluster of DR systems"
"5. Wintel task to present the Production LUNS"
"6. Attach DR system databases"
"7. Starting from Orphan login problem solve after database attachment"
"8. Starting SAP cluster of DR systems"
"9. Start from R3TRANS check"
"10. Modify configuration of DR system"
"11. Start DR system"
"12. Run SICK command on DR system"

do
{
	$Temp = Read-Host 'What is your choilce between 1 to 12?';
	if ($Temp -notmatch "[0-9]")
 	{
        	Write-Host "Please enter a valid choice between 1 to 12"
        	$input="notok"
	}
	else
	{
		$Choice = ([int]$Temp)-1;
		if($Choice -gt 11 -or $Choice -lt 0)
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
		$startProc=Start-Process powershell.exe -Credential $credentials -ArgumentList ("-file $args") -PassThru
		$startProc.WaitForExit();
		$startProc1=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args1") -PassThru
		$startProc1.WaitForExit();
        	$startProc3=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args3") -PassThru
		$startProc3.WaitForExit();
		startClusterGroup("SQL Server (MSSQLSERVER)"); ## Start the Cluster Group
		checkClusterStatus("SQL Server (MSSQLSERVER)"); ##Failover test
		checkClusterStatus("SQL Server (MSSQLSERVER)"); ##Failback to original cluster test
		$startProc2=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args2") -PassThru
		$startProc2.WaitForExit();
		attachDatabaseCRM;
		OrphanLoginProblem;
		startClusterGroup("SAP CP1"); ## Start the Cluster Group
		checkClusterStatus("SAP CP1"); ##Failover test
		checkClusterStatus("SAP CP1"); ##Failback to original cluster test
		CheckR3trans;
		clearTableContentCRM; ## Clear table and SQL queries for CRM
		StartSAPSystem; ## To start the SAP system
		startSICK; ## Run SICK T-Code in system
	}
	1
	{ 
		$startProc1=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args1") -PassThru
		$startProc1.WaitForExit();
        	$startProc3=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args3") -PassThru
		$startProc3.WaitForExit();
		startClusterGroup("SQL Server (MSSQLSERVER)"); ## Start the Cluster Group
		checkClusterStatus("SQL Server (MSSQLSERVER)"); ##Failover test
		checkClusterStatus("SQL Server (MSSQLSERVER)"); ##Failback to original cluster test
		$startProc2=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args2") -PassThru
		$startProc2.WaitForExit();
		attachDatabaseCRM;
		OrphanLoginProblem;
		startClusterGroup("SAP CP1"); ## Start the Cluster Group
		checkClusterStatus("SAP CP1"); ##Failover test
		checkClusterStatus("SAP CP1"); ##Failback to original cluster test
		CheckR3trans;
		clearTableContentCRM; ## Clear table and SQL queries for CRM
		StartSAPSystem; ## To start the SAP system
		startSICK; ## Run SICK T-Code in system
	}
	2
	{    
        	$startProc3=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args3") -PassThru
		$startProc3.WaitForExit();
		startClusterGroup("SQL Server (MSSQLSERVER)"); ## Start the Cluster Group
		checkClusterStatus("SQL Server (MSSQLSERVER)"); ##Failover test
		checkClusterStatus("SQL Server (MSSQLSERVER)"); ##Failback to original cluster test
		$startProc2=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args2") -PassThru
		$startProc2.WaitForExit();
		attachDatabaseCRM;
		OrphanLoginProblem;
		startClusterGroup("SAP CP1"); ## Start the Cluster Group
		checkClusterStatus("SAP CP1"); ##Failover test
		checkClusterStatus("SAP CP1"); ##Failback to original cluster test
		CheckR3trans;
		clearTableContentCRM; ## Clear table and SQL queries for CRM
		StartSAPSystem; ## To start the SAP system
		startSICK; ## Run SICK T-Code in system
	}
	3
	{ 
		startClusterGroup("SQL Server (MSSQLSERVER)"); ## Start the Cluster Group
		checkClusterStatus("SQL Server (MSSQLSERVER)"); ##Failover test
		checkClusterStatus("SQL Server (MSSQLSERVER)"); ##Failback to original cluster test   
		$startProc2=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args2") -PassThru
		$startProc2.WaitForExit();
		attachDatabaseCRM;
		OrphanLoginProblem;
		startClusterGroup("SAP CP1"); ## Start the Cluster Group
		checkClusterStatus("SAP CP1"); ##Failover test
		checkClusterStatus("SAP CP1"); ##Failback to original cluster test
		CheckR3trans;
		clearTableContentCRM; ## Clear table and SQL queries for CRM
		StartSAPSystem; ## To start the SAP system
		startSICK; ## Run SICK T-Code in system
	}
	4
	{    
		$startProc2=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args2") -PassThru
		$startProc2.WaitForExit();
		attachDatabaseCRM;
		OrphanLoginProblem;
		startClusterGroup("SAP CP1"); ## Start the Cluster Group
		checkClusterStatus("SAP CP1"); ##Failover test
		checkClusterStatus("SAP CP1"); ##Failback to original cluster test
		CheckR3trans;
		clearTableContentCRM; ## Clear table and SQL queries for CRM
		StartSAPSystem; ## To start the SAP system
		startSICK; ## Run SICK T-Code in system
	}
	5
	{    
		attachDatabaseCRM;
		OrphanLoginProblem;
		startClusterGroup("SAP CP1"); ## Start the Cluster Group
		checkClusterStatus("SAP CP1"); ##Failover test
		checkClusterStatus("SAP CP1"); ##Failback to original cluster test
		CheckR3trans;
		clearTableContentCRM; ## Clear table and SQL queries for CRM
		StartSAPSystem; ## To start the SAP system
		startSICK; ## Run SICK T-Code in system
	}
	6
	{    
		OrphanLoginProblem;
		startClusterGroup("SAP CP1"); ## Start the Cluster Group
		checkClusterStatus("SAP CP1"); ##Failover test
		checkClusterStatus("SAP CP1"); ##Failback to original cluster test
		CheckR3trans;
		clearTableContentCRM; ## Clear table and SQL queries for CRM
		StartSAPSystem; ## To start the SAP system
		startSICK; ## Run SICK T-Code in system
	}
	7
	{    
		startClusterGroup("SAP CP1"); ## Start the Cluster Group
		checkClusterStatus("SAP CP1"); ##Failover test
		checkClusterStatus("SAP CP1"); ##Failback to original cluster test
		CheckR3trans;
		clearTableContentCRM; ## Clear table and SQL queries for CRM
		StartSAPSystem; ## To start the SAP system
		startSICK; ## Run SICK T-Code in system
	}
	8
	{    
		CheckR3trans;
		clearTableContentCRM; ## Clear table and SQL queries for CRM
		StartSAPSystem; ## To start the SAP system
		startSICK; ## Run SICK T-Code in system
	}
	9
	{    
		clearTableContentCRM; ## Clear table and SQL queries for CRM
		StartSAPSystem; ## To start the SAP system
		startSICK; ## Run SICK T-Code in system
	}
	10
	{    
		StartSAPSystem; ## To start the SAP system
		startSICK; ## Run SICK T-Code in system
	}
	11
	{    
		startSICK; ## Run SICK T-Code in system
	}

}

"*******************************************************************" | Add-Content $OutputFilePath
"SAP DR Preparation has been finished date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
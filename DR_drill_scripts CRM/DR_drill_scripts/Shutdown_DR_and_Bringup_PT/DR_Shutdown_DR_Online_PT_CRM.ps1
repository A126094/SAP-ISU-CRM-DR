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


. E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Start_Stop_SAP_PT.ps1
. E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\SQLServiceStop_PT.ps1
. E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\AttachDettach_DB_CRM_PT.ps1
$OutputFilePath="E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Logs\OUTPUT_DR_LOG.txt";
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
	$args = "E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Start_PT_CRM.ps1"
	if($CheckValid -eq "True"){ break;}
} while(1)

	$args1 = "E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\RemoveDRDisk_Wintel.ps1"
	$args2 = "E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\AddPTDisktoCluster_Wintel.ps1"
	$args3 = "E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\DRunmapPTmap_Storage.ps1"

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
"SAP bring DR offile and PT online preparation has been initiated start date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath


"Please enter your choice::"
"1. Start activity bring down DR and online PT"
"2. Start detach DR database"
"3. Stop SQL cluster of DR system"
"4. Wintel task to un map DR LUNS"
"5. Storage task to allocate PT LUNS on DR server"
"6. Wintel task to present the PT LUNS"
"7. Starting PT systems"

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
		if($Choice -gt 6 -or $Choice -lt 0)
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
		StopSAPSystem; #This will stop DR system
		detachDatabaseCRMDR; #Detach IP1 DR database
		stopSQLService; # Stop SQL cluster for IP1 DR without the disks
		$startProc1=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args1") -PassThru
		$startProc1.WaitForExit();
        	$startProc3=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args3") -PassThru
		$startProc3.WaitForExit();
		$startProc2=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args2") -PassThru
		$startProc2.WaitForExit();
		$startProc=Start-Process powershell.exe -Credential $credentials -ArgumentList ("-file $args") -PassThru
		$startProc.WaitForExit();
	}
	1
	{
		detachDatabaseCRMDR; #Detach IP1 DR database
		stopSQLService; # Stop SQL cluster for IP1 DR without the disks
		$startProc1=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args1") -PassThru
		$startProc1.WaitForExit();
        	$startProc3=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args3") -PassThru
		$startProc3.WaitForExit();
		$startProc2=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args2") -PassThru
		$startProc2.WaitForExit();
		$startProc=Start-Process powershell.exe -Credential $credentials -ArgumentList ("-file $args") -PassThru
		$startProc.WaitForExit();
	}
	2
	{
		stopSQLService; # Stop SQL cluster for IP1 DR without the disks
		$startProc1=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args1") -PassThru
		$startProc1.WaitForExit();
        	$startProc3=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args3") -PassThru
		$startProc3.WaitForExit();
		$startProc2=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args2") -PassThru
		$startProc2.WaitForExit();
		$startProc=Start-Process powershell.exe -Credential $credentials -ArgumentList ("-file $args") -PassThru
		$startProc.WaitForExit();
	}
	3
	{
		$startProc1=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args1") -PassThru
		$startProc1.WaitForExit();
        	$startProc3=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args3") -PassThru
		$startProc3.WaitForExit();
		$startProc2=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args2") -PassThru
		$startProc2.WaitForExit();
		$startProc=Start-Process powershell.exe -Credential $credentials -ArgumentList ("-file $args") -PassThru
		$startProc.WaitForExit();
	}
	4
	{ 
        	$startProc3=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args3") -PassThru
		$startProc3.WaitForExit();
		$startProc2=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args2") -PassThru
		$startProc2.WaitForExit();
		$startProc=Start-Process powershell.exe -Credential $credentials -ArgumentList ("-file $args") -PassThru
		$startProc.WaitForExit();

	}
	5
	{    
		$startProc2=Start-Process powershell.exe -Verb runas -ArgumentList ("-file $args2") -PassThru
		$startProc2.WaitForExit();
		$startProc=Start-Process powershell.exe -Credential $credentials -ArgumentList ("-file $args") -PassThru
		$startProc.WaitForExit();
	}
	6
	{    
		$startProc=Start-Process powershell.exe -Credential $credentials -ArgumentList ("-file $args") -PassThru
		$startProc.WaitForExit();
	}

}

"*******************************************************************" | Add-Content $OutputFilePath
"SAP DR system is down and PT system is up and running now date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
$OutputFilePath="E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Logs\OUTPUT_DR_LOG.txt";
$ServernamePT= "SQLCLUSTER21\SQLSVRCPT"
$DatabasePT = "CPT"
$ServernameDR= "SQLDRCLUSTER11"
$DatabaseDR = "CP1"
$OutputPath="E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Logs";
$ScriptPath="E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT";

#Loads Assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null



function detachDatabaseCRMDR
{
"Detach database has been started Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $ServernameDR
push-location
import-module sqlps -disablenamechecking
Invoke-sqlcmd -inputfile "$ScriptPath\Detach_DR_DB_CRM.sql" -serverinstance "$ServernameDR" -ConnectionTimeout 360
$dbs = $server.Databases;
	foreach ($db in $dbs) 
	{

		if ($db.Name -like $DatabaseDR) 
		{
			"Database $($db.Name) still present in the SQL server"
			"Database $($db.Name) still present in the SQL server" | Add-Content $OutputFilePath
			exit;
		}
	
	}
pop-location;
"Database $DatabaseDR has been dettached successfully"
"Database $DatabaseDR has been dettached successfully" | Add-Content $OutputFilePath
}

function attachDatabaseCRM
{
"Attach database has been started Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
#addFilePermission; #Adding permission to database files of CPT

$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $ServernamePT
push-location
import-module sqlps -disablenamechecking
invoke-sqlcmd -inputfile "$ScriptPath\Attach_PT_DB_CRM.sql" -serverinstance "$ServernamePT" -ConnectionTimeout 360
$dbs = $server.Databases;
$DBStatus="Not Exist";
	foreach ($db in $dbs) 
	{

		if ($db.Name -like $DatabasePT) 
		{
			"Database $($db.Name) has been attached successfully"
			"Database $($db.Name) has been attached successfully" | Add-Content $OutputFilePath
			$DBStatus="Exist";
		}
	
	}
	if ($DBStatus -like "Not Exist")
	{
		write-output "Database doesn't exist"
		exit;
	}
pop-location;
}

function addFilePermission
{


	$DBServerName = (Get-ClusterGroup -Name "SQL Server (SQLSVRCPT)" | Select-Object -Property OwnerNode | Format-Table -HideTableHeaders| Out-String).Trim();
	Invoke-Command -ComputerName:$DBServerName -Credential:$credentials { 
	$Acl1 = (Get-Item H:\ID1DATA\ID1DATA1.mdf).GetAccessControl('access')
	$Acl2 = (Get-Item H:\ID1DATA\ID1DATA2.ndf).GetAccessControl('access')
	$Acl3 = (Get-Item H:\ID1DATA\ID1DATA3.ndf).GetAccessControl('access')
	$Acl4 = (Get-Item H:\ID1DATA\ID1DATA4.ndf).GetAccessControl('access')
	$Acl5 = (Get-Item H:\ID1DATA\ID1LOG1.ldf).GetAccessControl('access')
	$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("AGL\cptadm","FullControl","Allow")
	$Acl1.SetAccessRule($Ar)
	$Acl2.SetAccessRule($Ar)
	$Acl3.SetAccessRule($Ar)
	$Acl4.SetAccessRule($Ar)
	$Acl5.SetAccessRule($Ar)
	Set-Acl "H:\ID1DATA\ID1DATA1.mdf" $Acl1
	Set-Acl "H:\ID1DATA\ID1DATA2.ndf" $Acl2
	Set-Acl "H:\ID1DATA\ID1DATA3.ndf" $Acl3
	Set-Acl "H:\ID1DATA\ID1DATA4.ndf" $Acl4
	Set-Acl "H:\ID1DATA\ID1LOG1.ldf" $Acl5
	}

}
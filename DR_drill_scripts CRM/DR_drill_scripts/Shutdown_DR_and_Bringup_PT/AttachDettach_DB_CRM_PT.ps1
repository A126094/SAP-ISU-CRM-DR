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
Invoke-sqlcmd -inputfile "$ScriptPath\Detach_DR_DB_CRM.sql" -serverinstance "$ServernameDR" -QueryTimeout 600  -ConnectionTimeout 600 -ErrorAction SilentlyContinue
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
invoke-sqlcmd -inputfile "$ScriptPath\Attach_PT_DB_CRM.sql" -serverinstance "$ServernamePT" -QueryTimeout 600  -ConnectionTimeout 600 -ErrorAction SilentlyContinue
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
$Acl1 = (Get-Item R:\CPTDATA1\CP1DATA1.mdf).GetAccessControl('access')
$Acl2 = (Get-Item R:\CPTDATA2\CP1DATA10.ndf).GetAccessControl('access')
$Acl3 = (Get-Item R:\CPTDATA3\CP1DATA11.ndf).GetAccessControl('access')
$Acl4 = (Get-Item R:\CPTDATA4\CP1DATA12.ndf).GetAccessControl('access')
$Acl5 = (Get-Item R:\CPTDATA5\CP1DATA13.ndf).GetAccessControl('access')
$Acl6 = (Get-Item R:\CPTDATA6\CP1DATA14.ndf).GetAccessControl('access')
$Acl7 = (Get-Item R:\CPTDATA7\CP1DATA15.ndf).GetAccessControl('access')
$Acl8 = (Get-Item R:\CPTDATA8\CP1DATA16.ndf).GetAccessControl('access')
$Acl9 = (Get-Item R:\CPTDATA2\CP1DATA2.ndf).GetAccessControl('access')
$Acl10 = (Get-Item R:\CPTDATA3\CP1DATA3.ndf).GetAccessControl('access')
$Acl11 = (Get-Item R:\CPTDATA4\CP1DATA4.ndf).GetAccessControl('access')
$Acl12 = (Get-Item R:\CPTDATA5\CP1DATA5.ndf).GetAccessControl('access')
$Acl13 = (Get-Item R:\CPTDATA6\CP1DATA6.ndf).GetAccessControl('access')
$Acl14 = (Get-Item R:\CPTDATA7\CP1DATA7.ndf).GetAccessControl('access')
$Acl15 = (Get-Item R:\CPTDATA8\CP1DATA8.ndf).GetAccessControl('access')
$Acl16 = (Get-Item R:\CPTDATA1\CP1DATA9.ndf).GetAccessControl('access')
$Acl17 = (Get-Item Y:\CP1LOG1\CP1LOG1.ldf).GetAccessControl('access')

$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("AGL\cptadm","FullControl","Allow")

$Acl1.SetAccessRule($Ar)
$Acl2.SetAccessRule($Ar)
$Acl3.SetAccessRule($Ar)
$Acl4.SetAccessRule($Ar)
$Acl5.SetAccessRule($Ar)
$Acl6.SetAccessRule($Ar)
$Acl7.SetAccessRule($Ar)
$Acl8.SetAccessRule($Ar)
$Acl9.SetAccessRule($Ar)
$Acl10.SetAccessRule($Ar)
$Acl11.SetAccessRule($Ar)
$Acl12.SetAccessRule($Ar)
$Acl13.SetAccessRule($Ar)
$Acl14.SetAccessRule($Ar)
$Acl15.SetAccessRule($Ar)
$Acl16.SetAccessRule($Ar)
$Acl17.SetAccessRule($Ar)

Set-Acl "R:\CPTDATA1\CP1DATA1.mdf " $Acl1
Set-Acl "R:\CPTDATA2\CP1DATA10.ndf " $Acl2
Set-Acl "R:\CPTDATA3\CP1DATA11.ndf " $Acl3
Set-Acl "R:\CPTDATA4\CP1DATA12.ndf " $Acl4
Set-Acl "R:\CPTDATA5\CP1DATA13.ndf " $Acl5
Set-Acl "R:\CPTDATA6\CP1DATA14.ndf " $Acl6
Set-Acl "R:\CPTDATA7\CP1DATA15.ndf " $Acl7
Set-Acl "R:\CPTDATA8\CP1DATA16.ndf " $Acl8
Set-Acl "R:\CPTDATA2\CP1DATA2.ndf " $Acl9
Set-Acl "R:\CPTDATA3\CP1DATA3.ndf " $Acl10
Set-Acl "R:\CPTDATA4\CP1DATA4.ndf " $Acl11
Set-Acl "R:\CPTDATA5\CP1DATA5.ndf " $Acl12
Set-Acl "R:\CPTDATA6\CP1DATA6.ndf " $Acl13
Set-Acl "R:\CPTDATA7\CP1DATA7.ndf " $Acl14
Set-Acl "R:\CPTDATA8\CP1DATA8.ndf " $Acl15
Set-Acl "R:\CPTDATA1\CP1DATA9.ndf " $Acl16
Set-Acl "Y:\CP1LOG1\CP1LOG1.ldf " $Acl17

	}

}
$OutputFilePath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs\OUTPUT_DR_LOG.txt";
$ServernamePT= "SQLCLUSTER20\SQLSVRIPT"
$DatabasePT = "IPT"
$ServernameDR= "SQLDRCLUSTER10"
$DatabaseDR = "IP1"
$OutputPath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs";
$ScriptPath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR";

#Loads Assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null



function detachDatabaseISUPT
{
"Detach database has been started Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
Start-Sleep -Seconds 10;
push-location
import-module sqlps -disablenamechecking
Invoke-sqlcmd -inputfile "$ScriptPath\Detach_PT_DB_ISU.sql" -serverinstance "$ServernamePT" -QueryTimeout 600 -ConnectionTimeout 360 -ErrorAction SilentlyContinue
Start-Sleep -Seconds 10;
Invoke-sqlcmd -inputfile "$ScriptPath\Detach_PT_DB_ISU.sql" -serverinstance "$ServernamePT" -QueryTimeout 600 -ConnectionTimeout 360 -ErrorAction SilentlyContinue
$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $ServernamePT
$dbs = $server.Databases;
	foreach ($db in $dbs) 
	{

		if ($db.Name -like $DatabasePT) 
		{
			"Database $($db.Name) still present in the SQL server"
			"Database $($db.Name) still present in the SQL server" | Add-Content $OutputFilePath
			exit;
		}
	
	}
pop-location;
"Database $DatabasePT has been dettached successfully"
"Database $DatabasePT has been dettached successfully" | Add-Content $OutputFilePath
}

function attachDatabaseISU
{
"Attach database has been started Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
addFilePermission; #Adding permission to database files of IP1

push-location
import-module sqlps -disablenamechecking
invoke-sqlcmd -inputfile "$ScriptPath\Attach_DR_DB_ISU.sql" -serverinstance "$ServernameDR" -QueryTimeout 600 -ConnectionTimeout 600 -ErrorAction SilentlyContinue
$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $ServernameDR
$dbs = $server.Databases;
$DBStatus="Not Exist";
	foreach ($db in $dbs) 
	{

		if ($db.Name -like $DatabaseDR) 
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


	$DBServerName = (Get-ClusterGroup -Name "SQL Server (MSSQLSERVER)" | Select-Object -Property OwnerNode | Format-Table -HideTableHeaders| Out-String).Trim();
	Invoke-Command -ComputerName:$DBServerName -Credential:$credentials { 
$Acl1 = (Get-Item G:\IP1DATA1\IP1DATA1\IP1DATA1.mdf).GetAccessControl('access')
$Acl2 = (Get-Item G:\IP1DATA2\IP1DATA2\IP1DATA10.ndf).GetAccessControl('access')
$Acl3 = (Get-Item G:\IP1DATA3\IP1DATA3\IP1DATA11.ndf).GetAccessControl('access')
$Acl4 = (Get-Item G:\IP1DATA4\IP1DATA4\IP1DATA12.ndf).GetAccessControl('access')
$Acl5 = (Get-Item G:\IP1DATA5\IP1DATA5\IP1DATA13.ndf).GetAccessControl('access')
$Acl6 = (Get-Item G:\IP1DATA6\IP1DATA6\IP1DATA14.ndf).GetAccessControl('access')
$Acl7 = (Get-Item G:\IP1DATA7\IP1DATA7\IP1DATA15.ndf).GetAccessControl('access')
$Acl8 = (Get-Item G:\IP1DATA8\IP1DATA8\IP1DATA16.ndf).GetAccessControl('access')
$Acl9 = (Get-Item G:\IP1DATA2\IP1DATA2\IP1DATA2.ndf).GetAccessControl('access')
$Acl10 = (Get-Item G:\IP1DATA3\IP1DATA3\IP1DATA3.ndf).GetAccessControl('access')
$Acl11 = (Get-Item G:\IP1DATA4\IP1DATA4\IP1DATA4.ndf).GetAccessControl('access')
$Acl12 = (Get-Item G:\IP1DATA5\IP1DATA5\IP1DATA5.ndf).GetAccessControl('access')
$Acl13 = (Get-Item G:\IP1DATA6\IP1DATA6\IP1DATA6.ndf).GetAccessControl('access')
$Acl14 = (Get-Item G:\IP1DATA7\IP1DATA7\IP1DATA7.ndf).GetAccessControl('access')
$Acl15 = (Get-Item G:\IP1DATA8\IP1DATA8\IP1DATA8.ndf).GetAccessControl('access')
$Acl16 = (Get-Item G:\IP1DATA1\IP1DATA1\IP1DATA9.ndf).GetAccessControl('access')
$Acl17 = (Get-Item F:\IP1LOG1\IP1LOG1.ldf).GetAccessControl('access')

$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("AGL\ip1adm","FullControl","Allow")

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

Set-Acl "G:\IP1DATA1\IP1DATA1\IP1DATA1.mdf " $Acl1
Set-Acl "G:\IP1DATA2\IP1DATA2\IP1DATA10.ndf " $Acl2
Set-Acl "G:\IP1DATA3\IP1DATA3\IP1DATA11.ndf " $Acl3
Set-Acl "G:\IP1DATA4\IP1DATA4\IP1DATA12.ndf " $Acl4
Set-Acl "G:\IP1DATA5\IP1DATA5\IP1DATA13.ndf " $Acl5
Set-Acl "G:\IP1DATA6\IP1DATA6\IP1DATA14.ndf " $Acl6
Set-Acl "G:\IP1DATA7\IP1DATA7\IP1DATA15.ndf " $Acl7
Set-Acl "G:\IP1DATA8\IP1DATA8\IP1DATA16.ndf " $Acl8
Set-Acl "G:\IP1DATA2\IP1DATA2\IP1DATA2.ndf " $Acl9
Set-Acl "G:\IP1DATA3\IP1DATA3\IP1DATA3.ndf " $Acl10
Set-Acl "G:\IP1DATA4\IP1DATA4\IP1DATA4.ndf " $Acl11
Set-Acl "G:\IP1DATA5\IP1DATA5\IP1DATA5.ndf " $Acl12
Set-Acl "G:\IP1DATA6\IP1DATA6\IP1DATA6.ndf " $Acl13
Set-Acl "G:\IP1DATA7\IP1DATA7\IP1DATA7.ndf " $Acl14
Set-Acl "G:\IP1DATA8\IP1DATA8\IP1DATA8.ndf " $Acl15
Set-Acl "G:\IP1DATA1\IP1DATA1\IP1DATA9.ndf " $Acl16
Set-Acl "F:\IP1LOG1\IP1LOG1.ldf " $Acl17

	}

}
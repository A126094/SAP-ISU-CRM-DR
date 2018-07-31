$OutputFilePath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs\OUTPUT_DR_LOG.txt";
$Servername= "SQLDRCLUSTER10"
$Database = "IP1"
$SQLScriptPath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR";
$OutputPath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs";
function CheckR3trans
{
"R3trans checking started Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
	"Checking Database connectivity with application please wait.."
	$Status=(& "\\sapisudclst01\sapmnt\IP1\SYS\exe\uc\NTAMD64\R3trans" -d | Out-String).Trim();
	
	if($Status -Like "*finished (0000)*")
	{
		"R3trans is ok to proceed";
		"R3trans is ok to proceed" | Add-Content $OutputFilePath;
	}
	else
	{
		"Status of R3trans run is :: $Status";
		"Status of R3trans run is :: $Status" | Add-Content $OutputFilePath;
		exit;
	}
"R3trans checking ended Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
	
}

function OrphanLoginProblem
{
"Orphan login problem solve started Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
$command = @'
cmd.exe /C "sqlcmd -S $Servername -d $Database -i $SQLScriptPath\OrphanProblem_ISU.sql -o $OutputPath\Orphan_Login_ISU.txt"
'@
Invoke-Expression -Command:$command

"Orphan login problem has been solved now"
"Orphan login problem has been solved now" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath

}



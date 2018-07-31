$OutputFilePath="E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Logs\OUTPUT_DR_LOG.txt";
$ServernamePT= "SQLCLUSTER21\SQLSVRCPT"
$DatabasePT = "CPT"
$SQLScriptPath="E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT";
$OutputPath="E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Logs";

function OrphanLoginProblem
{
"Orphan login problem solve started Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
$command = @'
cmd.exe /C "sqlcmd -S $ServernamePT -d $DatabasePT -i $SQLScriptPath\OrphanProblem_CRM_PT.sql -o $OutputPath\Orphan_Login_CRM_PT.txt"
'@
Invoke-Expression -Command:$command

"Orphan login problem has been solved now"
"Orphan login problem has been solved now" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath

}



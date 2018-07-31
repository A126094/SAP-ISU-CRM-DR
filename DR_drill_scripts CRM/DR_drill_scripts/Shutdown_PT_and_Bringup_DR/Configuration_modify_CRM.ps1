$Test= "\\sapcrmdclst01\sapmnt\CP1\SYS\exe\uc\NTAMD64";
$Servername= "SQLDRCLUSTER11";
$Database = "CP1";
$SQLScriptPath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR";
$OutputPath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs";
$OutputFilePath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs\OUTPUT_DR_LOG.txt";

function clearTableContentCRM
{
"Table clear Job hold and RFC modify start Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
$command = @'
cmd.exe /C "sqlcmd -S $Servername -d $Database -i $SQLScriptPath\CRM_Prod_config.sql -o $OutputPath\CRM_Prod_config.txt"
'@
Invoke-Expression -Command:$command


"Table clear/Job hold/RFC modify/configuration modify completed please check the output file at below location: $OutputPath "
"Table clear/Job hold/RFC modify/configuration modify completed Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath

}
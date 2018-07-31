$OutputFilePath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs\OUTPUT_DR_LOG.txt";
$SQLClusterName="SQL Server (SQLSVRIPT)";

function stopSQLService
{
	"Stopping SQL cluster without the disks"
	"Stopping SQL cluster without the disks Start: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath
	$CluserResources=(Get-ClusterGroup -Name $SQLClusterName| Get-ClusterResource | Select-Object -Property Name | Format-Table -HideTableHeaders | Out-String).Trim().Split([Environment]::NewLine).Trim();
	for($i=0;$i -lt $CluserResources.length; $i=$i+2)
	{
		if(($CluserResources[$i]).contains("Disk"))
		{
	
		}
		else 
		{
			$StopStatus=(Stop-ClusterResource -Name $CluserResources[$i] |Select-Object -Property State | Format-Table -HideTableHeaders| Out-String).Trim();
		}	
	}
	"SQL cluster has been stopped without the disks"
	"SQL cluster has been stopped without the disks at: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath	
}



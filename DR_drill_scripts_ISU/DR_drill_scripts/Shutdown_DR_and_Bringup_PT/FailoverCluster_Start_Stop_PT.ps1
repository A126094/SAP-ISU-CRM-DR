$OutputFilePath="E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Logs\OUTPUT_DR_LOG.txt";

function BringClusterOffline($ClusterGroupName)
{
	"Bring Down Cluster Group $ClusterGroupName has been started at Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*********************************************************************" | Add-Content $OutputFilePath
	$var=(Get-ClusterGroup -Name $ClusterGroupName | Select-Object -Property State | Format-Table -HideTableHeaders | Out-String).Trim();
    If($var -eq "Offline")
    {
        "Cluster is already offline"
        "Cluster is already offline" | Add-Content $OutputFilePath
    }
    else
    {
        "Cluster $ClusterGroupName is online... bring it offline.."
        "Cluster $ClusterGroupName is online... bring it offline.." | Add-Content $OutputFilePath
        Stop-ClusterGroup($ClusterGroupName)
    }
}


function checkClusterStatus($ClusterGroupName)
{
	"Cluster Group $ClusterGroupName failover has been started at Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath
	$var=(Get-ClusterGroup -Name $ClusterGroupName | Select-Object -Property State | Format-Table -HideTableHeaders | Out-String).Trim();
	If($var -eq "Online")
	{
		"Cluster is up and running"
		"Cluster is up and running"| Add-Content $OutputFilePath
		checkClusterOwner($ClusterGroupName);
	}
	else
	{
		"Cluster is down"
		"Cluster is down"| Add-Content $OutputFilePath

		
	}



}

function checkClusterOwner($ClusterGroupName)
{
	$var=(Get-ClusterGroup -Name $ClusterGroupName | Select-Object -Property OwnerNode | Format-Table -HideTableHeaders | Out-String).Trim();
	$NexFailoverNode=determineFailOverNode($var);
	checkClusterfailOver($NexFailoverNode, $ClusterGroupName);



}

function checkClusterfailOver($NewAndNextNode)
{
	"Failover to node $NewAndNextNode started please wait.."
	"Failover to node $NewAndNextNode started please wait.."| Add-Content $OutputFilePath
	Move-ClusterGroup  -Name $NewAndNextNode[1] -Node $NewAndNextNode[0];

	"Cluseter Group $($NewAndNextNode[1]) failover completed at Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath
	
}


function determineFailOverNode($CurrentNode)
{
	$AvilableNodes=((Get-ClusterNode |Select-Object -Property Name | Format-Table -HideTableHeaders | Out-String).Trim()).Split([Environment]::NewLine).Trim();
	
	
		if($AvilableNodes[0] -eq $CurrentNode )
		{
			return $AvilableNodes[2];
		}
		else
		{
			return $AvilableNodes[0];
		}

	
}

function startClusterGroup($ClusterGroupName)
{
	"Cluseter Group $ClusterGroupName is starting please wait..";
	"Cluseter Group $ClusterGroupName is starting at Date and time is: $((Get-Date).ToString())" |  Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath

	$ClusterStatus=(Start-ClusterGroup  -Name $ClusterGroupName |Select-Object -Property State | Format-Table -HideTableHeaders| Out-String).Trim();

	if($ClusterStatus -eq "Failed")
	{
		"Unable to start Cluster Group $ClusterGroupName trying to bring up the resources"
		"Unable to start Cluster Group $ClusterGroupName trying to bring up the resources"| Add-Content $OutputFilePath
		bringClusterResourceUp($ClusterGroupName);

		
	}
	else
	{
		"Cluster Group $ClusterGroupName is up and running"
		"Cluster Group $ClusterGroupName is up and running"| Add-Content $OutputFilePath
	}
	"Cluseter Group $ClusterGroupName has been started at Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath
}

function bringClusterResourceUp($ClusterGroupName)
{
	"Bringing up the resource of cluseter Group $ClusterGroupName at Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath
	$CluserResources=(Get-ClusterGroup -Name $ClusterGroupName | Get-ClusterResource | Select-Object -Property Name | Format-Table -HideTableHeaders | Out-String).Trim().Split([Environment]::NewLine).Trim();
	for($i=0;$i -lt $CluserResources.length; $i=$i+2)
	{
		$StartStatus=(Start-ClusterResource -Name $CluserResources[$i] |Select-Object -Property State | Format-Table -HideTableHeaders| Out-String).Trim();
		if($StartStatus -eq "Online")
		{
			"Cluster resource $($CluserResources[$i]) is Online and running"
			"Cluster resource $($CluserResources[$i]) is Online and running"| Add-Content $OutputFilePath
		}
		else
		{
			"Cluster resource $($CluserResources[$i]) is offline please check"
			"Cluster Group $ClusterGroupName is failed to start please check manually"
			"Cluster resource $($CluserResources[$i]) is offline please check"| Add-Content $OutputFilePath
			"Cluster Group $ClusterGroupName is failed to start please check manually"| Add-Content $OutputFilePath

			exit;
		
		}

	}
	"*******************************************************************" | Add-Content $OutputFilePath
	

}

function bringClusterResourceDown($ClusterGroupName)
{
	"Bringing down the resource of cluseter Group $ClusterGroupName at Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath
	$CluserResources=(Get-ClusterGroup -Name $ClusterGroupName | Get-ClusterResource | Select-Object -Property Name | Format-Table -HideTableHeaders | Out-String).Trim().Split([Environment]::NewLine).Trim();
	for($i=0;$i -lt $CluserResources.length; $i=$i+2)
	{
		$StartStatus=(Stop-ClusterResource -Name $CluserResources[$i] |Select-Object -Property State | Format-Table -HideTableHeaders| Out-String).Trim();
		if($StartStatus -eq "Offline")
		{
			"Cluster resource $($CluserResources[$i]) is Offline"
			"Cluster resource $($CluserResources[$i]) is Offline"| Add-Content $OutputFilePath
		}
		else
		{
			"Cluster resource $($CluserResources[$i]) is not stopped please check"
			"Cluster Group $ClusterGroupName is failed to stop please check manually"
			"Cluster resource $($CluserResources[$i]) is offline please check"| Add-Content $OutputFilePath
			"Cluster Group $ClusterGroupName is failed to stop please check manually"| Add-Content $OutputFilePath

			exit;
		
		}

	}
	"*******************************************************************" | Add-Content $OutputFilePath
	

}


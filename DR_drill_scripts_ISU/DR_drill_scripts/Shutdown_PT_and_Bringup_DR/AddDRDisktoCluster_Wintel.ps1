$OutputFilePath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs\OUTPUT_DR_LOG.txt";
"Add DR disk to cluster started: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath

Write-host "*******************************************Addition of DR disks to cluster is started***********************************" -ForegroundColor Green
if(Test-Path "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\TempDRDisks.txt")
{
  Remove-Item "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\TempDRDisks.txt"
  New-Item "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\TempDRDisks.txt" -ItemType file
}
Else
{New-Item "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\TempDRDisks.txt" -ItemType file}
$server = hostname
$nodes = Get-ClusterNode
foreach($node in $nodes)
{
 if($node.name -match $server)
 { 
  Update-HostStorageCache -ErrorAction SilentlyContinue
 }
 Else
 {
   $session = New-CimSession -ComputerName $node.Name
   Update-HostStorageCache -CimSession $session -ErrorAction SilentlyContinue
  }
 }

$ClusterName = "GLAISUCLST10"
$temp = "" | Select ClusterDiskNumber, VolumeName, DriveLetter, LUNid, PhysicalDiskNumber, SizeinGB, OwnerNode, ClusterGroup
$nodes = Get-ClusterNode -Cluster $ClusterName
$node1 = $nodes[0].Name
$node2 = $nodes[1].Name
$disks = Get-ClusterAvailableDisk | Add-ClusterDisk
foreach($disk1 in $disks)
{

 Move-ClusterResource -Name $disk1.Name -Group "SQL Server (MSSQLSERVER)"
 $DiskResourceName = $disk1.Name
 $DiskResourceName | Out-File "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\TempDRDisks.txt" -Append
 $DiskResource = gwmi MSCluster_Resource -Namespace root/mscluster | ?{ $_.Name -eq $DiskResourceName }
 $Disk = gwmi -Namespace root/mscluster -Query “Associators of {$DiskResource} Where ResultClass=MSCluster_Disk”
 $Partition = gwmi -Namespace root/mscluster -Query “Associators of {$Disk} Where ResultClass=MSCluster_DiskPartition”
 $temp.ClusterDiskNumber = $DiskResourceName
 $temp.VolumeName = $Partition.VolumeLabel
 if($Partition.MountPoints -ne $null){$temp.DriveLetter = $Partition.MountPoints[0]} Else{$temp.DriveLetter = "Not found"}
 $temp.LUNid = $Disk.ScsiLun
 $temp.OwnerNode = $Disk1.OwnerNode
 $temp.PhysicalDiskNumber = $Disk.Number
 $size = ($Partition.TotalSize)/1024
 $temp.SizeinGB = $size
 $temp.ClusterGroup = $Disk1.OwnerGroup
 $temp
 $server1 = hostname
 if($temp.OwnerNode -match $server1)
 {
  
  if(($temp.DriveLetter -notmatch "IP1Data") -and ($temp.DriveLetter -ne "Not found") -and ($temp.VolumeName -ne "SAP Server LogFile"))
  {
  
   $accesspath = "G:\"+$temp.VolumeName
   Write-Host "Access path $accesspath" -ForegroundColor Green
   
   Add-PartitionAccessPath -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $accesspath
   Remove-PartitionAccessPath -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $temp.DriveLetter
  }
  Else
  {
   if(($temp.DriveLetter -notmatch "IP1Data") -and ($temp.DriveLetter -eq "Not found") -and ($temp.VolumeName -ne "SAP Server LogFile"))
   {
   $accesspath = "G:\"+$temp.VolumeName
   Write-Host "Access path $accesspath" -ForegroundColor Green
   Add-PartitionAccessPath -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $accesspath
   }
  }
 }
 Else
 {
   $session1 = New-CimSession -ComputerName $temp.OwnerNode
   if(($temp.DriveLetter -notmatch "IP1Data") -and ($temp.DriveLetter -ne "Not found") -and ($temp.DriveLetter -ne "SAP Server LogFile"))
  {
   $accesspath = "G:\"+$temp.VolumeName
   Add-PartitionAccessPath -CimSession $session1 -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $accesspath
   Remove-PartitionAccessPath -CimSession $session1 -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $temp.DriveLetter
  }
  Else
  {
   if(($temp.DriveLetter -notmatch "IP1Data") -and ($temp.DriveLetter -eq "Not found") -and ($temp.DriveLetter -ne "SAP Server LogFile"))
   {
   $accesspath = "G:\"+$temp.VolumeName
   Add-PartitionAccessPath -CimSession $session1 -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $accesspath
   }
  }
    if(($temp.VolumeName -eq "SAP Server LogFile") -and ($temp.DriveLetter -eq "Not found"))
  {Add-PartitionAccessPath -CimSession $session1 -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath "F:\"} 

 }

Get-ClusterResource "SQL Server" | Add-ClusterResourceDependency -Resource $disk1.Name
 
} 

"Add DR disk to cluster finished: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
"Add DR disk to cluster finished"

$var = new-object -comobject wscript.shell;
$intAnswer = $var.popup("Do you want to proceed with DR database attach?",0,"SICK succeeded",48+4)
If ($intAnswer -ne 6) 
{

		Get-WmiObject -Query "select * from win32_process where name = 'powershell.exe'" | Remove-WmiObject
}
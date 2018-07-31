$OutputFilePath="E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Logs\OUTPUT_DR_LOG.txt";
"*******************************************************************" | Add-Content $OutputFilePath
"PT Disk addition to cluster started: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath

Write-host "*******************************************Addition of PT disks to cluster is startedd***********************************" -ForegroundColor Green

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


$temp = "" | Select ClusterDiskNumber, VolumeName, DriveLetter, LUNid, PhysicalDiskNumber, SizeinGB, OwnerNode, ClusterGroup

$disks = Get-ClusterAvailableDisk | Add-ClusterDisk
<#foreach($disk in $disks)
{
 Move-ClusterResource -Name $disk.Name -Group "SQL Server (SQLSVRIPT)"
 Get-ClusterResource "SQL Server (SQLSVRIPT)" | Add-ClusterResourceDependency -Resource $disk.Name
} #>




foreach($disk1 in $disks)
{

 Move-ClusterResource -Name $disk1.Name -Group "SQL Server (SQLSVRCPT)"
 $DiskResourceName = $disk1.Name
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
  
  if(($temp.DriveLetter -notmatch "CPTData") -and ($temp.DriveLetter -ne $null) -and ($temp.VolumeName -ne "CP1LOG"))
  {
   $st = $temp.VolumeName
   $st1 = $st.replace("CP1DATA","")
   $accesspath = "R:\"+"CPTDATA"+$st1
   Write-Host "Access path $accesspath" -ForegroundColor Green
   
   Add-PartitionAccessPath -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $accesspath
   Remove-PartitionAccessPath -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $temp.DriveLetter -ErrorAction SilentlyContinue
  }
  Else
  {
   if(($temp.DriveLetter -notmatch "CPTData") -and ($temp.DriveLetter -eq $null) -and ($temp.VolumeName -ne "CP1LOG"))
   {
   $st = $temp.VolumeName
   $st1 = $st.replace("CP1DATA","")
   $accesspath = "R:\"+"CPTDATA"+$st1
   Write-Host "Access path $accesspath" -ForegroundColor Green
   Add-PartitionAccessPath -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $accesspath
   }
  }
    if(($temp.VolumeName -eq "CP1LOG") -and ($temp.DriveLetter -eq "Not found"))
  {Add-PartitionAccessPath -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath "Y:\"}
 }
 Else
 {
   $session1 = New-CimSession -ComputerName $temp.OwnerNode
   if(($temp.DriveLetter -notmatch "CPTData") -and ($temp.DriveLetter -ne $null) -and ($temp.DriveLetter -ne "CP1LOG"))
  {
   
   $st = $temp.VolumeName
   $st1 = $st.replace("CP1DATA","")
   $accesspath = "R:\"+"CPTDATA"+$st1
   Add-PartitionAccessPath -CimSession $session1 -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $accesspath
   Remove-PartitionAccessPath -CimSession $session1 -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $temp.DriveLetter -ErrorAction SilentlyContinue
  }
  Else
  {
   if(($temp.DriveLetter -notmatch "CPTData") -and ($temp.DriveLetter -eq $null) -and ($temp.DriveLetter -ne "CP1LOG"))
   {
   $st = $temp.VolumeName
   $st1 = $st.replace("CP1DATA","")
   $accesspath = "R:\"+"CPTDATA"+$st1
   Add-PartitionAccessPath -CimSession $session1 -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath $accesspath
   }
  }
  if(($temp.VolumeName -eq "CP1LOG") -and ($temp.DriveLetter -eq "Not found"))
  {Add-PartitionAccessPath -CimSession $session1 -DiskNumber $temp.PhysicalDiskNumber -PartitionNumber 2 -AccessPath "Y:\"}

 }

Get-ClusterResource "SQL Server (SQLSVRCPT)" | Add-ClusterResourceDependency -Resource $disk1.Name
 
} 

$var = new-object -comobject wscript.shell;
$intAnswer = $var.popup("Do you want to proceed with DR database attach?",0,"SICK succeeded",48+4)
If ($intAnswer -ne 6) 
{

		Get-WmiObject -Query "select * from win32_process where name = 'powershell.exe'" | Remove-WmiObject
}

"PT Disk addition to cluster finished: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
"PT Disk addition to cluster finished"

$var = new-object -comobject wscript.shell;
$intAnswer = $var.popup("Do you want to proceed PT system Up?",0,"PT system Starting",48+4)
If ($intAnswer -ne 6) 
{

		Get-WmiObject -Query "select * from win32_process where name = 'powershell.exe'" | Remove-WmiObject
}
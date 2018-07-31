$OutputFilePath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs\OUTPUT_DR_LOG.txt";
"PT unmap DR Map Storage task started: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
Write-host "*******************************************PT LUN unmapping and DR LUN mapping activity is started***********************************" -ForegroundColor Green

# Connect to FlashArray.
if((Test-Path "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\ClonedVolumes.txt") -match "False")
{
 New-Item "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\ClonedVolumes.txt" -ItemType file -Force
}
Else{
Remove-Item "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\ClonedVolumes.txt"
New-Item "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\ClonedVolumes.txt" -ItemType file -Force
}
#create secure password file
#$credential = Get-Credential
#$credential.Password | ConvertFrom-SecureString | Set-Content "E:\DR_drill_scripts\PureSecureCredential.txt"
 

$encrypted = Get-Content "E:\DR_drill_scripts\PureSecureCredential.txt" | ConvertTo-SecureString
$credential1 = New-Object System.Management.Automation.PsCredential("pureuser", $encrypted)
$f = New-PfaArray -EndPoint glapsa001.agl.int -Credentials $credential1 -IgnoreCertificateError
#Store the existing PT volumes mapped.
$volumestoRemove = @()
$volumestoRemove +="iptdata1"
$volumestoRemove +="iptdata2"
$volumestoRemove +="iptdata3"
$volumestoRemove +="iptdata4"
$volumestoRemove +="iptdata5"
$volumestoRemove +="iptdata6"
$volumestoRemove +="iptdata7"
$volumestoRemove +="iptdata8"
$volumestoRemove +="iptlog"
$PHostGroupVolumes=Get-PfaHostGroupVolumeConnections -Array $f -HostGroupName "SQLCluster20"
$PHostGroupVolumes
$HostGroup="SQLCluster20"
ForEach ($PHostGroupVolume in $PHostGroupVolumes)
{
 if($volumestoRemove.Contains($PHostGroupVolume.vol ))
 { 
    Remove-PfaHostGroupVolumeConnection -Array $f -VolumeName $PHostGroupVolume.vol -HostGroupName $HostGroup 
    }
}


$PGroupSnapshotset = @()
$allsnapshots =  Get-PfaProtectionGroupSnapshots -Array $f -Name "glbpsa001:SAPReplication"
foreach($snapshot in $allsnapshots)
{
  If (([DateTime]($snapshot.created) -gt (get-date).AddMinutes(-31)) -and ([DateTime]($snapshot.created) -lt (get-date).AddMinutes(-1) ) )
  {
   $latestsnapshot = $snapshot.Name
  }
 }
 

 $snapshotvolumes = Get-PfaSnapshotSpaceMetrics -Array $f -Name * | Where{$_.name -match $latestsnapshot}

 foreach($snapshotvolume in $snapshotvolumes)
 {
   if(($snapshotvolume.name -match "ip1") -and ($snapshotvolume.name -notmatch "interface"))
   {
    $PGroupSnapshotset +=Get-PfaVolumeSnapshots -Array $f -VolumeName $snapshotvolume.name
    #$PGroupSnapshotset
   }
}

#$PGroupSnapshotset
 foreach($PGroupSnapshot in $PGroupSnapshotset)
 {
    $CloneName = $PGroupSnapshot.Name + "_Clone"
    $clone1 = $CloneName.Replace(":","")
    $clone2 = $clone1.Replace(".","")
    $clone2 | Out-File "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\ClonedVolumes.txt" -Append
    New-PfaVolume -Array $f -VolumeName $clone2 -Source $PGroupSnapshot.name
    New-PfaHostGroupVolumeConnection -Array $f -HostGroupName $HostGroup -VolumeName $clone2
 }


"PT unmap DR Map Storage task finished: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
"PT unmap DR Map Storage task finished"

$var = new-object -comobject wscript.shell;
$intAnswer = $var.popup("Do you want to proceed with Wintel DR map task?",0,"SICK succeeded",48+4)
If ($intAnswer -ne 6) 
{

		Get-WmiObject -Query "select * from win32_process where name = 'powershell.exe'" | Remove-WmiObject
}
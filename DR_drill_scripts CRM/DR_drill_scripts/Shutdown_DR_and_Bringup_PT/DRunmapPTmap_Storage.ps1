$OutputFilePath="E:\DR_drill_scripts\Shutdown_DR_and_Bringup_PT\Logs\OUTPUT_DR_LOG.txt";
"*******************************************************************" | Add-Content $OutputFilePath
"PT LUN mapping has been started: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath

Write-host "*******************************************DR LUN unmapping and PT LUN mapping activity is started***********************************" -ForegroundColor Green

# Connect to FlashArray.
$encrypted = Get-Content "E:\DR_drill_scripts\PureSecureCredential.txt" | ConvertTo-SecureString
$credential1 = New-Object System.Management.Automation.PsCredential("pureuser", $encrypted)
#create secure password file
#$credential = Get-Credential
#$credential.Password | ConvertFrom-SecureString | Set-Content "E:\DR_drill_scripts\PureSecureCredential.txt"
 

$f = New-PfaArray -EndPoint glapsa001.agl.int -Credentials $credential1 -IgnoreCertificateError
#Store the existing PT volumes mapped.
$volumestoRemove = Get-Content "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\ClonedVolumes.txt"
$PHostGroupVolumes=Get-PfaHostGroupVolumeConnections -Array $f -HostGroupName "SQLCluster21"
$PHostGroupVolumes
$HostGroup="SQLCluster21"
ForEach ($PHostGroupVolume in $PHostGroupVolumes)
{
 if($volumestoRemove.Contains($PHostGroupVolume.vol ))
 { 
    Remove-PfaHostGroupVolumeConnection -Array $f -VolumeName $PHostGroupVolume.vol -HostGroupName $HostGroup 
    }
}

#Store the existing PT volumes mapped.
$volumestoAddPT = @()
$volumestoAddPT +="cptdata1"
$volumestoAddPT +="cptdata2"
$volumestoAddPT +="cptdata3"
$volumestoAddPT +="cptdata4"
$volumestoAddPT +="cptdata5"
$volumestoAddPT +="cptdata6"
$volumestoAddPT +="cptdata7"
$volumestoAddPT +="cptdata8"
$volumestoAddPT +="cptlog"
ForEach ($volume in $volumestoAddPT)
{
 New-PfaHostGroupVolumeConnection -Array $f -VolumeName $volume -HostGroupName $HostGroup
}


"PT LUN mapping has been finished: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
"PT LUN mapping has been finished"

$var = new-object -comobject wscript.shell;
$intAnswer = $var.popup("Do you want to proceed with PT disk mapping Wintel task?",0,"PT Mapping Wintel",48+4)
If ($intAnswer -ne 6) 
{

		Get-WmiObject -Query "select * from win32_process where name = 'powershell.exe'" | Remove-WmiObject
}
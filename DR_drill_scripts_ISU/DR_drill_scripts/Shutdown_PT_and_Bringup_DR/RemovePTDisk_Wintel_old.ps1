$OutputFilePath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs\OUTPUT_DR_LOG.txt";
"Remove PT disk has been started: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
"Remove PT disk has been started"
if(Test-Path "E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Temp.csv")
{Remove-Item E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Temp.csv}
Else 
{
if((Test-Path E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR) -match "False"){mkdir E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR}
}

$ClusterName = "GLAISUCLST10"
$r = Get-Cluster $ClusterName
#If($r -eq $null){Write-Host "The cluster name you entered is incorrect. Please provide correct cluster name"; Exit}

$ClusterDisks = Get-ClusterResource -Cluster $ClusterName | Where{$_.Name -match "Cluster Disk"} | Sort-Object
$temp = "" | Select ClusterDiskNumber, VolumeName, DriveLetter, LUNid, PhysicalDiskNumber, SizeinGB, OwnerNode, ClusterGroup
$nodes = Get-ClusterNode -Cluster $ClusterName
$node1 = $nodes[0].Name
$node2 = $nodes[1].Name
foreach($ClusterDisk in $ClusterDisks)
{
 $DiskResourceName = $ClusterDisk.Name
 $DiskResource = gwmi -ComputerName $node1 MSCluster_Resource -Namespace root/mscluster | ?{ $_.Name -eq $DiskResourceName }
 $Disk = gwmi -ComputerName $node1 -Namespace root/mscluster -Query “Associators of {$DiskResource} Where ResultClass=MSCluster_Disk”
 $Partition = gwmi -ComputerName $node1 -Namespace root/mscluster -Query “Associators of {$Disk} Where ResultClass=MSCluster_DiskPartition”
 $temp.ClusterDiskNumber = $DiskResourceName
 $temp.VolumeName = $Partition.VolumeLabel
 if($Partition.MountPoints -ne $null){$temp.DriveLetter = $Partition.MountPoints[0]} Else{$temp.DriveLetter = "Not found"}
 $temp.LUNid = $Disk.ScsiLun
 $temp.OwnerNode = $ClusterDisk.OwnerNode
 $temp.PhysicalDiskNumber = $Disk.Number
 $size = ($Partition.TotalSize)/1024
 $temp.SizeinGB = $size
 $temp.ClusterGroup = $ClusterDisk.OwnerGroup
 $temp |Export-csv E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Temp.csv -NoTypeInformation -Append
 $temp.ClusterDiskNumber = $null
 $temp.VolumeName = $null
 $temp.DriveLetter = $null
 $temp.LUNid = $null
 $temp.OwnerNode = $null
 $temp.PhysicalDiskNumber = $null
 $temp.SizeinGB = $null
 $temp.ClusterGroup = $null
} 

$data = Import-csv E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Temp.csv
$data | FT
$data.Count

$head = @"
<style>
table {
    font-family: arial, sans-serif;
    border-collapse: collapse;
    width: 100%;
}

td, th {
    border: 1px solid #dddddd;
    text-align: left;
    padding: 8px;
}

tr:nth-child(even) {
    background-color: #dddddd;
}
</style>
"@

$bodyformat = '<h1>Cluster Disk information</h1>'
Import-csv E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Temp.csv | ConvertTo-Html -head $head -body $bodyformat | Out-File E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Temp.html

    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$XAML = @'
    <Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Cluster Disk information" WindowStartupLocation="CenterScreen">

            <WebBrowser Name="WebBrowser"></WebBrowser>

    </Window>
'@

    #Read XAML
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
    #===========================================================================
    # Store Form Objects In PowerShell
    #===========================================================================
    $WebBrowser = $Form.FindName("WebBrowser")

    $WebBrowser.Navigate("E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Temp.html")

    $Form.ShowDialog()

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Data Entry Form'
$form.Size = New-Object System.Drawing.Size(900,600)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(300,450)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(500,450)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(380,20)
$label.Text = 'Please select corresponding disk to be removed from cluster'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(800,100)

$listBox.SelectionMode = 'MultiExtended'
#$data.count
for ($i=0; $i –lt $data.count; $i++)
{
 $t1 = $data.ClusterDiskNumber[$i]
[void] $listBox.Items.Add("$t1")
}

$listBox.Height = 400
$form.Controls.Add($listBox)
$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $disks = $listBox.SelectedItems
 #   $disks
}
$dependencyvalues = @()
$cdisk = $null
$Disks
$RemovedLuns = @()
foreach($cdisk in $disks)
{
$cdisk
 $DiskResource1 = gwmi -ComputerName $node1 MSCluster_Resource -Namespace root/mscluster | ?{ $_.Name -eq $cdisk }
 $Disk1 = gwmi -ComputerName $node1 -Namespace root/mscluster -Query “Associators of {$DiskResource1} Where ResultClass=MSCluster_Disk”
 $lunid = $disk1.ScsiLun
 Get-ClusterResource "SQL Server (SQLSVRIPT)" | Remove-ClusterResourceDependency -Resource $cdisk
 Get-ClusterResource -Cluster $ClusterName $cdisk | Suspend-ClusterResource
 Get-ClusterResource -Cluster $ClusterName $cdisk | Stop-ClusterResource -IgnoreLocked
 Get-ClusterResource -Cluster $ClusterName $cdisk | Move-ClusterResource -Group "Available Storage"
 Get-ClusterResource -Cluster $ClusterName $cdisk | Remove-ClusterResource -Force
 $RemovedLuns +=$lunid
 Write-Host "$lunid has been offlined on the cluster nodes"
}

$RemovedLuns

"Remove PT disk has been finished: $((Get-Date).ToString())" | Add-Content $OutputFilePath
"*******************************************************************" | Add-Content $OutputFilePath
"Remove PT disk has been finished"

$var = new-object -comobject wscript.shell;
$intAnswer = $var.popup("Do you want to proceed with storage task?",0,"SICK succeeded",48+4)
If ($intAnswer -ne 6) 
{

		Get-WmiObject -Query "select * from win32_process where name = 'powershell.exe'" | Remove-WmiObject
}
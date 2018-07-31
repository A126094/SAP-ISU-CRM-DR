$OutputFilePath="E:\DR_drill_scripts\Shutdown_PT_and_Bringup_DR\Logs\OUTPUT_DR_LOG.txt";
function StopSAPSystem 
{
	"*******************************************************************" | Add-Content $OutputFilePath
	"SAP system is shutting down and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath
	C:\PROGRA~1\SAP\hostctrl\exe\sapcontrol.exe -nr 31 -prot PIPE -function GetSystemInstanceList | Select-Object -skip 5 | 
	%{
		$f = $_.split(‘,’);”host: $($f[0]) number: $($f[1])”;
		C:\PROGRA~1\SAP\hostctrl\exe\sapcontrol.exe -prot PIPE -nr $f[1] -host $f[0] -function InstanceStop $f[0] $f[1]
	 }
	checkStopStatus;
	"SAP system has been stopped successfully date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath
}

function StartSAPSystem
{
	"*******************************************************************" | Add-Content $OutputFilePath
	"SAP system is starting Date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath
	C:\PROGRA~1\SAP\hostctrl\exe\sapcontrol.exe -nr 01 -prot PIPE -function GetSystemInstanceList | Select-Object -skip 5 | 
	%{
		$f = $_.split(‘,’);”host: $($f[0]) number: $($f[1])”;
		C:\PROGRA~1\SAP\hostctrl\exe\sapcontrol.exe -prot PIPE -nr $f[1] -host $f[0] -function InstanceStart $f[0] $f[1]
	 }

	ShowSystemStatus;
	"SAP system has been started successfully date and time is: $((Get-Date).ToString())" | Add-Content $OutputFilePath
	"*******************************************************************" | Add-Content $OutputFilePath
}


function ShowSystemStatus
{
	$SystemStatus="Up";
	C:\PROGRA~1\SAP\hostctrl\exe\sapcontrol.exe -nr 01 -prot PIPE -function GetSystemInstanceList | Select-Object -skip 5| 
	%{
		$f = $_.split(‘,’);”host: $($f[0]) number: $($f[1])”;
		C:\PROGRA~1\SAP\hostctrl\exe\sapcontrol.exe -prot PIPE -nr $f[1] -host $f[0] -function GetProcessList | 
		Select-Object -skip 11
		if($lastexitcode -eq 3)
		{

     			“Instance $($f[1]) on host $($f[0]) is fine here”

		}

		else

		{

     			“Instance $($f[1]) on host $($f[0]) is not started please wait..”
			$SystemStatus="Down";

		}
	}
	if ($SystemStatus -eq "Down")
	{
		$SystemStatus="Down";
		Start-Sleep -s 10;
		$System_Start_Stop_Time=$System_Start_Stop_Time+10;
		Clear-Host;
		if($System_Start_Stop_Time -gt 300)
		{
			$var = new-object -comobject wscript.shell;
			$intAnswer = $var.popup("5 mins past do you want to wait?",0,"Action stopped",48+4);
			if ($intAnswer -eq 6) 
			{
				$System_Start_Stop_Time=0;
			} 
			else 
			{
				exit;
			}
		}
		ShowSystemStatus;
	}
	else
	{
		"SYSTEM IS UP AND RUNNING";
		"SYSTEM IS UP AND RUNNING" | Add-Content $OutputFilePath
	}

}


function checkStopStatus
{

	$SystemStatus="Down";
	C:\PROGRA~1\SAP\hostctrl\exe\sapcontrol.exe -nr 31 -prot PIPE -function GetSystemInstanceList | Select-Object -skip 5| 
	%{
		$f = $_.split(‘,’);”host: $($f[0]) number: $($f[1])”;
		C:\PROGRA~1\SAP\hostctrl\exe\sapcontrol.exe -prot PIPE -nr $f[1] -host $f[0] -function GetProcessList | 
		Select-Object -skip 11
		if($lastexitcode -eq 4)
		{

     			“Instance $($f[1]) on host $($f[0]) has been stopped successfully”

		}

		else

		{

     			“Instance $($f[1]) on host $($f[0]) is not stopped please wait..”
			$SystemStatus="Up";

		}
	}
	if ($SystemStatus -eq "Up")
	{
		$SystemStatus="Up";
		Start-Sleep -s 10;
		$System_Start_Stop_Time=$System_Start_Stop_Time+10;
		Clear-Host;
		if($System_Start_Stop_Time -gt 300)
		{
			$var = new-object -comobject wscript.shell;
			$intAnswer = $var.popup("5 mins past do you want to wait?",0,"Action stopped",48+4)
			if ($intAnswer -eq 6) 
			{
				$System_Start_Stop_Time=0;
			} 
			else 
			{
				exit;
			}
		}
		checkStopStatus;
	}
	else
	{
		"SYSTEM IS DOWN NOW";
		"SYSTEM IS DOWN NOW" | Add-Content $OutputFilePath
	}



}

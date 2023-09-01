Param (
	[Parameter(Position=0,mandatory=$true)]		[String]$AlertID,
	[Parameter(Position=1,mandatory=$true)]		[String]$AlertSourceKey
)

# Configuration
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Import-Module OperationsManager
if ($?){write-host -ForegroundColor Green "Module has been successfully imported.";echo ""; echo ""} 
else {
    if (!$scomModulePath){
       Write-Host "Attempting to locate SCOM installation path."; echo ""; echo ""
       if (Test-Path "C:\Program Files\Microsoft System Center 2012"){$scomModulePath = "C:\Program Files\Microsoft System Center 2012\Operations Manager\Powershell\OperationsManager\OperationsManager.psm1"; Write-Host -NoNewline "Trying to locate 'C:\Program Files\Microsoft System Center 2012'     :  "; Write-Host -ForegroundColor Green "SCOM 2012 Install path found"}
       if (!$scomModulePath){Write-Host -NoNewline "Trying to locate 'C:\Program Files\Microsoft System Center 2012'     :  "; Write-Host -ForegroundColor Yellow "SCOM 2012 Install path not found"}
       if (Test-Path "C:\Program Files\Microsoft System Center 2012 R2"){$scomModulePath = "C:\Program Files\Microsoft System Center 2012 R2\Operations Manager\Powershell\OperationsManager\OperationsManager.psm1"; Write-Host -NoNewline "Trying to locate 'C:\Program Files\Microsoft System Center 2012 R2'  :  "; Write-Host -ForegroundColor Green "SCOM 2012 R2 Install path found"}
       if (!$scomModulePath){Write-Host -NoNewline "Trying to locate 'C:\Program Files\Microsoft System Center 2012 R2'  :  "; Write-Host -ForegroundColor Yellow "SCOM 2012 R2 Install path not found"}
       if (Test-Path "C:\Program Files\Microsoft System Center 2016"){$scomModulePath = "C:\Program Files\Microsoft System Center 2016\Operations Manager\Powershell\OperationsManager\OperationsManager.psm1"; Write-Host -NoNewline "Trying to locate 'C:\Program Files\Microsoft System Center 2016'     :  "; Write-Host -ForegroundColor Green "SCOM 2016 Install path found"}
       if (!$scomModulePath){Write-Host -NoNewline "Trying to locate 'C:\Program Files\Microsoft System Center 2016'     :  "; Write-Host -ForegroundColor Yellow "SCOM 2016 Install path not found"}
       if (Test-Path "C:\Program Files\Microsoft System Center 2019"){$scomModulePath = "C:\Program Files\Microsoft System Center 2019\Operations Manager\Powershell\OperationsManager\OperationsManager.psm1"; Write-Host -NoNewline "Trying to locate 'C:\Program Files\Microsoft System Center 2019'     :  "; Write-Host -ForegroundColor Green "SCOM 2019 Install path found"}
       if (!$scomModulePath){Write-Host -NoNewline "Trying to locate 'C:\Program Files\Microsoft System Center 2019'     :  "; Write-Host -ForegroundColor Yellow "SCOM 2019 Install path not found"}
       if (Test-Path "C:\Program Files\Microsoft System Center"){$scomModulePath = "C:\Program Files\Microsoft System Center\Operations Manager\Powershell\OperationsManager\OperationsManager.psm1"; Write-Host -NoNewline "Trying to locate 'C:\Program Files\Microsoft System Center'          :  "; Write-Host -ForegroundColor Green "SCOM Install path found"}
       if (!$scomModulePath){Write-Host -NoNewline "Trying to locate 'C:\Program Files\Microsoft System Center'          :  "; Write-Host -ForegroundColor Yellow "SCOM Install path not found"}
    }
    else {Import-Module $scomModulePath}
    echo ""; echo ""; Write-host -NoNewline "Attempting to import Operations Manager Powershell Module            :  "
    Import-Module $scomModulePath
    if ($?){write-host -ForegroundColor Green "Module has been successfully imported.";echo ""; echo ""} else {echo ""; echo ""; write-host -NoNewline -ForegroundColor Yellow "Could not improt module try specifying it using ";write-host -NoNewline -ForegroundColor Cyan "-scomModulePath <path>";write-host -ForegroundColor yellow " when starting this script.";exit}
}

$Url = "https://api.ilert.com/api/v1/events/ms-scom/" + $AlertSourceKey

# Receive Alert Information
$Alert = Get-SCOMAlert -id $AlertID

# Determine the Event Type
switch ($Alert.ResolutionState){
	0		{$EventType="alert"}
	249		{$EventType="accepted"}
	254		{$EventType="resolved"}
	255		{$EventType="resolved"}
	default		{$EventType="alert"}
}

# Determine the Severity
switch ($Alert.Severity){
	"Information"	{$Severity="INFO"}
	"Warning"	{$Severity="WARNING"}
	"Error"		{$Severity="ERROR"}
	"Critical"	{$Severity="CRITICAL"}
	default		{$Severity="CRITICAL"}
}

[String]$Hostname = if($Alert.NetbiosComputerName){$Alert.NetbiosComputerName}
elseif($Alert.MonitoringObjectPath){$Alert.MonitoringObjectFullName}
elseif($Alert.MonitoringObjectName){$Alert.MonitoringObjectName}
else {"Hostname Not Available"}

[String]$AlertSummary = ("["+ $Severity + "]: " + $Hostname + " - " + $Alert.Name).Trim()
[String]$AlertDescription = $Alert.Description

[String]$Priority	= if ($Alert.Priority){$Alert.Priority} else {"NONE"}
[String]$CustomField1	= if ($Alert.CustomField1){$Alert.CustomField1} else {"NONE"}
[String]$CustomField2	= if ($Alert.CustomField2){$Alert.CustomField2} else {"NONE"}
[String]$CustomField3	= if ($Alert.CustomField3){$Alert.CustomField3} else {"NONE"}
[String]$CustomField4	= if ($Alert.CustomField4){$Alert.CustomField4} else {"NONE"}
[String]$CustomField5	= if ($Alert.CustomField5){$Alert.CustomField5} else {"NONE"}
[String]$CustomField6	= if ($Alert.CustomField6){$Alert.CustomField6} else {"NONE"}
[String]$CustomField7	= if ($Alert.CustomField7){$Alert.CustomField7} else {"NONE"}
[String]$CustomField8	= if ($Alert.CustomField8){$Alert.CustomField8} else {"NONE"}
[String]$CustomField9	= if ($Alert.CustomField9){$Alert.CustomField9} else {"NONE"}
[String]$CustomField10	= if ($Alert.CustomField10){$Alert.CustomField10} else {"NONE"}

$AlertPayload = @{
	apiKey		= $AlertSourceKey
	eventType	= $EventType
	alertId		= $AlertID.Trim('{}')
	payload = @{
		summary		= $AlertSummary
		description	= $AlertDescription
		priority	= $Priority
		severity	= $Severity
		source		= $Hostname
		timestamp	= $Alert.TimeRaised.ToString("o")
		customDetails	= @{
			CustomField1	= $CustomField1
			CustomField2	= $CustomField2
			CustomField3	= $CustomField3
			CustomField4	= $CustomField4
			CustomField5	= $CustomField5
			CustomField6	= $CustomField6
			CustomField7	= $CustomField7
			CustomField8	= $CustomField8
			CustomField9	= $CustomField9
			CustomField10	= $CustomField10
		}
	}
}

$json = ConvertTo-Json -InputObject $AlertPayload

$logEvents = "C:\scripts\ilert\ilert_log.txt"

# Send Request to iLert
$LogMtx = New-Object System.Threading.Mutex($False, "LogMtx")
$LogMtx.WaitOne() | Out-Null

try {
    Invoke-RestMethod	-Method Post `
    					-ContentType "application/json; charset=utf-8" `
    					-Body $json `
    					-Uri $Url `
    					| Out-File $logEvents -Append
}

catch {
    $dateTime = Get-Date -UFormat "%m/%d/%Y %R"
    out-file -InputObject "[$dateTime]: Exception Type: $($_.Exception.GetType().FullName) Exception Message: $($_.Exception.Message) AlertID = $AlertID Alert = $Alert ResolutionState = $Alert.ResolutionState Summary = $AlertSummary" -FilePath $logEvents -Append
}

finally {
	$LogMtx.ReleaseMutex() | Out-Null
}

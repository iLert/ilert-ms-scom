Param (
	[Parameter(Position=0,mandatory=$true)]		[String]$AlertID,
	[Parameter(Position=1,mandatory=$true)]	    [String]$AlertSourceKey
)

# Configuration
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Import-Module "C:\Program Files\Microsoft System Center 2016\Operations Manager\Powershell\OperationsManager\OperationsManager.psm1"
$Url = "https://api.ilert.com/api/v1/events/ms-scom/" + $AlertSourceKey

# Receive Alert Information
$Alert = Get-SCOMAlert -id $AlertID

# Determine the Event Type
switch ($Alert.ResolutionState){
        0       	{$EventType="alert"}
        249         {$EventType="accepted"}
        254		    {$EventType="resolved"} 
        255     	{$EventType="resolved"}
        default 	{$EventType="alert"}
    }

# Determine the Severity
switch ($Alert.Severity){
	"Information"	{$Severity="INFO"}
	"Warning"	    {$Severity="WARNING"}
	"Error"		    {$Severity="ERROR"}
	"Critical"	    {$Severity="CRITICAL"}
	default		    {$Severity="CRITICAL"}
}

[String]$Hostname = if($Alert.NetbiosComputerName){$Alert.NetbiosComputerName}
elseif($Alert.MonitoringObjectPath){$Alert.MonitoringObjectFullName}
elseif($Alert.MonitoringObjectName){$Alert.MonitoringObjectName}
else {"Hostname Not Available"}

[String]$AlertSummary = ("["+ $Severity + "]: " + $Hostname + " - " + $Alert.Name).Trim()
[String]$AlertDescription = $Alert.Description

[String]$Priority	= if ($Alert.Priority){$Alert.Priority} else {"NONE"}
[String]$CustomField1 	= if ($Alert.CustomField1){$Alert.CustomField1} else {"NONE"}
[String]$CustomField2	= if ($Alert.CustomField2){$Alert.CustomField2} else {"NONE"}
[String]$CustomField3 	= if ($Alert.CustomField3){$Alert.CustomField3} else {"NONE"}
[String]$CustomField4	= if ($Alert.CustomField4){$Alert.CustomField4} else {"NONE"}
[String]$CustomField5	= if ($Alert.CustomField5){$Alert.CustomField5} else {"NONE"}
[String]$CustomField6	= if ($Alert.CustomField6){$Alert.CustomField6} else {"NONE"}
[String]$CustomField7	= if ($Alert.CustomField7){$Alert.CustomField7} else {"NONE"}
[String]$CustomField8	= if ($Alert.CustomField8){$Alert.CustomField8} else {"NONE"}
[String]$CustomField9	= if ($Alert.CustomField9){$Alert.CustomField9} else {"NONE"}
[String]$CustomField10	= if ($Alert.CustomField10){$Alert.CustomField10} else {"NONE"}

$AlertPayload = @{
	apiKey 			= $AlertSourceKey
	eventType 			= $EventType
	alertId 			= $AlertID.Trim('{}')
	payload = @{
		summary 		= $AlertSummary
        description     = $AlertDescription
        priority	    = $Priority
		severity 		= $Severity
		source			= $Hostname
		timestamp		= $Alert.TimeRaised.ToString("o")
		customDetails		= @{
			CustomField1 	= $CustomField1
			CustomField2	= $CustomField2
			CustomField3 	= $CustomField3
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
    					-ContentType "application/json" `
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

###############
#  Ping-Test  #
###############

#  Intended use of this script is to record ping times from hosts into a csv to help detect inconsistant latency  
# Major portions of this script taken from here: https://community.spiceworks.com/topic/337701-ping-via-powershell-log-results-with-timestamp


# June 7th, 2016 - Initial Creation



# Script will ping each host 3 times and take an average 

#output format is:  "TimeStamp","Source","Destination","IPV4Address","Status","ResponseTime"

[CmdletBinding()]
Param (
    [int32]$Count = 5,  # Number of loops of $PingsForAverage pings  (eg. 5 loops with 3 pingsforaverage = 15 pings total)
    
    [Parameter(ValueFromPipeline=$true)]
    [String[]]$Computer = "127.0.0.1",
    
    [string]$LogPath = ".\pinglog.csv"
)

#Variable initalization 
$Ping = @() #Initalize the array

#Test if path exists, if not, create it
If (-not (Test-Path (Split-Path $LogPath) -PathType Container))
{   Write-Verbose "Folder doesn't exist $(Split-Path $LogPath), creating..."
    New-Item (Split-Path $LogPath) -ItemType Directory | Out-Null
}

#Test if log file exists, if not seed it with a header row
If (-not (Test-Path $LogPath))
{   Write-Verbose "Log file doesn't exist: $($LogPath), creating..."
    Add-Content -Value '"TimeStamp","Source","Destination","IPV4Address","Status","ResponseTime"' -Path $LogPath
}

#Log collection loop
Write-Verbose "Beginning Ping monitoring of $Comptuer for $Count tries:"
While ($Count -gt 0)
{   
    $Ping = Get-WmiObject Win32_PingStatus -Filter "Address = '$Computer'" | Select @{Label="TimeStamp";Expression={Get-Date}},@{Label="Source";Expression={ $_.__Server }},@{Label="Destination";Expression={ $_.Address }},IPv4Address,@{Label="Status";Expression={ If ($_.StatusCode -ne 0) {"Failed"} Else {""}}},ResponseTime
    $Result = $Ping | Select TimeStamp,Source,Destination,IPv4Address,Status,ResponseTime | ConvertTo-Csv -NoTypeInformation
    Write-verbose ($Ping | Select TimeStamp,Source,Destination,IPv4Address,Status,ResponseTime | Format-Table -AutoSize | Out-String)
    Start-Sleep -Seconds 1
    $count--
    $Result[1] | Add-Content -Path $LogPath
}
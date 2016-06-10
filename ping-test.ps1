###############
#  Ping-Test  #
###############

#  Intended use of this script is to record ping times from hosts into a csv to help detect inconsistant latency  
# Major portions of this script taken from here: https://community.spiceworks.com/topic/337701-ping-via-powershell-log-results-with-timestamp


# June 7th, 2016 - Initial Creation



# Script will ping each host and record the data to a csv 

#output format is:  "TimeStamp","Source","Destination","IPV4Address","Status","ResponseTime"
#TimeStamp - Time the ping started
#Source - Source IP
#Destination - Destination supplied to the script (NAme, or ip)
#IPV4Address - IPV4 Address of Destination
#Status - Failed or NULL  (Timed out)
#Responsetime = ms response or NULL if Failed (Timed out)

[CmdletBinding()]
Param (
    [int32]$Count = 5,  # Number of pings
    
    [Parameter(ValueFromPipeline=$true)]
    [String]$Computer = "127.0.0.1",
    [int32]$ComputerPORT = $null,
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
if ($ComputerPORT) {
    $output = New-Object System.Object
    While ($count -gt 0){
        #Fill in TCP Ping details
        Write-Verbose "Beginning TCP moniotring of $Computer on Port $ComputerPORT. $count tests remaining"
        $output | Add-Member -type NoteProperty -name Timestamp -Value $(Get-Date)
        $time = Measure-Command {$result = test-netconnection -ComputerName $Computer -Port $ComputerPORT -InformationLevel Detailed}
        write-Verbose "Time: $Time"
        $output | Add-Member -type NoteProperty -name Source -Value $env:ComputerName
        $output | Add-Member -type NoteProperty -name Destination -Value $result.ComputerName
        $output | Add-Member -type NoteProperty -name IPV4Address -Value $result.RemoteAddress
        $output | Add-Member -type NoteProperty -name Status -Value $result.PingSucceeded
        $output | Add-Member -type NoteProperty -name ResponseTime -Value $result.PingReplyDetails
        $output | Add-Member -type NoteProperty -name TCPRemotePort -Value $result.RemotePort
        $output | Add-Member -type NoteProperty -name TCPTestSucceeded -Value $result.TCPTestSucceeded
        $output | Add-Member -type NoteProperty -name TimeMeasure -Value $time
  #      $output.RemotePort = $result.RemotePort

        write-Verbose ($Result | Format-Table -AutoSize | Out-String)
        Write-Verbose ($output | Format-Table -AutoSize | Out-String)
        $count--
    }
}
else {
    Write-Verbose "Beginning Ping monitoring of $Comptuer. $Count tests remaining"
    While ($Count -gt 0)
    {   
        $Ping = Get-WmiObject Win32_PingStatus -Filter "Address = '$Computer'" | Select @{Label="TimeStamp";Expression={Get-Date}},@{Label="Source";Expression={ $_.__Server }},@{Label="Destination";Expression={ $_.Address }},IPv4Address,@{Label="Status";Expression={ If ($_.StatusCode -ne 0) {"Failed"} Else {""}}},ResponseTime
       $Result = $Ping | Select TimeStamp,Source,Destination,IPv4Address,Status,ResponseTime
       if ($Result.status -eq "Failed" ) {
           $Result.ResponseTime = 9999999
        }
       Write-verbose ($Result | Format-Table -AutoSize | Out-String)
       $ResultCSV = $Result | ConvertTo-Csv -NoTypeinformation
       Start-Sleep -Seconds 1
       $count--
       $ResultCSV[1] | Add-Content -Path $LogPath
    }
}

#This script launches ping-test.ps1 multiple times, once per item in the array
# Lance's local IP 10.160.197.194
# Gateway 10.160.197.2
# Telus 172.31.176.210, 172.31.176.161, 172.31.122.1, 172.31.62.17, 172.31.8.18
# Citrix Server 10.195.200.206
$Computers = @("10.160.197.194","10.160.197.2","172.31.176.210","172.31.176.161","172.31.122.1","172.31.62.17","172.31.8.18","10.195.200.206")
$ComputerTCP = @($null,$null,$null,$null,$null,$null,$null,1494)
$ScriptPath = ".\ping-test.ps1"
$TCPPort = 1494
$Count = 1 # = 86400 =24 hours in seconds (with perfect pings = 1 day)
$date = get-date -Format yyyy-MM-dd
foreach ($computer in $computers)  {
    $logpath = ".\$date-$Computer-Pinglog.csv"
    $TCPPort = $ComputerTCP[$Computers.IndexOf($computer)]
    $Arguments = "$Scriptpath -Computer $computer -count $Count -LogPath $logpath -ComputerPort $TCPPort -Verbose" 
    write-host $Arguments
    start-Process -filepath powershell -ArgumentList $Arguments
}
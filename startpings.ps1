#This script launches ping-test.ps1 multiple times, once per item in the array

$Computers = @("127.0.0.1","www.google.com","www.google.ca","invalid")
$ScriptPath = ".\ping-test.ps1"
$Count = 5 # = 86400 =24 hours in seconds (with perfect pings = 1 day)
$date = get-date -Format yyyy-MM-dd
foreach ($computer in $computers)  {
    $logpath = ".\$date -$Computer-Pinglog.csv"
    $Arguments = "$Scriptpath -Computer $computer -count $Count -LogPath $logpath -Verbose" 
    write-host $Arguments
    start-Process -filepath powershell -ArgumentList $Arguments
}
$Error.Clear()
$ErrorActionPreference = "Continue"

New-Item -Path 'C:\Users\Administrator\Cache' -ItemType Directory

Write-Output "`n#########################"
Write-Output "#    Hostname/Domain    #"
Write-Output "#########################"

Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select-Object Name, Domain

Write-Output "`n#########################"
Write-Output "#          IP           #"
Write-Output "#########################`n"

Get-WmiObject Win32_NetworkAdapterConfiguration | ? { $_.IpAddress -ne $null } | % { $_.ServiceName + "`n" + $_.IPAddress + "`n" }

Write-Output "#########################"
Write-Output "#                       #"
Write-Output "#      Hardening        #"
Write-Output "#                       #"
Write-Output "#########################"

# Password
param(
    # New User Name
    [Parameter(Mandatory = $true)]
    [String]$Admin,

    # Password for other accounts
    [Parameter(Mandatory = $true)]
    [String]$P1,

    # Password for new user
    [Parameter(Mandatory = $true)]
    [String]$P2
)

.\Hardening\Fix.ps1
.\Hardening\Hard.ps1
.\Hardening\NullSession.ps1
.\Hardening\Passwd.ps1 -Admin $Admin -P1 $P1 -P2 $P2
.\Hardening\php.ps1
.\Hardening\SMB.ps1

Write-Output "#########################"
Write-Output "#                       #"
Write-Output "#         Enum          #"
Write-Output "#                       #"
Write-Output "#########################"

.\Hardening\Log.ps1

.\Hardening\ScheduledTasks.ps1 > C:\Users\Administrator\Cache\ScheduledTasks.txt
Get-Content -Path C:\Users\Administrator\Cache\ScheduledTasks.txt

.\Hardening\Inv.ps1 > C:\Users\Administrator\Cache\Inventory.txt
Get-Content -Path C:\Users\Administrator\Cache\Inventory.txt

Write-Output "#########################"
Write-Output "#                       #"
Write-Output "#        Finish         #"
Write-Output "#                       #"
Write-Output "#########################"
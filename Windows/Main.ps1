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

$Error.Clear()
$ErrorActionPreference = "Continue"

New-Item -Force -Path 'C:\Users\Administrator\Cache' -ItemType Directory

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

.\Hardening\Passwd.ps1 -Admin $Admin -P1 $P1 -P2 $P2
<#
$pwd = Get-Location

$job1 = Start-Job -FilePath "$pwd\Hardening\Fix.ps1"
$job2 = Start-Job -FilePath "$pwd\Hardening\Hard.ps1"
$job3 = Start-Job -FilePath "$pwd\Hardening\NullSession.ps1"
$job4 = Start-Job -FilePath "$pwd\Hardening\php.ps1"
$job5 = Start-Job -FilePath "$pwd\Hardening\SMB.ps1"

Get-Job | Wait-Job

$results = Get-Job | Sort-Object -Property Id | Receive-Job

Write-Output $results
#>

.\Hardening\Fix.ps1
.\Hardening\Hard.ps1
.\Hardening\NullSession.ps1
.\Hardening\php.ps1
.\Hardening\SMB.ps1

Write-Output "#########################"
Write-Output "#                       #"
Write-Output "#         Enum          #"
Write-Output "#                       #"
Write-Output "#########################"

.\Enum\Log.ps1

.\Enum\ScheduledTasks.ps1 > C:\Users\Administrator\Cache\ScheduledTasks.txt 2>&1

.\Enum\Inv.ps1 > C:\Users\Administrator\Cache\Inventory.txt 2>&1

.\Post\Comp.ps1 > C:\Users\Administrator\Cache\Changes.txt 2>&1

Write-Output "#########################"
Write-Output "#                       #"
Write-Output "#        Finish         #"
Write-Output "#                       #"
Write-Output "#########################"
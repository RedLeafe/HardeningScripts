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

Add-Type -AssemblyName System.Web

$Error.Clear()
$ErrorActionPreference = "SilentlyContinue"

$DC = $false
if (Get-WmiObject -Query "select * from Win32_OperatingSystem where ProductType='2'") {
    $DC = $true
    Write-Output "$Env:ComputerName [INFO] Domain Controller"
}


if (!$DC) {
    $users = Get-WmiObject -class win32_useraccount
    foreach ($user in $users) { 
        $username = $user.Name

        try {
            net user $username $P1 | Out-Null
            Write-Output "$Env:ComputerName [INFO] Password for user $username changed successfully"
        } catch {
            Write-Output "$Env:ComputerName [ERROR] Failed to change password for user $username. Error: $_"
        }
    }

    net user $Admin $P2 /add /y | Out-Null
    Write-Output "$Env:ComputerName [INFO] User $Admin created"
    net localgroup Administrators $Admin /add | Out-Null
    net localgroup "Remote Desktop Users" $Admin /add | Out-Null
    net localgroup "Remote Management Users" $Admin /add | Out-Null
    Write-Output "$Env:ComputerName [INFO] User $Admin added to groups"
}

if ($Error[0]) {
    Write-Output "`n#########################"
    Write-Output "#        ERRORS         #"
    Write-Output "#########################`n"


    foreach ($err in $error) {
        Write-Output $err
    }
}
$Error.Clear()
$ErrorActionPreference = "SilentlyContinue"

Write-Output "#########################"
Write-Output "#                       #"
Write-Output "#          Comp         #"
Write-Output "#                       #"
Write-Output "#########################"

Write-Output "#########################"
Write-Output "#    Service Creation   #"
Write-Output "#########################`n"

$events = Get-WinEvent -FilterHashtable @{LogName = 'System'; ID = 7045 }

foreach ($event in $events) {
    $properties = $event.Properties
    $creationDate = $event.TimeCreated
    $serviceName = $properties[0].Value
    $binaryPath = $properties[1].Value
    Write-Output "Creation Date: $creationDate"
    Write-Output "Service Name: $serviceName"
    Write-Output "Binary Path: $binaryPath"
    Write-Output ""
}

Write-Output "#########################"
Write-Output "#    Password Change    #"
Write-Output "#########################\n"

# ID 4742 = password changes
$events = Get-WinEvent -FilterHashtable @{LogName = 'Security'; ID = 4742 }

foreach ($event in $events) {
    $properties = $event.Properties
    $creationDate = $event.TimeCreated
    Write-Output "Computer Name: $($properties[1].Value)"
    Write-Output "User: $($properties[5].Value)"
    Write-Output "Event Time: $creationDate"
    Write-Output ""
}

Write-Output "\n#########################"
Write-Output "#     Share Access      #"
Write-Output "#########################"

$events = Get-WinEvent -FilterHashtable @{LogName = 'Security'; ID = 5140 }

foreach ($event in $events) {
    if ($event.Properties[7].Value -match "IPC") {
        $properties = $event.Properties

        $creationDate = $event.TimeCreated

        Write-Output "Share: $($properties[7].Value)"
        Write-Output "Username: $($properties[1].Value)"
        Write-Output "Ip Address: $($properties[5].Value)"
        Write-Output "Access Mask: $($properties[9].Value)"
        Write-Output "Event Time: $creationDate"
        Write-Output ""
    }
    
}

if ($Error[0]) {
    Write-Output "`n#########################"
    Write-Output "#        ERRORS         #"
    Write-Output "#########################`n"


    foreach ($err in $error) {
        Write-Output $err
    }
}
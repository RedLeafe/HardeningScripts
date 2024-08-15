$Error.Clear()
$ErrorActionPreference = "SilentlyContinue"

Write-Output "`n#########################"
Write-Output "#                       #"
Write-Output "#          Log          #"
Write-Output "#                       #"
Write-Output "#########################`n"

######### Logging#########

# Enable logging
# Stored in Event Viewer (eventvwr) or C:\Windows\System32\winevt\Logs\
auditpol /set /category:* /success:enable /failure:enable | Out-Null

# Include command line in process creation events
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v "ProcessCreationIncludeCmdLine_Enabled" /t REG_DWORD /d 1 /f | Out-Null

# Powershell command transcription (logs all commands executed in PowerShell sessions)
# Stored in C:\Users\Administrator\Cache\PSLogs
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v EnableTranscripting /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v EnableInvocationHeader /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v OutputDirectory /t REG_SZ /d "C:\Users\Administrator\Cache\PSLogs" /f | Out-Null

# Powershell script block logging
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames" /v "*" /t REG_SZ /d "*" /f | Out-Null

# HTTP logging
Write-Output "$Env:ComputerName [INFO] Powershell Logging enabled"
try {
    C:\Windows\System32\inetsrv\appcmd.exe set config /section:httpLogging /dontLog:False
    Write-Output "$Env:ComputerName [INFO] IIS Logging enabled"
}
catch {
    Write-Output "$Env:ComputerName [ERROR] IIS Logging failed"
}

$pwd = Get-Location

######### Sysmon Setup #########
if ($Env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    .\Runnables\Sysmon64.exe -accepteula -i
    .\Runnables\Sysmon64.exe -c .\Runnables\smce.xml
    Write-Output "$Env:ComputerName [INFO] Sysmon64 installed and configured"
}
else {
    .\Runnables\Sysmon.exe -accepteula -i 
    .\Runnables\Sysmon.exe -c .\Runnables\smce.xml
    Write-Output "$Env:ComputerName [INFO] Sysmon32 installed and configured"
}


if ($Error[0]) {
    Write-Output "`n#########################"
    Write-Output "#        ERRORS         #"
    Write-Output "#########################`n"


    foreach ($err in $error) {
        Write-Output $err
    }
}
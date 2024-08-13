$Error.Clear()
$ErrorActionPreference = "Continue"

Write-Output "#########################"
Write-Output "#                       #"
Write-Output "#          PHP          #"
Write-Output "#                       #"
Write-Output "#########################"

######### Disable PHP Functions #########

# Find each php.exe file
$php = Get-ChildItem C:\ php.exe -recurse -ErrorAction SilentlyContinue | ForEach-Object { & $_.FullName --ini | Out-String }
$ConfigFiles = @()
ForEach ($OutputLine in $($php -split "`r`n")) {
    if ($OutputLine -match 'Loaded') {
        ForEach-Object {
            $ConfigFiles += ($OutputLine -split "\s{9}")[1]
        }
    }
}

# Apply hardening php settings to every php file
$ConfigString_DisableFuncs = "disable_functions=exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source"
$COnfigString_FileUploads = "file_uploads=off"
Foreach ($ConfigFile in $ConfigFiles) {
    Add-Content $ConfigFile $ConfigString_DisableFuncs
    Add-Content $ConfigFile $ConfigString_FileUploads
    Write-Output "$Env:ComputerName [INFO] PHP functions disabled in $ConfigFile"
}

if ($Error[0]) {
    Write-Output "`n#########################"
    Write-Output "#        ERRORS         #"
    Write-Output "#########################`n"


    foreach ($err in $error) {
        Write-Output $err
    }
}
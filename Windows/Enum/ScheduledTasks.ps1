#Scheduled Tasks
Write-Output "`n#### Start Scheduled Tasks ####" 
$scheduledTasksXml = schtasks /query /xml ONE
$tasks = [xml]$scheduledTasksXml
$taskList = @()
for ($i = 0; $i -lt $tasks.Tasks.'#comment'.Count; $i++) {
    $taskList += [PSCustomObject] @{
        TaskName = $tasks.Tasks.'#comment'[$i]
        Task     = $tasks.Tasks.Task[$i]
    }
}
$filteredTasks = $taskList | Where-Object {
    ($_.Task.RegistrationInfo.Author -notlike '*.exe*') -and
    ($_.Task.RegistrationInfo.Author -notlike '*.dll*')
}
$filteredTasks | ForEach-Object {
    $taskName = $_.TaskName
    $fields = schtasks /query /tn $taskName.trim() /fo LIST /v | Select-String @('TaskName:', 'Author: ', 'Task to Run:')
    $fields | Out-String
}
Write-Output "#### End Scheduled Tasks ####" 
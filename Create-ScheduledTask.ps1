<#
    This script creates Scheduled task and start it if switch "StartWhenAvailable" specified
#>

param(
    [string]$taskName = "SerialUpdater",
    [string]$executable = 'dotnet.exe',
    [string]$Argument = "C:\inetpub\SerialUpdater\SerialUpdater.dll",
    [int]$RepetitionInterval = 15,
    [int]$ExecutionTimeLimit = 29,
    [switch]$StartWhenAvailable
)

$StartTime = (get-date).AddMinutes(1)
$TaskLifeTime = New-TimeSpan -Days 10000
$RepeatEvery = New-TimeSpan -Minutes $RepetitionInterval
$StopExecutionAfter = New-TimeSpan -Minutes $ExecutionTimeLimit

import-module ScheduledTasks
$action = New-ScheduledTaskAction -Execute $executable -Argument $Argument
$TaskUserName = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$trigger = New-ScheduledTaskTrigger -At $StartTime -RepetitionDuration $TaskLifeTime -RepetitionInterval $RepeatEvery -Once
$settings = New-ScheduledTaskSettingsSet -Hidden -ExecutionTimeLimit $StopExecutionAfter -Disable
$Task = New-ScheduledTask -Action $action -Principal $TaskUserName -Trigger $trigger -Settings $settings -Description "Licensing scheduled task"

Register-ScheduledTask -TaskName $taskName -InputObject $Task -Force

If ($StartWhenAvailable){
    Enable-ScheduledTask -TaskName $taskName
    Start-ScheduledTask -TaskName $taskName
}
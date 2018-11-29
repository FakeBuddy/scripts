$log = "$PSScriptRoot\install.log"
$class = "MSFT_WUOperations"
$ns = "root/Microsoft/Windows/WindowsUpdate"
$timestamp = Get-Date

Function Send-Telegram ($message){
    Invoke-WebRequest -UseBasicParsing `
                      -Uri "https://api.telegram.org/<bot_id>/sendMessage?chat_id=<chat_id>&text=$message" `
                      -Method Get
}

Write-Output "$timestamp $env:COMPUTERNAME Get Windows Updates." | Out-File -FilePath $log -Append
Try {
    $Updates = (Invoke-CimMethod -Namespace $ns `
                             -ClassName $class `
                             -MethodName ScanForUpdates `
                             -Arguments @{SearchCriteria="IsInstalled=0"} `
                             -ErrorAction Stop ).updates 
}
Catch {
    Write-Output "$timestamp Fail to get updates. `n$($_.Exception)" | Out-File -FilePath $log -Append
    Out-File -FilePath "$PSScriptRoot\installation_status.log" -InputObject "$env:COMPUTERNAME Installation complete with errors"
    Send-Telegram "$env:COMPUTERNAME Fail to get updates"
    Exit 1
}

if ($Updates){
        
    Try {
        $installResults = Invoke-CimMethod -Namespace $ns `
                                           -ClassName $class `
                                           -MethodName InstallUpdates `
                                           -Arguments @{Updates=$Updates} `
                                           -ErrorAction Stop
    }
    Catch {
        Write-Output "$timestamp There were errors during installation. `n$($Error[0].Exception)" | Out-File -FilePath $log -Append
        Out-File -FilePath "$PSScriptRoot\installation_status.log" -InputObject "$env:COMPUTERNAME Installation complete with errors"
        Send-Telegram "$env:COMPUTERNAME Installation complete with errors"
        Exit 2
    }

    $msg = "$timestamp $env:COMPUTERNAME Windows Update Installation completed. RebootRequired: $($installResults.RebootRequired)"
    Out-File -FilePath $log -Append -InputObject $msg
    Send-Telegram "$env:COMPUTERNAME $msg"
}
else {
    $msg = "$timestamp $env:COMPUTERNAME Windows Updates. Nothing to install at this time" 
    Out-File -FilePath $log -Append -InputObject $msg
    Send-Telegram "$env:COMPUTERNAME $msg"
}

$eventLogs = Get-EventLog System | Where-Object {
    ($_.Source -eq 'Microsoft-Windows-WindowsUpdateClient') `
    -and ($_.TimeWritten.Date -eq (Get-Date).Date) `
} | Select-Object TimeWritten,EntryType,Message | Format-List | Out-String

Send-Telegram "$env:COMPUTERNAME $eventLogs"

Out-File -FilePath "$PSScriptRoot\installation_status.log" -InputObject "$env:COMPUTERNAME Installation complete"



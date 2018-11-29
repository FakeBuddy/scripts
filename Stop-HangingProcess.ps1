<#
    .Synopsis
        Stop-HangingProcess.ps1 script.

    .Description
        Script check running processes by name defined in ARGUMENTS and stops those running longer than 1 day.

    .Parameter ProcessName
        Process Name for search pattern.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ProcessName = "plink",
    [string]$MailFrom = "",
    [string]$MailTo = "",
    [string]$Smtp = ""
)

# TO-DO. Event Logging.

Function Get-HangingProcess($proc){

    [array](Get-Process $proc -ErrorAction SilentlyContinue)

}

Function Send-Message ($subject, $message) {

    Send-MailMessage -From $MailFrom -To $MailTo -SmtpServer $Smtp -Subject $subject -Body $msg

}


$Processes = Get-HangingProcess($ProcessName)
$currentTime = Get-Date
$MailSubject = "Stop Dangling Plink Processes"

If ($Processes){

    $Stopped = @()

    foreach ($proc in $Processes){

        $TimeElapsed = $currentTime - $proc.StartTime

        # ($TimeElapsed.Hours -gt 20) -or
        If ($TimeElapsed.Days -gt 1){

            # Gather stopped processes to notify administrator
            $Stopped += $proc

            Try {

                Stop-Process -Id $proc.Id -Force

            }
            Catch {
                
                $msg = "Failed to stop process. Id: $($proc.Id). StartTime: $($proc.StartTime) `n`n$_.Exception.Message"

                Send-Message -Subject $MailSubject -message $msg
            
            }

        }

    }

    If ($Stopped) {

        $msg = "Stopped processes: "

        $Stopped | ForEach-Object -Begin {
            
        } -Process {
        
            $msg += "`n Name: $($_.Name), Id: $($_.Id), StartTime: $($_.StartTime)"

        }

    }

    Else {
        
        $msg = "There are no any plink processes hanging longer than 1 day"

    }

    Send-Message -subject $MailSubject -message $msg

}

Else{

    $msg = "There are no any plink processes"

    Send-Message -subject $MailSubject -message $msg

}
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"set-scheduled-task-state.psm1"
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\"title-templates.psm1"

# Adapted from: https://youtu.be/qWESrvP_uU8
# Adapted from: https://github.com/ChrisTitusTech/win10script
# Adapted from: https://gist.github.com/matthewjberger/2f4295887d6cb5738fa34e597f457b7f
# Adapted from: https://github.com/Sycnex/Windows10Debloater
# Adapted from: https://github.com/kalaspuffar/windows-debloat

function Optimize-TaskScheduler() {
    [CmdletBinding()]
    param (
        [Switch] $Revert
    )

    # Adapted from: https://docs.microsoft.com/pt-br/windows-server/remote/remote-desktop-services/rds-vdi-recommendations#task-scheduler
    $DisableScheduledTasks = @(
        "\Microsoft\Office\OfficeTelemetryAgentLogOn"
        "\Microsoft\Office\OfficeTelemetryAgentFallBack"
        "\Microsoft\Office\Office 15 Subscription Heartbeat"
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
        "\Microsoft\Windows\Application Experience\StartupAppTask"
        "\Microsoft\Windows\Autochk\Proxy"
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"         # Recommended state for VDI use
        "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"       # Recommended state for VDI use
        "\Microsoft\Windows\Customer Experience Improvement Program\Uploader"
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"              # Recommended state for VDI use
        "\Microsoft\Windows\Defrag\ScheduledDefrag"                                       # Recommended state for VDI use
        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
        "\Microsoft\Windows\Location\Notifications"                                       # Recommended state for VDI use
        "\Microsoft\Windows\Location\WindowsActionDialog"                                 # Recommended state for VDI use
        "\Microsoft\Windows\Maps\MapsToastTask"                                           # Recommended state for VDI use
        "\Microsoft\Windows\Maps\MapsUpdateTask"                                          # Recommended state for VDI use
        "\Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser"                # Recommended state for VDI use
        "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"                   # Recommended state for VDI use
        "\Microsoft\Windows\Retail Demo\CleanupOfflineContent"                            # Recommended state for VDI use
        "\Microsoft\Windows\Shell\FamilySafetyMonitor"                                    # Recommended state for VDI use
        "\Microsoft\Windows\Shell\FamilySafetyRefreshTask"                                # Recommended state for VDI use
        "\Microsoft\Windows\Shell\FamilySafetyUpload"
        "\Microsoft\Windows\Windows Media Sharing\UpdateLibrary"                          # Recommended state for VDI use
    )

    $EnableScheduledTasks = @(
        "\Microsoft\Windows\Maintenance\WinSAT"                     # WinSAT detects incorrect system configurations, that causes performance loss, then sends it via telemetry | Reference (PT-BR): https://youtu.be/wN1I0IPgp6U?t=16
        "\Microsoft\Windows\RecoveryEnvironment\VerifyWinRE"        # Verify the Recovery Environment integrity, it's the Diagnostic tools and Troubleshooting when your PC isn't healthy on BOOT, need this ON.
        "\Microsoft\Windows\Windows Error Reporting\QueueReporting" # Windows Error Reporting event, needed to improve compatibility with your hardware
    )

    Write-Title -Text "Task Scheduler tweaks"
    Write-Section -Text "Disabling Scheduled Tasks"

    If ($Revert) {
        Write-Status -Symbol "<" -Type "TaskScheduler" -Status "Reverting: $Revert." -Warning
        $CustomMessage = { "Resetting the $ScheduledTask task as 'Ready' ..." }
        Set-ScheduledTaskState -Ready -ScheduledTask $DisableScheduledTasks -CustomMessage $CustomMessage
    }
    Else {
        Set-ScheduledTaskState -Disabled -ScheduledTask $DisableScheduledTasks
    }

    Write-Section -Text "Enabling Scheduled Tasks"
    Set-ScheduledTaskState -Ready -ScheduledTask $EnableScheduledTasks
}

function Main() {
    # List all Scheduled Tasks:
    #Get-ScheduledTask | Select-Object -Property State, TaskPath, TaskName, Description | Sort-Object State, TaskPath, TaskName | Out-GridView

    If (!$Revert) {
        Optimize-TaskScheduler # Disable Scheduled Tasks that causes slowdowns
    }
    Else {
        Optimize-TaskScheduler -Revert
    }
}

Main
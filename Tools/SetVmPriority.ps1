param (
    [switch]$IgnoreNotRunning
)

Function SetVMPriority{
    param ($vmName, $affinity, $priority)
    while($true){
        try
        {
            $allWin32Process = Get-WmiObject -Class Win32_Process | ? {$_.ProcessName -eq 'vmmem'} | ForEach-Object {
                $owner = $_.GetOwner()
                New-Object PSObject -Property @{
                    ProcessName = $_.Name
                    UserName = $owner.User
                    Process = $_
                }
            }
            $vmGUID = (Get-VM $vmName).id
            $vmmemWin32Process = $allWin32Process | ? {$_.UserName -match $vmGUID}
            $vmmemWin32Process | Format-List -Property *

            $vmmemPowerShellProcess = Get-Process -Id $vmmemWin32Process.Process.ProcessId
            $vmmemPowerShellProcess.ProcessorAffinity = $affinity
            $vmmemPowerShellProcess.PriorityClass = $priority
            Write-Host "$vmName Success"
            break
        }
        catch
        {
            Write-Host "An error occurred!" -ForegroundColor Red
            Write-Host "VMName: $vmName, Error details: $($_.Exception.Message)"
            if ($IgnoreNotRunning){
                break
            }
            Start-Sleep -Seconds 1
        }
    }
}

# PriorityClass available values
# Normal, Idle, High, RealTime, BelowNormal, AboveNormal
# ProcessorAffinity default value: 4095

# Only lower priority
SetVMPriority "VMName" 4095 "BelowNormal"

# Bind to cores 6-7 8-9 10-11: 0x0FC0
# Highest priority
SetVMPriority "VMName" 0x0FC0 "Realtime"

# Moonlight client
$moonlight = Get-Process -Name "Moonlight"
$moonlight.ProcessorAffinity = 4095
$moonlight.PriorityClass = "High"

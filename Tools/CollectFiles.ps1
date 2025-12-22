$cardName = "1080 Ti"

# Prepare export folder
Remove-Item -Path "C:\GpuDriverExtra" -Recurse

# Declare files array structure
# [0]: file in Windows dir
# [1]: file copy to GpuDriverExtra
$filesToCollectArray = @()

# Parse DxDiag.txt to get driver files
$driverFileListBegin = $false
$dxDiagFile = Get-Content -Path "$PSScriptRoot\DxDiag.txt"
foreach ($line in $dxDiagFile) {
    # Find card name line
    $line = $line.Trim()
    if ($line.Contains("Name") -and $line.Contains($cardName)){
        $driverFileListBegin = $true
        continue
    }
    # Find any new device after card name located, end card name
    if ($driverFileListBegin -and $line.Contains("Name")){
        $driverFileListBegin = $false
        break
    }

    # Collect file
    if ($driverFileListBegin -and $line.StartsWith("Driver")){
        $removeDriverPrefix = $line.Split(" ", 2)[1]
        $removeDescription = $removeDriverPrefix.Split(",", 2)[0]
        $fileToCollect = $removeDescription

        # Ignore file will be installed by inf
        if ($fileToCollect.Contains("DriverStore")){
            continue
        }

        $fileCopyDest = $fileToCollect.Replace("C:\WINDOWS", "C:\GpuDriverExtra\Windows")
        $filesToCollectArray += , (@($fileToCollect, $fileCopyDest))
    }
}

# Create install, upgrade and uninstall script
$installScriptPath = "C:\GpuDriverExtra\install.ps1"
$installWithDataScriptPath = "C:\GpuDriverExtra\install_with_data.ps1"
# File name _z has less priority to be autocomplete on console
$uninstallScriptPath = "C:\GpuDriverExtra\uninstall_z_remove_data.ps1"
$uninstallKeepDataScriptPath = "C:\GpuDriverExtra\uninstall_keep_data.ps1"
# Overwrite exist
New-Item -ItemType File -Path $installScriptPath -Force
New-Item -ItemType File -Path $installWithDataScriptPath -Force
New-Item -ItemType File -Path $uninstallScriptPath -Force
New-Item -ItemType File -Path $uninstallKeepDataScriptPath -Force

# Write upgrade (uninstall keep data) script header
# Code from InstallGuestDriver, remove display driver from HostDriverStore
$uninstallKeepDataScriptContent = @'
$drivers = Get-WindowsDriver -Online -All
$targetDriver = $drivers | Where-Object { $_.ClassName -EQ "Display" -and $_.ProviderName -Like "NVIDIA" }
$targetDriver
$targetDriverOemFile = $targetDriver.Driver
$targetDriverOemFile

$targetDriverIndex = 0
$driverInstallDir = $targetDriver[$targetDriverIndex].OriginalFileName
$driverInstallDir = Split-Path $driverInstallDir
$driverInstallDirName = Split-Path -Leaf $driverInstallDir
$hostDriverStoreDir = "C:\Windows\System32\HostDriverStore\FileRepository"
$hostDriverStoreDir = Join-Path $hostDriverStoreDir $driverInstallDirName

# Preview and verify path
$driverInstallDir
$hostDriverStoreDir

pnputil /delete-driver "$targetDriverOemFile"
Remove-Item -Path "$hostDriverStoreDir" -Recurse

'@
$uninstallKeepDataScriptContent | Out-File $uninstallKeepDataScriptPath -Append

# Write each file to different script
foreach ($file in $filesToCollectArray) {
    $src = $file[0]
    $dest = $file[1]
    # Create parent folder if not exist and copy file
    New-Item -ItemType File -Path $dest -Force
    Copy-Item -Path $src -Destination $dest -Force

    # install command
    "New-Item -ItemType File -Path `"$src`" -Force" | Out-File $installScriptPath -Append
    "Copy-Item -Path `"$dest`" -Destination `"$src`"" | Out-File $installScriptPath -Append
    "New-Item -ItemType File -Path `"$src`" -Force" | Out-File $installWithDataScriptPath -Append
    "Copy-Item -Path `"$dest`" -Destination `"$src`"" | Out-File $installWithDataScriptPath -Append

    # uninstall command
    "Remove-Item -Path `"$dest`"" | Out-File $uninstallScriptPath -Append

    # upgrade command
    "Remove-Item -Path `"$dest`"" | Out-File $uninstallKeepDataScriptPath -Append
}

# Copy exist driver settings to export folder
Copy-Item -Path "C:\ProgramData\NVIDIA Corporation" -Destination "C:\GpuDriverExtra\ProgramData\NVIDIA Corporation" -Recurse

# Append to install with data
"Copy-Item -Path `"C:\GpuDriverExtra\ProgramData\NVIDIA Corporation`" -Destination `"C:\ProgramData`" -Recurse" | Out-File $installWithDataScriptPath -Append

# Append to uninstall script
"Remove-Item -Path `"C:\ProgramData\NVIDIA Corporation`" -Recurse" | Out-File $uninstallScriptPath -Append

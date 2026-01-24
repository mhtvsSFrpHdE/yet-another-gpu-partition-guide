$cardName = "1080 Ti"

# Prepare export folder
Remove-Item -Path "C:\GpuDriver" -Recurse

# Declare inplace files array structure
#   these copy from src to dest, then copy back to src on install
# [0]: file in Windows dir
# [1]: file copy to GpuDriver
$inplaceFilesToCollectArray = @()

# Declare HostDriverStore files array structure
#   these copy from src to dest, then copy back to HostDriverStore on install
# [0]: file in DriverStore dir
# [1]: file copy to GpuDriver
# [2]: copy to where on install
$hostDriverStoreFilesToCollectArray = @()

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

        $fileCopyDest = ""
        # File will be installed by inf, copy to HostDriverStore
        if ($fileToCollect.Contains("DriverStore")){
            $fileCopyDest = $fileToCollect -ireplace [regex]::Escape("C:\WINDOWS\System32\DriverStore"), "C:\GpuDriver\HostDriverStore"
            $fileInstallTo = $fileToCollect -ireplace [regex]::Escape("C:\WINDOWS\System32\DriverStore"), "C:\WINDOWS\System32\HostDriverStore"
            $hostDriverStoreFilesToCollectArray += , (@($fileToCollect, $fileCopyDest, $fileInstallTo))
        }
        else{
            $fileCopyDest = $fileToCollect -ireplace [regex]::Escape("C:\WINDOWS"), "C:\GpuDriver\Windows"
            $inplaceFilesToCollectArray += , (@($fileToCollect, $fileCopyDest))
        }
    }
}

# Create install, upgrade and uninstall script
$installScriptPath = "C:\GpuDriver\install.ps1"
$installWithDataScriptPath = "C:\GpuDriver\install_with_data.ps1"
# File name _z has less priority to be autocomplete on console
$uninstallScriptPath = "C:\GpuDriver\uninstall_z_remove_data.ps1"
$uninstallKeepDataScriptPath = "C:\GpuDriver\uninstall_keep_data.ps1"
# Overwrite exist
New-Item -ItemType File -Path $installScriptPath -Force
New-Item -ItemType File -Path $installWithDataScriptPath -Force
New-Item -ItemType File -Path $uninstallScriptPath -Force
New-Item -ItemType File -Path $uninstallKeepDataScriptPath -Force

# Write each file to different script
foreach ($file in $inplaceFilesToCollectArray) {
    $src = $file[0]
    $dest = $file[1]

    # Create parent folder if not exist and copy file to GpuDriver export folder
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
foreach ($file in $hostDriverStoreFilesToCollectArray) {
    $src = $file[0]
    $dest = $file[1]
    $installTo = $file[2]

    # Create parent folder if not exist and copy file to GpuDriver export folder
    New-Item -ItemType File -Path $dest -Force
    Copy-Item -Path $src -Destination $dest -Force

    # install command
    "New-Item -ItemType File -Path `"$installTo`" -Force" | Out-File $installScriptPath -Append
    "Copy-Item -Path `"$dest`" -Destination `"$installTo`"" | Out-File $installScriptPath -Append
    "New-Item -ItemType File -Path `"$installTo`" -Force" | Out-File $installWithDataScriptPath -Append
    "Copy-Item -Path `"$dest`" -Destination `"$installTo`"" | Out-File $installWithDataScriptPath -Append

    # uninstall command
    "Remove-Item -Path `"$installTo`"" | Out-File $uninstallScriptPath -Append

    # upgrade command
    "Remove-Item -Path `"$installTo`"" | Out-File $uninstallKeepDataScriptPath -Append
}

# Copy exist driver settings to export folder
Copy-Item -Path "C:\ProgramData\NVIDIA Corporation" -Destination "C:\GpuDriver\ProgramData\NVIDIA Corporation" -Recurse

# Append to install with data
"Copy-Item -Path `"C:\GpuDriver\ProgramData\NVIDIA Corporation`" -Destination `"C:\ProgramData`" -Recurse" | Out-File $installWithDataScriptPath -Append

# Append to uninstall script
"Remove-Item -Path `"C:\ProgramData\NVIDIA Corporation`" -Recurse" | Out-File $uninstallScriptPath -Append

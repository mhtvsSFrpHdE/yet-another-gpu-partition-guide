$cardName = "1080 Ti"

# [0]: file in Windows dir
# [1]: file copy to GpuDriverExtra
$filesToCollectArray = @()

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

# Create install and uninstall script
$installScriptPath = "C:\GpuDriverExtra\install.ps1"
$uninstallScriptPath = "C:\GpuDriverExtra\uninstall.ps1"
# Overwrite exist
New-Item -ItemType File -Path $installScriptPath -Force
New-Item -ItemType File -Path $uninstallScriptPath -Force
foreach ($file in $filesToCollectArray) {
    $src = $file[0]
    $dest = $file[1]
    # Create parent folder if not exist and copy file
    New-Item -ItemType File -Path $dest -Force
    Copy-Item -Path $src -Destination $dest -Force

    # install command
    "New-Item -ItemType File -Path `"$src`" -Force" | Out-File $installScriptPath -Append
    "Copy-Item -Path `"$dest`" -Destination `"$src`"" | Out-File $installScriptPath -Append

    # uninstall command
    "Remove-Item -Path `"$dest`"" | Out-File $uninstallScriptPath -Append
}

# Copy exist driver settings
Remove-Item -Path "C:\GpuDriverExtra\ProgramData\NVIDIA Corporation" -Recurse
Copy-Item -Path "C:\ProgramData\NVIDIA Corporation" -Destination "C:\GpuDriverExtra\ProgramData\NVIDIA Corporation" -Recurse
# Append to install and uninstall script
"Copy-Item -Path `"C:\GpuDriverExtra\ProgramData\NVIDIA Corporation`" -Destination `"C:\ProgramData`" -Recurse" | Out-File $installScriptPath -Append
"Remove-Item -Path `"C:\ProgramData\NVIDIA Corporation`" -Recurse" | Out-File $uninstallScriptPath -Append

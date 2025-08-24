$cardName = "1080 Ti"

# [0]: file in Windows dir
# [1]: file copy to GpuDriverExtra
$filesToCollectArray = @()

$driverFileListBegin = $false
$dxDiagFile = Get-Content -Path "DxDiag.txt"
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
foreach ($file in $filesToCollectArray) {
    $src = $file[0]
    $dest = $file[1]
    # Create parent folder if not exist and copy file
    New-Item -ItemType File -Path $dest -Force
    Copy-Item -Path $src -Destination $dest -Force

    # install command
    "Copy-Item -Path `"$dest`" -Destination `"$src`"" | Out-File $installScriptPath -Append

    # uninstall command
    "Remove-Item -Path `"$dest`"" | Out-File $uninstallScriptPath -Append
}

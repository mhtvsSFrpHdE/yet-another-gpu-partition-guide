## Install driver
```
# Copy driver files from GetAndSetHost $driverExportDir to guest OS
$driverExportDir = "C:\GpuDriver"
pnputil /add-driver "$driverExportDir\*.inf" /install
```

## Preview installed driver list
```
$drivers = Get-WindowsDriver -Online -All
$targetDriver = $drivers | Where-Object { $_.ClassName -EQ "Display" -and $_.ProviderName -Like "NVIDIA" }
$targetDriver
```

## If there is any unwanted or mismatch version, remove it and refresh driver list
```
pnputil /delete-driver oem<XX>.inf
$drivers = Get-WindowsDriver -Online -All
$targetDriver = $drivers | Where-Object { $_.ClassName -EQ "Display" -and $_.ProviderName -Like "NVIDIA" }
$targetDriver
```

## Copy driver to HostDriverStore
```
$targetDriverIndex = 0
$driverInstallDir = $targetDriver[$targetDriverIndex].OriginalFileName
$driverInstallDir = Split-Path $driverInstallDir
$driverInstallDirName = Split-Path -Leaf $driverInstallDir
$hostDriverStoreDir = "C:\Windows\System32\HostDriverStore\FileRepository"
$hostDriverStoreDir = Join-Path $hostDriverStoreDir $driverInstallDirName

# Preview and verify path
$driverInstallDir
$hostDriverStoreDir

Copy-item -Force -Recurse "$driverInstallDir" -Destination "$hostDriverStoreDir"
```

## Finish
Reboot now, after reboot it should work  
Once you succussfully configured GPU Partition  
You **MUST** record your Windows version and driver version like this
- Windows 11 OS Build 26100.2033
- Nvidia 572.16

You'll need them if GPU Partition break by Windows or driver update so you can perform a downgrade to known good version combination

Installed driver may not be reserved on large Windows update  
It's recommended to keep driver export folder copied to guest OS, for future use  
See "Troubleshoot - Emergency recovery" for more information, and about downgrade

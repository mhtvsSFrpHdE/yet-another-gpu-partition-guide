## Emergency recovery
The GPU Partition may fail due to reasons  
If you sure you can't boot to desktop because of GPU Partition  
There is two method to recovery from chaos so you can re configure it without GPU

### Remove virtual GPU adapter
Shutdown first, then remove and try to boot
```
$vmName = "GuestVmWithGpu"
Remove-VMGpuPartitionAdapter -VMName $vmName
```

### Safe mode / Uninstall / Update driver
If simply remove virtual GPU adapter doesn't work  
You can use virtual machine reset button serval times on boot phase when you see Windows icon  
Until "Preparing Automatic Repair" shows, and "Startup Settings", "Enable Safe Mode" in these menu

In safe mode, check if there is any driver installed in guest
```
$drivers = Get-WindowsDriver -Online -All
$targetDriver = $drivers | Where-Object { $_.ClassName -EQ "Display" -and $_.ProviderName -Like "NVIDIA" }
$targetDriver
```

If there is nothing, you may install it again since it doesn't survived after large Windows update  
After install, shutdown and exit safe mode, add back virtual GPU adapter to see if works
```
$driverExportDir = "C:\GpuDriver"
pnputil /add-driver "$driverExportDir\*.inf" /install
```

If you plan to remove it so you can boot without GPU driver
```
pnputil /delete-driver oemXX.inf
```

Or with /force if something happened
```
pnputil /delete-driver oemXX.inf /force
```

Finally, delete copied driver files
```
$targetDriverIndex = 0
$driverInstallDir = $targetDriver[$targetDriverIndex].OriginalFileName
$driverInstallDir = Split-Path $driverInstallDir
$driverInstallDirName = Split-Path -Leaf $driverInstallDir
$hostDriverStoreDir = "C:\Windows\System32\HostDriverStore\FileRepository"
$hostDriverStoreDir = Join-Path $hostDriverStoreDir $driverInstallDirName

# Preview and verify path again to prevent you delete something wrong
$hostDriverStoreDir

Remove-Item -LiteralPath "$hostDriverStoreDir" -Force -Recurse
```

## I'm on desktop, but can't get GPU Partition work after Windows update
Double check your guest OS and host OS running same version Windows and driver  
For example
- Windows 11 OS Build 26100.2033
- Nvidia 572.16

Downgrade GPU driver first to a known good version and see if work  
If not, grab a early published Windows 11 24H2 disk ISO  
Use it to "upgrade" current system and keep all data  
After "upgrade", your OS patch level will back to early stage of 24H2  
You may google how to exclude certain Windows update and install the rest, or don't install update at all

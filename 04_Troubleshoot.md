## Emergency recovery
The GPU Partition may fail due to reasons  
If you sure you can't boot to desktop because of GPU Partition  
There is method to recovery from chaos so you can re configure it without GPU

### Remove virtual GPU adapter
Shutdown first, then remove and try to boot
```
$vmName = "GuestVmWithGpu"
Remove-VMGpuPartitionAdapter -VMName $vmName
```
### Install script access denied / Cleanup INF
In early version I use INF install method and they are deprecated  
https://github.com/mhtvsSFrpHdE/unofficial-gpu-partition-document/issues/12

Check if there is any INF driver installed in guest  
Notice that this command output nothing in safe mode, only show drivers in normal boot
```
$drivers = Get-WindowsDriver -Online -All
$targetDriver = $drivers | Where-Object { $_.ClassName -EQ "Display" -and $_.ProviderName -Like "NVIDIA" }
$targetDriver
```

Remove it so you can boot without GPU driver
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

Reboot to safe mode  
Run `C:\GpuDriver\uninstall_keep_data.ps1` with admin permission to remove extra files  
If don't want to keep driver settings, run `uninstall_z_remove_data.ps1` to delete `C:\ProgramData\NVIDIA Corporation`

Now there are still files and directory with system permission can't be delete by script  
Get TrustedInstaller permission and delete manually
- `C:\Windows\System32\nvapi64.dll`
- `C:\Windows\System32\HostDriverStore\FileRepository\nv_dispsi.inf...`

If you see any file access denied red error in future, delete them with TrustedInstaller permission too

## I'm on desktop, but can't get GPU Partition work after Windows update
Windows Update may break GPU partition and happened before, check  
https://github.com/mhtvsSFrpHdE/unofficial-gpu-partition-document/wiki/Known-good-combination  
and Downgrade to known good version and see if work

You may google how to exclude certain Windows update and install the rest, or don't install update at all  
also verify update work or not in test environment before deploy them to production PC

## Update driver
- Boot guest OS in safe mode
- Run `C:\GpuDriver\uninstall_keep_data.ps1`
- Delete `C:\GpuDriver`
- Reboot and copy new version driver files from host OS
- Run `C:\GpuDriver\install.ps1`
- Reboot, driver should up to date

## Uninstall
- Boot guest OS in safe mode
- Run `C:\GpuDriver\uninstall_keep_data.ps1`  
  if don't want to keep driver settings, run `C:\GpuDriver\uninstall_z_remove_data.ps1` instead
- Delete `C:\GpuDriver`
- Reboot

## If want to completely remove gpu from VM
Find a VM that never add gpu partition as "sample"
```
$sampleVM = Get-VM "GuestVmNoGpu"
$vmName = "GuestVmWithGpu"
Remove-VMGpuPartitionAdapter -VMName $vmName
Set-VM -GuestControlledCacheTypes $sampleVM.GuestControlledCacheTypes -VMName $vmName
Set-VM -LowMemoryMappedIoSpace $sampleVM.LowMemoryMappedIoSpace -VMName $vmName
Set-VM -HighMemoryMappedIoSpace $sampleVM.HighMemoryMappedIoSpace -VMName $vmName
```

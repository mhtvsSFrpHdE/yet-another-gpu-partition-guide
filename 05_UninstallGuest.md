# If want to completely remove gpu from VM
Find a VM hasn't add gpu partition as "sample"
```
$sampleVM = Get-VM "GuestVmNoGpu"
$vmName = "GuestVmWithGpu"
Remove-VMGpuPartitionAdapter -VMName $vmName
Set-VM -GuestControlledCacheTypes $sampleVM.GuestControlledCacheTypes -VMName $vmName
Set-VM -LowMemoryMappedIoSpace $sampleVM.LowMemoryMappedIoSpace -VMName $vmName
Set-VM -HighMemoryMappedIoSpace $sampleVM.HighMemoryMappedIoSpace -VMName $vmName
```

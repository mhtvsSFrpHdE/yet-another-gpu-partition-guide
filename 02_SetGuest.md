## Prerequisite
**DO NOT** use "Save" as "Automatic Stop Action" in Settings for virtual machine  
I will use shutdown as auto stop action, require manually set in Hyper-V manager because  
The following line set stop action doesn't work on LTSC 24H2 (it's not Windows Server edition)  
```
Get-ClusterResource -name vmname | Set-ClusterParameter -Name "OfflineAction" -Value 3
```
https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/partition-assign-vm-gpu?tabs=powershell

**DO NOT** use dynamic RAM, on LTSC 24H2 host, when set dynamic RAM for VM has GpuPartitionAdapeter  
It will show a hint says doesn't support dynamic RAM.  
However, I discover I can actually adjust fixed RAM value while virtual machine is running  
and value can apply immediately without need to shutdown VM

## Set guest
```
# VM name
$vmName = "GuestVmWithGpu"

$hostGpus = Get-VMHostPartitionableGpu
$targetGpuIndex = 0
$targetGpu = $hostGpus[$targetGpuIndex]

# From nvidia docs https://docs.nvidia.com/vgpu/latest/pdf/grid-vgpu-user-guide.pdf
Remove-VMGpuPartitionAdapter -VMName $vmName
Add-VMGpuPartitionAdapter -VMName $vmName `
-MinPartitionVRAM $targetGpu.MinPartitionVRAM `
-MaxPartitionVRAM $targetGpu.MaxPartitionVRAM `
-OptimalPartitionVRAM $targetGpu.OptimalPartitionVRAM `
-MinPartitionEncode $targetGpu.MinPartitionEncode `
-MaxPartitionEncode $targetGpu.MaxPartitionEncode `
-OptimalPartitionEncode $targetGpu.OptimalPartitionEncode `
-MinPartitionDecode $targetGpu.MinPartitionDecode `
-MaxPartitionDecode $targetGpu.MaxPartitionDecode `
-OptimalPartitionDecode $targetGpu.OptimalPartitionDecode `
-MinPartitionCompute $targetGpu.MinPartitionCompute `
-MaxPartitionCompute $targetGpu.MaxPartitionCompute `
-OptimalPartitionCompute $targetGpu.OptimalPartitionCompute

# Allow the VM to control cache types for MMIO access.
Set-VM -GuestControlledCacheTypes $true -VMName $vmName

# Set the lower MMIO space to 1 GB to allow sufficient MMIO space to be mapped.
# This amount is twice the amount that the device must allow for alignment. Lower
# MMIO space is the address space below 4 GB and is required for any device that has
# 32-bit BAR memory
Set-VM -LowMemoryMappedIoSpace 1Gb -VMName $vmName

# Set the upper MMIO space to 32 GB to allow sufficient MMIO space to be mapped.
# This amount is twice the amount that the device must allow for alignment. Upper
# MMIO space is the address space above approximately 64 GB
Set-VM -HighMemoryMappedIoSpace 32GB -VMName $vmName
```

## Driver
Now boot VM and copy driver folder exported from host OS  
Go to InstallGuestDriver

## Misc
Check added gpu, work only after VM boot  
Although in real world this command never be used once
```
Get-VMGpuPartitionAdapter -VMName $vmName
```

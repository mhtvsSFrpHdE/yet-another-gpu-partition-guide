## Prerequisite
I believe the only restriction is driver version should be same  
Guest OS and Host OS version is not necessary the same  
However, due to several bugs in mid 2025, GPU partition is heavily rely on known good combination to be stable

## Known good combination
Combination not listed here not means won't work just nobody test and report  
Here only list latest tested, check more combination at [wiki](https://github.com/mhtvsSFrpHdE/unofficial-gpu-partition-document/wiki/Known-good-combination)
- Host OS Windows 11 `25H2 26200.7840`
- Guest OS Windows 11 `25H2 26200.7840` / `24H2 26100.7840`
- Nvidia GeForce Security Update Driver `582.28` (1)

Other, for reference, usually not cause problems
- Sunshine `v2025.924.154138`
- Moonlight-qt `6.1.0`
- GPU EVGA GTX 1080 Ti SC Black Edition w/ iCX Cooler 11G-P4-6393-KR

### (1)
Nvidia add virtualization support to customer graphics card in driver version `465.89`  
Anything below that won't work  
It turns out Nvidia driver version doesn't cause problems, mainly Windows bug

Series 9/10 Geforce GPU owners: Use `582.28` if run latest Windows 11  
this version contains `581.94` hotfix

### Where to get certain version of Windows
https://github.com/mhtvsSFrpHdE/yet-another-gpu-partition-guide/wiki/Where-to-get-certain-version-of-Windows

## Get host gpu information
```
Get-VMHostPartitionableGpu | Select-Object -Property Name,ValidPartitionCounts
$hostGpus = Get-VMHostPartitionableGpu | Select-Object -Property Name,ValidPartitionCounts
```

## Set which host gpu to be use in VM
```
$targetGpuIndex = 0
$targetGpuPartitionCountIndex = 0
$targetGpu = $hostGpus[$targetGpuIndex]
$targetGpuName = ($targetGpu.Name.Split("\") | Select-Object -SkipLast 1) -join "\"
$targetValidPartitionCounts = $targetGpu.ValidPartitionCounts[$targetGpuPartitionCountIndex]
Set-VMHostPartitionableGpu -Name $targetGpuName -PartitionCount $targetValidPartitionCounts
```

## Collect files
Open dxdiag on host PC, Save All Information as `DxDiag.txt`, put together with `Tools\CollectFiles.ps1`  
Open `DxDiag.txt` and looking for your graphics card name, copy it and edit to first line of `Tools\CollectFiles.ps1`

Run `Tools\CollectFiles.ps1`, files will be saved to `C:\GpuDriver`  
This folder need copy to guest OS later

## What does collect files do
- Read `DxDiag.txt`, know what file belones driver
- Copy most driver files to `C:\GpuDriver`  
  and will copy back to original location on install to guest
- Copy files in `C:\Windows\System32\DriverStore` to `C:\GpuDriver`  
  but copy to `C:\Windows\System32\HostDriverStore` on install to guest
- Generate install and uninstall script

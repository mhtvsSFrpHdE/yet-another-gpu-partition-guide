## Prerequisite
I believe the only restriction is driver version should be same  
Guest OS and Host OS version is not necessary the same  
However, due to several bugs in mid 2025, GPU partition is heavily rely on known good combination

## Known good combination
- Host OS Windows 11 `25H2 26200.7462`
- Guest OS Windows 11 `25H2 26200.7462`
- Nvidia Game Ready/Studio driver `581.57` (1)

Other, for reference, usually not cause problems
- Sunshine `v2025.924.154138`
- Moonlight-qt `6.1.0`
- GPU EVGA GTX 1080 Ti SC Black Edition w/ iCX Cooler 11G-P4-6393-KR

### (1)
I recommend use Studio driver so you don't need to bother with Dynamic Range: Limited 16-235 vs Full 0-255  
Studio default is 0-255

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

## Prepare host driver export dir
```
$driverExportDir = "C:\GpuDriver"
Remove-Item -LiteralPath "$driverExportDir" -Force -Recurse
New-Item -ItemType Directory -Path "$driverExportDir"
```

## Preview which host gpu driver to export
```
$drivers = Get-WindowsDriver -Online -All
$targetDriver = $drivers | Where-Object { $_.ClassName -EQ "Display" -and $_.ProviderName -Like "NVIDIA" }
$targetDriver
```
If multiple version exist, choose the one currently active on your system  
Or you may want to uninstall unwanted driver by type (optional, carefully)
```
pnputil /delete-driver oemXX.inf
```
then redo preview step

## Confirm export which driver
```
$targetDriverIndex = 0
$targetDriverFileName = $targetDriver[$targetDriverIndex].Driver
pnputil /export-driver "$targetDriverFileName" "$driverExportDir"
```

Copy driver files from $driverExportDir to guest OS  
Go to SetGuest before boot into VM

## Collect extra files
Open dxdiag on host PC, Save All Information as `DxDiag.txt`, put together with `Tools\CollectFiles.ps1`  
Open `DxDiag.txt` and looking for your graphics card name, copy it and edit to first line of `Tools\CollectFiles.ps1`

Run `Tools\CollectFiles.ps1`, files will be saved to `C:\GpuDriverExtra`  
This folder also need copy to guest OS later, allow guest OS to access Nvidia Control Panel and driver settings  
Although Nvidia Control Panel can't be installed directly, but use Nvidia Profile Inspector will possible

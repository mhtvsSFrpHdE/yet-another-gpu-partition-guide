## Prerequisite
Guest OS and Host OS must run exact same version of Windows and driver  
For example
- Windows 11 OS Build 26100.2033
- Nvidia 572.16

## Prepare host driver export dir
```
$driverExportDir = "C:\GpuDriver"
Remove-Item -LiteralPath "$driverExportDir" -Force -Recurse
New-Item -ItemType Directory -Path "$driverExportDir"
```

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

## Preview which host gpu driver to export
```
$drivers = Get-WindowsDriver -Online -All
$targetDriver = $drivers | Where-Object { $_.ClassName -EQ "Display" -and $_.ProviderName -Like "NVIDIA" }
```

## Confirm export which driver
```
$targetDriver
```

## If multiple version exist, choose the one currently active on your system
```
$targetDriverIndex = 0
$targetDriverFileName = $targetDriver[$targetDriverIndex].Driver
pnputil /export-driver "$targetDriverFileName" "$driverExportDir"
```

Copy driver files from $driverExportDir to guest OS  
Go to SetGuest before boot into VM

## Collect extra files
Run `Tools\CollectFiles.ps1`, files will be saved to `C:\GpuDriverExtra`  
This folder will also copy to guest OS later, allow guest OS to access Nvidia Control Panel  
Although Nvidia Control Panel can't be installed directly, but use Nvidia Profile Inspector will possible

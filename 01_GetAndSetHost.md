## Prerequisite
Guest OS and Host OS should run exact same version of Windows and driver  
For example
- Windows 11 OS Build 26100.2033
- Nvidia 572.16

However, due to several bugs in mid 2025, GPU partition is heavily rely on known good combination

## Known good combination
- Host OS Windows 11 build `26100.4946` (1)
- Guest OS Windows 11 build `26100.2033` (2)
- Nvidia Game Ready driver `580.97`
- Sunshine `v2025.628.4510`
- Moonlight `6.1.0`
- GPU EVGA GTX 1080 Ti SC Black Edition w/ iCX Cooler 11G-P4-6393-KR

### (1), (2)
When use `26100.2033` as host OS, `vmmem` process has memory leak issue  
Microsoft support suggest upgrade to latest version, and indeed fixed

When use `26100.4946` (the latest suggest by Microsoft support at time)  
as guest OS, `Microsoft Hyper-V Video` / `Generic Monitor (HyperVMonitor)`  
can't be lit on in guest OS and has nvlddmkm 153 when connect with enhanced mode  
but it runs fine as host OS

The idea is run `26100.4946` as host so there is no memory leak  
and run `26100.2033` as guest so virtual monitor can be lit on to brings OpenGL and Vulkan support

### Where to get certain version of Windows
- Microsoft has a page that lists Windows build number [windows-11-version-24h2-update-history](https://support.microsoft.com/en-us/topic/windows-11-version-24h2-update-history-0929c747-1815-4543-8461-0160d16f15e5)
- On the page looking for `OS Build <version number>`, like 26100.2033
- Find build number in this website https://files.rg-adguard.net/version/f0bd8307-d897-ef77-dbd6-216fefbe94c5
- Follow instructions on page to download file
- Try mount the iso in system and run `setup.exe` directly to see if you can downgrade without reinstall
- If downgrade in-place upgrade failed, no choice but have to reinstall
- Next time remember to backup system partition before click on the cursed `Download & install all` button in Windows Update  
Use `Backup and Restore (Windows 7)`, `Create a system image`  
or `export virtual machine` to somewhere in case GPU Partition virtual machine doesn't support checkpoint

Reference  
[[Windows Server 2025 Host] KB5062553 (and June’s) Breaks GPU-P to Windows 11 VM – Anyone Else?](https://www.reddit.com/r/HyperV/comments/1lvduk4/windows_server_2025_host_kb5062553_and_junes)

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
Open dxdiag on host PC, Save All Information as `DxDiag.txt`, put together with `Tools\CollectFiles.ps1`  
Open `DxDiag.txt` and looking for your graphics card name, copy it and edit to first line of `Tools\CollectFiles.ps1`

Run `Tools\CollectFiles.ps1`, files will be saved to `C:\GpuDriverExtra`  
This folder also need copy to guest OS later, allow guest OS to access Nvidia Control Panel and driver settings  
Although Nvidia Control Panel can't be installed directly, but use Nvidia Profile Inspector will possible

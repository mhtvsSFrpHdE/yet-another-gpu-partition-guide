# Background
Although Hyper-V GPU Partition is known best virtual machine product with GPU support  
But Microsoft don't have decent solution to maximum its potential  
All Microsoft method to connect to VM bottlenecks the performance

1. Basic mode
- Run good within 1080P, but can't handle more like 4K
- Higher resolution command: `Set-VMVideo -VMName "vmName" -HorizontalResolution 3840 -VerticalResolution 2160 -ResolutionType Maximum`
- No sound, no clipboard sync, no file transfer
2. Enhanced session
- Adds sound, clipboard sync, file transfer compare to basic mode
- Break graphics compatibility with many applications
- API limitations, at least can't detect NVENC, DirectDraw and AGP Texture Acceleration not available in `dxdiag`
- Although use VMBus and doesn't limit by network bandwidth, but performance even worse than network based Remote Desktop RDP
3. Remote desktop
- Currently is just enhanced session use network and better performance
- Require some group policy edit otherwise don't have GPU
- Hardware accelerated H264/AVC encoding doesn't work when using GPU Partition

For short, when you have 4K desktop you don't even get smooth Start Menu animations with these  
Not to mention real heavy applications

# The gaming way
This method may requires 4th Gen NVENC cards for 4K 60 FPS desktop streaming,  
for example GeForce GTX 10 series, GP107 ~ GP102 chip, 1050 or above, not include 1030.

1st Gen NVENC GT 640 can't handle 1080P 60 FPS, only about 1080P 52 FPS.  
If FPS can't reach 60, Microsoft RDP still a good choice.  
Under 60 FPS, mouse cursor will lag while desktop streaming, Microsoft RDP won't.

If still prefer use desktop streaming, these Moonlight shortcuts might help
- Toggle client side cursor show / hide: "Ctrl+Alt+Shift+C"
- Toggle remote side cursor / hide: "Ctrl+Alt+Shift+N"

Sadly these options have no config and "Ctrl+Alt+Shift+C" need to press manually each time reconnect to guest OS  
"Ctrl+Alt+Shift+N" requires once after reboot and status remains until next guest OS reboot

## Before you start
Enable remote desktop and make sure you can connect to VM with RDP  
The basic mode may temporary not work during setup

## Install Sunshine on guest OS
https://app.lizardbyte.dev/Sunshine  
https://github.com/LizardByte/Sunshine

After install, go to WebGUI do these

Don't let Sunshine touch screen resolution and refresh rate settings  
to prevent after reboot virtual display driver resolution reset to 800x600
```
Configuration, Audio/Video, Advanced display device options, Device configuration, change to "Disabled"
```

If not using YUV444, higher quality screen text to reduce color blend on font to background
```
Configuration, Audio/Video, NVIDIA NVENC Encoder, Spatial AQ, change to `Enabled (slower)`
The other options do nothing, keep defaults
```

If you tired to waiting for Sunshine take too long to switch between regular desktop and UAC secure desktop  
You can disable UAC secure desktop from Local Security Policy (`secpol.msc`)  
```
Security Settings - Local Policies - Security Options
User Account Control: Switch to the secure desktop when prompting for elevation: Disabled
```

## Install virtual monitor on guest OS
https://github.com/VirtualDrivers/Virtual-Display-Driver  

Actually there is nothing to be configured in Virtual Driver Control app  
just the driver itself is suitable

Later if Microsoft basic mode shows nothing  
imagine you now have dual monitor setup on guest OS  
Go to display settings and play with settings  
"Show only on 2" of course cause Microsoft basic mode shows nothing
In this case, you can use enhanced session or remote desktop RDP to make bootstrap

After install, restart Sunshine, tell it to capture your virtual display instead of Hyper-V basic mode:  
Go to Troubleshooting tab and check Logs
```
  {
    "device_id": "{9acddf6d-43cc-576e-9aff-0c5fc80b4cc8}",    // <- Look at here, {9acddf6d-43cc-576e-9aff-0c5fc80b4cc8}
    "display_name": "\\\\.\\DISPLAY2",
    "friendly_name": "VDD by MTT",    // <- Looking for friendly_name called "VDD by MTT" instead of "HyperVMonitor"
    ...
```
Paste your device_id to Configuration, Audio/Video, Display Device Id, like this `{9acddf6d-43cc-576e-9aff-0c5fc80b4cc8}`  
Save and restart Sunshine

Microsoft Hyper-V basic mode is not support dual monitor natively  
you can't mouse click via basic mode after having dual monitor is a normal behavior

## Install virtual sound card on guest OS
Hyper-V doesn't have sound card, Sunshine/Moonlight require a sound card to capture sound  
before I use [VB-Audio Hi-Fi Cable](https://vb-audio.com/Cable/#DownloadASIOBridge)  
but now I find sunshine already provide "Steam Streaming Speakers" as a choice  
there is no sound quality difference in theory in my opinion

You may want to change it's playback and record sample rate to something like  
16 bit 48000 from 24 bit in sound settings to match physical sound card settings

## Install Moonlight to connect
On computer want to connect to guest OS, install Moonlight  
https://moonlight-stream.org  
https://github.com/moonlight-stream/moonlight-qt

Moonlight settings:
- Resolution and FPS: `4K (1080P if you), 60FPS (more if you)`
- Video bitrate: `Untouched or whatever you want`
- Display mode: `Fullscreen`
- V-Sync: `On`
- Optimize mouse for remote desktop: `On`, `Off` if you are actually gaming, this sets unlimit mouse moving, good for FPS game
- Capture system keyboard shortcuts: `in fullscreen`

For Video codec, it very depends on GPU

Give a shot on Most common [Moonlight shortcuts](https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide#keyboardmousegamepad-input-options) before connect to prevent you can't exit VIM:
- Quit: "Ctrl+Alt+Shift+Q"
- Minimize: "Ctrl+All+Shift+D"
- Paste text in clipboard: "Ctrl+Alt+Shift+V"
- Toggle fullscreen: "Ctrl+Alt+Shift+X"
- Performance static: "Ctrl+Alt+Shift+S

Click on plus symbol, type your guest OS IP address  
and go to guest OS Sunshine WebUI, the "PIN" page to enter pair information

Once connected, config dual monitor inside guest OS
- Drag Hyper-V monitor to right side of virtual display driver monitor
- Change Hyper-V monitor resolution to 800x600 or any minimal for reduce overhead
- Set virtual display driver monitor as main display (primary monitor) 
- Set multi display mode to "Extend these displays", allow OpenGL apps to run by not disabling Hyper-V monitor
- Change virtual display monitor refresh rate to 90 Hz, or anything greater than 64 Hz
- Optional: Disable "Enhance pointer precision" in guest OS to get better responsive mouse  
You can leave it on in host OS if you prefer

The 90 Hz hack fixed Sunshine capture performance drop when Hyper-V monitor is enabled  
Maybe because it removed vertical sync for Windows dwm on second monitor  
Reference: [VALORANT OPTIMIZATION - HOW TO DISABLE WINDOWS 10 VSYNC USING A SECOND MONITOR + REDUCE INPUT LAG](https://youtu.be/ij9nBgjESNQ?t=208)

## Fix "slow connection" lag on excellent network frequently
By disable memory compression  
Run `Disable-MMAgent -mc` on Hyper-V host PC, and reboot host PC
No need to run this in guest OS

It seems memory compression on host OS effect virtual machine realtime performance  
but memory compression inside guest VM doesn't

You may also interested in  
View advanced system settings - Advanced - Performance - Settings - Advanced - Processor scheduling  
Program vs Background service  
but I have no time to verify it is related to this issue or not

Related issue https://github.com/mhtvsSFrpHdE/yet-another-gpu-partition-guide/issues/4

## FAQ
<details>
    <summary><b>Clipboard sync</b></summary>

Use Syncthing file sync software and paste clipboard to file like
- `Clipboard.txt` constantly open with Microsoft Notepad `notepad.exe`
- `Clipboard.png` edit with Microsoft Paint `mspaint.exe`

https://syncthing.net

Or for paste simple quick text to guest, use Moonlight shortcut `Ctrl+Alt+Shift+V`

</details>

<details>
    <summary><b>Volume lower than expected or bad audio quality</b></summary>

Sunshine version: `v2025.628.4510`  
Moonlight version: `6.1.0`

<img width="380" height="173" alt="Image" src="https://github.com/user-attachments/assets/90b41c7f-3270-494a-aa3c-b2a82b26c613" />

On PC run moonlight, check control panel Sound, Speaker properties, at Levels tab  
right click on volume value, change it from percentage to decibels  
drag the volume bar all the way left, record value you see like `-65.2 dB`

If this value is not equal to `-96 dB`...  
**Unplug all real audio speakers, headphones from PC running sunshine if you have attached them directly to it!**  
**these preamp action and volume settings will damage physical audio device!**  
Only plug physical audio device to PC where moonlight running  
or use the mute while streaming feature to prevent modified audio singal send to these physical device
- Check sunshine settings, enable and use Steam Streaming Speakers to transfer audio, don't use your real sound card
- Install Equalzer APO inside guest OS where sunshine installed, choose Steam Streaming Speakers while install
- Greater than `-96`, for example `-65.2`: Add `96 - 65.2 - 0.1` = `30.7 dB` preamp gain to Steam Streaming Speakers
- Less than `-96`, for example `-128`: Add `-1 * (128 - 96)` = `-32 dB` preamp gain to Steam Streaming Speakers  
Note that this "less than" fix is only in threory, it may not needed  
I don't have sound card has -128 decibels range
- Add a device control filter to make sure these settings only apply to Steam Streaming Speakers

Equalizer APO config.txt example:
```
Device: Speakers Steam Streaming Speakers
# Gain (Moonlight)
Preamp: 30.7 dB
```

After you can verify these settings won't affect your if any physical sound card on PC running sunshine  
you may plug speakers or headphones back for handy reason, but this is still very risky, careful with that  
Make sure when you put audio singal to physical device, the peak gain value is below 0 dB like -0.1 dB  
Peak gain greater than 0 is only designed to fix volume issue during moonlight streaming

Related issue https://github.com/mhtvsSFrpHdE/yet-another-gpu-partition-guide/issues/7

</details>

<details>
    <summary><b>Nvidia Control Panel and driver settings</b></summary>

Nvidia driver can't be installed directly and Nvidia Control Pannel UWP apps don't recognize vGPU  
You can edit control panel in host PC and copy entire `C:\ProgramData\NVIDIA Corporation` to same location in guest OS  
then use Nvidia Profile Inspector in guest OS to adjust settings

Frame limiter in driver settings is known to not work, you can use RivaTuner come with MSI Afterburner which also works fine

</details>

<details>
    <summary><b>Vertical sync</b></summary>

Turn off vertical sync in guest OS as much as possible, this reduced the latency A LOT  
You'll need Nvidia driver settings to do this

Only turn on vertican sync in Moonlight client settings, not in guest OS

</details>

<details>
    <summary><b>OpenGL applications</b></summary>

If play Minecraft and you may notice any OpenGL game or applications can't be opened  
Hyper-V monitor must be enabled to support OpenGL, just virtual display driver is not enough

Also there is a config in Nvidia Profile Inspector to allow you turn on shader cache for OpenGL apps if you interested

</details>

<details>
    <summary><b>Vulkan applications</b></summary>

Vulkan doesn't play well with sunshine DXGI capture and dual monitor setup at same time  
You need to start Vulkan apps in dual monitor, after open Vulkan,  
turn off Hyper-V Video secondary monitor temporary to get best video capture performance  
After Vulkan apps exit, switch back to dual monitor to allow you open other non DirectX apps  
I have scripts do this quick in `Tools\Vulkan`

</details>

<details>
    <summary><b>YUV420 vs YUV444</b></summary>

Some Nvidia cards support H.264 YUV444 encoding  
but decoder doesn't support YUV 444, client side decode performance may poor and latency >= 16.6 ms (60 FPS)  
if software decode latency <= 16.6 ms then is fine

There is also a hack that is set Moonlight client resolution to 3840x2160 and downscale to 1920x1080  
this allows emulate YUV444 color while hardware only support decode YUV420  
however, it eats a lot encoding performance  
because now GPU need to upscale image and finally latency >= 16.6 ms (60 FPS)  
also it can't provide pixel perfect experience, color is good but image is blur

To get pixel perfect full color experience, Microsoft remote desktop is still a choice  
to transfer lossless video by use group policy, at cost of performance  
The drawbacks not at application performance but transfer performance  
Your app indeed running at 60 FPS in remote environment with [DWMFRAMEINTERVAL](https://learn.microsoft.com/en-us/troubleshoot/windows-server/remote/frame-rate-limited-to-30-fps)  
but video not make it tranfer at 60 FPS thus laggy

</details>

<details>
    <summary><b>Control virtual machine CPU affinity and priority</b></summary>

<img width="456" height="346" alt="Image" src="https://github.com/user-attachments/assets/dcf3b8ec-cacd-4591-9cba-59ed2c6f6508" />

On customer version Windows 11, Hyper-V use `0x4`, the "Root scheduler"  
If you want to carefully allocate CPU resource  
the result is these settings won't work and you may trapped into certain problems

Before start, if your virtual machine is imported from other computer  
Go to virtual machine settings, Processor, expand it and select NUMA  
click on `Use Hardware Topology` to update Hyperthread/SMT settings

I have a script under `Tools\SetVmPriority.ps1`  
you can run it after boot all your VM, to set each VM CPU affinity and priority  
After download, use notepad open it and scroll to bottom  
you can see function call to adjust affinity and priority  
and code to adjust moonlight client too

Modify argument as you like, then run the script with admin permission  
Script file argument `-IgnoreNotRunning`: script will skip not running VM instead of wait it to boot

Code is one time, only apply to running process, not persistent  
need to re-run after VM shutdown/boot again

Hyper-V doesn't allow you to really bind a certain process running in guest OS to a certain physical CPU core  
If you set affinity inside guest OS, although guest OS think it's bind to one core  
but on physical PC, you will still notice that CPU usage divide evenly between multiple cores  
With this tool, at least you can specify guest OS as a whole to running on certain cores

Related issue https://github.com/mhtvsSFrpHdE/yet-another-gpu-partition-guide/issues/4

</details>

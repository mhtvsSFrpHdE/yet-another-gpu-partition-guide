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

Higher quality screen text to reduce color blend on font to background
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

## Install virtual sound card on guest OS
https://vb-audio.com/Cable/#DownloadASIOBridge

Hyper-V doesn't have sound card, Sunshine/Moonlight require a sound card to capture sound  
thus VB-Audio Hi-Fi Cable is recommended

You may want to change it's playback and record sample rate to 16 bit 48000 from default 24 bit in sound settings

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

The 90 Hz hack fixed Sunshine capture performance drop when Hyper-V monitor is enabled  
Maybe because it removed vertical sync for Windows dwm on second monitor  
Reference: [VALORANT OPTIMIZATION - HOW TO DISABLE WINDOWS 10 VSYNC USING A SECOND MONITOR + REDUCE INPUT LAG](https://youtu.be/ij9nBgjESNQ?t=208)

## FAQ
### Clipboard sync
Use Syncthing file sync software and paste clipboard to file like
- `Clipboard.txt` constantly open with Microsoft Notepad `notepad.exe`
- `Clipboard.png` edit with Microsoft Paint `mspaint.exe`

https://syncthing.net

Or for paste simple quick text to guest, use Moonlight shortcut `Ctrl+Alt+Shift+V`

### Nvidia Control Panel and driver settings
Nvidia driver can't be installed directly and Nvidia Control Pannel UWP apps don't recognize vGPU  
You can edit control panel in host PC and copy entire `C:\ProgramData\NVIDIA Corporation` to same location in guest OS  
then use Nvidia Profile Inspector in guest OS to adjust settings

### Vertical sync
Turn off vertical sync in guest OS as much as possible, this reduced the latency A LOT  
You'll need Nvidia driver settings to do this

Only turn on vertican sync in Moonlight client settings, not in guest OS

### OpenGL applications
If play Minecraft and you may notice any OpenGL game or applications can't be opened  
Hyper-V monitor must be enabled to support OpenGL, just virtual display driver is not enough

Also there is a config in Nvidia Profile Inspector to allow you turn on shader cache for OpenGL apps if you interested

### Vulkan applications
Vulkan doesn't play well with sunshine DXGI capture and dual monitor setup at same time  
You need to start Vulkan apps in dual monitor, after open Vulkan,  
turn off Hyper-V Video secondary monitor temporary to get best video capture performance  
After Vulkan apps exit, switch back to dual monitor to allow you open other non DirectX apps  
I have scripts do this quick in `Tools\Vulkan`

### YUV420 vs YUV444
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

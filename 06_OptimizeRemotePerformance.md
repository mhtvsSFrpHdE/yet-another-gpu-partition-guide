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
- Although use VMBus and doesn't limit by network bandwidth, bug performance even worse than network based Remote Desktop RDP
3. Remote desktop
- Currently is just enhanced session use network and better performance
- Require some group policy edit otherwise don't have GPU
- Hardware accelerated H264/AVC encoding doesn't work when using GPU Partition

For short, when you have 4K desktop you don't even get smooth Start Menu animations with these  
Not to mention real heavy applications

# The gaming way

## Install Sunshine on guest OS
https://app.lizardbyte.dev/Sunshine  
https://github.com/LizardByte/Sunshine

After install, go to WebGUI do these

Don't let Sunshine touch screen resolution and refresh rate settings  
to prevent after reboot virtual display driver resolution reset to 800x600
```
Configuration, Audio/Video, Advanced display device options, Device configuration, change to "Disabled"
```

Higher quality screen text to reduce color blend to background  
By my testing, YUV420 doesn't cause bad text, color blend did
```
Configuration, Audio/Video, NVIDIA NVENC Encoder, Spatial AQ, change to `Enabled (slower)`
The other options do nothing, keep defaults
```

## Install virtual monitor on guest OS
https://github.com/VirtualDrivers/Virtual-Display-Driver  

Actually there is nothing to be configured in Virtual Driver Control app  
just the driver itself is suitable

Later if Microsoft basic mode shows nothing  
imagine you now have dual monitor setup on guest OS  
Go to display settings and play with settings  
"Show only on 2" of course cause Microsoft basic mode shows nothing  
but may improve performance for not waste on something not being used  
In this case you can use enhanced session or remote desktop RDP

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
- Resolution and FPS: `4K, 60FPS`
- Video bitrate: `Untouched or whatever you want`
- Display mode: `Fullscreen`
- V-Sync: `On`
- Optimize mouse for remote desktop: `On`, `Off` if you are actually gaming, this sets unlimit mouse moving
- Capture system keyboard shortcuts: `in fullscreen`For Video codec, it very depends on GPU.

Give a shot on Most common [Moonlight shortcuts](https://github.com/moonlight-stream/moonlight-docs/wiki/Setup-Guide#keyboardmousegamepad-input-options) before connect to prevent you can't exit VIM:
- Quit: "Ctrl+Alt+Shift+Q"
- Minimize: "Ctrl+All+Shift+D"
- Paste text in clipboard: "Ctrl+Alt+Shift+V"
- Toggle fullscreen: "Ctrl+Alt+Shift+X"
- Performance static: "Ctrl+Alt+Shift+S

Type your guest OS IP address, and go to guest OS Sunshine WebUI, the "PIN" page to enter pair information  
After pair, you may need to close Moonlight, open "Moonlight.ini" and check if IP is right  
My guest OS have multiple IP so it saved wrong information
```
[hosts]
1\hostname=<guest OS device name>
1\localaddress=<guest OS LAN IP>
1\remoteaddress=<Moonlight client computer IP>
```

## YUV420 vs YUV444
Seems H.264 have lower lantency by opinion from internet  
YUV 444 only available on H.264 on myside, and decoder doesn't support YUV 444, client side decode performance is poor  
Nvenc HEVC also use 444 only until 50 series to support 422  
All of these video encoded protocol have sight color blend which may not important if gaming  
Turn on "Spatial AQ" in Sunshine NVENC encoder settings, reduced color blend to barely noticeable  
To get perfect full color experience, Microsoft remote desktop still a choice, at cost of performance

## Clipboard sync
Not yet confirm how to do that  
Use Syncthing file sync software and paste clipboard to file as a temp solution
